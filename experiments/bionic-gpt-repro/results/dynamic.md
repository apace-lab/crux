# bionic-gpt Phase 2: instrumented-from-source dynamic run (2026-09-16)

## What this shows

The real bionic-gpt `web-server`, **built from source** against the **live
Postgres**, **instrumented at the sites AFG cares about**, run with **two real
users** through the **real HTTP request path**, produces an AFG trace whose
resource-linked verdict is **no leak**. This is the positive-control side of the
dynamic pipeline: the shared-store access is dominated by an ownership check, so
even though both principals reach the same PANode, no cross-user data flows.

The same analyzer flags a tabby-shape trace (unscoped read that returns rows) as
a leak, so the no-leak verdict on bionic is a real discrimination, not a blind
pass.

## Build (real bionic build environment)

Built in bionic's own devcontainer image, arm64, on the live DB network:

- image `purtontech/rust-on-nails-devcontainer:1.3.46` (arm64), rustc 1.97.1
- `CARGO_TARGET_DIR` on a docker volume (fast native fs; the macOS bind mount is
  slow for cargo)
- `DATABASE_URL` / `APP_DATABASE_URL` -> the live `bionic-gpt` DB on the
  `infra-as-code_default` network, so cornucopia's compile-time `query`
  introspection and typecheck run against the real schema
- `cargo build --bin web-server` (baseline built clean in ~90s; the instrumented
  rebuild was incremental, ~18s)

## Instrumentation (real source, AFG probe)

A small probe module was added to the real web-server crate and called at the
three sites AFG flags. It emits the exact AFG JSONL trace schema afg_observe
consumes, reading the principal explicitly from the request's `Jwt` (which axum
already threads into every handler), so no task-local middleware is needed and
the trace is correct under real multi-threaded axum.

Files touched (real bionic source):

- `crates/web-server/afg_probe.rs` (new): trace writer; `auth()` and `access()`.
  `access` records the resource INSTANCE (`conversation:<id>`) and the rows the
  access yielded, keyed to PANode `7100` (the shared `llm.chats` store).
- `crates/web-server/main.rs`: `pub mod afg_probe;`
- `crates/web-server/jwt.rs`: `afg_probe::auth(sub, "jwt")` at both points where a
  `Jwt` is established (the real reverse-proxy auth path).
- `crates/web-server/handlers/console/send_message.rs`: after the chat insert,
  `afg_probe::access(WRITE, conversation:<id>, count=1)`.
- `crates/web-server/handlers/console/conversation.rs`: after the chats fetch,
  `afg_probe::access(READ, conversation:<id>, count=chats.len())`.

## Run (two real users, real request path)

Instrumented binary run on the DB network with `DANGER_JWT_OVERRIDE` unset (so
real `X-Forwarded-User` / `X-Forwarded-Email` auth is exercised), `AFG_TRACE_PATH`
set. Then:

1. alice `POST /o/gbHJdm/send_message` (message `ALICE_PHASE2_SECRET`) -> creates
   `conversation:2`.
2. alice `GET /o/gbHJdm/console/2` (own read) -> 200.
3. bob `GET /o/EfhxLZ/console/2` (bob's team, alice's conversation id) -> 200.

HTTP content matched the trace exactly: alice's page contained
`ALICE_PHASE2_SECRET` (1 hit), bob's did not (0 hits).

## Trace (produced by the real instrumented app)

`results/trace.jsonl`:

```
auth   principal=alice-sub
access WRITE node=7100 resource=conversation:2 count=1   send_message.rs:139
auth   principal=alice-sub
access READ  node=7100 resource=conversation:2 count=1   conversation.rs:38
auth   principal=bob-sub
access READ  node=7100 resource=conversation:2 count=0   conversation.rs:38
```

## Verdict (afg_observe)

`cargo run --example analyze -- results/trace.jsonl`:

```
coarse PANode overlaps (static-style signal): 1
  alice-sub <-> bob-sub on nodes {7100}

resource-linked leak verdict: 0 confirmed leak(s)
  none: every cross-principal read of a shared instance returned no rows
        (dominated by an ownership check)
```

The coarse overlap (both principals reach node 7100) is the static-style signal
that alone would false-positive. The **resource-linked verdict** refines it: bob
read the same instance (`conversation:2`) alice owns, but was served 0 rows, so
no data flowed. Positive control confirmed.

Negative control (`results/negative_control_trace.jsonl`, tabby shape, illustr.):
same coarse overlap on node 7100, but the verdict is **1 confirmed leak** (bob
served 3 rows of alice's `thread:9`). Same analyzer, opposite verdict, driven
purely by whether the cross-principal read returned data.

## New AFG machinery this required

The per-instance verdict is the resource-linked refinement (Option A):

- `afg_runtime`: `Event::Access` gained optional `resource` and `count`;
  `access_resource()` and `afg_access!(... resource=, count=)`.
- `afg_observe`: `AccessObservation` parses `resource`/`count`;
  `ResourceLeak` + `compute_resource_leaks` derive the verdict (owner = first
  writer of an instance; a read by another principal that returns rows is a leak;
  a read that returns none was dominated). Unit tests cover both controls.
- `afg_observe/examples/analyze.rs`: analyze an existing trace without re-running
  the app.

## Not done here (and why)

AFG's static producer auto-locating the sites on bionic (the LLVM step) is
blocked by a toolchain version matrix: bionic requires rustc 1.97 (emits LLVM 22
IR), while the producer's `llvm-ir` parser targets LLVM <= 21, and bionic cannot
downgrade to an older rustc (its deps need 1.97). Static AFG is already published
and the current focus is dynamic, so this corroboration is deferred rather than
forcing a toolchain match. The instrumented sites here are the same categories
the catalog matches (jsonwebtoken auth, tokio-postgres data access).
