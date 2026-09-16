# bionic-gpt: the instrumented dynamic run

This is the dynamic half of the bionic experiment. We build bionic from source,
add AFG probes to the real handlers, run it with two real users, and check what
AFG's trace says. The point is to show the dynamic pipeline agreeing with the
static picture from RESULTS.md: bionic does not leak, and AFG sees why.

Run date: 2026-09-16.

## What we found

The trace AFG produced shows alice writing and reading her conversation, and bob
reading the same conversation id and getting nothing back. AFG's resource-linked
verdict on that trace is: no leak. The coarse signal (both users reach the same
chat store node) does show an overlap, but the per-conversation verdict clears it,
because bob's read of alice's conversation returned zero rows. That is the whole
value of the per-instance check: an overlap on the shared node is only a real
leak if someone was actually served another user's data.

For contrast, the same analyzer run on a tabby-shaped trace (a read that does
return another user's rows) reports one confirmed leak. So the no-leak verdict on
bionic is a real discrimination, not the analyzer failing to fire.

## How it happens

Same enforcement as RESULTS.md: get_permisisons sets the RLS user id, and the
chats query filters by `user_id = current_app_user()`. bob's read runs, but the
filter returns nothing, so the probe records a read with count 0. alice's own
read records count 1. AFG decides ownership per conversation from the trace (the
first writer owns it, here alice) and only flags a cross-user read that returns
rows. bob's returns none, so nothing is flagged.

## How we tested it

Built the real bionic web-server from source in bionic's own devcontainer image
(purtontech/rust-on-nails-devcontainer:1.3.46, rustc 1.97.1), on the live DB
network so cornucopia's compile-time query checks ran against the real schema.
Put the cargo target dir on a docker volume, the macOS bind mount is too slow for
cargo.

Instrumentation is a small probe module in the real web-server crate
(crates/web-server/afg_probe.rs) plus three call sites: the auth point in jwt.rs,
the chat write in send_message.rs, and the chat read in conversation.rs. The
probe reads the principal straight from the request's Jwt, which axum already
hands to every handler, so we do not need a task-local middleware and the trace
is correct under real multi-threaded axum. It writes the same JSONL schema
afg_observe reads.

Then we ran the instrumented binary with real header auth (DANGER_JWT_OVERRIDE
unset), had alice create a conversation and read it, and had bob try to read it.
The HTTP responses matched the trace exactly: alice's page contained her secret,
bob's did not.

Trace (results/trace.jsonl):

```
auth   alice
write  conversation:2  count 1     send_message.rs
read   conversation:2  count 1     conversation.rs   (alice, her own)
auth   bob
read   conversation:2  count 0     conversation.rs   (bob, blocked by the ownership check)
```

Verdict (afg_observe):

```
coarse overlap: alice <-> bob on the chat store node
resource-linked leak verdict: 0 leaks (every cross-user read returned no rows)
```

results/negative_control_trace.jsonl is the tabby-shaped trace the analyzer
flags as a leak, kept next to this one so the contrast is checkable.

## How to reproduce

1. Build web-server from source in the devcontainer image with the live DB
   reachable, SQLX is not used here (cornucopia needs the live schema).
2. Add the probe module and the three calls (see the diff in the web-server
   crate), rebuild.
3. Run the binary with APP_DATABASE_URL set, DANGER_JWT_OVERRIDE unset,
   AFG_TRACE_PATH pointing at a file.
4. alice creates + reads a conversation, bob reads it.
5. Analyze: `cargo run --example analyze -- <trace.jsonl>` from afg_observe.

## One caveat, stated plainly

AFG's static producer could not auto-locate the sites on bionic because bionic
needs rustc 1.97 (LLVM 22) and the producer's IR parser targets LLVM 21 and
below, and bionic cannot be built on an older rustc. The static side is already a
published result, and the current focus is dynamic, so we instrumented the sites
by hand rather than force a toolchain match. AppFlowy-Cloud, which pins rustc
1.86 / LLVM 19, does not have this problem.
