# AFG on zed (collab server) - results

Target: `zed-industries/zed`, crate `crates/collab` (the collaboration server), commit
`739fdbe`. Toolchain rustc 1.98.1 (LLVM 20+), so this is a **dynamic** target (the
LLVM-19 static producer is blocked, same as bionic-gpt). Enforcement mechanism =
**channel membership check** (`check_user_is_channel_participant`), the 4th distinct
mechanism across our targets (tabby = missing check, bionic = Postgres RLS,
AppFlowy = casbin RBAC, zed = membership check).

## Verdict: TRUE NEGATIVE (no cross-user leak)

The shared resource is the per-channel collaborative buffer ("channel notes"),
labeled PANode 7300 in the dynamic trace. Two principals reach it (the coarse
static-style overlap AFG flags), but the resource-linked dynamic refinement finds
no leak: the read is dominated on all paths by the participant check.

Run on the real collab server via zed's own integration harness (`TestServer` +
`TestClient` over real RPC, real DB, deterministic executor) inside Docker on Linux
(gpui blade backend, no Metal; `CC=clang CXX=clang++` for webrtc-sys). Not a mimic:
the server code, RPC, DB queries, and the guard are all real zed.

### Trace 1 - non-member denied (`afg_trace_denied.jsonl`)

Scenario: user A creates a private channel with no other members and writes to the
buffer; user B (not a member) sends the raw `JoinChannelBuffer` RPC straight to the
server (the malicious-client path).

```
auth    principal 1  join_channel_buffer
access  principal 1  node 7300  read   channel:1     (guard passed -> buffer served)
auth    principal 2  join_channel_buffer            (B's RPC reached the server)
                                                     (NO read event for principal 2)
```

The absence of a read event for principal 2 is the dominance invariant on the real
server: B's request reached the handler (auth event present) but the participant
check returned `Err` at the `?` before the read probe. The test asserts B's request
`is_err()` - B got an error, not the buffer.

`afg_observe`:
```
principals: 1
  1: read_nodes={7300} write_nodes={}
coarse PANode overlaps: 0
resource-linked leak verdict: 0 confirmed leak(s)
  none: dominated by an ownership check
```

### Trace 2 - both members (`afg_trace_core.jsonl`)

Scenario: A and B are both channel members; both open the buffer (zed's own
`test_core_channel_buffers`).

```
auth/access  principal 1  node 7300  read  channel:1
auth/access  principal 2  node 7300  read  channel:1
```

`afg_observe`:
```
principals: 2
coarse PANode overlaps: 1   ->   1 <-> 2 on nodes {7300}
resource-linked leak verdict: 0 confirmed leak(s)
```

The coarse overlap is present (two principals reach the shared buffer store) but the
resource-linked verdict is clean: both reads are authorized members, no cross-user
instance data is served.

## What is real zed vs AFG scaffolding

Real zed: the collab server, the RPC handlers (`join_channel_buffer`,
`update_channel_buffer`), the DB queries (`db.join_channel_buffer`), the guard
`check_user_is_channel_participant`, and the whole `TestServer`/`TestClient`
integration harness. Hand-added: `crates/collab/src/afg_probe.rs` (the JSONL emitter,
a no-op unless `AFG_TRACE_PATH` is set), two probe calls in `rpc.rs`
(`afg_probe::auth` at the handler entry, `afg_probe::access` right after the DB read),
and the `test_afg_non_member_denied` integration test that drives the malicious-client
path. Node id 7300 stands for the shared channel-buffer store the overlap analysis
flags.

## How to reproduce (remote Linux box, Docker)

```sh
# base image: rust:1.98-bookworm + zed linux deps + protobuf-compiler, CC/CXX=clang
docker run --rm \
  -v ~/afg/zed:/zed -v zed_target:/target \
  -v zed_cargo_reg:/usr/local/cargo/registry -v zed_cargo_git:/usr/local/cargo/git \
  -e CARGO_TARGET_DIR=/target -e AFG_TRACE_PATH=/zed/afg_trace_denied.jsonl \
  -w /zed zed-afg:base bash -c 'export PATH=/usr/local/cargo/bin:$PATH; \
    cargo test -p collab --test collab_tests --features test-support -- \
    channel_buffer_tests::test_afg_non_member_denied --exact --nocapture'

# verdict:
cd afg_prototype/afg_observe
cargo run --example analyze -- ../experiments/zed-repro/results/afg_trace_denied.jsonl
```

## Metrics (seed / interleaving / timing sweeps)

All on the 128-core Linux box, headless SQLite, deterministic gpui executor. Two
sweep families: sequential scenarios (structurally one interleaving) and a
concurrent 4-user join race (many interleavings). Every run passed; the dominance
invariant (non-member never reads node 7300) held on every schedule.

### Coverage
| Metric | Value |
|---|---|
| collab src LOC | 15,130 |
| RPC handlers (access-control edge points) | 176 |
| Data-layer membership-guard sites | 15 (buffers 3 + channels 12) |
| LLM API calls | 0 (collab is not an LLM app) |
| Instrumented sites (AFG probe) | 2 (auth + channel-buffer read), node 7300 |

### Seeds / interleavings / leaks
| Scenario | Seeds | Distinct interleavings | Overlaps found | Leaks found |
|---|---|---|---|---|
| denied (non-member join) | 30 | 1 (sequential) | 0 | 0 |
| core (2 members) | 30 | 1 (sequential) | 30 (1/seed: 1<->2 node 7300) | 0 |
| race (3 members + 1 non-member, concurrent) | 60 | 21 | 60 (1/seed) | 0 |

- #seeds so that no more leaks can be detected: 0 additional - the invariant holds
  from seed 0 and across all 21 distinct race interleavings; no leak is reachable.
- # seeds swept to first leak: 3 for zed (the schedule-dependent join/removal race
  leak; first leaking seed is the 3rd). See the schedule-dependent leak section below.

### Timing (per-seed wall time; instrumented vs baseline)
| Scenario | best | avg (instrumented) | avg (baseline) | worst |
|---|---|---|---|---|
| denied | 0.170s | 0.1710s | 0.1713s | 0.180s |
| core | 0.190s | 0.1927s | 0.1920s | 0.200s |
| race (4-user) | 0.220s | 0.2272s | 0.2287s | 0.230s |

Instrumentation overhead is within measurement noise (a few JSONL writes per run).

Totals: 240 instrumented+baseline runs across the two sweeps in ~244s wall
(sequential sweep 119s / 120 runs; race sweep 125s / 120 runs). Build: cold 4m29s,
incremental after a source edit 10-22s.

## Removal-path LEAK (AFG-discovered): post-revocation buffer delivery

The join path is guarded (above), but AFG found a real cross-user leak on the
*update/broadcast* path: a member removed from a channel keeps receiving the
channel's collaborative document edits.

Mechanism (all real zed code, commit 739fdbe):
- `remove_channel_member` (db/queries/channels.rs:466) deletes the `channel_member`
  row and `notify_membership_updated` unsubscribes the connection from channel
  pub/sub and tells the client the channel is gone. It does NOT delete the user's
  `channel_buffer_collaborator` row, and there is no server-side buffer eviction on
  removal (the only eviction paths are the client's own `leave_channel_buffer`,
  connection loss, and server-restart stale cleanup).
- `update_channel_buffer` (db/queries/buffers.rs:451) rechecks only the WRITER
  (`check_user_is_channel_member/participant` on `user`), then broadcasts the edit
  operations to every connection in `channel_buffer_collaborator` for the channel.
- So a removed member's connection stays in that set and is delivered every
  subsequent edit. The reference client cosmetically drops the channel, but the
  server still transmits the private document to the removed connection; a passive
  or malicious client that does not send `leave_channel_buffer` keeps reading it.

This is a check-at-join / use-during-session gap: access is verified when joining
the buffer but never revalidated during the live session, and revocation does not
tear the session down. It is the exact failure the AFG dominance invariant targets
(a shared-resource access that is not dominated by an ownership check for the
current principal on ALL paths).

Test `channel_buffer_tests::test_afg_removed_member_persistent_leak`: A and B are
members, both open the buffer; A removes B; A then makes 3 edits (each fully
drained). Trace `results/afg_trace_persistent.jsonl`:

```
write  principal 1  channel:1  count 1     (A edit #1, post-removal)
read   principal 2  channel:1  count 1     (removed B delivered edit #1)   <- LEAK
write  principal 1  channel:1  count 1     (A edit #2)
read   principal 2  channel:1  count 1     (removed B delivered edit #2)   <- LEAK
write  principal 1  channel:1  count 1     (A edit #3)
read   principal 2  channel:1  count 1     (removed B delivered edit #3)   <- LEAK
```

`afg_observe`: `resource-linked leak verdict: 3 confirmed leak(s)` (B, a non-member,
served A's channel:1 on every edit). The single-edit case is
`results/afg_trace_removed_drained.jsonl` (1 leak).

Instrumentation added for this: a delivery probe in the `update_channel_buffer`
handler (rpc.rs) that maps each broadcast recipient ConnectionId to its principal
via the connection pool and emits a write (author) + read (each recipient) at
node 7300. This faithfully mirrors the actual broadcast set.

Property: this variant of the leak is DETERMINISTIC (persistent), reproduced on the
natural interleaving; the first run already exposes it (seeds swept to first leak =
1), so no seed sweep is needed here. The schedule-DEPENDENT variant that does need a
sweep (seeds swept to first leak = 3) is in the section below; either way it is a
genuine real-world cross-user leak. zed is therefore a MIXED
target: join path guarded (true negative across 21 interleavings), removal path
leaks (confirmed), analogous to AppFlowy (single-get guarded, batch leaks).

NOTE (responsible disclosure): this is a real access-control gap in a widely used
application. Before any public paper release, report it to the zed maintainers and
allow time to fix / coordinate.

## Schedule-DEPENDENT LEAK (join vs removal race): the schedule-driven-testing result

The persistent leak above is deterministic. AFG also finds a variant whose very
existence depends on the interleaving, which is the case schedule-driven testing is
for. Scenario: B is a channel member but has NOT opened the buffer; A removes B and
B opens the buffer CONCURRENTLY (no drain between the two RPCs). Two orderings:

- removal commits first -> B join's participant check fails -> B denied (no leak).
- B join commits first (B still a member at check time) -> B is inserted as a
  channel_buffer_collaborator; removal then deletes membership but does NOT evict
  the collaborator -> B is a stale collaborator and receives A subsequent edits.

Which ordering happens is decided by the executor schedule (seed). Sweep of
`channel_buffer_tests::test_afg_join_removal_race` over 40 seeds:

```
b_join wins (leak):   15 / 40 seeds  (37.5%)
removal wins (clean): 25 / 40 seeds
first leaking seed:   seed index 2 (the 3rd seed tried); seeds 0,1 are clean
```

`afg_observe` on a leaking seed: `1 confirmed leak (2 read 1's channel:1, served 1
row)`. So a single "natural" run misses the leak 62.5% of the time; AFG's schedule
sweep surfaces it by the 3rd interleaving.

Metrics (schedule-driven testing, this leak):
- # seeds swept to first leak: 3 (first leaking seed is the 3rd;
  seed; expected ~2.7 given the 37.5% per-seed rate).
- per-seed time: instrumented avg 0.181 s, baseline 0.180 s (overhead within noise).
- time to hit the leak: ~0.5 s (3 seeds x ~0.18 s).

This is the same underlying bug as the persistent leak (removal does not evict the
buffer collaborator and the broadcast rechecks only the writer); the race decides
whether B gets INTO the collaborator set. It demonstrates that AFG's seed sweep
finds a real cross-user leak that a single interleaving misses.

## Role-downgrade variant (verified 2026-09-23)

The same leak is reachable via role downgrade, not only removal. Demoting a member
to `Banned` (loses read access) through `set_channel_member_role` also fails to evict
the buffer session (the handler calls `notify_membership_updated` but never removes
the `channel_buffer_collaborator` row). Test
`channel_buffer_tests::test_afg_banned_member_still_receives_edits`: after the ban, A
edit is delivered to banned B; `afg_observe` = 1 confirmed leak
(`afg_trace_banned.jsonl`). So the root cause is general (any access-losing
membership transition, not just removal), which broadens both the finding and the
required fix.

## Projects subsystem: ROBUST (the discriminating contrast)

We ran the same methodology (delivery probe + seed sweep) on zed's project/worktree
collaboration, which is structurally different from channel buffers: the project
collaborator lifecycle is atomically coupled to room membership.
- `join_project` performs its access check (`access_project` -> must be a room
  participant) AND the collaborator insert in ONE transaction.
- `leave_room` deletes the room participant AND the `project_collaborator` row in ONE
  transaction.

Test `channel_buffer_tests::test_afg_project_leave_no_leak`: A hosts a shared project;
B and C join as guests; B leaves the room (`hang_up`); A then changes a file. The
worktree-delivery probe (node 7400) shows B and C both receive the pre-leave sync, but
the POST-leave update is delivered only to C, never to B. Seed sweep (20 seeds):
B received the post-leave update in 0/20 schedules; C in 20/20 (sanity). So the
departed guest is evicted on every interleaving.

This is the discriminating result: the SAME AFG technique flags the channel-buffer
subsystem (invariant violated: access not revalidated / not torn down on revocation)
and clears the project subsystem (invariant holds: collaborator lifecycle atomically
dominated by membership). The structural difference is exactly the dominance invariant.
Channel chat, the third channel-scoped subsystem, has been removed from current zed.
