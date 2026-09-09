# AFG Observer prototype

A source-level runtime observation layer for AFG + MadSim.

## Fixed toolchain

- rustc 1.85.0
- `madsim = 0.2.31`
- `madsim-tokio = 0.2.30`

## Runtime primitives

- `afg_auth!`: establishes principal/auth metadata in task-local AFG context and logs it.
- `afg_monitor!`: records function-scope execution.
- `afg_access!`: records access to a static `PANodeId`; no runtime address mapping.
- `afg_schedule_point!`: optional cooperative event gate above MadSim.

## Run in observation-only mode

```bash
AFG_TRACE_PATH=afg-events.jsonl \
MADSIM_TEST_SEED=12345 \
RUSTFLAGS="--cfg madsim" \
cargo run -p example-app
```

## Run with an AFG event ordering

```bash
AFG_TRACE_PATH=afg-events.jsonl \
AFG_SCHEDULE_PATH=schedule.json \
MADSIM_TEST_SEED=12345 \
RUSTFLAGS="--cfg madsim" \
cargo run -p example-app
```

The schedule file constrains AFG-visible application events, not MadSim's internal task polling decisions.

## Static-analysis integration

The static AFG produces stable IDs such as `PANodeId`, `FunctionId`, and `PACallSiteId`. The source instrumentation phase inserts those IDs directly into macros. Therefore the runtime never needs to map concrete addresses back to PANodes.
