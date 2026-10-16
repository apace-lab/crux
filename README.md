# CRUX - Cross-User Interleaving Examination

CRUX detects and reproduces **cross-user data leaks** in async Rust services: cases
where one principal's request can read data written by another principal
through a shared store, cache, database or LLM context. It combines a static stage
over LLVM IR via [rail-rs](https://github.com/apace-lab/RAIL.git) that runs PSA
(Principal-Sensitive Analysis) and ACE (Access-Control Enforcement)
with dynamic, deterministic observation on [MadSim](https://github.com/madsim-rs/madsim),
then runs R4 (Runtime-preserving Record/Replay/Rescheduling) and the scheduler (Cross-User
Interleaving Exploration) to confirm a leak actually occurs.

See [`experiments/tabby-repro/README.md`](experiments/tabby-repro/README.md)
for an end-to-end run against a real ~45k-LOC app
([TabbyML/tabby](https://github.com/TabbyML/tabby)) that reproduces a genuine
cross-user leak.

## Directory layout

[rail-rs](https://github.com/apace-lab/RAIL.git) is checked out next to this repo and referenced by relative path:

```text
parent/
├── rail-rs/                 # https://github.com/apace-lab/RAIL.git
├── crux/            # this repo
│   ├── Cargo.toml             # rail-rs = { path = "../rail-rs" }
│   └── src/main.rs            # the `crux` CLI
└── my-app/                  # the app crux analyzes/instruments 
```

## CRUX pipeline and major commands

```text
LLVM IR
  -> rail-rs PAG + PSA/ACE (auth points, LLM calls, data-store access,
     static cross-user overlaps)                                [PSA + ACE]
  -> InstrumentationPlan
  -> source instrumentation (inserts crux_auth! / crux_monitor! / crux_access!
     / crux_schedule_point! at the flagged sites)                [R4: crux_instrument]
  -> MadSim observation, N deterministic seeds                  [R4: crux_runtime]
  -> per-principal scopes + cross-user overlap detection        [crux_observe]
  -> schedule generation (e.g., writer-before-reader orderings) [the scheduler: crux_scheduler]
  -> optional replay against a schedule -> leak verdict         [crux_dashboard]
```

By default `crux` runs the whole pipeline end to end. Two flags are designed to stop the pipeline at certain stage:

- `--static-only` - run just the first stage (PAG + PSA/ACE) and write
  `instrumentation.json`, then stop. For apps whose source isn't available
  to instrument (e.g. analyzing a compiled real-world app).
- `--instrument-only` - run the static stage *and* source instrumentation,
  write the instrumented app, then stop before running via MadSim. For apps you'll run
  yourself outside MadSim (e.g. a live server on real tokio).

Without either flag, `crux` continues past instrumentation into MadSim
observation, scope/overlap analysis, and schedule generation; `--replay`
additionally executes the generated schedules and reports a leak verdict.

## Repo layout

| Crate | Role |
|---|---|
| [`src/`](src) (`crux`) | CLI driving the whole pipeline (see below) |
| [`crux_instrument/`](crux_instrument) | R4: turns an `InstrumentationPlan` into source edits (currently line-based, see limitations) |
| [`crux_observe/`](crux_observe) | Runs the app under MadSim, parses JSONL traces into per-principal scopes and overlaps (the leak oracle) |
| [`crux_scheduler/`](crux_scheduler) | the scheduler: generates writer/reader schedules from overlaps and verifies replays |
| [`crux_runtime/`](crux_runtime) | R4: runtime crate the instrumented app depends on: `crux_auth!`, `crux_monitor!`, `crux_access!`, `crux_schedule_point!` ([details](crux_runtime/README.md)) |
| [`crux_dashboard/`](crux_dashboard) | Standalone web console: tails a trace or a finished run-dir and shows scopes/overlaps/schedules/verdicts |
| [`examples/example-app/`](examples/example-app) | Minimal two-principal app instrumented by hand against `crux_runtime` ([details](examples/example-app/README.md)) |
| [`experiments/tabby-repro/`](experiments/tabby-repro) | Reproduction kit running CRUX against a real-world app (TabbyML/tabby) |

`crux_instrument`, `crux_observe`, and `crux_scheduler` are path dependencies of
the top-level `crux` package; `crux_runtime` and `crux_dashboard` are separate
crates built/run on their own.

## Config and build

Add the absolute path of your `crux/crux_runtime` to `my-app/Cargo.toml` as a dependency: 
```toml 
[dependencies]
crux_runtime = { path = "$PATH-TO-YOUR/crux/crux_runtime" }
```

then run: 
```bash
rustup override set 1.85.0
cargo build
```

## One-command run

```bash
cargo run -- \
  --project ../my-app \
  --llvm-ir ../my-app/target/llvm/my-app.ll \
  --run-dir runs/test-001 \ 
  --seeds 10 \
  --seed-start 1
```

With generated-schedule replay:

```bash
cargo run -- \
  --project ../my-app \
  --llvm-ir ../my-app/target/llvm/my-app.ll \
  --run-dir runs/test-001 \
  --seeds 10 \
  --seed-start 1 \
  --replay
```

Useful flags are (`cargo run -- --help` for the full list):

- `--llvm-ir` - repeatable, for a multi-module app (e.g. lib + bin)
- `--llm-api` / `--ac` / `--data-access` - signature catalogs, default to
  `../rail-rs/signatures/*.json`
- `--crux-runtime` - path to the `crux_runtime` crate added to the instrumented app
- `--static-only` - stop after the static stage (no source needed)
- `--instrument-only` - stop after instrumenting (no MadSim observe/replay)
- `--cargo-cmd` - cargo subcommand the observe stage runs (`test` or `run`)

## Expected output structure

```text
runs/test-001/
├── static/instrumentation.json
├── instrumented/app/
├── observe/
│   ├── seed-1.jsonl
│   ├── seed-2.jsonl
│   └── scopes.json
├── schedule/
│   └── schedule-000.json
└── result/
    ├── replay-000.jsonl
    └── verdict-000.json
```

## Dashboard

`crux_dashboard` serves a browser console over any trace file or run-dir
produced above, including events, per-principal scopes, overlaps, schedules, replay
verdicts, and any app-reported leaks:

```bash
cd crux_dashboard
cargo run -- --run-dir ../runs/test-001   # or: --trace path/to/trace.jsonl
# http://127.0.0.1:8090
```


## Example demo

[afg-demo](https://github.com/sanjib-sen/afg-demo) is a companion repo: a
runnable multi-user chat service with real login and LLM integration, run live
on real `tokio` (not MadSim). Its [`run.sh`](https://github.com/sanjib-sen/afg-demo/blob/main/run.sh) script
drives the whole thing end to end - see its README for the full walkthrough.

To be specific, `crux --instrument-only` finds and instruments its
auth check and LLM call automatically; the app's own shared answer cache is
what turns one user's cached answer into another user's leak. A built-in admin
console shows the live trace, per-principal scopes, and detected overlaps via our dashboard.



## Important prototype limitation

The source rewriter in `crux_instrument` is line-based; it demonstrates the
orchestration interface but is not syntax-aware. It currently does not insert
`crux_schedule_point!(...).await` correctly inside multi-line method chains
(see the known limitation in
[`experiments/tabby-repro/README.md`](experiments/tabby-repro/README.md)).
A syntax-aware Rust rewriter is needed before instrumenting arbitrary
real-world async code automatically.
