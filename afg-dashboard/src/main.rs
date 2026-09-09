// A reusable AFG dashboard: one console for every example.
//
// It connects to an app/example purely through files (no coupling to app code):
//   --trace <file.jsonl>  a live AFG trace to tail (a running service)
//   --run-dir <dir>       a finished pipeline run (observe/*.jsonl + result/verdict-*.json)
//
// It runs the real `afg_observe::analyze_traces` + `afg_scheduler::generate_schedules`
// over the trace(s) and serves a browser console showing events, per-principal
// scopes, cross-user overlaps, schedules, any replay verdicts, and any optional
// app-reported leaks (afg-runtime `Leak` events).
use std::path::{Path, PathBuf};

use anyhow::{bail, Result};
use axum::{extract::State, response::Html, routing::get, Json, Router};
use clap::Parser;
use serde::Serialize;
use std::sync::Arc;

use afg_observe::analyze_traces;
use afg_scheduler::generate_schedules;

#[derive(Parser, Debug)]
#[command(name = "afg-dashboard")]
struct Cli {
    /// A live AFG trace file (JSONL) to tail.
    #[arg(long, conflicts_with = "run_dir")]
    trace: Option<PathBuf>,

    /// A pipeline run dir (reads observe/*.jsonl and result/verdict-*.json).
    #[arg(long)]
    run_dir: Option<PathBuf>,

    #[arg(long, default_value_t = 8090)]
    port: u16,
}

struct Source {
    traces: Vec<PathBuf>,
    run_dir: Option<PathBuf>,
    label: String,
}

fn resolve(cli: &Cli) -> Result<Source> {
    if let Some(trace) = &cli.trace {
        return Ok(Source {
            traces: vec![trace.clone()],
            run_dir: None,
            label: format!("live trace: {}", trace.display()),
        });
    }
    if let Some(dir) = &cli.run_dir {
        let observe = dir.join("observe");
        let mut traces: Vec<PathBuf> = Vec::new();
        if let Ok(entries) = std::fs::read_dir(&observe) {
            for e in entries.flatten() {
                let p = e.path();
                if p.extension().and_then(|x| x.to_str()) == Some("jsonl") {
                    traces.push(p);
                }
            }
        }
        traces.sort();
        return Ok(Source {
            traces,
            run_dir: Some(dir.clone()),
            label: format!("run dir: {}", dir.display()),
        });
    }
    bail!("provide --trace <file.jsonl> or --run-dir <dir>");
}

#[derive(Serialize)]
struct Event {
    seq: u64,
    kind: String,
    principal: String,
    node: Option<u64>,
    site: Option<u64>,
    function_id: Option<u64>,
    file: Option<String>,
    line: Option<u64>,
    owner: Option<String>,
    detail: Option<String>,
}

#[derive(Serialize)]
struct LeakItem {
    reader: String,
    owner: String,
    detail: String,
}

#[derive(Serialize)]
struct AfgState {
    source: String,
    events: Vec<Event>,
    principals: Vec<String>,
    scopes: serde_json::Value,
    overlaps: serde_json::Value,
    schedules: serde_json::Value,
    leaks: Vec<LeakItem>,
    verdicts: serde_json::Value,
}

fn read_events(paths: &[PathBuf]) -> Vec<Event> {
    let mut out = Vec::new();
    for path in paths {
        let Ok(text) = std::fs::read_to_string(path) else {
            continue;
        };
        for line in text.lines() {
            if line.trim().is_empty() {
                continue;
            }
            let Ok(v) = serde_json::from_str::<serde_json::Value>(line) else {
                continue;
            };
            let s = |k: &str| v.get(k).and_then(|x| x.as_str()).map(|x| x.to_string());
            let u = |k: &str| v.get(k).and_then(|x| x.as_u64());
            out.push(Event {
                seq: u("seq").unwrap_or(0),
                kind: s("event").unwrap_or_default(),
                principal: s("principal").unwrap_or_else(|| "?".into()),
                node: u("node"),
                site: u("site"),
                function_id: u("function_id"),
                file: s("file"),
                line: u("line"),
                owner: s("owner"),
                detail: s("detail"),
            });
        }
    }
    out
}

fn read_verdicts(run_dir: &Path) -> serde_json::Value {
    let result = run_dir.join("result");
    let mut verdicts: Vec<serde_json::Value> = Vec::new();
    if let Ok(entries) = std::fs::read_dir(&result) {
        let mut files: Vec<PathBuf> = entries
            .flatten()
            .map(|e| e.path())
            .filter(|p| {
                p.file_name()
                    .and_then(|n| n.to_str())
                    .map(|n| n.starts_with("verdict-") && n.ends_with(".json"))
                    .unwrap_or(false)
            })
            .collect();
        files.sort();
        for f in files {
            if let Ok(text) = std::fs::read_to_string(&f) {
                if let Ok(v) = serde_json::from_str::<serde_json::Value>(&text) {
                    verdicts.push(v);
                }
            }
        }
    }
    serde_json::Value::Array(verdicts)
}

async fn afg_state(State(src): State<Arc<Source>>) -> Json<AfgState> {
    let obs = analyze_traces(&src.traces).unwrap_or_default();
    let schedules = generate_schedules(&obs, 20);
    let events = read_events(&src.traces);

    let leaks: Vec<LeakItem> = events
        .iter()
        .filter(|e| e.kind == "leak")
        .map(|e| LeakItem {
            reader: e.principal.clone(),
            owner: e.owner.clone().unwrap_or_default(),
            detail: e.detail.clone().unwrap_or_default(),
        })
        .collect();

    let verdicts = src
        .run_dir
        .as_ref()
        .map(|d| read_verdicts(d))
        .unwrap_or_else(|| serde_json::Value::Array(vec![]));

    Json(AfgState {
        source: src.label.clone(),
        events,
        principals: obs.principals.keys().cloned().collect(),
        scopes: serde_json::to_value(&obs.principals).unwrap_or_default(),
        overlaps: serde_json::to_value(&obs.overlaps).unwrap_or_default(),
        schedules: serde_json::to_value(&schedules).unwrap_or_default(),
        leaks,
        verdicts,
    })
}

async fn index() -> Html<&'static str> {
    Html(include_str!("../static/console.html"))
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    let src = Arc::new(resolve(&cli)?);

    let router = Router::new()
        .route("/", get(index))
        .route("/afg", get(afg_state))
        .with_state(src.clone());

    let addr = format!("127.0.0.1:{}", cli.port);
    let listener = tokio::net::TcpListener::bind(&addr).await?;
    println!("AFG dashboard on http://{addr}  ({})", src.label);
    axum::serve(listener, router).await?;
    Ok(())
}
