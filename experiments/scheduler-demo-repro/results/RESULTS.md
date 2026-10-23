# CRUX madsim rescheduler on the controlled demo (demo_dynamic)

This experiment runs CRUX's own scheduler (`crux_scheduler`) with madsim replay, to show
the rescheduler component end to end: it generates alternative interleavings and
reproduces a cross-user leak by forcing a write-then-read order on the shared node.
The four real-app targets (tabby, bionic, AppFlowy, zed) do not build under madsim, so
their schedule exploration used the app's native executor (zed) or a single run (the
others); this demo is where CRUX's own rescheduler is exercised.

Target: `rail-rs/examples/demo_dynamic` (bin `crux_dyn_demo`), a two-user madsim app.
Toolchain: rustc 1.85 / LLVM 19 (static producer applies). Run date 2026-09-23.

## The app and the leak

`demo_dynamic` is a two-user LLM service over one shared answer cache (main.rs). Each
request authenticates via `jsonwebtoken::decode`, then:

- cache miss: call the LLM, then WRITE the shared cache node (`CACHE_NODE = 5000`);
- cache hit: READ the shared cache node, and if the entry's owner is not the requester,
  serve another user's answer (the cross-user leak).

So the leak is a write-then-read on the same node (5000): user A's miss writes the
cache, user B's hit for the same prompt reads A's answer. Whether it fires depends on
the order of A's write and B's read, which is what the scheduler controls.

## What we did

Full CRUX pipeline with replay, driven by the `afg` producer binary:

```sh
# 1) emit LLVM IR for the demo (rustc 1.85)
cd rail-rs/examples/demo_dynamic
cargo +1.85.0 rustc --bin crux_dyn_demo -- --emit=llvm-ir -Cdebuginfo=2 -Ccodegen-units=1
LL=$(ls -t target/debug/deps/crux_dyn_demo-*.ll | head -1)

# 2) producer -> instrument -> madsim observe -> analyze -> generate schedules -> replay
cd ../../../crux
LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 ./target/debug/afg \
  --llvm-ir "../rail-rs/examples/demo_dynamic/$LL" \
  --project ../rail-rs/examples/demo_dynamic \
  --crux-runtime "$PWD/crux_runtime" \
  --llm-api ../rail-rs/signatures/llm_api_functions.json \
  --ac ../rail-rs/signatures/ac_functions.json \
  --data-access ../rail-rs/signatures/data_access_functions.json \
  --run-dir /tmp/afg_dyn --cargo-cmd run --seeds 1 --replay
```

The `[5/6] Generate schedules` stage calls `crux_scheduler::generate_schedules`, which
emits one candidate schedule (an ordered list of `{principal, site}` steps) per shared
PANode. The `[6/6] Replay` stage re-runs the instrumented app under madsim once per
schedule with `CRUX_SCHEDULE_PATH` set (which forces that order via the
`crux_schedule_point!` gate), then `crux_scheduler::verify_replay` decides whether a
non-owner read of a node its owner wrote actually occurred.

## What we found

Static: 3 semantic points, 1 auth and 1 llm-access instrumented (argon2's
`verify_password` is detected and skipped as the principal source; `decode` is the
principal). The scheduler generated 2 candidate interleavings, one per shared node:

| schedule | node | order | replay verdict |
|---|---|---|---|
| schedule-000 | 890 (LLM result) | alice then bob | not reproduced (890 is read by both, never written) |
| schedule-001 | 5000 (cache) | alice then bob | LEAK REPRODUCED (alice wrote 5000, then bob read it) |

```
replay verdict: 1/2 schedule(s) reproduced a cross-user leak
```

So CRUX's rescheduler reproduced the cross-user leak by forcing the write-then-read
order on the cache node. The reproducing schedule is schedule-001 (the second of the
two). Artifacts: `results/schedule/` (the two schedules), `results/verdict/` (the two
verdicts), `results/replay-001.jsonl` (the leaking replay trace).

Metrics (CRUX rescheduler, this demo):
- rescheduled interleavings generated: 2 (one per shared PANode).
- rescheduled interleavings that reproduced the leak: 1 (schedule-001, the cache node).
- reschedule-to-leak: 2 (the leak reproduced on the second schedule).
- per-replay wall time (built binary, madsim, 5 runs): best 21 ms, avg 23 ms, worst
  27 ms. Replaying both schedules to reproduce the leak is about 46 ms.

## How to reproduce

Prerequisites: rustc 1.85, LLVM 19 at `/opt/homebrew/opt/llvm@19`, the `afg` producer
built (`LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 cargo build --bin afg`), and the
demo's `crux_runtime` dependency pointing at `crux/crux_runtime`. Then run the
two commands above. To re-time one replay:

```sh
cd /tmp/afg_dyn/instrumented
RUSTFLAGS="--cfg madsim" MADSIM_TEST_SEED=1 \
  CRUX_SCHEDULE_PATH=/tmp/afg_dyn/schedule/schedule-001.json \
  CRUX_TRACE_PATH=/tmp/replay.jsonl cargo +1.85.0 run
```

## What to expect

- `instrumentation sites: 1 auth, 1 llm-access, 2 total`.
- 2 schedules under `/tmp/afg_dyn/schedule/` (one for node 890, one for node 5000).
- `schedule 000: not reproduced`; `schedule 001: LEAK REPRODUCED (alice wrote PANode
  5000, then bob read it)`; `replay verdict: 1/2 schedule(s) reproduced a cross-user
  leak`.
- `verdict-001.json` records `{"verdict":"reproduced","writer":"alice","reader":"bob","panode":5000}`.
- Each replay is a madsim run of about 23 ms on a built binary.

## How this relates to the real-app results

- On zed (a real app with a native deterministic executor) the schedule-dependent leak
  was found by sweeping the app's own scheduler; CRUX's madsim rescheduler was not used
  there because gpui does not build under madsim.
- The four real-app targets are Tokio or gpui based and do not build under madsim, so
  this controlled demo is where CRUX's rescheduler is exercised directly. It confirms
  the rescheduler generates alternative interleavings and reproduces a write-then-read
  cross-user leak by forcing the order, with a concrete reschedule-to-leak count and
  per-replay time.

## Note on the mini-chat-service demo

`rail-rs/examples/mini-chat-service` was also run through the pipeline. Its leak is a
read-read cache overlap (both users read the same cached answer), so the runtime
`crux_leak!` fires ("bob served a cached answer owned by alice") but the write-then-read
replay verdict does not reproduce (the instrumented node is read by both, never
written): `replay verdict: 0/1`. demo_dynamic is the demo whose instrumented shared
node carries an explicit write and read, which is why its replay reproduces.
