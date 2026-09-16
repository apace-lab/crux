# AppFlowy-Cloud: instrumented dynamic run

AppFlowy-Cloud built from source, instrumented with AFG probes, run with two real
users. Target: AppFlowy-Cloud commit `c5bcfd3` (2026-09-11). Run date 2026-09-16.

## What we found

Two endpoints read the same collab (document) store; one checks access, the other
does not.

- `GET /api/workspace/{ws}/collab/{id}` (single): calls casbin
  `enforce_action(Read)` before it reads. A non-member is refused (`1012`).
- `GET /api/workspace/{ws}/collab_list` (batch): calls no check. A non-member is
  served the document.

Concretely: alice owns document `WS`; bob is not in alice's workspace. bob's
single-get is refused; bob's batch-get returns 4393 bytes of alice's document.
In plain terms: any logged-in user can read another user's document through the
batch endpoint.

From the trace the instrumented app wrote (`results/trace.jsonl`):

```
auth   alice
read   collab:WS  count 4393     alice, own document (batch)
auth   bob                        single-get: casbin refused before the read, no read event
auth   bob
read   collab:WS  count 4393     bob served alice's document (batch)
```

`afg_observe` over that trace:

```
overlap: alice <-> bob on the collab store node
resource-linked leak: 1   bob read alice's collab:WS, served 4393 bytes
```

What it means: both users reach the same store node and the same document, but the
per-instance verdict fires only for the batch read. bob's single-get returned no
bytes (the casbin check dominated it), his batch read returned alice's bytes (no
check). That is the bug AFG targets: a read of a shared resource that is not
guarded for the requesting user. In this checkout `batch_get_collab` takes the
user id as `_uid` (unused), does no per-object check, and has no access-control
middleware in front of the route.

## How to reproduce

Build from source in AppFlowy's own build image, run that binary as the app
service, drive two users.

```sh
# 1) build (rustc 1.86 / LLVM 19; SQLX_OFFLINE=true; apt: protobuf-compiler lld clang)
cargo build --bin appflowy_cloud

# 2) add the probe and the handler calls, then rebuild:
#    - src/afg_probe.rs                     (writes the AFG trace)
#    - src/api/workspace.rs                 (auth + read in the two collab handlers)

# 3) bring the stack up with a compose override that runs the built binary as the
#    appflowy_cloud service and sets AFG_TRACE_PATH (backing services: postgres,
#    redis, gotrue, minio, nginx; casbin on). minio: point at quay.io/minio/minio.

# 4) sign up + verify alice and bob (source build has no seat limit), then:
GET /api/workspace/{WS}/collab/{WS}      # single -> 1012 refused
GET /api/workspace/{WS}/collab_list      # batch  -> 200, alice's bytes (leak)

# 5) copy the trace out of the container and analyze it
cargo run --example analyze -- results/trace.jsonl   # from afg_observe
```

Expected: single-get refused, batch-get served, and one confirmed
resource-linked leak (bob read alice's document).

## Version note

The leak is in commit `c5bcfd3`. A newer released image adds the check and blocks
bob on the batch path too (see the prebuilt-image run in RESULTS.md). So this is a
real bug in that version, since fixed upstream; AFG would have caught it before
the fix.
