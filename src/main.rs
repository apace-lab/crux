use anyhow::{Context, Result};
use clap::Parser;
use serde::{Deserialize, Serialize};
use std::{
    fs,
    path::{Path, PathBuf},
};

use crux_instrument::{
    instrument_project, AccessKind, InstrumentSite, InstrumentationPlan, SiteAction,
};
use crux_observe::{analyze_traces, run_observation, ObservationConfig, ObservationResult};
use crux_scheduler::{generate_schedules, verify_replay, write_schedule, LeakVerdict};

#[derive(Parser, Debug)]
#[command(name = "crux")]
struct Cli {
    /// Application source dir (needed for the dynamic stages; unused with --static-only)
    #[arg(long, default_value = ".")]
    project: PathBuf,

    /// LLVM IR module(s). Repeat for a multi-module app (e.g. lib + bin).
    #[arg(long, required = true)]
    llvm_ir: Vec<PathBuf>,

    /// LLM API signature catalog (JSON)
    #[arg(long, default_value = "../rail-rs/signatures/llm_api_functions.json")]
    llm_api: PathBuf,

    /// Access-control signature catalog (JSON)
    #[arg(long, default_value = "../rail-rs/signatures/ac_functions.json")]
    ac: PathBuf,

    /// Data-store (database / cache) signature catalog (JSON)
    #[arg(long, default_value = "../rail-rs/signatures/data_access_functions.json")]
    data_access: PathBuf,

    /// Source-level DAO capture catalog (JSON): recovers per-instance resources for
    /// ORM calls the IR erases via `#[async_trait]`. Missing file means no rules.
    #[arg(long, default_value = "../rail-rs/signatures/source_dao_functions.json")]
    source_dao: PathBuf,

    /// Serve-site capture catalog (JSON): at an auto-selected serve, iterates the
    /// in-scope served rows and emits a resource-linked access per row capturing the
    /// principal directly, for handlers that serve many rows (vaultwarden's
    /// `_get_org_details`). Missing file means no rules.
    #[arg(long, default_value = "../rail-rs/signatures/serve_capture_functions.json")]
    serve_capture: PathBuf,

    /// Path to the crux_runtime crate, added as a dependency to the instrumented app
    #[arg(long, default_value = "crux_runtime")]
    crux_runtime: PathBuf,

    #[arg(long, default_value = "runs/latest")]
    run_dir: PathBuf,

    #[arg(long, default_value_t = 3)]
    seeds: u64,

    #[arg(long, default_value_t = 1)]
    seed_start: u64,

    #[arg(long, default_value_t = false)]
    replay: bool,

    /// cargo subcommand the observe stage runs on the instrumented app
    /// ("test" for test-based apps, "run" for a main-based demo)
    #[arg(long, default_value = "test")]
    cargo_cmd: String,

    /// Run only the static stage (PAG + taint analysis + overlap detection) and
    /// stop after writing the instrumentation plan. Use this on a compiled
    /// real-world app when its source is not available for instrumentation.
    #[arg(long, default_value_t = false)]
    static_only: bool,

    /// Run producer + source instrumentation, then stop (skip observe / schedule
    /// / replay). Use to instrument an app you will run yourself, e.g. a live web
    /// server on real tokio instead of the MadSim observe stage.
    #[arg(long, default_value_t = false)]
    instrument_only: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct StaticStageResult {
    instrumentation_plan: InstrumentationPlan,
    /// DWARF struct-field index (type name -> field names), recovered from the IR debug
    /// info and threaded into the serve-capture inference so it can pick a served row's id
    /// field and a principal type's id field by naming convention. Not persisted (it is a
    /// large derived map rebuilt from the IR each run).
    #[serde(skip, default)]
    struct_fields: std::collections::HashMap<String, Vec<String>>,
}

/// Stable (deterministic across runs) numeric id for a function name, used as
/// the runtime `function_id` in instrumentation.
fn hash_fn_id(name: &str) -> u64 {
    use std::hash::{Hash, Hasher};
    let mut h = std::collections::hash_map::DefaultHasher::new();
    name.hash(&mut h);
    h.finish()
}

/// Project-relative source location of a PANode, if it has debug info.
fn node_loc(engine: &rail_rs::PrincipalSensitiveAnalysis<'_>, node_id: usize) -> Option<(String, usize)> {
    let node = engine.nodes.get(&node_id)?;
    let loc = node.source_loc.as_ref()?;
    let file = loc.file.clone()?;
    let line = loc.line? as usize;
    Some((
        file.trim_start_matches("./")
            .trim_start_matches('/')
            .to_string(),
        line,
    ))
}

/// Whether an access-control point establishes the request principal (a token,
/// session, or identity we can name from the call's first argument) or is only a
/// credential check. Password / secret verifiers such as argon2 and bcrypt take
/// the secret as their first argument, not the user, so they are credential
/// checks: the principal is established at a separate token / session / identity
/// point. Only principal-establishing points get an `crux_auth!` site. Keying this
/// on the matched catalog function (which the taint analysis already resolved) is
/// more reliable than inspecting the source line at instrument time.
fn establishes_principal(matched_fn_name: &str, principal_from_return: bool) -> bool {
    // An entry that explicitly declares the principal in the call's return value
    // (e.g. the app's own auth fn `Claims::validate -> LocalUserId`) always
    // establishes the principal; honor it regardless of the name.
    if principal_from_return {
        return true;
    }
    let short = matched_fn_name
        .rsplit("::")
        .next()
        .unwrap_or(matched_fn_name);
    // Credential / token-verification functions authenticate but their FIRST
    // ARGUMENT is a secret or token, not the user's identity, so they must not be
    // wrapped as a first-arg principal:
    //   - argon2 PasswordVerifier::verify_password / bcrypt::verify take the password;
    //   - jsonwebtoken::decode / decode_header take the raw JWT. The identity is the
    //     DECODED claims, which the app surfaces at its own auth point (cataloged
    //     with principal_from_return), not this generic verify call. Matching the
    //     JWT string as the principal (what happened before) is simply wrong.
    // The principal is established at that separate identity point instead.
    let credential_check = short == "verify_password"
        || matched_fn_name.starts_with("bcrypt::verify")
        || matched_fn_name.starts_with("jsonwebtoken::");
    !credential_check
}

/// Direction of a shared data-store access, from the catalog category. A
/// "data-write" puts data into the store; anything else (a read/query) reads it
/// out, which is the leak-exposing direction.
fn data_access_kind(category: &str) -> AccessKind {
    if category == "data-write" {
        AccessKind::Write
    } else {
        AccessKind::Read
    }
}

/// Compute a shared-store RESOURCE id for each data-access site, keyed by
/// callsite_id. The store a data-access call touches is a pointer argument (a
/// `&Pool` / `&Transaction` / store handle) whose points-to target is the store
/// object; that same object is referenced by every data-access site on that store.
/// So a site's resource id is the points-to target its arguments reference that is
/// shared with the most other data-access sites. Two sites on the same store (a
/// write via `execute`, a read via `fetch_one`) therefore get the SAME resource id
/// even though their per-callsite PANodes differ, which is what lets the
/// write-then-read leak verdict link across them. Sites with no shared store
/// pointee (e.g. a lone store) get no id and fall back to per-callsite behaviour.
fn compute_data_resource_ids(engine: &rail_rs::PrincipalSensitiveAnalysis<'_>) -> std::collections::HashMap<usize, u64> {
    use std::collections::{BTreeSet, HashMap};

    // Per data-access site: the pointees its store arguments alias (tier 1), and
    // the store-handle argument nodes themselves (tier 2 fallback).
    let mut site_pointees: Vec<(usize, BTreeSet<usize>)> = Vec::new();
    let mut site_handles: Vec<(usize, BTreeSet<usize>)> = Vec::new();
    for point in engine.semantic_points.iter() {
        if !matches!(point.kind, rail_rs::psa::SemanticPointKind::DataAccess { .. }) {
            continue;
        }
        let mut pts: BTreeSet<usize> = BTreeSet::new();
        let mut handles: BTreeSet<usize> = BTreeSet::new();
        for arg in &point.store_arg_nodes {
            if let Some(n) = engine.nodes.get(arg) {
                pts.extend(n.points_to.iter().copied());
                if n.is_store_handle() {
                    handles.insert(*arg);
                }
            }
        }
        if std::env::var_os("CRUX_DEBUG_RESOURCE").is_some() {
            eprintln!(
                "[crux-resource] callsite {} pointees={:?} handles={:?}",
                point.callsite_id, pts, handles
            );
        }
        site_pointees.push((point.callsite_id, pts));
        site_handles.push((point.callsite_id, handles));
    }

    // How many data-access sites reference each candidate (pointee, then handle).
    let freq = |sites: &[(usize, BTreeSet<usize>)]| -> HashMap<usize, usize> {
        let mut f: HashMap<usize, usize> = HashMap::new();
        for (_, s) in sites {
            for x in s {
                *f.entry(*x).or_default() += 1;
            }
        }
        f
    };
    let pointee_freq = freq(&site_pointees);
    let handle_freq = freq(&site_handles);

    // Each site's resource id is the candidate it references that is shared with
    // the most other sites (shared by >= 2), ties broken by smallest id. Prefer a
    // shared pointee (the store object the handle aliases, the real-app case) and
    // fall back to a shared store-handle node (the stub case, where the store is
    // hidden behind a global and only a handle is passed).
    let pick = |cands: &BTreeSet<usize>, f: &HashMap<usize, usize>| -> Option<usize> {
        cands
            .iter()
            .filter(|c| f.get(*c).copied().unwrap_or(0) >= 2)
            .max_by_key(|c| (f[*c], std::cmp::Reverse(**c)))
            .copied()
    };

    let mut out: HashMap<usize, u64> = HashMap::new();
    for i in 0..site_pointees.len() {
        let (id, pts) = &site_pointees[i];
        let handles = &site_handles[i].1;
        let chosen = pick(pts, &pointee_freq).or_else(|| pick(handles, &handle_freq));
        if let Some(r) = chosen {
            out.insert(*id, r as u64);
        }
    }
    out
}

/// Adapter between this prototype and our existing rail-rs + nested taint analysis.
///
/// Parses the LLVM IR, runs the PAG + taint analysis, and emits an
/// `InstrumentationPlan`: `Auth` sites at access-control points (so the runtime
/// per-user principal is established) and `Access` sites at LLM calls and any
/// statically-detected cross-user overlaps. The dynamic stages then distinguish
/// users at runtime.
fn run_pag_and_crux(
    llvm_ir: &[PathBuf],
    llm_api: &Path,
    ac: &Path,
    data_access: &Path,
) -> Result<StaticStageResult> {
    use std::collections::HashSet;

    println!("[1/6] PAG + CRUX static analysis");

    // Parse the module(s) and set up the cross-module analysis.
    let mut modules = Vec::with_capacity(llvm_ir.len());
    for path in llvm_ir {
        println!("      LLVM IR: {}", path.display());
        let module = rail_rs::llvm_ir::Module::from_ir_path(path)
            .map_err(|e| anyhow::anyhow!("failed to parse LLVM IR {}: {e}", path.display()))?;
        modules.push(module);
    }
    let mut analysis = rail_rs::CrossModuleAnalysis::new(modules.iter());

    // Load the signature catalogs so the PAG records semantic (LLM/AC/data) points.
    let llm_sigs = rail_rs::signature::load_signatures(llm_api)
        .map_err(|e| anyhow::anyhow!("failed to load LLM catalog {}: {e}", llm_api.display()))?;
    let mut ac_sigs = rail_rs::signature::load_signatures(ac)
        .map_err(|e| anyhow::anyhow!("failed to load AC catalog {}: {e}", ac.display()))?;
    let data_sigs = rail_rs::signature::load_signatures(data_access).map_err(|e| {
        anyhow::anyhow!("failed to load data-store catalog {}: {e}", data_access.display())
    })?;

    // CRUX_INFER_CHECKS: derive application access-control checks structurally (a call whose
    // boolean result controls a guard branch) and add them as synthetic authorization
    // signatures, so bespoke app checks (e.g. `is_accessible_to_user`) need not be cataloged
    // by hand. Opt-in and heuristic; see rail_rs::guard_inference.
    // CRUX_INFER_CHECKS: structurally derive candidate application access-control checks (calls
    // whose boolean result controls a guard branch). It has high recall (it surfaces the real
    // app checks, e.g. `is_accessible_to_user`), but over-approximates: it also proposes
    // operators and predicates, so using it to *clear* accesses is unsound (it can hide a real
    // leak). By default it therefore only SUGGESTS the catalog (prints the list for curation);
    // set CRUX_INFER_CHECKS=apply to actually add them (unsound, for experiments only).
    if let Ok(mode) = std::env::var("CRUX_INFER_CHECKS") {
        let app = std::env::var("CRUX_APP_CRATE")
            .ok()
            .filter(|s| !s.is_empty())
            .unwrap_or_else(|| rail_rs::detect_app_crate(modules.iter()));
        // Data-access catalog names (reduced to last-two segments) let guard inference require
        // that a candidate check's protected arm actually performs a data-access.
        let last2 = |s: &str| -> String {
            let p: Vec<&str> = s.rsplitn(3, "::").collect();
            if p.len() >= 2 { format!("{}::{}", p[1], p[0]) } else { s.to_string() }
        };
        let data_names: std::collections::BTreeSet<String> =
            data_sigs.iter().map(|s| last2(&s.fn_name)).collect();
        let inferred =
            rail_rs::guard_inference::inferred_check_functions(modules.iter(), &app, &data_names);
        let data_names: std::collections::BTreeSet<&str> =
            data_sigs.iter().map(|s| s.fn_name.as_str()).collect();
        // a serve is never its own check
        let suggestions: Vec<&String> =
            inferred.iter().filter(|f| !data_names.contains(f.as_str())).collect();
        println!(
            "      guard inference (SUGGESTIONS, review before trusting): {} candidate check fn(s): {:?}",
            suggestions.len(),
            suggestions.iter().take(20).collect::<Vec<_>>()
        );
        if mode == "apply" {
            let before = ac_sigs.len();
            for fq in &suggestions {
                if ac_sigs.iter().any(|s| &s.fn_name == *fq) {
                    continue;
                }
                ac_sigs.push(rail_rs::signature::Signature {
                    fn_name: (*fq).clone(),
                    category: Some("authorization".to_string()),
                    ..Default::default()
                });
            }
            println!(
                "      guard inference: APPLIED {} inferred check(s) to the AC catalog (UNSOUND: may hide leaks; experiments only)",
                ac_sigs.len() - before
            );
        }
    }

    println!(
        "      catalogs: {} LLM, {} AC, {} data-store signatures",
        llm_sigs.len(),
        ac_sigs.len(),
        data_sigs.len()
    );
    analysis.set_context_catalogs(llm_sigs, ac_sigs, data_sigs);

    // Recover debug-info struct types from the textual IR (see rail_rs::debuginfo). The
    // dominance pass uses them to keep resources of different concrete types from binding
    // when opaque-pointer points-to over-merges them. Harmless when the IR has no debug info.
    let debug_types = rail_rs::debuginfo::DebugTypes::parse_files(llvm_ir.iter());
    println!(
        "      debug-info: {} struct type(s), {} value->type link(s) recovered",
        debug_types.composite_count(),
        debug_types.value_link_count()
    );
    // Struct-field index for serve-capture inference (type name -> field names), built from
    // the debug info before it is moved into the analysis.
    let struct_fields = debug_types.struct_field_index();
    analysis.set_debug_types(debug_types);

    // Build the PAG (crux mode) and run the taint analysis.
    let engine = analysis.psa("crux", None);
    println!(
        "      taint analysis: app_crate={:?}, {} semantic points, {} principals, {} tagged nodes",
        engine.app_crate,
        engine.semantic_points.len(),
        engine.active_principals.len(),
        engine.node_contexts.len()
    );

    use rail_rs::psa::SemanticPointKind;

    // --- Access-control dominance analysis (automated enforcement pass) ---
    // Enumerate data-access sites not dominated, on all paths, by an access-control check
    // bound to the accessed resource (the leak candidates). Block-level dominance comes
    // from the per-function dominator trees; resource binding from the points-to sets.
    // See rail_rs::ace (the access-control enforcement pass).
    {
        use rail_rs::ace::{self as dominance, AccessSite, CallSite, CheckSite, DominanceFacts, PrecomputedOracle};
        use rail_rs::CFGNode;
        use std::collections::{BTreeMap, BTreeSet};

        let app = engine.app_crate.clone();
        let in_app = |name: &str| app.is_empty() || name.contains(app.as_str());

        // Propagate recovered debug types through the SSA dataflow so temporaries (the
        // actual resource pointers at real access sites, e.g. GEP results and spill loads)
        // carry a struct type, not just named source variables.
        // CRUX_NO_TYPE_GATE disables the debug-type gate (for A/B comparison on identical IR).
        let type_gate_on = std::env::var("CRUX_NO_TYPE_GATE").is_err();
        let value_types = if type_gate_on {
            analysis.debug_types().map(|dt| dt.propagate_types(modules.iter()))
        } else {
            None
        };

        // A shared-infrastructure type: a DB connection / pool / transaction handle, which is
        // an argument to nearly every data call but is not a per-user resource. Recognized by
        // its recovered debug type, so it can be excluded on principle rather than by the
        // frequency heuristic.
        let is_infra_type = |tok: &str| -> bool {
            let last = tok.rsplit("::").next().unwrap_or(tok);
            ["Connection", "DbConn", "Pool", "Transaction", "Executor", "Client"]
                .iter()
                .any(|m| last.contains(m))
        };
        // Resource set of a site = points-to targets of its argument nodes, excluding args
        // whose recovered debug type is shared infrastructure (a connection/pool/transaction).
        let node_pts = |ids: &[usize]| -> BTreeSet<u64> {
            let mut s = BTreeSet::new();
            for id in ids {
                if let Some(n) = engine.nodes.get(id) {
                    if let (Some((func, val)), Some(vt)) = (n.ssa_ref(), value_types.as_ref()) {
                        if vt.token(func, &val).map(is_infra_type).unwrap_or(false) {
                            continue; // skip connection/pool handles
                        }
                    }
                    for p in &n.points_to {
                        s.insert(*p as u64);
                    }
                }
            }
            s
        };

        // Stable hash of a debug-type signature string into the type-tag id space (a set
        // disjoint in purpose from the points-to resource ids).
        let hash_type = |s: &str| -> u64 {
            use std::hash::{Hash, Hasher};
            let mut h = std::collections::hash_map::DefaultHasher::new();
            s.hash(&mut h);
            h.finish()
        };

        // Debug-type tag of a site = the propagated struct type token(s) of its pointer
        // argument SSA values (named vars AND temporaries). Empty when no debug info
        // resolves (then the dominance pass falls back to pure points-to binding).
        let type_tag_of = |arg_ids: &[usize], store_ids: &[usize]| -> BTreeSet<u64> {
            let mut s = BTreeSet::new();
            let Some(vt) = value_types.as_ref() else { return s };
            for id in arg_ids.iter().chain(store_ids.iter()) {
                if let Some(n) = engine.nodes.get(id) {
                    if let Some((func, val)) = n.ssa_ref() {
                        if let Some(tok) = vt.token(func, &val) {
                            s.insert(hash_type(tok));
                        }
                    }
                }
            }
            s
        };

        // Diagnostic: dump the resource nodes at the first few sites and whether each types.
        if std::env::var("CRUX_DEBUG_TYPETAG").is_ok() {
            if let Some(vt) = value_types.as_ref() {
                eprintln!("[TYPETAG] propagate_types total typed values = {}", vt.len());
                for (f, v, t) in vt.sample(8) {
                    let ft: String = f.chars().rev().take(34).collect::<String>().chars().rev().collect();
                    eprintln!("    sample: fn=...{} {} -> {}", ft, v, t);
                }
            }
            let mut shown = 0;
            for p in engine.semantic_points.iter() {
                let is_site = matches!(
                    p.kind,
                    SemanticPointKind::DataAccess { .. }
                        | SemanticPointKind::AccessControl { .. }
                        | SemanticPointKind::AccessControlRecovery { .. }
                );
                if !is_site {
                    continue;
                }
                let callee = p.callee.clone().unwrap_or_default();
                let tail: String = callee.chars().rev().take(40).collect::<String>().chars().rev().collect();
                eprintln!("[TYPETAG] site callee=...{} store_args={} result={:?}", tail, p.store_arg_nodes.len(), p.result_node);
                for id in p.store_arg_nodes.iter().chain(p.result_node.iter()) {
                    if let Some(n) = engine.nodes.get(id) {
                        let sr = n.ssa_ref();
                        let (func, name) = sr.clone().map(|(f, v)| (f.to_string(), v)).unwrap_or_default();
                        let tok = value_types.as_ref().and_then(|vt| vt.token(&func, &name).map(|t| t.to_string()));
                        let nfor = value_types.as_ref().map(|vt| vt.count_for(&func)).unwrap_or(0);
                        let ftail: String = func.chars().rev().take(30).collect::<String>().chars().rev().collect();
                        eprintln!("    node#{} name={:?} fn=...{} typed_in_fn={} token={:?}", id, name, ftail, nfor, tok);
                    }
                }
                shown += 1;
                if shown >= 12 {
                    break;
                }
            }
        }

        // Prefer the `async fn` construction call over its coroutine-body driver. An async
        // method call appears both as the construction `Type::method(sret, &resource, ...)`
        // (which carries the real resource argument) and, after suffix-stripped matching, as
        // the coroutine-body driver `Type::method::{{closure}}(sret, env)` (whose arguments
        // are only the coroutine frame, not the resource). When a caller has both for the same
        // method and category, the body-form site is a spurious access/check, so drop it. When
        // only the body form exists (the construction was inlined away), keep it for coverage.
        let is_coroutine_body = |callee: &str| -> bool {
            callee.contains("{{closure}}") || callee.contains("{async_fn") || callee.contains("{closure#")
        };
        let base_method = |callee: &str| -> String {
            let mut cur = callee;
            while let Some(idx) = cur.rfind("::") {
                if cur[idx + 2..].starts_with('{') {
                    cur = &cur[..idx];
                } else {
                    break;
                }
            }
            cur.to_string()
        };
        let kind_key = |p: &rail_rs::psa::SemanticPoint| -> Option<&'static str> {
            match &p.kind {
                SemanticPointKind::AccessControl { .. }
                | SemanticPointKind::AccessControlRecovery { .. } => Some("ac"),
                SemanticPointKind::DataAccess { .. } => Some("data"),
                _ => None,
            }
        };
        let mut has_construction: BTreeSet<(String, String, &'static str)> = BTreeSet::new();
        for p in engine.semantic_points.iter() {
            if let Some(kk) = kind_key(p) {
                if !is_coroutine_body(&p.security_point.callee) {
                    has_construction.insert((p.caller.clone(), base_method(&p.security_point.callee), kk));
                }
            }
        }
        let is_redundant_body = |p: &rail_rs::psa::SemanticPoint| -> bool {
            match kind_key(p) {
                Some(kk) => {
                    is_coroutine_body(&p.security_point.callee)
                        && has_construction.contains(&(
                            p.caller.clone(),
                            base_method(&p.security_point.callee),
                            kk,
                        ))
                }
                None => false,
            }
        };

        // Coroutine capture identity: two sites in the same async fn that use the same env
        // capture (same offset) touch the same resource instance, so add a per-capture token
        // to the resource set. This binds a check and a serve that both operate on a captured
        // resource whose reloads otherwise point to distinct objects.
        let capture_tag_of = |arg_ids: &[usize], store_ids: &[usize]| -> BTreeSet<u64> {
            let mut s = BTreeSet::new();
            let Some(vt) = value_types.as_ref() else { return s };
            for id in arg_ids.iter().chain(store_ids.iter()) {
                if let Some(n) = engine.nodes.get(id) {
                    if let Some((func, val)) = n.ssa_ref() {
                        if let Some(off) = vt.capture_offset(func, &val) {
                            s.insert(hash_type(&format!("cap:{func}:{off}")));
                        }
                    }
                }
            }
            s
        };
        // Raw resource sets (+ debug-type tags), then exclude shared infrastructure (a DB
        // pool / connection is an argument to nearly every site, so it would spuriously bind
        // every check to every access). A pointee present in >= half of the sites is infra.
        // Each raw site carries (pointee resources, capture tokens, type tags) separately: the
        // shared-infra exclusion applies only to pointees; capture tokens are precise binding
        // signals and must never be excluded (with few sites they would look "ubiquitous").
        let mut checks_raw: Vec<(String, String, BTreeSet<u64>, BTreeSet<u64>, BTreeSet<u64>)> =
            Vec::new();
        let mut accs_raw: Vec<(usize, String, String, BTreeSet<u64>, BTreeSet<u64>, BTreeSet<u64>)> =
            Vec::new();
        for p in engine.semantic_points.iter() {
            if is_redundant_body(p) {
                continue;
            }
            match &p.kind {
                SemanticPointKind::AccessControl { .. }
                | SemanticPointKind::AccessControlRecovery { .. } => {
                    checks_raw.push((
                        p.caller.clone(),
                        p.block.clone(),
                        node_pts(&p.store_arg_nodes),
                        capture_tag_of(&p.argument_nodes, &p.store_arg_nodes),
                        type_tag_of(&p.argument_nodes, &p.store_arg_nodes),
                    ));
                }
                SemanticPointKind::DataAccess { .. } => {
                    accs_raw.push((
                        p.callsite_id,
                        p.caller.clone(),
                        p.block.clone(),
                        node_pts(&p.store_arg_nodes),
                        capture_tag_of(&p.argument_nodes, &p.store_arg_nodes),
                        type_tag_of(&p.argument_nodes, &p.store_arg_nodes),
                    ));
                }
                _ => {}
            }
        }
        let total_sites = (checks_raw.len() + accs_raw.len()).max(1);
        let mut freq: BTreeMap<u64, usize> = BTreeMap::new();
        for (_, _, r, _, _) in &checks_raw {
            for p in r {
                *freq.entry(*p).or_default() += 1;
            }
        }
        for (_, _, _, r, _, _) in &accs_raw {
            for p in r {
                *freq.entry(*p).or_default() += 1;
            }
        }
        let ubiquitous: BTreeSet<u64> =
            freq.iter().filter(|(_, c)| **c * 2 >= total_sites).map(|(p, _)| *p).collect();
        // refined pointees (infra excluded) unioned with the always-kept capture tokens
        let refine = |r: &BTreeSet<u64>, cap: &BTreeSet<u64>| -> BTreeSet<u64> {
            let mut out: BTreeSet<u64> =
                r.iter().filter(|p| !ubiquitous.contains(p)).copied().collect();
            out.extend(cap.iter().copied());
            out
        };

        let n_typed_checks = checks_raw.iter().filter(|(_, _, _, _, t)| !t.is_empty()).count();
        let n_typed_accs = accs_raw.iter().filter(|(_, _, _, _, _, t)| !t.is_empty()).count();

        let checks: Vec<CheckSite> = checks_raw
            .iter()
            .map(|(f, b, r, cap, t)| CheckSite {
                function: f.clone(),
                block: b.clone(),
                resources: refine(r, cap),
                type_tag: t.clone(),
            })
            .collect();
        let accesses: Vec<AccessSite> = accs_raw
            .iter()
            .map(|(id, f, b, r, cap, t)| AccessSite {
                id: *id,
                function: f.clone(),
                block: b.clone(),
                resources: refine(r, cap),
                type_tag: t.clone(),
            })
            .collect();

        // Call sites with blocks (from the IR), restricted to app-crate callers.
        let calls: Vec<CallSite> = dominance::call_sites_with_blocks(modules.iter())
            .into_iter()
            .filter(|c| in_app(&c.caller))
            .collect();

        // Entries: app-crate functions with no app-internal caller (call-graph roots).
        let mut fns: BTreeSet<String> = BTreeSet::new();
        let mut has_in: BTreeSet<String> = BTreeSet::new();
        for c in &calls {
            fns.insert(c.caller.clone());
            if in_app(&c.callee) {
                fns.insert(c.callee.clone());
                has_in.insert(c.callee.clone());
            }
        }
        for c in &checks {
            fns.insert(c.function.clone());
        }
        for a in &accesses {
            fns.insert(a.function.clone());
        }
        let entries: BTreeSet<String> =
            fns.iter().filter(|f| !has_in.contains(*f)).cloned().collect();

        // Precompute true dominance pairs from the per-function dominator trees, for each
        // function that performs a check (dominator of its access and call blocks).
        let check_fns: BTreeSet<String> = checks.iter().map(|c| c.function.clone()).collect();
        let mut pairs: BTreeSet<(String, String, String)> = BTreeSet::new();
        for cf in &check_fns {
            let check_blocks: Vec<String> =
                checks.iter().filter(|c| &c.function == cf).map(|c| c.block.clone()).collect();
            let mut targets: BTreeSet<String> = BTreeSet::new();
            for a in &accesses {
                if &a.function == cf {
                    targets.insert(a.block.clone());
                }
            }
            for c in &calls {
                if &c.caller == cf {
                    targets.insert(c.block.clone());
                }
            }
            if let Some((func, module)) = analysis.get_func_by_name(cf) {
                let fa = analysis.module_analysis(&module.name).fn_analysis(cf);
                // Coroutine-normalized dominance: for async fns this rewires the resume
                // dispatch so a check before an `await` dominates a serve after it. Identical
                // to the plain dominator tree for non-coroutine functions.
                // CRUX_NO_COROUTINE_DOM disables it (for A/B comparison on identical IR).
                let dt = if std::env::var("CRUX_NO_COROUTINE_DOM").is_ok() {
                    fa.dominator_tree()
                } else {
                    fa.dominator_tree_coroutine()
                };
                let name_of = |bs: &str| {
                    func.basic_blocks.iter().map(|bb| &bb.name).find(|n| n.to_string() == bs)
                };
                let dbg_dom = std::env::var("CRUX_DEBUG_DOM").map(|v| cf.contains(&v)).unwrap_or(false);
                for cb in &check_blocks {
                    for tb in &targets {
                        if let (Some(cn), Some(tn)) = (name_of(cb), name_of(tb)) {
                            let d = dt.dominates(CFGNode::Block(cn), CFGNode::Block(tn));
                            if dbg_dom {
                                eprintln!("[DOM] check {cb} dominates access/target {tb} ? {d}");
                            }
                            if d {
                                pairs.insert((cf.clone(), cb.clone(), tb.clone()));
                            }
                        }
                    }
                }
            }
        }

        let n_checks = checks.len();
        let oracle = PrecomputedOracle { pairs };
        let facts = DominanceFacts { checks, accesses, calls, entries };
        let report = dominance::analyze(&facts, &oracle);
        println!(
            "      dominance: {} data-access site(s), {} dominated, {} unreachable, {} UN-DOMINATED candidate(s); {} check site(s), {} shared-infra pointee(s) excluded",
            report.total_accesses,
            report.dominated_accesses,
            report.unreachable_accesses,
            report.candidates.len(),
            n_checks,
            ubiquitous.len()
        );
        println!(
            "      dominance (debug-types): {} check(s) and {} access(es) carry a recovered struct type for resource binding",
            n_typed_checks, n_typed_accs
        );
        let tail = |s: &str| -> String {
            let n = s.len();
            s[n.saturating_sub(70)..].to_string()
        };
        for c in report.candidates.iter().take(50) {
            println!("        [candidate] access#{} in ...{}", c.access_id, tail(&c.function));
        }
    }

    let mut sites: Vec<InstrumentSite> = Vec::new();
    let (mut n_auth, mut n_access, mut n_credential, mut n_data) = (0usize, 0usize, 0usize, 0usize);

    // Resource id per data-access site: the shared store its arguments alias, so a
    // write and a read on the same store link even though their PANodes differ.
    let data_resource_ids = compute_data_resource_ids(&engine);

    // 1) Auth sites at access-control points; 2) Access sites at LLM calls.
    for point in engine.semantic_points.iter() {
        match &point.kind {
            SemanticPointKind::AccessControl { .. }
            | SemanticPointKind::AccessControlRecovery { .. } => {
                let matched = &point.security_point.matched_fn_name;
                // Only principal-establishing auth points get an crux_auth! site.
                // Credential checks (argon2/bcrypt password verifiers) authenticate
                // but do not name the user, so the principal is established at a
                // separate token / session / identity point.
                let p_from_return = point
                    .security_point
                    .principal_from_return
                    .unwrap_or(false);
                if !establishes_principal(matched, p_from_return) {
                    n_credential += 1;
                    continue;
                }
                // Location = the auth call site (its result node); the instrumenter
                // extracts the call's first argument as the runtime principal.
                let node = point.result_node.or_else(|| point.argument_nodes.first().copied());
                let Some(node) = node else { continue };
                let Some((file, line)) = node_loc(&engine, node) else {
                    continue;
                };
                let call_name = matched.rsplit("::").next().unwrap_or(matched).to_string();
                sites.push(InstrumentSite {
                    file: file.into(),
                    line,
                    action: SiteAction::Auth {
                        call_name: call_name.clone(),
                        principal_from_return: point.security_point.principal_from_return,
                        principal_expr: point.security_point.principal_expr.clone(),
                    },
                    reason: format!("auth point: {call_name}"),
                });
                n_auth += 1;
            }
            SemanticPointKind::LlmCall { .. } | SemanticPointKind::LlmPrompt { .. } => {
                let node = point.result_node.or_else(|| point.argument_nodes.first().copied());
                let Some(node) = node else { continue };
                // Location hint from any node at the call; the instrumenter then
                // locates the actual call line by name and inserts after it.
                let loc = node_loc(&engine, node).or_else(|| {
                    point.argument_nodes.iter().find_map(|n| node_loc(&engine, *n))
                });
                let Some((file, line)) = loc else { continue };
                let matched = &point.security_point.matched_fn_name;
                let short = matched.rsplit("::").next().unwrap_or(matched).to_string();
                let function_id = engine.nodes.get(&node).and_then(|n| n.function()).map(hash_fn_id);
                sites.push(InstrumentSite {
                    file: file.into(),
                    line,
                    action: SiteAction::Access {
                        panode: node as u64,
                        function_id,
                        access: AccessKind::Read,
                        call_name: Some(short),
                        // gate this access so a replay schedule can order it
                        // across principals (the LLM call sits in an async fn).
                        schedule_site: Some(node as u64),
                        // LLM calls are not a shared data store; no resource id.
                        resource: None,
                        resource_arg: None,
                        resource_prefix: None,
                        resource_from_return: None,
                        resource_expr: None,
                    },
                    reason: format!("llm access: {}", point.callee.as_deref().unwrap_or("?")),
                });
                n_access += 1;
            }
            SemanticPointKind::DataAccess { category } => {
                // A shared data-store read/write. Direction comes from the catalog
                // category; a read exposes stored data, a write puts data in.
                let access = data_access_kind(category);
                let node = point.result_node.or_else(|| point.argument_nodes.first().copied());
                let Some(node) = node else { continue };
                let loc = node_loc(&engine, node).or_else(|| {
                    point.argument_nodes.iter().find_map(|n| node_loc(&engine, *n))
                });
                let Some((file, line)) = loc else { continue };
                let matched = &point.security_point.matched_fn_name;
                let short = matched.rsplit("::").next().unwrap_or(matched).to_string();
                let function_id = engine.nodes.get(&node).and_then(|n| n.function()).map(hash_fn_id);
                sites.push(InstrumentSite {
                    file: file.into(),
                    line,
                    action: SiteAction::Access {
                        panode: node as u64,
                        function_id,
                        access,
                        call_name: Some(short),
                        // gate it so a replay schedule can order a write before a
                        // cross-user read (data-store calls are usually async).
                        schedule_site: Some(node as u64),
                        // the shared store this access touches (points-to), so a
                        // write and a read on the same store link across PANodes.
                        resource: data_resource_ids.get(&point.callsite_id).copied(),
                        // the argument naming the resource INSTANCE (file path, row
                        // id) from the catalog, so the instrumenter captures the
                        // runtime id and the oracle gets per-instance resolution.
                        resource_arg: point.security_point.resource_arg,
                        resource_prefix: point.security_point.resource_prefix.clone(),
                        resource_from_return: point.security_point.resource_from_return,
                        resource_expr: point.security_point.resource_expr.clone(),
                    },
                    reason: format!("data access ({category}): {}", point.callee.as_deref().unwrap_or("?")),
                });
                n_data += 1;
            }
            _ => {}
        }
    }

    // 3) Any statically-detected cross-user overlaps (nodes reached by >=2 distinct
    // principals) also become access sites.
    for (node_id, ctxs) in engine.node_contexts.iter() {
        let principals: HashSet<usize> = ctxs
            .iter()
            .filter_map(|e| match e {
                rail_rs::PAContextElem::Principal { auth_callsite } => Some(*auth_callsite),
                _ => None,
            })
            .collect();
        if principals.len() < 2 {
            continue;
        }
        if let Some((file, line)) = node_loc(&engine, *node_id) {
            let function_id = engine.nodes.get(node_id).and_then(|n| n.function()).map(hash_fn_id);
            sites.push(InstrumentSite {
                file: file.into(),
                line,
                action: SiteAction::Access {
                    panode: *node_id as u64,
                    function_id,
                    access: AccessKind::Read,
                    call_name: None,
                    // no gate: static-overlap sites may not sit in an async fn.
                    schedule_site: None,
                    // a raw overlap node is already the shared resource itself.
                    resource: None,
                    resource_arg: None,
                    resource_prefix: None,
                    resource_from_return: None,
                    resource_expr: None,
                },
                reason: format!("static cross-user overlap ({} principals)", principals.len()),
            });
        }
    }

    println!(
        "      instrumentation sites: {n_auth} auth, {n_access} llm-access, {n_data} data-access, {} total ({n_credential} credential-check point(s) skipped)",
        sites.len()
    );
    Ok(StaticStageResult {
        instrumentation_plan: InstrumentationPlan { sites },
        struct_fields,
    })
}

fn prepare_run_dir(run_dir: &Path) -> Result<()> {
    for d in ["static", "instrumented", "observe", "schedule", "result"] {
        fs::create_dir_all(run_dir.join(d))?;
    }
    Ok(())
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    prepare_run_dir(&cli.run_dir)?;

    let static_result = run_pag_and_crux(&cli.llvm_ir, &cli.llm_api, &cli.ac, &cli.data_access)?;
    fs::write(
        cli.run_dir.join("static/instrumentation.json"),
        serde_json::to_string_pretty(&static_result.instrumentation_plan)?,
    )?;

    if cli.static_only {
        println!(
            "static-only: wrote {} overlap site(s) to {}; stopping.",
            static_result.instrumentation_plan.sites.len(),
            cli.run_dir.join("static/instrumentation.json").display()
        );
        return Ok(());
    }

    println!("[2/6] Source instrumentation");
    let instrumented_project = cli.run_dir.join("instrumented/app");
    // SOURCE-level DAO capture rules (catalog-driven): recover per-instance
    // resources for ORM calls the IR erases via `#[async_trait]`. Absent file -> none.
    let source_dao = crux_instrument::load_source_dao_rules(&cli.source_dao)
        .with_context(|| format!("loading source-DAO catalog {}", cli.source_dao.display()))?;
    if !source_dao.is_empty() {
        println!("      source-DAO rules: {}", source_dao.len());
    }
    let serve_capture = crux_instrument::load_serve_capture_rules(&cli.serve_capture)
        .with_context(|| format!("loading serve-capture catalog {}", cli.serve_capture.display()))?;
    if !serve_capture.is_empty() {
        println!("      serve-capture rules: {}", serve_capture.len());
    }
    instrument_project(
        &cli.project,
        &instrumented_project,
        &static_result.instrumentation_plan,
        &cli.crux_runtime,
        &source_dao,
        &serve_capture,
        &static_result.struct_fields,
    )?;

    if cli.instrument_only {
        println!(
            "instrument-only: wrote CRUX-instrumented app to {}; run it yourself.",
            instrumented_project.display()
        );
        return Ok(());
    }

    println!("[3/6] MadSim observation");
    let mut trace_paths = Vec::new();
    for seed in cli.seed_start..(cli.seed_start + cli.seeds) {
        let trace = cli
            .run_dir
            .join("observe")
            .join(format!("seed-{seed}.jsonl"));

        run_observation(&ObservationConfig {
            project_dir: instrumented_project.clone(),
            seed,
            trace_path: trace.clone(),
            schedule_path: None,
            cargo_args: vec![cli.cargo_cmd.clone()],
        })
        .with_context(|| format!("observation failed for seed {seed}"))?;

        trace_paths.push(trace);
    }

    println!("[4/6] Analyze dynamic scopes");
    let observation: ObservationResult = analyze_traces(&trace_paths)?;
    fs::write(
        cli.run_dir.join("observe/scopes.json"),
        serde_json::to_string_pretty(&observation)?,
    )?;

    println!("[5/6] Generate schedules");
    let schedules = generate_schedules(&observation, 20);
    for (i, schedule) in schedules.iter().enumerate() {
        write_schedule(
            schedule,
            &cli.run_dir
                .join("schedule")
                .join(format!("schedule-{i:03}.json")),
        )?;
    }

    println!("[6/6] Replay");
    if cli.replay {
        let mut reproduced = 0usize;
        for i in 0..schedules.len() {
            let replay_trace = cli
                .run_dir
                .join("result")
                .join(format!("replay-{i:03}.jsonl"));
            run_observation(&ObservationConfig {
                project_dir: instrumented_project.clone(),
                seed: cli.seed_start,
                trace_path: replay_trace.clone(),
                schedule_path: Some(
                    cli.run_dir
                        .join("schedule")
                        .join(format!("schedule-{i:03}.json")),
                ),
                cargo_args: vec![cli.cargo_cmd.clone()],
            })?;

            // Verdict: did the scheduled writer-then-reader leak actually occur?
            let replay_obs = analyze_traces(&[replay_trace])?;
            let verdict = verify_replay(&schedules[i], &replay_obs);
            fs::write(
                cli.run_dir
                    .join("result")
                    .join(format!("verdict-{i:03}.json")),
                serde_json::to_string_pretty(&verdict)?,
            )?;
            match &verdict {
                LeakVerdict::Reproduced { writer, reader, panode, resource } => {
                    reproduced += 1;
                    let where_ = match resource {
                        Some(r) => format!("resource {r}"),
                        None => format!("PANode {panode}"),
                    };
                    println!(
                        "      schedule {i:03}: LEAK REPRODUCED ({writer} wrote {where_}, then {reader} read it)"
                    );
                }
                LeakVerdict::NotReproduced { reason } => {
                    println!("      schedule {i:03}: not reproduced ({reason})");
                }
            }
        }
        println!(
            "      replay verdict: {reproduced}/{} schedule(s) reproduced a cross-user leak",
            schedules.len()
        );
    } else {
        println!("      replay disabled; add --replay to execute generated schedules");
    }

    println!("CRUX pipeline completed: {}", cli.run_dir.display());
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::{data_access_kind, establishes_principal};
    use crux_instrument::AccessKind;

    #[test]
    fn data_access_direction_from_category() {
        // A write puts data into the shared store; a read exposes it (the leak
        // direction). Unknown/generic categories are treated as reads.
        assert_eq!(data_access_kind("data-write"), AccessKind::Write);
        assert_eq!(data_access_kind("data-read"), AccessKind::Read);
        assert_eq!(data_access_kind("data-access"), AccessKind::Read);
    }

    #[test]
    fn credential_and_token_checks_are_not_first_arg_principal_sources() {
        // Password / secret verifiers and raw JWT decode: authenticate, but their
        // first argument is a secret or token, NOT the user's identity. They must
        // not be wrapped as a first-arg principal.
        assert!(!establishes_principal("argon2::PasswordVerifier::verify_password", false));
        assert!(!establishes_principal("bcrypt::verify", false));
        assert!(!establishes_principal("jsonwebtoken::decode", false));
        assert!(!establishes_principal("jsonwebtoken::decoding::decode", false));
    }

    #[test]
    fn identity_points_are_first_arg_principal_sources() {
        // Token / session / identity points whose first argument names the user.
        assert!(establishes_principal("actix_identity::Identity::id", false));
        assert!(establishes_principal("ldap3::Ldap::simple_bind", false));
    }

    #[test]
    fn principal_from_return_is_always_a_source() {
        // An entry that declares the principal in its RETURN value is honored
        // regardless of the function name (the app's own auth fn), even for a
        // name that is otherwise a credential/token check.
        assert!(establishes_principal("lemmy_api_common::claims::Claims::validate", true));
        assert!(establishes_principal("jsonwebtoken::decode", true));
    }
}
