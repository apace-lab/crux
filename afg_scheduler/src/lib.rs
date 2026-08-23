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
    let Ok(v) = serde_json::to_value(observation) else { return Vec::new(); };
    let Some(accesses) = v.get("accesses").and_then(|x| x.as_array()) else { return Vec::new(); };

    let mut out = Vec::new();

    for a in accesses {
        let Some(ap) = a.get("principal").and_then(|x| x.as_str()) else { continue; };
        let Some(node) = a.get("panode").and_then(|x| x.as_u64()) else { continue; };
        let Some(ak) = a.get("access").and_then(|x| x.as_str()) else { continue; };
        let Some(asite) = a.get("site").and_then(|x| x.as_u64()) else { continue; };
        if !ak.eq_ignore_ascii_case("write") { continue; }

        for b in accesses {
            let Some(bp) = b.get("principal").and_then(|x| x.as_str()) else { continue; };
            let Some(bnode) = b.get("panode").and_then(|x| x.as_u64()) else { continue; };
            let Some(bk) = b.get("access").and_then(|x| x.as_str()) else { continue; };
            let Some(bsite) = b.get("site").and_then(|x| x.as_u64()) else { continue; };

            if ap == bp || node != bnode || !bk.eq_ignore_ascii_case("read") { continue; }

            out.push(SchedulePlan {
                reason: format!("cross-principal write/read overlap on PANode {node}"),
                panode: node,
                steps: vec![
                    ScheduleStep { principal: ap.to_string(), site: asite },
                    ScheduleStep { principal: bp.to_string(), site: bsite },
                ],
            });

            if out.len() >= max_schedules { return out; }
        }
    }

    out
}

pub fn write_schedule(plan: &SchedulePlan, path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() { fs::create_dir_all(parent)?; }
    fs::write(path, serde_json::to_string_pretty(&plan.steps)?)?;
    Ok(())
}
