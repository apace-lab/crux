# example-app

A minimal, two-principal demo app used to exercise [`afg_runtime`](../../afg_runtime)
directly. It depends on `afg_runtime`, not the other way around, and it is
**hand-instrumented**: the `afg_auth!` / `afg_monitor!` / `afg_schedule_point!`
/ `afg_access!` calls in [`src/main.rs`](src/main.rs) are written by hand to
show what the `afg` pipeline's source-instrumentation step would otherwise
insert automatically. It is not run through the `afg` CLI itself.

## What it does

Two tasks share one in-memory cache behind a single `PANodeId`
(`NODE_SHARED_CACHE`):

- `alice` authenticates, then writes her chat prompt into the shared cache
  (`chat_write`).
- `bob` authenticates separately, then reads from the same shared cache
  (`chat_read`).

Because both principals hit the same node, this is the toy case AFG is meant
to catch: bob's read can observe alice's write, i.e. a cross-user leak
through a shared store. Running it under `afg_runtime` produces a JSONL trace
of both principals' auth/monitor/access/schedule events, which is what
`afg_observe`/`afg_scheduler` (or the dashboard) consume to detect and
schedule that overlap.

## Config

Add the absolute path of your `afg_prototype/afg_runtime` to `afg-demp/Cargo.toml`. 

## Run in observation-only mode

```bash
cd examples/example-app
AFG_TRACE_PATH=afg-events.jsonl \
MADSIM_TEST_SEED=12345 \
RUSTFLAGS="--cfg madsim" \
cargo run
```

This just records the trace; alice and bob run in whatever order MadSim's
scheduler happens to pick for that seed.

## Run with an AFG event ordering

```bash
cd examples/example-app
AFG_TRACE_PATH=afg-events.jsonl \
AFG_SCHEDULE_PATH=schedule.json \
MADSIM_TEST_SEED=12345 \
RUSTFLAGS="--cfg madsim" \
cargo run
```

`schedule.json` (a `Vec<ScheduleStep>`, e.g. produced by `afg_scheduler`)
forces alice's write before bob's read at their `afg_schedule_point!` sites,
to deterministically confirm the leak rather than relying on MadSim to pick
that interleaving by chance. See [`afg_runtime`'s README](../../afg_runtime/README.md)
for the primitives and env vars this app is built on, and the
[top-level README](../../README.md) for how this fits into the full
static-analysis + instrumentation + replay pipeline.
