use anyhow::{Context, Result};
use clap::Parser;
use serde::{Deserialize, Serialize};
use std::{
    fs,
    path::{Path, PathBuf},
};

use afg_instrument::{
    instrument_project, AccessKind, InstrumentSite, InstrumentationPlan, SiteAction,
};
use afg_observe::{analyze_traces, run_observation, ObservationConfig, ObservationResult};
use afg_scheduler::{generate_schedules, verify_replay, write_schedule, LeakVerdict};

#[derive(Parser, Debug)]
#[command(name = "afg")]
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

    /// Path to the afg-runtime crate, added as a dependency to the instrumented app
    #[arg(long, default_value = "afg-runtime")]
    afg_runtime: PathBuf,

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
fn node_loc(engine: &rail_rs::TaintAnalysis<'_>, node_id: usize) -> Option<(String, usize)> {
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
/// point. Only principal-establishing points get an `afg_auth!` site. Keying this
/// on the matched catalog function (which the taint analysis already resolved) is
/// more reliable than inspecting the source line at instrument time.
fn establishes_principal(matched_fn_name: &str) -> bool {
    let short = matched_fn_name
        .rsplit("::")
        .next()
        .unwrap_or(matched_fn_name);
    let credential_check = short == "verify_password"       // argon2 PasswordVerifier
        || matched_fn_name.starts_with("bcrypt::verify");   // bcrypt::verify
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

/// Adapter between this prototype and our existing rail-rs + nested taint analysis.
///
/// Parses the LLVM IR, runs the PAG + taint analysis, and emits an
/// `InstrumentationPlan`: `Auth` sites at access-control points (so the runtime
/// per-user principal is established) and `Access` sites at LLM calls and any
/// statically-detected cross-user overlaps. The dynamic stages then distinguish
/// users at runtime.
fn run_pag_and_afg(
    llvm_ir: &[PathBuf],
    llm_api: &Path,
    ac: &Path,
    data_access: &Path,
) -> Result<StaticStageResult> {
    use std::collections::HashSet;

    println!("[1/6] PAG + AFG static analysis");

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
    let ac_sigs = rail_rs::signature::load_signatures(ac)
        .map_err(|e| anyhow::anyhow!("failed to load AC catalog {}: {e}", ac.display()))?;
    let data_sigs = rail_rs::signature::load_signatures(data_access).map_err(|e| {
        anyhow::anyhow!("failed to load data-store catalog {}: {e}", data_access.display())
    })?;
    println!(
        "      catalogs: {} LLM, {} AC, {} data-store signatures",
        llm_sigs.len(),
        ac_sigs.len(),
        data_sigs.len()
    );
    analysis.set_context_catalogs(llm_sigs, ac_sigs, data_sigs);

    // Build the PAG (afg mode) and run the taint analysis.
    let engine = analysis.taint_analysis("afg", None);
    println!(
        "      taint analysis: app_crate={:?}, {} semantic points, {} principals, {} tagged nodes",
        engine.app_crate,
        engine.semantic_points.len(),
        engine.active_principals.len(),
        engine.node_contexts.len()
    );

    use rail_rs::taint_analysis::SemanticPointKind;
    let mut sites: Vec<InstrumentSite> = Vec::new();
    let (mut n_auth, mut n_access, mut n_credential, mut n_data) = (0usize, 0usize, 0usize, 0usize);

    // 1) Auth sites at access-control points; 2) Access sites at LLM calls.
    for point in engine.semantic_points.iter() {
        match &point.kind {
            SemanticPointKind::AccessControl { .. }
            | SemanticPointKind::AccessControlRecovery { .. } => {
                let matched = &point.security_point.matched_fn_name;
                // Only principal-establishing auth points get an afg_auth! site.
                // Credential checks (argon2/bcrypt password verifiers) authenticate
                // but do not name the user, so the principal is established at a
                // separate token / session / identity point.
                if !establishes_principal(matched) {
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

    let static_result = run_pag_and_afg(&cli.llvm_ir, &cli.llm_api, &cli.ac, &cli.data_access)?;
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
    instrument_project(
        &cli.project,
        &instrumented_project,
        &static_result.instrumentation_plan,
        &cli.afg_runtime,
    )?;

    if cli.instrument_only {
        println!(
            "instrument-only: wrote AFG-instrumented app to {}; run it yourself.",
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
                LeakVerdict::Reproduced { writer, reader, panode } => {
                    reproduced += 1;
                    println!(
                        "      schedule {i:03}: LEAK REPRODUCED ({writer} wrote PANode {panode}, then {reader} read it)"
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

    println!("AFG pipeline completed: {}", cli.run_dir.display());
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::{data_access_kind, establishes_principal};
    use afg_instrument::AccessKind;

    #[test]
    fn data_access_direction_from_category() {
        // A write puts data into the shared store; a read exposes it (the leak
        // direction). Unknown/generic categories are treated as reads.
        assert_eq!(data_access_kind("data-write"), AccessKind::Write);
        assert_eq!(data_access_kind("data-read"), AccessKind::Read);
        assert_eq!(data_access_kind("data-access"), AccessKind::Read);
    }

    #[test]
    fn credential_checks_are_not_principal_sources() {
        // Password / secret verifiers: authenticate, but do not name the user.
        assert!(!establishes_principal("argon2::PasswordVerifier::verify_password"));
        assert!(!establishes_principal("bcrypt::verify"));
    }

    #[test]
    fn token_and_identity_points_are_principal_sources() {
        // Token / session / identity points: their first argument names the user.
        assert!(establishes_principal("jsonwebtoken::decode"));
        assert!(establishes_principal("actix_identity::Identity::id"));
        assert!(establishes_principal("ldap3::Ldap::simple_bind"));
    }
}
