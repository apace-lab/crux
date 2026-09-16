# AppFlowy-Cloud: the instrumented dynamic run (AFG catches a real leak)

This is the dynamic half of the AppFlowy experiment, and it is the most useful
result of the three apps. We build AppFlowy-Cloud from source, add AFG probes to
the real handlers, run it with two real users, and AFG's trace catches an actual
cross-user document leak on one code path while correctly clearing the other. Two
reads of the same shared store, one guarded and one not, and AFG tells them apart.

Run date: 2026-09-16.

## What we found

alice has a document. bob is not in her workspace. bob asks for alice's document
two ways:

- through the single-document endpoint (collab/{id}): refused, casbin blocks him.
- through the batch endpoint (collab_list): served. bob gets 4393 bytes of
  alice's document.

So the batch path leaks. AFG's trace and verdict pick this up: it records bob
reading a document that alice owns and being served real bytes, and reports one
confirmed leak. bob's blocked single-get shows up in the trace as an auth event
with no read after it, because casbin returned before any read happened, so AFG
does not flag that path.

## How it happens

The two paths differ in one thing: whether they call casbin.

- The single-get path (get_collab_handler -> get_full_encode_collab) calls
  `enforce_action(Read)` before it reads. bob fails that, so nothing is served.
- The batch path (batch_get_collab_handler -> batch_get_collab) does not. In this
  source checkout `batch_get_collab` even takes the user id as `_uid` (unused),
  there is no per-object check, and there is no access-control middleware in front
  of the route. So it reads and returns whatever object ids you ask for.

That is exactly the kind of bug AFG is built to find: a read of a shared resource
that is not dominated by an ownership check for the current user. casbin works
fine; this path just forgot to call it.

## How we tested it

Built appflowy_cloud from the source checkout (commit c5bcfd3) in AppFlowy's own
build image (lukemathwalker/cargo-chef:latest-rust-1.86, SQLX_OFFLINE=true, with
protobuf-compiler/lld/clang). The source build has no seat license, so two real
users sign up and provision through the real gotrue flow, no seeding needed this
time.

We then ran that binary as the appflowy_cloud service (a compose override swaps
the image for the build base and runs /target/debug/appflowy_cloud from the build
volume, with AFG_TRACE_PATH set) against the real backing services (postgres,
redis, gotrue, minio, nginx), casbin on.

The probe is a small module in the real crate (src/afg_probe.rs) plus calls in
src/api/workspace.rs. The principal is the request's uid, the resource is
collab:<object_id>, the count is bytes served. The single-get handler records a
read only after the casbin check passes; the batch handler records a read for
each object it actually serves.

Trace (results/trace.jsonl):

```
auth   alice
read   collab:WS  count 4393    (alice, her own, batch)
auth   bob                       (bob single-get: casbin blocked before the read, no read event)
auth   bob
read   collab:WS  count 4393    (bob, batch, alice's document)
```

Verdict (afg_observe, cargo run --example analyze):

```
coarse overlap: alice <-> bob on the collab store node
resource-linked leak verdict: 1 confirmed leak
  bob read alice's collab:WS and was served 4393 rows
```

Same node, same document, opposite verdicts on the two paths.

## How to reproduce

1. Build appflowy_cloud from the source checkout in the cargo-chef rust-1.86
   image, SQLX_OFFLINE=true, apt install protobuf-compiler lld clang,
   `cargo build --bin appflowy_cloud`.
2. Add the probe module and the handler calls (see the diff in src/api/workspace.rs
   and src/afg_probe.rs), rebuild.
3. Bring up the stack with a compose override that runs your built binary as the
   appflowy_cloud service and sets AFG_TRACE_PATH.
4. Sign up + verify alice and bob (no seat limit on the source build). alice reads
   her document, bob reads it via single-get (blocked) and via collab_list (leak).
5. Copy the trace out of the container and run
   `cargo run --example analyze -- <trace.jsonl>` from afg_observe.

## Honest about the version

This leak is in the source checkout (commit c5bcfd3). The newer released image
(the one in RESULTS.md) has since added a check that blocks bob on the batch path
too. So this is a real class of bug, a shared read that skips its ownership check,
that AFG catches in a real version and that upstream later fixed. AFG would have
flagged it before the fix landed.
