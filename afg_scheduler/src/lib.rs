use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::{fs, path::Path};

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

    out
}

pub fn write_schedule(plan: &SchedulePlan, path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() { fs::create_dir_all(parent)?; }
    fs::write(path, serde_json::to_string_pretty(&plan.steps)?)?;
    Ok(())
}
