# bionic-gpt: instrumented dynamic run

bionic-gpt built from source, instrumented with CRUX probes, run with two real
users. Target: bionic-gpt commit `6a82275` (2026-07-24). Run date 2026-09-16.
This is the no-leak case: the dynamic pipeline should agree with the static
picture in RESULTS.md and report no leak.

## What we found

alice writes and reads her conversation; bob reads the same conversation id and is
served nothing. CRUX reports no leak. Both users reach the same chat store node
(that is a coarse overlap), but the per-conversation verdict clears it because
bob's read of alice's conversation returned zero rows.

From the trace the instrumented app wrote (`results/trace.jsonl`):

```
auth   alice
write  conversation:2  count 1     alice (send_message)
read   conversation:2  count 1     alice, her own (conversation view)
auth   bob
read   conversation:2  count 0     bob, blocked by the ownership check
```

`crux_observe` over that trace:

```
overlap: alice <-> bob on the chat store node
resource-linked leak: 0   every cross-user read returned no rows
```

What it means: the read is dominated by the ownership check (RLS plus the
`user_id = current_app_user()` predicate, see RESULTS.md), so bob's read records
count 0 and no data flowed. CRUX decides ownership per conversation from the trace
(first writer owns it, here alice) and only flags a cross-user read that returns
rows; bob's returns none. `results/negative_control_trace.jsonl` is a tabby-shaped
trace (a read that does return rows) that the same analyzer flags as a leak, so
the no-leak verdict here is a real discrimination, not the analyzer failing to
fire.

## How to reproduce

```sh
# build web-server from source in bionic's devcontainer image, live DB reachable
# (cornucopia typechecks queries against the real schema at build time)
cargo build --bin web-server

# apply the CRUX instrumentation, then rebuild. On a clean checkout of commit 6a82275:
#   git apply .../bionic-gpt-repro/instrumentation.patch
# (adds crates/web-server/crux_probe.rs and edits main.rs, jwt.rs [auth],
#  handlers/console/send_message.rs [write], handlers/console/conversation.rs [read])

# run the binary with APP_DATABASE_URL set, DANGER_JWT_OVERRIDE unset,
# CRUX_TRACE_PATH set. alice creates + reads a conversation, bob reads it.

# analyze
cargo run --example analyze -- results/trace.jsonl   # from crux_observe
```

Expected: bob's read records count 0, and zero confirmed leaks.

## Note

CRUX's static producer cannot auto-locate the sites on bionic: bionic needs rustc
1.97 (LLVM 22) and the producer's IR parser targets LLVM 21 and below, and bionic
cannot be built on an older rustc. So the sites here were instrumented by hand.
AppFlowy-Cloud (rustc 1.86 / LLVM 19) does not have this problem.
