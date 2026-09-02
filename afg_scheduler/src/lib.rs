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

    let mut out = Vec::new();

    // One schedule per detected cross-user overlap: order the two principals'
    // accesses to the shared node so a replay can exercise the leak.
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
                out.push(SchedulePlan {
                    reason: format!("cross-user overlap on PANode {node} ({left} vs {right})"),
                    panode: node,
                    steps: vec![
                        ScheduleStep {
                            principal: left.to_string(),
                            site: site_for(left, node),
                        },
                        ScheduleStep {
                            principal: right.to_string(),
                            site: site_for(right, node),
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
}
