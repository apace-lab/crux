use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    io::{BufRead, BufReader},
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Debug, Clone)]
pub struct ObservationConfig {
    pub project_dir: PathBuf,
    pub seed: u64,
    pub trace_path: PathBuf,
    pub schedule_path: Option<PathBuf>,
    pub cargo_args: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccessObservation {
    pub seed: Option<u64>,
    pub seq: Option<u64>,
    pub principal: String,
    pub panode: u64,
    pub access: String,
    pub function_id: Option<u64>,
    pub site: Option<u64>,
    // Resource INSTANCE the access touched (e.g. "conversation:1"), and the rows it
    // yielded. Present when the site is instrumented with the resource-linked form.
    pub resource: Option<String>,
    pub count: Option<u64>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PrincipalScope {
    pub functions: BTreeSet<u64>,
    pub read_nodes: BTreeSet<u64>,
    pub write_nodes: BTreeSet<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScopeOverlap {
    pub left: String,
    pub right: String,
    pub shared_nodes: BTreeSet<u64>,
}

/// A confirmed cross-user leak on a single resource INSTANCE: `reader` (who does
/// not own it) read `resource` and was served `rows` rows that belong to `owner`.
/// This refines the coarse PANode overlap: an overlap on a node is only a real
/// leak when some principal actually read another principal's instance data. A
/// read that returns zero rows was dominated by an ownership check and produces
/// no ResourceLeak (the positive-control case).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResourceLeak {
    pub resource: String,
    pub panode: u64,
    pub owner: String,
    pub reader: String,
    pub rows: u64,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ObservationResult {
    pub accesses: Vec<AccessObservation>,
    pub principals: BTreeMap<String, PrincipalScope>,
    pub overlaps: Vec<ScopeOverlap>,
    pub resource_leaks: Vec<ResourceLeak>,
}

pub fn run_observation(cfg: &ObservationConfig) -> Result<()> {
    if let Some(parent) = cfg.trace_path.parent() { fs::create_dir_all(parent)?; }
    if cfg.trace_path.exists() { fs::remove_file(&cfg.trace_path)?; }

    let mut cmd = Command::new("cargo");
    cmd.args(&cfg.cargo_args)
        .current_dir(&cfg.project_dir)
        .env("MADSIM_TEST_SEED", cfg.seed.to_string())
        .env("AFG_TRACE_PATH", &cfg.trace_path);

    let old = std::env::var("RUSTFLAGS").unwrap_or_default();
    let flags = if old.trim().is_empty() {
        "--cfg madsim".to_string()
    } else {
        format!("{old} --cfg madsim")
    };
    cmd.env("RUSTFLAGS", flags);

    if let Some(schedule) = &cfg.schedule_path {
        cmd.env("AFG_SCHEDULE_PATH", schedule);
    }

    let status = cmd.status().context("failed to launch target application")?;
    if !status.success() { bail!("target application exited with {status}"); }
    Ok(())
}

pub fn analyze_traces(paths: &[PathBuf]) -> Result<ObservationResult> {
    let mut out = ObservationResult::default();
    for path in paths {
        if path.exists() { parse_jsonl_trace(path, &mut out)?; }
    }
    compute_overlaps(&mut out);
    compute_resource_leaks(&mut out);
    Ok(out)
}

fn parse_jsonl_trace(path: &Path, out: &mut ObservationResult) -> Result<()> {
    let reader = BufReader::new(fs::File::open(path)?);
    for line in reader.lines() {
        let line = line?;
        if line.trim().is_empty() { continue; }
        let v: Value = serde_json::from_str(&line)
            .with_context(|| format!("invalid JSONL in {}", path.display()))?;

        let event = v.get("event").and_then(Value::as_str).unwrap_or("");
        let principal = v.get("principal").and_then(Value::as_str).unwrap_or("unknown").to_string();
        let function_id = v.get("function_id").and_then(Value::as_u64);

        if event == "monitor" {
            if let Some(fid) = function_id {
                out.principals.entry(principal).or_default().functions.insert(fid);
            }
            continue;
        }

        if event != "access" { continue; }

        let Some(panode) = v.get("node").or_else(|| v.get("panode")).and_then(Value::as_u64) else { continue; };
        let access = v.get("kind").or_else(|| v.get("access")).and_then(Value::as_str).unwrap_or("Unknown").to_string();

        let obs = AccessObservation {
            seed: v.get("seed").and_then(|x| x.as_u64().or_else(|| x.as_str()?.parse().ok())),
            seq: v.get("seq").and_then(Value::as_u64),
            principal: principal.clone(),
            panode,
            access: access.clone(),
            function_id,
            site: v.get("site").and_then(Value::as_u64),
            resource: v.get("resource").and_then(Value::as_str).map(str::to_string),
            count: v.get("count").and_then(Value::as_u64),
        };

        let scope = out.principals.entry(principal).or_default();
        if let Some(fid) = function_id { scope.functions.insert(fid); }
        match access.to_ascii_lowercase().as_str() {
            "read" => { scope.read_nodes.insert(panode); }
            "write" => { scope.write_nodes.insert(panode); }
            _ => {}
        }

        out.accesses.push(obs);
    }
    Ok(())
}

fn compute_overlaps(out: &mut ObservationResult) {
    let names: Vec<_> = out.principals.keys().cloned().collect();
    for i in 0..names.len() {
        for j in (i + 1)..names.len() {
            let a = &out.principals[&names[i]];
            let b = &out.principals[&names[j]];
            let mut aa = a.read_nodes.clone(); aa.extend(a.write_nodes.iter().copied());
            let mut bb = b.read_nodes.clone(); bb.extend(b.write_nodes.iter().copied());
            let shared_nodes = aa.intersection(&bb).copied().collect::<BTreeSet<_>>();
            if !shared_nodes.is_empty() {
                out.overlaps.push(ScopeOverlap {
                    left: names[i].clone(),
                    right: names[j].clone(),
                    shared_nodes,
                });
            }
        }
    }
}

/// Resource-linked verdict: for each resource INSTANCE, the owner is the principal
/// of the first observed write (or, absent a write, the first accessor). A read of
/// that instance by any other principal that returns rows is a confirmed leak. A
/// read that returns no rows was dominated by an ownership check and is not a leak,
/// even though both principals reach the same PANode (the positive-control case).
fn compute_resource_leaks(out: &mut ObservationResult) {
    let mut by_resource: BTreeMap<String, Vec<AccessObservation>> = BTreeMap::new();
    for a in &out.accesses {
        if let Some(res) = &a.resource {
            by_resource.entry(res.clone()).or_default().push(a.clone());
        }
    }

    for (resource, mut accesses) in by_resource {
        accesses.sort_by_key(|a| a.seq.unwrap_or(u64::MAX));
        let owner = accesses
            .iter()
            .find(|a| a.access.eq_ignore_ascii_case("write"))
            .or_else(|| accesses.first())
            .map(|a| a.principal.clone());
        let Some(owner) = owner else { continue };

        for a in &accesses {
            if a.access.eq_ignore_ascii_case("read")
                && a.principal != owner
                && a.count.unwrap_or(0) > 0
            {
                out.resource_leaks.push(ResourceLeak {
                    resource: resource.clone(),
                    panode: a.panode,
                    owner: owner.clone(),
                    reader: a.principal.clone(),
                    rows: a.count.unwrap_or(0),
                });
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn acc(seq: u64, principal: &str, access: &str, resource: &str, count: u64) -> AccessObservation {
        AccessObservation {
            seed: None,
            seq: Some(seq),
            principal: principal.to_string(),
            panode: 7000,
            access: access.to_string(),
            function_id: None,
            site: None,
            resource: Some(resource.to_string()),
            count: Some(count),
        }
    }

    // Positive control (bionic-gpt shape): alice owns conversation:1, bob's read of
    // it returns 0 rows (dominated by the ownership check). No leak, even though both
    // reach node 7000.
    #[test]
    fn dominated_read_is_not_a_leak() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "conversation:1", 1),
            acc(2, "alice", "read", "conversation:1", 1),
            acc(3, "bob", "read", "conversation:1", 0),
        ];
        compute_resource_leaks(&mut out);
        assert!(out.resource_leaks.is_empty(), "positive control must have no leak");
    }

    // Negative control (tabby shape): alice owns thread:9, bob reads it and is served
    // rows. Confirmed cross-user leak.
    #[test]
    fn cross_user_read_with_rows_is_a_leak() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "thread:9", 1),
            acc(2, "bob", "read", "thread:9", 3),
        ];
        compute_resource_leaks(&mut out);
        assert_eq!(out.resource_leaks.len(), 1);
        let leak = &out.resource_leaks[0];
        assert_eq!(leak.owner, "alice");
        assert_eq!(leak.reader, "bob");
        assert_eq!(leak.rows, 3);
    }

    // The owner reading their own instance is never a leak.
    #[test]
    fn owner_read_is_not_a_leak() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "conversation:1", 1),
            acc(2, "alice", "read", "conversation:1", 5),
        ];
        compute_resource_leaks(&mut out);
        assert!(out.resource_leaks.is_empty());
    }
}
