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
    #[arg(long)]
    project: PathBuf,

    #[arg(long)]
    llvm_ir: PathBuf,

    #[arg(long, default_value = "runs/latest")]
    run_dir: PathBuf,

    #[arg(long, default_value_t = 3)]
    seeds: u64,

    #[arg(long, default_value_t = 1)]
    seed_start: u64,

    #[arg(long, default_value_t = false)]
    replay: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct StaticStageResult {
    instrumentation_plan: InstrumentationPlan,
}

/// Adapter between this prototype and our existing ll_parser + nested afg-engine.
fn run_pag_and_afg(llvm_ir: &Path) -> Result<StaticStageResult> {
    println!("[1/6] PAG + AFG static analysis");
    println!("      LLVM IR: {}", llvm_ir.display());

    // TODO: call our pag and afg_engine here

    let instrumentation_plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 1,
            panode: 1308,
            function_id: Some(210),
            site_id: 401,
            access: AccessKind::Read,
            reason: "prototype-placeholder".into(),
        }],
    };

    Ok(StaticStageResult {
        instrumentation_plan,
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

    let static_result = run_pag_and_afg(&cli.llvm_ir)?;
    fs::write(
        cli.run_dir.join("static/instrumentation.json"),
        serde_json::to_string_pretty(&static_result.instrumentation_plan)?,
    )?;

    println!("[2/6] Source instrumentation");
    let instrumented_project = cli.run_dir.join("instrumented/app");
    instrument_project(
        &cli.project,
        &instrumented_project,
        &static_result.instrumentation_plan,
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
