use anyhow::{Context, Result};
use clap::Parser;
use serde::{Deserialize, Serialize};
use std::{
    fs,
    path::{Path, PathBuf},
};

use afg_instrument::{instrument_project, AccessKind, InstrumentSite, InstrumentationPlan};
use afg_observe::{analyze_traces, run_observation, ObservationConfig, ObservationResult};
use afg_scheduler::{generate_schedules, write_schedule};

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
    #[arg(long, default_value = "../ll_parser/signatures/llm_api_functions.json")]
    llm_api: PathBuf,

    /// Access-control signature catalog (JSON)
    #[arg(long, default_value = "../ll_parser/signatures/ac_functions.json")]
    ac: PathBuf,

    /// Path to the afg-runtime crate, added as a dependency to the instrumented app
    #[arg(long, default_value = "../afg_observer/afg-runtime")]
    afg_runtime: PathBuf,

    #[arg(long, default_value = "runs/latest")]
    run_dir: PathBuf,

    #[arg(long, default_value_t = 3)]
    seeds: u64,

    #[arg(long, default_value_t = 1)]
    seed_start: u64,

    #[arg(long, default_value_t = false)]
    replay: bool,

    /// Run only the static stage (PAG + AFG engine + overlap detection) and
    /// stop after writing the instrumentation plan. Use this on a compiled
    /// real-world app when its source is not available for instrumentation.
    #[arg(long, default_value_t = false)]
    static_only: bool,
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

/// Adapter between this prototype and our existing ll_parser + nested afg-engine.
///
/// Parses the LLVM IR, runs the PAG + AFG engine, and turns the cross-user
/// overlaps (PANodes reached by two or more distinct principals) into an
/// `InstrumentationPlan`. Tolerant of zero overlaps: emits an empty plan until
/// the engine's principal propagation produces data.
fn run_pag_and_afg(llvm_ir: &[PathBuf], llm_api: &Path, ac: &Path) -> Result<StaticStageResult> {
    use std::collections::HashSet;

    println!("[1/6] PAG + AFG static analysis");

    // Parse the module(s) and set up the cross-module analysis.
    let mut modules = Vec::with_capacity(llvm_ir.len());
    for path in llvm_ir {
        println!("      LLVM IR: {}", path.display());
        let module = ll_parser::llvm_ir::Module::from_ir_path(path)
            .map_err(|e| anyhow::anyhow!("failed to parse LLVM IR {}: {e}", path.display()))?;
        modules.push(module);
    }
    let mut analysis = ll_parser::CrossModuleAnalysis::new(modules.iter());

    // Load the signature catalogs so the PAG records semantic (LLM/AC) points.
    let llm_sigs = ll_parser::signature::load_signatures(llm_api)
        .map_err(|e| anyhow::anyhow!("failed to load LLM catalog {}: {e}", llm_api.display()))?;
    let ac_sigs = ll_parser::signature::load_signatures(ac)
        .map_err(|e| anyhow::anyhow!("failed to load AC catalog {}: {e}", ac.display()))?;
    println!(
        "      catalogs: {} LLM, {} AC signatures",
        llm_sigs.len(),
        ac_sigs.len()
    );
    analysis.set_context_catalogs(llm_sigs, ac_sigs);

    // Build the PAG (afg mode) and run the AFG engine.
    let engine = analysis.afg_engine("afg", None);
    println!(
        "      afg engine: app_crate={:?}, {} semantic points, {} principals, {} tagged nodes",
        engine.app_crate,
        engine.semantic_points.len(),
        engine.active_principals.len(),
        engine.node_contexts.len()
    );

    // A cross-user overlap is a PANode whose context set carries two or more
    // distinct principals (by auth callsite). Map each to an InstrumentSite.
    let mut sites: Vec<InstrumentSite> = Vec::new();
    for (node_id, ctxs) in engine.node_contexts.iter() {
        let principals: HashSet<usize> = ctxs
            .iter()
            .filter_map(|e| match e {
                ll_parser::PAContextElem::Principal { auth_callsite } => Some(*auth_callsite),
                _ => None,
            })
            .collect();
        if principals.len() < 2 {
            continue;
        }

        // We can only instrument a node that has a source location.
        let Some(node) = engine.nodes.get(node_id) else {
            continue;
        };
        let Some(loc) = node.source_loc.as_ref() else {
            continue;
        };
        let (Some(file), Some(line)) = (loc.file.clone(), loc.line) else {
            continue;
        };

        // Gap 2: normalize to a project-relative path. LLVM debug `file` is
        // usually already relative (e.g. "src/foo.rs"); strip any "./" or
        // leading slash so it joins cleanly under the instrumented project.
        let rel_file = file
            .trim_start_matches("./")
            .trim_start_matches('/')
            .to_string();

        // Gap 3: real function_id (stable hash of the enclosing function) and a
        // distinct site_id (the PANode id). Access defaults to Read; per-site
        // read/write refinement needs per-access (load/store) instrumentation.
        let function_id = node.function().map(hash_fn_id);

        sites.push(InstrumentSite {
            file: rel_file.into(),
            line: line as usize,
            panode: *node_id as u64,
            function_id,
            site_id: *node_id as u64,
            access: AccessKind::Read,
            reason: format!("cross-user overlap ({} principals)", principals.len()),
        });
    }

    println!("      cross-user overlap sites: {}", sites.len());
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

    let static_result = run_pag_and_afg(&cli.llvm_ir, &cli.llm_api, &cli.ac)?;
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
            cargo_args: vec!["test".into()],
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
        for i in 0..schedules.len() {
            run_observation(&ObservationConfig {
                project_dir: instrumented_project.clone(),
                seed: cli.seed_start,
                trace_path: cli
                    .run_dir
                    .join("result")
                    .join(format!("replay-{i:03}.jsonl")),
                schedule_path: Some(
                    cli.run_dir
                        .join("schedule")
                        .join(format!("schedule-{i:03}.json")),
                ),
                cargo_args: vec!["test".into()],
            })?;
        }
    } else {
        println!("      replay disabled; add --replay to execute generated schedules");
    }

    println!("AFG pipeline completed: {}", cli.run_dir.display());
    Ok(())
}
