# AFG Observer prototype

A source-level runtime observation layer for AFG + MadSim. Instrumented apps
depend on this crate and call its macros at the auth/monitor/access/schedule
sites `afg_instrument` inserts; see the [top-level README](../README.md) for
where this fits in the AFG pipeline, and
[`examples/example-app`](../examples/example-app) for a minimal, hand-instrumented
app built against it (with run commands).

## Fixed toolchain

- rustc 1.85.0
- `madsim = 0.2.31`
- `madsim-tokio = 0.2.30`

## Runtime primitives

- `afg_auth!`: establishes principal/auth metadata in task-local AFG context and logs it.
- `afg_monitor!`: records function-scope execution.
- `afg_access!`: records access to a static `PANodeId`; no runtime address mapping.
- `afg_schedule_point!`: optional cooperative event gate above MadSim.
- `afg_leak!`: optional, app-reported domain-level leak ("this principal was
  served `owner`'s data"). Purely additive -- apps that don't call it just
  produce no `Leak` events, and detection falls back to AFG-derived overlaps.

## Environment variables

- `AFG_TRACE_PATH`: JSONL trace output path (default `afg-events.jsonl`).
- `AFG_SCHEDULE_PATH`: optional replay schedule (a JSON `Vec<ScheduleStep>`);
  unset means observation-only.
- `AFG_SCHEDULE_MAX_SPINS`: cap on cooperative-yield retries at a schedule
  gate before it gives up and proceeds ungated (default `10000`), so a
  divergent replay path can't hang the run forever.
- `MADSIM_TEST_SEED`: MadSim's deterministic seed; also recorded on every
  trace event.

For an app with only one real principal, the scheduler can synthesize a
second one (`SYNTHETIC_PRINCIPAL`, i.e. `afg-synthetic`) to test a leak; an
app can check `schedule_contains_principal("afg-synthetic")` to know whether
to inject that synthetic user, since the check is only true during such a
replay, not during plain observation.

## Static-analysis integration

The static AFG produces stable IDs such as `PANodeId`, `FunctionId`, and `PACallSiteId`. The source instrumentation phase inserts those IDs directly into macros. Therefore the runtime never needs to map concrete addresses back to PANodes.
