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

/// The ordered access-then-access pattern a schedule forces between its two steps.
/// Only the three orderings that involve a WRITE are hazards (a read-then-read
/// discloses nothing and mutates nothing). step 0 is the first (victim) access, step 1
/// is the second (actor) access:
/// - `WriteThenRead`: step 0 writes, step 1 reads -> CONFIDENTIALITY (actor is served
///   another principal's data). This was historically the only pattern.
/// - `WriteThenWrite`: step 0 writes, step 1 writes -> INTEGRITY (actor overwrites a
///   resource another principal wrote).
/// - `ReadThenWrite`: step 0 reads, step 1 writes -> INTEGRITY / TOCTOU (actor mutates
///   a resource another principal had just read).
/// The authoritative classification of a replay is `crux_observe`'s access-then-access
/// verdict; this enum records which ordering the schedule was generated to force.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum SchedulePattern {
    #[default]
    WriteThenRead,
    WriteThenWrite,
    ReadThenWrite,
}

impl SchedulePattern {
    /// (kind of step 0, kind of step 1) that a replay must exhibit, in order.
    fn kinds(&self) -> (&'static str, &'static str) {
        match self {
            SchedulePattern::WriteThenRead => ("write", "read"),
            SchedulePattern::WriteThenWrite => ("write", "write"),
            SchedulePattern::ReadThenWrite => ("read", "write"),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchedulePlan {
    pub reason: String,
    pub panode: u64,
    /// Shared-store resource this schedule targets (e.g. "res:123"). When set, the
    /// hazard spans the two accesses on the SAME store through possibly different
    /// PANodes (a real store's write and read are different methods), so the
    /// verdict is checked per resource rather than per PANode. None keeps the
    /// single-PANode behaviour (e.g. a hand-marked cache node).
    #[serde(default)]
    pub resource: Option<String>,
    /// Which access-then-access ordering this schedule forces. Defaults to
    /// write-then-read for older schedules read back without the field.
    #[serde(default)]
    pub pattern: SchedulePattern,
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

    // Resource-linked pass. A real store's accesses are DIFFERENT methods (e.g.
    // `execute` vs `fetch_one`), so a cross-user access-then-access hazard spans two
    // PANodes joined only by the shared store. The single-PANode overlap pass below
    // cannot see that. Here we group accesses by their resource id and generate a
    // schedule for each of the three write-involving orderings between two DIFFERENT
    // principals (see `SchedulePattern`): write-then-read (an unauthorized reader is
    // served another's data), write-then-write (an unauthorized writer overwrites it),
    // and read-then-write (an unauthorized writer mutates what another had read). The
    // replay is then classified per resource by `crux_observe`.
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

        // (writers, readers) per resource, plus the owner (first writer seen) and the
        // authorized sets. read_authz = writers + grants (an authorized reader is a
        // legitimate second party, so no W->R schedule explores it). write_authz =
        // owner + grants ONLY (a later non-owner writer is an unauthorized mutation,
        // which is exactly what the two integrity orderings explore; mirrors crux_observe).
        let mut by_resource: BTreeMap<String, (BTreeSet<String>, BTreeSet<String>)> = BTreeMap::new();
        let mut owner_by_resource: BTreeMap<String, String> = BTreeMap::new();
        let mut read_authz: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
        let mut grants_by_resource: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
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
                owner_by_resource.entry(res.to_string()).or_insert_with(|| p.to_string());
                read_authz.entry(res.to_string()).or_default().insert(p.to_string());
            } else {
                entry.1.insert(p.to_string());
            }
            if let Some(list) = a.get("authorized").and_then(|x| x.as_array()) {
                for n in list {
                    if let Some(s) = n.as_str() {
                        read_authz.entry(res.to_string()).or_default().insert(s.to_string());
                        grants_by_resource.entry(res.to_string()).or_default().insert(s.to_string());
                    }
                }
            }
        }

        for (resource, (writers, readers)) in &by_resource {
            let r_authz = read_authz.get(resource);
            let owner = owner_by_resource.get(resource);
            let grants = grants_by_resource.get(resource);
            // write_authz = owner + grants.
            let write_authorized = |p: &str| -> bool {
                owner.map_or(false, |o| o == p) || grants.map_or(false, |g| g.contains(p))
            };

            let push = |pattern: SchedulePattern,
                            reason: String,
                            first: &str,
                            first_kind: &str,
                            second: &str,
                            second_kind: &str,
                            out: &mut Vec<SchedulePlan>|
             -> bool {
                let (Some((fs_, fnode)), Some((ss, _))) = (
                    site_and_node(first, resource, first_kind),
                    site_and_node(second, resource, second_kind),
                ) else {
                    return false;
                };
                out.push(SchedulePlan {
                    reason,
                    panode: fnode,
                    resource: Some(resource.clone()),
                    pattern,
                    steps: vec![
                        ScheduleStep { principal: first.to_string(), site: fs_ },
                        ScheduleStep { principal: second.to_string(), site: ss },
                    ],
                });
                true
            };

            // write-then-read: owner (or any writer) writes, an unauthorized reader reads.
            'wtr: for w in writers {
                for r in readers {
                    if w == r || r_authz.map_or(false, |s| s.contains(r)) {
                        continue;
                    }
                    if push(
                        SchedulePattern::WriteThenRead,
                        format!("cross-user disclosure on resource {resource} ({w} writes before {r} reads, linked across PANodes)"),
                        w, "write", r, "read", &mut out,
                    ) {
                        if out.len() >= max_schedules { return out; }
                        break 'wtr;
                    }
                }
            }

            // write-then-write: owner wrote, an unauthorized writer overwrites it.
            if let Some(o) = owner {
                'wtw: for w2 in writers {
                    if w2 == o || write_authorized(w2) {
                        continue;
                    }
                    if push(
                        SchedulePattern::WriteThenWrite,
                        format!("cross-user integrity (overwrite) on resource {resource} ({o} wrote, {w2} overwrites)"),
                        o, "write", w2, "write", &mut out,
                    ) {
                        if out.len() >= max_schedules { return out; }
                        break 'wtw;
                    }
                }
            }

            // read-then-write: a principal read, an unauthorized writer then mutates it.
            'rtw: for r in readers {
                for w2 in writers {
                    if w2 == r || write_authorized(w2) {
                        continue;
                    }
                    if push(
                        SchedulePattern::ReadThenWrite,
                        format!("cross-user integrity (TOCTOU) on resource {resource} ({r} read, {w2} mutates)"),
                        r, "read", w2, "write", &mut out,
                    ) {
                        if out.len() >= max_schedules { return out; }
                        break 'rtw;
                    }
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
                    // The single-PANode pass is the coarse legacy signal; it confirms a
                    // write-then-read on the node (the reader after the writer).
                    pattern: SchedulePattern::WriteThenRead,
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
                    pattern: SchedulePattern::WriteThenRead,
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
    // step 0 is the first (victim) access, step 1 the second (actor) access; the plan's
    // pattern says which access KIND each must be. For write-then-read this is the
    // historical "writer wrote, reader then read"; for the two integrity orderings it
    // is "writer wrote / reader read, then the actor wrote after".
    let first = plan.steps[0].principal.clone();
    let second = plan.steps[1].principal.clone();
    let (first_kind, second_kind) = plan.pattern.kinds();
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

    // Target match: on a resource (the two accesses may be on different PANodes) if
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

    let first_at = ordered
        .iter()
        .filter(|(_, p, n, k, res)| {
            *p == first && on_target(*n, *res) && k.eq_ignore_ascii_case(first_kind)
        })
        .map(|(o, ..)| *o)
        .min();
    let Some(w) = first_at else {
        return LeakVerdict::NotReproduced {
            reason: format!("{first} did not {first_kind} {target}"),
        };
    };

    let second_after = ordered
        .iter()
        .filter(|(o, p, n, k, res)| {
            *p == second && on_target(*n, *res) && k.eq_ignore_ascii_case(second_kind) && *o > w
        })
        .map(|(o, ..)| *o)
        .min();

    if second_after.is_some() {
        LeakVerdict::Reproduced { writer: first, reader: second, panode: node, resource }
    } else {
        LeakVerdict::NotReproduced {
            reason: format!("{second} did not {second_kind} {target} after {first}'s {first_kind}"),
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
            pattern: SchedulePattern::WriteThenRead,
            steps: vec![step(writer, node), step(reader, node)],
        }
    }

    fn plan_pat(first: &str, second: &str, node: u64, pattern: SchedulePattern) -> SchedulePlan {
        SchedulePlan {
            reason: "test".into(),
            panode: node,
            resource: None,
            pattern,
            steps: vec![step(first, node), step(second, node)],
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
            pattern: SchedulePattern::WriteThenRead,
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
            pattern: SchedulePattern::WriteThenRead,
            steps: vec![step("alice", 10), step("bob", 20)],
        };
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice", "panode": 10, "access": "Write", "resource": "res:900" },
            { "seq": 2, "principal": "bob",   "panode": 20, "access": "Read",  "resource": "res:901" }
        ]});
        assert!(!verify_replay(&plan, &replay).reproduced());
    }

    // write-then-write: alice wrote res:5, mallory (not owner, not granted) overwrites
    // it. A schedule is generated for the integrity ordering, and the replay reproduces
    // it only when mallory's write follows alice's.
    #[test]
    fn generate_and_verify_write_then_write() {
        let obs = json!({
            "accesses": [
                { "seq": 1, "principal": "alice",   "panode": 10, "access": "Write", "resource": "res:5", "site": 10 },
                { "seq": 2, "principal": "mallory", "panode": 10, "access": "Write", "resource": "res:5", "site": 10 }
            ],
            "overlaps": []
        });
        let plans = generate_schedules(&obs, 20);
        let wtw = plans
            .iter()
            .find(|p| p.pattern == SchedulePattern::WriteThenWrite)
            .expect("expected a write-then-write schedule");
        assert_eq!(wtw.steps[0].principal, "alice");
        assert_eq!(wtw.steps[1].principal, "mallory");

        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice",   "panode": 10, "access": "Write", "resource": "res:5" },
            { "seq": 2, "principal": "mallory", "panode": 10, "access": "Write", "resource": "res:5" }
        ]});
        assert!(verify_replay(wtw, &replay).reproduced());
        // reverse order does not reproduce the ordering
        let rev = json!({ "accesses": [
            { "seq": 1, "principal": "mallory", "panode": 10, "access": "Write", "resource": "res:5" }
        ]});
        assert!(!verify_replay(wtw, &rev).reproduced());
    }

    // read-then-write: alice read res:7, mallory (not owner, not granted) then writes.
    #[test]
    fn verify_read_then_write() {
        let plan = plan_pat("alice", "mallory", 30, SchedulePattern::ReadThenWrite);
        let replay = json!({ "accesses": [
            { "seq": 1, "principal": "alice",   "panode": 30, "access": "Read"  },
            { "seq": 2, "principal": "mallory", "panode": 30, "access": "Write" }
        ]});
        assert!(verify_replay(&plan, &replay).reproduced());
        // a read-then-read must NOT reproduce a read-then-write schedule
        let rr = json!({ "accesses": [
            { "seq": 1, "principal": "alice",   "panode": 30, "access": "Read" },
            { "seq": 2, "principal": "mallory", "panode": 30, "access": "Read" }
        ]});
        assert!(!verify_replay(&plan, &rr).reproduced());
    }

    // A granted collaborator's overwrite generates NO integrity schedule.
    #[test]
    fn granted_co_writer_no_integrity_schedule() {
        let obs = json!({
            "accesses": [
                { "seq": 1, "principal": "alice", "panode": 10, "access": "Write", "resource": "res:5", "site": 10, "authorized": ["bob"] },
                { "seq": 2, "principal": "bob",   "panode": 10, "access": "Write", "resource": "res:5", "site": 10 }
            ],
            "overlaps": []
        });
        let plans = generate_schedules(&obs, 20);
        assert!(
            !plans.iter().any(|p| p.pattern == SchedulePattern::WriteThenWrite
                || p.pattern == SchedulePattern::ReadThenWrite),
            "granted co-writer must not produce an integrity schedule"
        );
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
