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

/// The ordered access-then-access pattern between two different principals on one
/// shared resource instance. Only the three orderings that INVOLVE A WRITE are
/// hazards: a read-then-read discloses nothing new and mutates nothing, so it is
/// not modeled.
///
/// - `WriteThenRead`: a principal reads data a DIFFERENT principal wrote. The only
///   operation that moves data out of the resource to a principal is a read, so this
///   is the CONFIDENTIALITY disclosure (the original, and only, leak the oracle used
///   to detect). The actor is the reader.
/// - `WriteThenWrite`: a principal overwrites/mutates a resource a DIFFERENT principal
///   wrote. No data flows to the actor, so this is not a disclosure; it is an
///   INTEGRITY violation (an unauthorized mutation / clobber). The actor is the second
///   writer.
/// - `ReadThenWrite`: a principal writes a resource a DIFFERENT principal had just
///   read. The reader now holds data that was mutated under it (a stale-read / TOCTOU
///   ordering), and the write itself is by a non-authorized principal, so this is also
///   an INTEGRITY violation. The actor is the writer.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AccessPattern {
    WriteThenRead,
    WriteThenWrite,
    ReadThenWrite,
}

impl AccessPattern {
    pub fn label(&self) -> &'static str {
        match self {
            AccessPattern::WriteThenRead => "write-then-read",
            AccessPattern::WriteThenWrite => "write-then-write",
            AccessPattern::ReadThenWrite => "read-then-write",
        }
    }
}

/// What kind of violation a finding is. A disclosure (confidentiality) is a read that
/// returns another principal's data; an integrity violation is an unauthorized write
/// on another principal's resource.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum FindingClass {
    Confidentiality,
    Integrity,
}

/// A confirmed cross-user access-then-access hazard on one resource INSTANCE. This
/// generalizes `ResourceLeak` (which was write-then-read only) to all three
/// write-involving orderings. `actor` is the NON-AUTHORIZED principal performing the
/// second access; `victim` is the principal whose prior access the actor violates
/// (the owner for a write-then-*, the prior reader for read-then-write). `rows` is the
/// rows served when the actor's access is a read, else 0.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccessFinding {
    pub resource: String,
    pub panode: u64,
    pub pattern: AccessPattern,
    pub class: FindingClass,
    pub victim: String,
    pub actor: String,
    pub actor_access: String,
    pub rows: u64,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ObservationResult {
    pub accesses: Vec<AccessObservation>,
    pub principals: BTreeMap<String, PrincipalScope>,
    pub overlaps: Vec<ScopeOverlap>,
    // Empty for apps/traces that emit no resource; also defaults to empty when an
    // older scopes.json without this field is read back. This is the write-then-read
    // CONFIDENTIALITY subset of `access_findings`, kept as its own field for the
    // consumers (dashboard, drivers, examples) that predate the generalization.
    #[serde(default)]
    pub resource_leaks: Vec<ResourceLeak>,
    // All three write-involving access-then-access hazards (write-then-read =
    // confidentiality, write-then-write and read-then-write = integrity). Superset of
    // `resource_leaks`. Defaults to empty for older results read back.
    #[serde(default)]
    pub access_findings: Vec<AccessFinding>,
}

pub fn run_observation(cfg: &ObservationConfig) -> Result<()> {
    if let Some(parent) = cfg.trace_path.parent() { fs::create_dir_all(parent)?; }
    if cfg.trace_path.exists() { fs::remove_file(&cfg.trace_path)?; }

    let mut cmd = Command::new("cargo");
    cmd.args(&cfg.cargo_args)
        .current_dir(&cfg.project_dir)
        .env("MADSIM_TEST_SEED", cfg.seed.to_string())
        .env("CRUX_TRACE_PATH", &cfg.trace_path);

    let old = std::env::var("RUSTFLAGS").unwrap_or_default();
    let flags = if old.trim().is_empty() {
        "--cfg madsim".to_string()
    } else {
        format!("{old} --cfg madsim")
    };
    cmd.env("RUSTFLAGS", flags);

    if let Some(schedule) = &cfg.schedule_path {
        cmd.env("CRUX_SCHEDULE_PATH", schedule);
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
    compute_access_findings(&mut out);
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

/// Access-then-access verdict over resource instances. This generalizes the original
/// write-then-read confidentiality check to the THREE orderings that involve a write
/// (see `AccessPattern`): a read of another principal's data (disclosure), and a write
/// over a resource another principal wrote or read (integrity).
///
/// Per resource instance, two authorization sets are derived from the observed
/// accesses, using the resource's own data model (the `authorized` grants a write
/// declares) rather than the app's access-control decision:
///   - owner      = the first writer (or the first accessor if the instance is only
///                  ever read). Reported as the victim for write-then-* patterns.
///   - grantees   = union of every access's `authorized` list (a PM's recipient, a
///                  document's collaborators).
///   - read_authz  = every writer + grantees. A reader not in this set that is served
///                   rows disclosed another principal's data. (Including every writer
///                   preserves the earlier behaviour exactly.)
///   - write_authz = owner + grantees. A writer not in this set mutated a resource it
///                   does not own and was not granted: an unauthorized write. (Note
///                   this does NOT include later writers, which is the whole point:
///                   under the old "every writer is authorized" rule an unauthorized
///                   overwrite could never be caught, because writing made you
///                   authorized.)
///
/// A read that returns no rows was dominated by an ownership check and is never a
/// finding (the positive-control case). The write-then-read findings are mirrored into
/// `out.resource_leaks` byte-for-byte compatibly with the previous verdict, so
/// existing consumers are unchanged; the full set (including the two integrity
/// orderings) is in `out.access_findings`.
fn compute_access_findings(out: &mut ObservationResult) {
    let mut by_resource: BTreeMap<String, Vec<AccessObservation>> = BTreeMap::new();
    for a in &out.accesses {
        if let Some(res) = &a.resource {
            by_resource.entry(res.clone()).or_default().push(a.clone());
        }
    }

    for (resource, mut accesses) in by_resource {
        accesses.sort_by_key(|a| a.seq.unwrap_or(u64::MAX));

        let is_write = |a: &AccessObservation| a.access.eq_ignore_ascii_case("write");
        let is_read = |a: &AccessObservation| a.access.eq_ignore_ascii_case("read");

        // The owner (for reporting) is the first writer, or the first accessor if the
        // instance is only ever read.
        let owner = accesses
            .iter()
            .find(|a| is_write(a))
            .or_else(|| accesses.first())
            .map(|a| a.principal.clone());
        let Some(owner) = owner else { continue };

        let mut grantees: BTreeSet<String> = BTreeSet::new();
        let mut writers: BTreeSet<String> = BTreeSet::new();
        for a in &accesses {
            if is_write(a) {
                writers.insert(a.principal.clone());
            }
            if let Some(extra) = &a.authorized {
                grantees.extend(extra.iter().cloned());
            }
        }

        // read_authz = every writer + grantees (preserves the original verdict). For a
        // read-only instance, the sole accessor (the owner) is the only authorized one.
        let mut read_authz: BTreeSet<String> = writers.clone();
        read_authz.extend(grantees.iter().cloned());
        if read_authz.is_empty() {
            read_authz.insert(owner.clone());
        }
        // write_authz = owner + grantees ONLY (a later non-owner writer is unauthorized).
        let mut write_authz: BTreeSet<String> = grantees.clone();
        write_authz.insert(owner.clone());

        for (i, a) in accesses.iter().enumerate() {
            if is_read(a) {
                // write-then-read: an unauthorized reader served another's rows.
                if !read_authz.contains(&a.principal) && a.count.unwrap_or(0) > 0 {
                    out.access_findings.push(AccessFinding {
                        resource: resource.clone(),
                        panode: a.panode,
                        pattern: AccessPattern::WriteThenRead,
                        class: FindingClass::Confidentiality,
                        victim: owner.clone(),
                        actor: a.principal.clone(),
                        actor_access: "read".to_string(),
                        rows: a.count.unwrap_or(0),
                    });
                }
            } else if is_write(a) {
                // write-then-write / read-then-write: an unauthorized writer mutated a
                // resource owned by another. Classify by the nearest PRIOR access by a
                // DIFFERENT principal on this instance.
                if write_authz.contains(&a.principal) {
                    continue;
                }
                let prior = accesses[..i]
                    .iter()
                    .rev()
                    .find(|p| p.principal != a.principal);
                let Some(prior) = prior else { continue };
                let pattern = if is_write(prior) {
                    AccessPattern::WriteThenWrite
                } else if is_read(prior) {
                    AccessPattern::ReadThenWrite
                } else {
                    continue;
                };
                out.access_findings.push(AccessFinding {
                    resource: resource.clone(),
                    panode: a.panode,
                    pattern,
                    class: FindingClass::Integrity,
                    victim: prior.principal.clone(),
                    actor: a.principal.clone(),
                    actor_access: "write".to_string(),
                    rows: 0,
                });
            }
        }
    }

    // Mirror the write-then-read findings into resource_leaks for existing consumers.
    out.resource_leaks = out
        .access_findings
        .iter()
        .filter(|f| f.pattern == AccessPattern::WriteThenRead)
        .map(|f| ResourceLeak {
            resource: f.resource.clone(),
            panode: f.panode,
            owner: f.victim.clone(),
            reader: f.actor.clone(),
            rows: f.rows,
        })
        .collect();
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
        compute_access_findings(&mut out);
        assert!(out.resource_leaks.is_empty(), "positive control must have no leak");
        assert!(out.access_findings.is_empty(), "positive control must have no finding");
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
        compute_access_findings(&mut out);
        assert_eq!(out.resource_leaks.len(), 1);
        let leak = &out.resource_leaks[0];
        assert_eq!(leak.owner, "alice");
        assert_eq!(leak.reader, "bob");
        assert_eq!(leak.rows, 3);
        assert_eq!(out.access_findings.len(), 1);
        assert_eq!(out.access_findings[0].pattern, AccessPattern::WriteThenRead);
        assert_eq!(out.access_findings[0].class, FindingClass::Confidentiality);
    }

    // The owner reading their own instance is never a leak.
    #[test]
    fn owner_read_is_not_a_leak() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "conversation:1", 1),
            acc(2, "alice", "read", "conversation:1", 5),
        ];
        compute_access_findings(&mut out);
        assert!(out.resource_leaks.is_empty());
        assert!(out.access_findings.is_empty());
    }

    // write-then-write: alice owns doc:1, mallory (not owner, not granted) overwrites
    // it. Integrity violation, NOT a confidentiality leak (mallory is served nothing).
    #[test]
    fn unauthorized_overwrite_is_write_then_write_integrity() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "doc:1", 1),
            acc(2, "mallory", "write", "doc:1", 1),
        ];
        compute_access_findings(&mut out);
        assert!(out.resource_leaks.is_empty(), "W->W is not a confidentiality leak");
        assert_eq!(out.access_findings.len(), 1);
        let f = &out.access_findings[0];
        assert_eq!(f.pattern, AccessPattern::WriteThenWrite);
        assert_eq!(f.class, FindingClass::Integrity);
        assert_eq!(f.victim, "alice");
        assert_eq!(f.actor, "mallory");
    }

    // A granted co-writer overwriting is legitimate, not a finding (the document's
    // data model declares the collaborator at write time).
    #[test]
    fn granted_co_writer_overwrite_is_not_a_finding() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc_grant(1, "alice", "write", "doc:1", 1, &["bob"]),
            acc(2, "bob", "write", "doc:1", 1),
        ];
        compute_access_findings(&mut out);
        assert!(out.access_findings.is_empty(), "granted collaborator write is legitimate");
    }

    // read-then-write: alice owns res:1 and reads it (a check), then mallory (not
    // owner, not granted) writes it. The write mutates a resource alice had just read
    // (stale-read / TOCTOU) and is unauthorized: integrity, read-then-write.
    #[test]
    fn unauthorized_write_after_read_is_read_then_write_integrity() {
        let mut out = ObservationResult::default();
        out.accesses = vec![
            acc(1, "alice", "write", "res:1", 1),
            acc(2, "alice", "read", "res:1", 1),
            acc(3, "mallory", "write", "res:1", 1),
        ];
        compute_access_findings(&mut out);
        assert!(out.resource_leaks.is_empty());
        assert_eq!(out.access_findings.len(), 1);
        let f = &out.access_findings[0];
        assert_eq!(f.pattern, AccessPattern::ReadThenWrite);
        assert_eq!(f.class, FindingClass::Integrity);
        assert_eq!(f.victim, "alice");
        assert_eq!(f.actor, "mallory");
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
        compute_access_findings(&mut out);
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
        compute_access_findings(&mut out);
        assert_eq!(out.resource_leaks.len(), 1);
        assert_eq!(out.resource_leaks[0].reader, "bob");
    }
}
