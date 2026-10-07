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
    // yielded. Present when the site is instrumented with the resource-linked form;
    // absent (default) for older traces and apps that do not emit a resource.
    #[serde(default)]
    pub resource: Option<String>,
    #[serde(default)]
    pub count: Option<u64>,
    // Principals that this access authorizes for the resource, beyond the writer
    // itself. A resource with more than one legitimate party (a private message has
    // a sender AND a recipient; a shared document has an owner AND its collaborators)
    // declares the extra parties here at write/create time, from the resource's own
    // data model (who the message is addressed to), NOT from the app's access-control
    // decision at read time. This keeps the read-site probe dumb (it just emits the
    // read) and the leak verdict independent of the app's own check. Absent for
    // single-owner resources and older traces.
    #[serde(default)]
    pub authorized: Option<Vec<String>>,
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
    // Empty for apps/traces that emit no resource; also defaults to empty when an
    // older scopes.json without this field is read back.
    #[serde(default)]
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
            authorized: v.get("authorized").and_then(Value::as_array).map(|arr| {
                arr.iter().filter_map(|x| x.as_str().map(str::to_string)).collect()
            }),
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

/// Resource-linked verdict: for each resource INSTANCE, a set of AUTHORIZED
/// principals is established from the observed writes: every principal that writes
/// the instance is authorized, plus any extra parties a write declares in its
/// `authorized` list (a private message's recipient, a document's collaborators),
/// which come from the resource's own data model, not the app's access check. The
/// owner reported for a leak is the first writer. A read of the instance by a
/// principal NOT in the authorized set that returns rows is a confirmed leak. A read
/// that returns no rows was dominated by an ownership check and is not a leak, even
/// though both principals reach the same PANode (the positive-control case).
///
/// The authorized-set model generalizes the earlier single-owner rule (which could
/// only express one legitimate party, forcing a two-party resource's probe to fake
/// the second party as a writer): with no `authorized` list present it reduces
/// exactly to "owner = first writer, every other reader-with-rows leaks".
fn compute_resource_leaks(out: &mut ObservationResult) {
    let mut by_resource: BTreeMap<String, Vec<AccessObservation>> = BTreeMap::new();
    for a in &out.accesses {
        if let Some(res) = &a.resource {
            by_resource.entry(res.clone()).or_default().push(a.clone());
        }
    }

    for (resource, mut accesses) in by_resource {
        accesses.sort_by_key(|a| a.seq.unwrap_or(u64::MAX));

        // The owner (for reporting) is the first writer, or the first accessor if the
        // instance is only ever read.
        let owner = accesses
            .iter()
            .find(|a| a.access.eq_ignore_ascii_case("write"))
            .or_else(|| accesses.first())
            .map(|a| a.principal.clone());
        let Some(owner) = owner else { continue };

        // The authorized set: every principal that writes the instance, plus every
        // extra party any access declares. If nothing is ever written (read-only
        // instance), the first accessor (the owner above) is the sole authorized one.
        let mut authorized: BTreeSet<String> = BTreeSet::new();
        for a in &accesses {
            if a.access.eq_ignore_ascii_case("write") {
                authorized.insert(a.principal.clone());
            }
            if let Some(extra) = &a.authorized {
                authorized.extend(extra.iter().cloned());
            }
        }
        if authorized.is_empty() {
            authorized.insert(owner.clone());
        }

        for a in &accesses {
            if a.access.eq_ignore_ascii_case("read")
                && !authorized.contains(&a.principal)
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
            authorized: None,
        }
    }

    // A write/create that also authorizes extra parties (a PM's recipient).
    fn acc_grant(seq: u64, principal: &str, access: &str, resource: &str, count: u64, grant: &[&str]) -> AccessObservation {
        let mut a = acc(seq, principal, access, resource, count);
        a.authorized = Some(grant.iter().map(|s| s.to_string()).collect());
        a
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

    // Two-party resource (lemmy private-message shape): alice creates pm:1 addressed
    // to bob, so the create declares bob as an authorized party. carol (a
    // non-participant) reading it with rows is a leak; bob (the recipient) reading it
    // is NOT a leak, with NO app-specific participant logic in the read-site probe
    // (both carol and bob emit a plain Read). This is the GHSA-r64r scenario expressed
    // in the authorized-set model.
    #[test]
    fn recipient_read_is_authorized_non_participant_read_leaks() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc_grant(1, "alice", "write", "pm:1", 1, &["bob"]), // alice -> bob
            acc(2, "carol", "read", "pm:1", 1),                  // non-participant: LEAK
            acc(3, "bob", "read", "pm:1", 1),                    // recipient: authorized
        ];
        compute_resource_leaks(&mut out);
        assert_eq!(out.resource_leaks.len(), 1, "only carol's read should leak");
        let leak = &out.resource_leaks[0];
        assert_eq!(leak.resource, "pm:1");
        assert_eq!(leak.owner, "alice");
        assert_eq!(leak.reader, "carol");
    }

    // Without the authorized grant, the old single-owner behaviour is preserved: the
    // recipient's read would (wrongly, for a PM) look like a leak too. This documents
    // why the grant is what distinguishes a legitimate second party.
    #[test]
    fn without_grant_second_party_read_is_flagged() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "pm:1", 1),
            acc(2, "bob", "read", "pm:1", 1),
        ];
        compute_resource_leaks(&mut out);
        assert_eq!(out.resource_leaks.len(), 1);
        assert_eq!(out.resource_leaks[0].reader, "bob");
    }
}
