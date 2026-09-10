# AFG prototype

Expected project structure:

```text
parent/
├── rail-rs/
│   └── src/
│       └── taint_analysis.rs
└── afg/
    ├── Cargo.toml
    ├── src/main.rs // take user commands
    ├── afg_instrument/
    ├── afg_observe/
    └── afg_scheduler/
```

`afg/Cargo.toml` uses:

```toml
rail-rs = { path = "../rail-rs" }
```

This project uses (rail-rs)[https://github.com/apace-lab/ll_parser.git] as dependency for static taint analysis, where the `taint_analysis` module generates the taint results from running pointer analysis by `rail-rs`.

## Pipeline

```text
LLVM IR
  -> rail-rs PAG
    -> run taint analysis together
  -> afg_instrument
    -> create InstrumentationPlan
    -> instrument app
  -> afg_observe
    -> MadSim observation
    -> per-principal PANode/function scopes
  -> afg_scheduler
    -> schedule JSON
  -> optional replay
```

## Integration point

Edit only `run_pag_and_afg()` in `src/main.rs`.

Replace the placeholder plan with our APIs, e.g., the `main.rs` in `rail-rs`:

The prototype intentionally does not invent public API names from our code in `rail-rs`.

## Build

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
    └── replay-000.jsonl
```

## Important prototype limitation

The source rewriter is line-based. It only demonstrates the orchestration interface.
Before inserting `afg_schedule_point!(...).await`, switch to a syntax-aware Rust rewriter,
because schedule points must be inserted in valid async contexts.

The target application's runtime layer is expected to provide `afg_monitor!`,
`afg_access!`, `afg_auth!`, `afg_schedule_point!`, and JSONL logging to
`AFG_TRACE_PATH`.
