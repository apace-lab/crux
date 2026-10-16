# example-app

A minimal, two-principal demo app used to exercise [`crux_r4_runtime`](../../crux_r4_runtime)
directly. It depends on `crux_r4_runtime`, not the other way around, and it is
**hand-instrumented**: the `crux_auth!` / `crux_monitor!` / `crux_schedule_point!`
/ `crux_access!` calls in [`src/main.rs`](src/main.rs) are written by hand to
show what the `crux` pipeline's source-instrumentation step would otherwise
insert automatically. It is not run through the `crux` CLI itself.

## What it does

Two tasks share one in-memory cache behind a single `PANodeId`
(`NODE_SHARED_CACHE`):

- `alice` authenticates, then writes her chat prompt into the shared cache
  (`chat_write`).
- `bob` authenticates separately, then reads from the same shared cache
  (`chat_read`).

Because both principals hit the same node, this is the toy case CRUX is meant
to catch: bob's read can observe alice's write, i.e. a cross-user leak
through a shared store. Running it under `crux_r4_runtime` produces a JSONL trace
of both principals' auth/monitor/access/schedule events, which is what
`crux_observe`/`crux_cuie` (or the dashboard) consume to detect and
schedule that overlap.

## Config

Add the absolute path of your `afg_prototype/crux_r4_runtime` to `crux-demp/Cargo.toml`. 

## Run in observation-only mode

```bash
cd examples/example-app
CRUX_TRACE_PATH=crux-events.jsonl \
MADSIM_TEST_SEED=12345 \
RUSTFLAGS="--cfg madsim" \
cargo run
```

This just records the trace; alice and bob run in whatever order MadSim's
scheduler happens to pick for that seed.

## Run with an CRUX event ordering

```bash
cd examples/example-app
CRUX_TRACE_PATH=crux-events.jsonl \
CRUX_SCHEDULE_PATH=schedule.json \
MADSIM_TEST_SEED=12345 \
RUSTFLAGS="--cfg madsim" \
cargo run
```

`schedule.json` (a `Vec<ScheduleStep>`, e.g. produced by `crux_cuie`)
forces alice's write before bob's read at their `crux_schedule_point!` sites,
to deterministically confirm the leak rather than relying on MadSim to pick
that interleaving by chance. See [`crux_r4_runtime`'s README](../../crux_r4_runtime/README.md)
for the primitives and env vars this app is built on, and the
[top-level README](../../README.md) for how this fits into the full
static-analysis + instrumentation + replay pipeline.
