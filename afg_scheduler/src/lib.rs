use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::{collections::BTreeSet, fs, path::Path};

/// Name given to the artificial second user synthesized when only one real user
/// is observed (see `generate_schedules`).
pub const SYNTHETIC_PRINCIPAL: &str = "afg-synthetic";

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ScheduleStep {
    pub principal: String,
    pub site: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchedulePlan {
    pub reason: String,
    pub panode: u64,
    /// Shared-store resource this schedule targets (e.g. "res:123"). When set, the
    /// leak spans a write and a read on the SAME store through possibly different
    /// PANodes (a real store's write and read are different methods), so the
    /// verdict is checked per resource rather than per PANode. None keeps the
    /// single-PANode behaviour (e.g. a hand-marked cache node).
    #[serde(default)]
    pub resource: Option<String>,
    pub steps: Vec<ScheduleStep>,
}

pub fn generate_schedules<T: Serialize>(observation: &T, max_schedules: usize) -> Vec<SchedulePlan> {
    let Ok(v) = serde_json::to_value(observation) else {
        return Vec::new();
    };
    let accesses = v
        .get("accesses")
        .and_then(|x| x.as_array())
        .cloned()
        .unwrap_or_default();

    // Gate id for (principal, node): the access's `site` if the trace recorded
    // one (from a schedule_point), else the PANode itself.
    let site_for = |principal: &str, node: u64| -> u64 {
        for a in &accesses {
            if a.get("principal").and_then(|x| x.as_str()) == Some(principal)
                && a.get("panode").and_then(|x| x.as_u64()) == Some(node)
            {
                return a
                    .get("site")
                    .and_then(|x| x.as_u64())
                    .unwrap_or(node);
            }
        }
        node
    };

    // Whether `principal` performed a Write access to `node` (used to order the
    // schedule writer-before-reader).
    let writes = |principal: &str, node: u64| -> bool {
        accesses.iter().any(|a| {
            a.get("principal").and_then(|x| x.as_str()) == Some(principal)
                && a.get("panode").and_then(|x| x.as_u64()) == Some(node)
                && a.get("access")
                    .and_then(|x| x.as_str())
                    .map(|s| s.eq_ignore_ascii_case("write"))
                    .unwrap_or(false)
        })
    };

    let mut out = Vec::new();

    // Resource-linked pass. A real store's write and read are DIFFERENT methods
    // (e.g. `execute` vs `fetch_one`), so a write-then-read leak spans two PANodes
    // joined only by the shared store. The single-PANode overlap pass below cannot
    // see that. Here we group data-access accesses by their resource id and, when
    // one principal writes a resource and a DIFFERENT principal reads it, schedule
    // the writer before the reader. The verdict is then checked per resource.
    {
        use std::collections::BTreeMap;
        // site (gate) and node of a principal's access of `kind` on `resource`.
        let site_and_node = |principal: &str, resource: &str, kind: &str| -> Option<(u64, u64)> {
            for a in &accesses {
                if a.get("principal").and_then(|x| x.as_str()) == Some(principal)
                    && a.get("resource").and_then(|x| x.as_str()) == Some(resource)
                    && a.get("access")
                        .and_then(|x| x.as_str())
                        .map(|s| s.eq_ignore_ascii_case(kind))
                        .unwrap_or(false)
                {
                    let node = a.get("panode").and_then(|x| x.as_u64()).unwrap_or(0);
                    let site = a.get("site").and_then(|x| x.as_u64()).unwrap_or(node);
                    return Some((site, node));
                }
            }
            None
        };

        let mut by_resource: BTreeMap<String, (BTreeSet<String>, BTreeSet<String>)> = BTreeMap::new();
        for a in &accesses {
            let Some(res) = a.get("resource").and_then(|x| x.as_str()) else { continue };
            let Some(p) = a.get("principal").and_then(|x| x.as_str()) else { continue };
            let is_write = a
                .get("access")
                .and_then(|x| x.as_str())
                .map(|s| s.eq_ignore_ascii_case("write"))
                .unwrap_or(false);
            let entry = by_resource.entry(res.to_string()).or_default();
            if is_write {
                entry.0.insert(p.to_string());
            } else {
                entry.1.insert(p.to_string());
            }
        }

        for (resource, (writers, readers)) in &by_resource {
            let mut made = false;
            for w in writers {
                for r in readers {
                    if w == r {
                        continue;
                    }
                    let (Some((ws, wnode)), Some((rs, _))) = (
                        site_and_node(w, resource, "write"),
                        site_and_node(r, resource, "read"),
                    ) else {
                        continue;
                    };
                    out.push(SchedulePlan {
                        reason: format!(
                            "cross-user leak on resource {resource} ({w} writes before {r} reads, linked across PANodes)"
                        ),
                        panode: wnode,
                        resource: Some(resource.clone()),
                        steps: vec![
                            ScheduleStep { principal: w.clone(), site: ws },
                            ScheduleStep { principal: r.clone(), site: rs },
                        ],
                    });
                    if out.len() >= max_schedules {
                        return out;
                    }
                    made = true;
                    break;
                }
                if made {
                    break;
                }
            }
        }
    }

    // One schedule per detected cross-user overlap. A cross-user leak is a
    // write-then-read on the shared node, so order the WRITER before the READER
    // (the reader must run after the writer has populated the node) to reproduce
    // it on replay. When the writer isn't uniquely determined (both or neither
    // write), keep the overlap's own order.
    if let Some(overlaps) = v.get("overlaps").and_then(|x| x.as_array()) {
        for ov in overlaps {
            let (Some(left), Some(right)) = (
                ov.get("left").and_then(|x| x.as_str()),
                ov.get("right").and_then(|x| x.as_str()),
            ) else {
                continue;
            };
            let Some(nodes) = ov.get("shared_nodes").and_then(|x| x.as_array()) else {
                continue;
            };
            for n in nodes {
                let Some(node) = n.as_u64() else { continue };
                let (first, second, by_write) = if writes(left, node) && !writes(right, node) {
                    (left, right, true)
                } else if writes(right, node) && !writes(left, node) {
                    (right, left, true)
                } else {
                    (left, right, false)
                };
                let reason = if by_write {
                    format!("cross-user overlap on PANode {node} ({first} writes before {second} reads)")
                } else {
                    format!("cross-user overlap on PANode {node} ({first} vs {second})")
                };
                out.push(SchedulePlan {
                    reason,
                    panode: node,
                    resource: None,
                    steps: vec![
                        ScheduleStep {
                            principal: first.to_string(),
                            site: site_for(first, node),
                        },
                        ScheduleStep {
                            principal: second.to_string(),
                            site: site_for(second, node),
                        },
                    ],
                });
                if out.len() >= max_schedules {
                    return out;
                }
            }
        }
    }

    // Fallback (single-user apps): if no real cross-user overlap was found but
    // exactly one user was observed, synthesize a second user that clones the
    // observed user's accesses, so we can still schedule a two-user run to probe
    // for a cross-user leak. (Only kicks in for a single principal; 2+ real users
    // keep the real-overlap behavior above.)
    if out.is_empty() {
        let principals: BTreeSet<String> = accesses
            .iter()
            .filter_map(|a| a.get("principal").and_then(|x| x.as_str()).map(str::to_string))
            .collect();
        if principals.len() == 1 {
            let real = principals.into_iter().next().unwrap();
            let nodes: BTreeSet<u64> = accesses
                .iter()
                .filter(|a| a.get("principal").and_then(|x| x.as_str()) == Some(real.as_str()))
                .filter_map(|a| a.get("panode").and_then(|x| x.as_u64()))
                .collect();
            for node in nodes {
                let site = site_for(&real, node);
                out.push(SchedulePlan {
                    reason: format!(
                        "synthesized cross-user overlap on PANode {node} ({real} vs {SYNTHETIC_PRINCIPAL}); second user clones the single observed user"
                    ),
                    panode: node,
                    resource: None,
                    steps: vec![
                        ScheduleStep {
                            principal: real.clone(),
                            site,
                        },
                        ScheduleStep {
                            principal: SYNTHETIC_PRINCIPAL.to_string(),
                            site,
                        },
                    ],
                });
                if out.len() >= max_schedules {
                    return out;
                }
            }
        }
    }

    out
}

pub fn write_schedule(plan: &SchedulePlan, path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() { fs::create_dir_all(parent)?; }
    fs::write(path, serde_json::to_string_pretty(&plan.steps)?)?;
    Ok(())
}

/// Outcome of replaying a schedule: did the cross-user write-then-read on the
/// shared node actually occur under the forced ordering?
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(tag = "verdict", rename_all = "snake_case")]
pub enum LeakVerdict {
    /// The writer wrote the shared node and the reader then read it (the
    /// scheduled dangerous interleaving was realized at runtime).
    Reproduced {
        writer: String,
        reader: String,
        panode: u64,
        /// Set when the leak was linked across the store (write and read on the
        /// same resource via different PANodes); None for a single-PANode leak.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        resource: Option<String>,
    },
    /// The interleaving did not occur; `reason` says why.
    NotReproduced { reason: String },
}

impl LeakVerdict {
    pub fn reproduced(&self) -> bool {
        matches!(self, LeakVerdict::Reproduced { .. })
    }
}

/// Verify a replayed run against the schedule it was given: confirm the writer
/// (step 0) wrote the shared PANode and the reader (step 1) read it afterwards.
/// `replay` is the analyzed replay trace (anything serializing to
/// `{ accesses: [{ seq?, principal, panode, access }] }`, e.g. an ObservationResult).
pub fn verify_replay<T: Serialize>(plan: &SchedulePlan, replay: &T) -> LeakVerdict {
    let Ok(v) = serde_json::to_value(replay) else {
        return LeakVerdict::NotReproduced {
            reason: "replay trace could not be read".into(),
        };
    };
    if plan.steps.len() < 2 {
        return LeakVerdict::NotReproduced {
            reason: "schedule has fewer than two steps".into(),
        };
    }
    let writer = plan.steps[0].principal.clone();
    let reader = plan.steps[1].principal.clone();
    let node = plan.panode;
    let resource = plan.resource.clone();

    let accesses = v
        .get("accesses")
        .and_then(|x| x.as_array())
        .cloned()
        .unwrap_or_default();

    // (order, principal, node, kind, resource) in trace order; `seq` if present.
    let ordered: Vec<(u64, &str, u64, &str, Option<&str>)> = accesses
        .iter()
        .enumerate()
        .filter_map(|(i, a)| {
            let p = a.get("principal").and_then(|x| x.as_str())?;
            let n = a.get("panode").and_then(|x| x.as_u64())?;
            let k = a.get("access").and_then(|x| x.as_str())?;
            let res = a.get("resource").and_then(|x| x.as_str());
            let ord = a.get("seq").and_then(|x| x.as_u64()).unwrap_or(i as u64);
            Some((ord, p, n, k, res))
        })
        .collect();

    // Target match: on a resource (write and read may be on different PANodes) if
    // the plan names one, else on the single PANode.
    let on_target = |n: u64, res: Option<&str>| -> bool {
        match &resource {
            Some(r) => res == Some(r.as_str()),
            None => n == node,
        }
    };
    let target = match &resource {
        Some(r) => format!("resource {r}"),
        None => format!("PANode {node}"),
    };

    let write_at = ordered
        .iter()
        .filter(|(_, p, n, k, res)| {
            *p == writer && on_target(*n, *res) && k.eq_ignore_ascii_case("write")
        })
        .map(|(o, ..)| *o)
        .min();
    let Some(w) = write_at else {
        return LeakVerdict::NotReproduced {
            reason: format!("writer {writer} did not write {target}"),
        };
    };

    let read_after = ordered
        .iter()
        .filter(|(o, p, n, k, res)| {
            *p == reader && on_target(*n, *res) && k.eq_ignore_ascii_case("read") && *o > w
        })
        .map(|(o, ..)| *o)
        .min();

    if read_after.is_some() {
        LeakVerdict::Reproduced { writer, reader, panode: node, resource }
    } else {
        LeakVerdict::NotReproduced {
            reason: format!("reader {reader} did not read {target} after {writer}'s write"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn step(p: &str, site: u64) -> ScheduleStep {
        ScheduleStep { principal: p.to_string(), site }
    }

    #[test]
    fn single_user_synthesizes_second() {
        let obs = json!({
            "accesses": [{ "principal": "alice", "panode": 81, "access": "Read", "site": null }],
            "principals": { "alice": { "functions": [], "read_nodes": [81], "write_nodes": [] } },
            "overlaps": []
        });
        let plans = generate_schedules(&obs, 20);
        assert_eq!(plans.len(), 1, "one accessed node -> one synthesized schedule");
        assert_eq!(plans[0].panode, 81);
        assert_eq!(plans[0].steps, vec![step("alice", 81), step(SYNTHETIC_PRINCIPAL, 81)]);
    }

    #[test]
    fn single_user_uses_recorded_site() {
        let obs = json!({
            "accesses": [{ "principal": "alice", "panode": 81, "access": "Read", "site": 401 }],
            "overlaps": []
        });
        let plans = generate_schedules(&obs, 20);
        assert_eq!(plans[0].steps, vec![step("alice", 401), step(SYNTHETIC_PRINCIPAL, 401)]);
    }

    #[test]
    fn two_real_users_keep_real_overlap() {
        let obs = json!({
            "accesses": [
                { "principal": "alice", "panode": 81, "access": "Write", "site": null },
                { "principal": "bob",   "panode": 81, "access": "Read",  "site": null }
            ],
            "overlaps": [{ "left": "alice", "right": "bob", "shared_nodes": [81] }]
        });
        let plans = generate_schedules(&obs, 20);
        assert_eq!(plans.len(), 1);
        assert_eq!(plans[0].steps, vec![step("alice", 81), step("bob", 81)]);
        // no synthetic user is introduced when two real users are present
        assert!(!plans
            .iter()
            .flat_map(|p| &p.steps)
            .any(|s| s.principal == SYNTHETIC_PRINCIPAL));
    }

    #[test]
    fn writer_scheduled_before_reader_even_if_overlap_lists_reader_first() {
        // overlap lists bob (reader) as left, alice (writer) as right; the schedule
        // must still put the writer (alice) first so a replay reproduces the leak.
        let obs = json!({
            "accesses": [
                { "principal": "alice", "panode": 81, "access": "Write", "site": null },
                { "principal": "bob",   "panode": 81, "access": "Read",  "site": null }
            ],
            "overlaps": [{ "left": "bob", "right": "alice", "shared_nodes": [81] }]
        });
        let plans = generate_schedules(&obs, 20);
        assert_eq!(plans.len(), 1);
        assert_eq!(
            plans[0].steps,
            vec![step("alice", 81), step("bob", 81)],
            "writer (alice) must come before reader (bob)"
        );
        assert!(plans[0].reason.contains("writes before"));
    }

    #[test]
    fn ambiguous_both_write_keeps_overlap_order() {
        // both principals write the node: writer isn't unique, keep overlap order.
        let obs = json!({
            "accesses": [
                { "principal": "alice", "panode": 81, "access": "Write", "site": null },
                { "principal": "bob",   "panode": 81, "access": "Write", "site": null }
            ],
            "overlaps": [{ "left": "alice", "right": "bob", "shared_nodes": [81] }]
        });
        let plans = generate_schedules(&obs, 20);
        assert_eq!(plans[0].steps, vec![step("alice", 81), step("bob", 81)]);
    }

    #[test]
    fn two_users_without_shared_node_do_not_synthesize() {
        // 2 principals but no overlap, so we must NOT synthesize (only the 1-principal case does)
        let obs = json!({
            "accesses": [
                { "principal": "alice", "panode": 81, "access": "Read", "site": null },
                { "principal": "bob",   "panode": 90, "access": "Read", "site": null }
            ],
            "overlaps": []
        });
        assert!(generate_schedules(&obs, 20).is_empty());
    }

    fn plan(writer: &str, reader: &str, node: u64) -> SchedulePlan {
        SchedulePlan {
            reason: "test".into(),
            panode: node,
            resource: None,
            steps: vec![step(writer, node), step(reader, node)],
        }
    }

    #[test]
    fn verdict_reproduced_on_write_then_read() {
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice", "panode": 50, "access": "Write" },
            { "seq": 2, "principal": "bob",   "panode": 50, "access": "Read"  }
        ]});
        assert_eq!(
            verify_replay(&plan("alice", "bob", 50), &replay),
            LeakVerdict::Reproduced { writer: "alice".into(), reader: "bob".into(), panode: 50, resource: None }
        );
    }

    #[test]
    fn verdict_not_reproduced_without_a_write() {
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice", "panode": 50, "access": "Read" },
            { "seq": 2, "principal": "bob",   "panode": 50, "access": "Read" }
        ]});
        assert!(!verify_replay(&plan("alice", "bob", 50), &replay).reproduced());
    }

    #[test]
    fn verdict_not_reproduced_when_read_precedes_write() {
        // reader reads BEFORE the writer writes, so it is not the leak interleaving
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "bob",   "panode": 50, "access": "Read"  },
            { "seq": 2, "principal": "alice", "panode": 50, "access": "Write" }
        ]});
        assert!(!verify_replay(&plan("alice", "bob", 50), &replay).reproduced());
    }

    #[test]
    fn verdict_not_reproduced_when_reader_absent() {
        // synthetic (or otherwise absent) reader never ran
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice", "panode": 50, "access": "Write" }
        ]});
        assert!(!verify_replay(&plan("alice", SYNTHETIC_PRINCIPAL, 50), &replay).reproduced());
    }

    #[test]
    fn no_users_no_schedules() {
        let obs = json!({ "accesses": [], "overlaps": [] });
        assert!(generate_schedules(&obs, 20).is_empty());
    }

    #[test]
    fn single_user_multiple_nodes_and_cap() {
        let obs = json!({
            "accesses": [
                { "principal": "alice", "panode": 81, "access": "Read", "site": null },
                { "principal": "alice", "panode": 82, "access": "Read", "site": null }
            ],
            "overlaps": []
        });
        // one schedule per distinct accessed node
        assert_eq!(generate_schedules(&obs, 20).len(), 2);
        // max_schedules is respected
        assert_eq!(generate_schedules(&obs, 1).len(), 1);
    }

    // Resource-linked leak: a real store's write and read are on DIFFERENT PANodes
    // (execute vs fetch_one) but the SAME resource. The single-PANode verdict would
    // miss it; the resource-linked verdict reproduces it.
    #[test]
    fn verdict_reproduced_across_panodes_on_same_resource() {
        let plan = SchedulePlan {
            reason: "test".into(),
            panode: 10, // the write node; read is on a different node
            resource: Some("res:900".into()),
            steps: vec![step("alice", 10), step("bob", 20)],
        };
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice", "panode": 10, "access": "Write", "resource": "res:900" },
            { "seq": 2, "principal": "bob",   "panode": 20, "access": "Read",  "resource": "res:900" }
        ]});
        assert_eq!(
            verify_replay(&plan, &replay),
            LeakVerdict::Reproduced {
                writer: "alice".into(),
                reader: "bob".into(),
                panode: 10,
                resource: Some("res:900".into()),
            }
        );
    }

    // Same two PANodes but DIFFERENT resources must NOT link into a leak.
    #[test]
    fn verdict_not_reproduced_across_different_resources() {
        let plan = SchedulePlan {
            reason: "test".into(),
            panode: 10,
            resource: Some("res:900".into()),
            steps: vec![step("alice", 10), step("bob", 20)],
        };
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice", "panode": 10, "access": "Write", "resource": "res:900" },
            { "seq": 2, "principal": "bob",   "panode": 20, "access": "Read",  "resource": "res:901" }
        ]});
        assert!(!verify_replay(&plan, &replay).reproduced());
    }

    // generate_schedules builds a resource-linked schedule when a write and a read
    // by different principals land on the same resource across different PANodes.
    #[test]
    fn generate_resource_linked_schedule() {
        let obs = json!({
            "accesses": [
                { "seq": 1, "principal": "alice", "panode": 10, "access": "Write", "resource": "res:900", "site": 10 },
                { "seq": 2, "principal": "bob",   "panode": 20, "access": "Read",  "resource": "res:900", "site": 20 }
            ],
            "overlaps": []
        });
        let plans = generate_schedules(&obs, 20);
        let linked = plans.iter().find(|p| p.resource.as_deref() == Some("res:900"));
        let linked = linked.expect("expected a resource-linked schedule");
        assert_eq!(linked.steps[0].principal, "alice");
        assert_eq!(linked.steps[1].principal, "bob");
    }
}
