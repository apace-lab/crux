# Schedule-driven testing in AFG

Technical write-up of AFG's schedule-driven testing: what it does, the result on
zed, how to reproduce it, and what output to expect. All numbers come from real runs
on real code (zed collab server, commit `739fdbe`); file and test names are exact.

## What problem it addresses

A single dynamic run executes one ordering of concurrent operations. If a cross-user
leak requires a specific ordering (operation A commits before operation B), a run that
happens to execute B before A does not expose it, and the app looks safe.

The access-control instance of this is a time-of-check to time-of-use (TOCTOU) gap:
the code checks membership at one point, but the guarded data access happens later, and
membership changes in between (the user is removed or downgraded). Whether the leak
fires depends on how the check and the change interleave. Finding it reliably requires
controlling the schedule and trying many orderings.

## What we did (method)

Schedule-driven testing has three components and one loop.

1. Deterministic scheduler. zed's collab integration tests run on a seeded
   deterministic executor (`gpui::BackgroundExecutor`, selected by the `SEED`
   environment variable). A fixed seed reproduces one interleaving; a different seed
   makes the executor choose a different order for pending tasks. A seed is therefore
   a handle to one point in the schedule space. (Apps without such an executor, e.g.
   the Tokio-based targets, would need a deterministic runtime simulator such as
   madsim. AFG's own scheduler with madsim replay is exercised on a controlled demo,
   see `scheduler-demo-repro/results/RESULTS.md`.)

2. Probes. `crates/collab/src/afg_probe.rs` plus call sites in `crates/collab/src/rpc.rs`
   record, per principal: the membership check outcome, the channel-buffer read at
   join (`join_channel_buffer`), and the delivery of each edit to each recipient in the
   `update_channel_buffer` broadcast. Each run writes a JSONL trace to the path in the
   `AFG_TRACE_PATH` environment variable; with the variable unset the probes are no-ops.

3. Verdict (`afg_prototype/afg_observe`). It reads a trace and applies the
   resource-linked rule: for each resource instance, the owner is the first principal
   to write it; if another principal reads that instance and is served rows (count > 0),
   that is a confirmed leak. This distinguishes a coarse overlap (two principals reach
   the same node) from a real leak (principal B was served principal A's data).

The loop: for `seed` in `0..N`, run the scenario at that seed, write a trace, and take
the verdict. If the scenario is schedule-insensitive the traces are byte-identical
across seeds (verified for the sequential scenarios); if it is schedule-sensitive the
per-seed verdicts differ, and that difference is the signal.

## What we found

### Result 1: a schedule-dependent cross-user leak in zed channel buffers

Channel notes are a shared document per channel, gated by
`check_user_is_channel_participant`. The join path is guarded: a non-member's
`join_channel_buffer` is refused before any read. The gap is on the removal path:

- `remove_channel_member` (and `set_channel_member_role` to `Banned`) deletes the
  membership row and notifies the client, but does not delete the user's
  `channel_buffer_collaborator` row, and there is no server-side teardown of the live
  session.
- `update_channel_buffer` broadcasts each edit to every connection in
  `channel_buffer_collaborator`, rechecking only the edit's author, not each recipient.

So a removed or downgraded member's connection keeps receiving the document's edits.
The reference client hides the channel from its UI, but the server still transmits the
edits over that connection; a client that ignores the removal reads them. This is
reported in `zed-repro/DISCLOSURE.md`.

The schedule-dependent form arises when the removal and a fresh join are concurrent
(`channel_buffer_tests::test_afg_join_removal_race`): member B has not opened the
buffer; admin A removes B while B opens it. The outcome is decided by which
transaction wins the SQLite write lock:

- Removal commits first: B's join membership check fails, B is denied. No leak.
- Join commits first: B's check still sees valid membership, B is inserted as a
  collaborator; the subsequent removal does not evict the collaborator, so B keeps
  receiving edits. Leak.

Same code and inputs; only the schedule differs. Sweep of 40 seeds:

| metric | value |
|---|---|
| seeds where the leak fires | 15 / 40 (37.5%) |
| first leaking seed | seed 2 (seeds 0 and 1 are clean) |
| seeds swept to first leak | 3 |
| time per seed (instrumented vs baseline) | 0.181 s vs 0.180 s (overhead within noise) |
| time to first leak | approx. 0.5 s (3 seeds) |

A single run that draws seed 0 or 1 reports zed as clean; the leak is only reached by
varying the schedule.

### Result 2: negative control, projects are robust

The same probe and seed sweep applied to zed's project/worktree collaboration returns
no leak, correctly. There the collaborator lifecycle is atomically coupled to room
membership: `join_project` performs its access check and the collaborator insert in one
transaction, and `leave_room` deletes the room participant and the project collaborator
in one transaction, so no window leaves a departed guest as a collaborator.

`channel_buffer_tests::test_afg_project_leave_no_leak`: A hosts a shared project, B and
C join, B leaves the room, A changes a file. The worktree-delivery probe shows the
post-leave update reaches C only, never B, on all 20 seeds (B: 0/20, C: 20/20). The
same criterion flags the channel-buffer subsystem and clears the project subsystem; the
difference is whether the shared access stays dominated by a membership check after
revocation. (zed's third channel-scoped subsystem, chat, has been removed from the
product.)

### Cross-app summary

- tabby: path-sensitive missing check. `list_thread_messages` is guarded on the
  `thread_messages` resolver path (`check_read_thread`) but not on the
  `convert_thread_to_page` path, which leaks any thread including private ones.
  Deterministic; the leak appears on the first run. (See `tabby-repro/results/ACCESS_CONTROL_ENFORCEMENT.md`.)
- AppFlowy: `batch_get_collab` reads with no access check while `get_full_encode_collab`
  enforces it. Deterministic; the leak appears on the first run.
- bionic-gpt: guarded by an in-query ownership predicate (`user_id = current_app_user()`)
  with a fail-closed principal. No leak.
- zed: guarded on join; leaks on the removal path, both deterministically (persistent
  post-removal delivery) and schedule-dependently (the join/removal race above).

zed is the one target that exercises the scheduler: static plus dynamic analysis
catches the deterministic access-control leaks, and schedule-driven testing is required
for the concurrency-timing subset, of which zed is a real-world instance.

## How to reproduce

Environment: a Linux host with Docker. The image is `rust:1.98-bookworm` plus zed's
Linux build dependencies and `protobuf-compiler`, built with `CC=clang CXX=clang++`
(webrtc-sys does not build under g++). zed source at commit `739fdbe`, with
`crates/collab/src/afg_probe.rs` and the probe call sites in `rpc.rs` applied, and the
tests in `crates/collab/tests/integration/channel_buffer_tests.rs`.

Build the test binary once:

```sh
docker run --rm -v <zed>:/zed -v zed_target:/target \
  -v zed_cargo_reg:/usr/local/cargo/registry -v zed_cargo_git:/usr/local/cargo/git \
  -e CARGO_TARGET_DIR=/target -w /zed <image> \
  bash -c 'export PATH=/usr/local/cargo/bin:$PATH; \
    cargo test -p collab --test collab_tests --features test-support --no-run'
```

Run one seed of the schedule-dependent race, writing a trace:

```sh
docker run --rm -v <zed>:/zed -v zed_target:/target ... \
  -e CARGO_TARGET_DIR=/target -e AFG_TRACE_PATH=/zed/trace.jsonl -e SEED=2 -w /zed <image> \
  bash -c 'export PATH=/usr/local/cargo/bin:$PATH; \
    cargo test -p collab --test collab_tests --features test-support -- \
    channel_buffer_tests::test_afg_join_removal_race --exact'
```

Sweep 40 seeds and classify each as leak or clean: `zed-repro` ships `afg_race2_sweep.sh`
(race) and `afg_projleave_sweep.sh` (project control); each loops `SEED` from 0 to N-1,
writes one trace per seed, and records leak/clean to a CSV. Take the verdict on a trace:

```sh
cd afg_prototype/afg_observe
cargo run --example analyze -- <trace>.jsonl
```

Data from the runs is in `zed-repro/results/race2/` (race sweep CSV and per-seed
traces) and `zed-repro/results/projleave/` (project control sweep).

## What to expect

- A trace is JSONL, one event per line: `auth` events (principal, method) and `access`
  events (principal, node, kind `read`/`write`, resource, count). Node 7300 is the
  channel-buffer store; node 7400 is the project worktree.
- `afg_observe` on a leaking race seed prints
  `resource-linked leak verdict: 1 confirmed leak(s)` with a line naming the reader,
  the owner, the resource instance, and the row count.
- The race sweep CSV shows leak on roughly 15 of 40 seeds, clean on the rest, with the
  first leak at seed 2.
- The project control sweep shows the post-leave update delivered to the remaining
  guest on all seeds and to the departed guest on none.
- Per-run wall time on the deterministic executor is about 0.18 s; instrumented and
  baseline runs are within run-to-run noise of each other.

## Metrics and their meaning

- `# leaks`: confirmed cross-user leaks (tabby 1, AppFlowy 1, zed 1, bionic 0).
- `# seeds run`: how many seeds were executed (1 for the single-run targets; 120 for
  zed across its scenarios).
- `# interleavings to find a leak or confirm a guard`: how many distinct interleavings
  yield a meaningful result, either a leak or confidence a guard holds. tabby / bionic /
  AppFlowy = 1; zed = 21 (the join-race interleavings that confirmed the membership
  guard holds).
- `# seeds swept to first leak`: interleavings explored before the first leak. zed = 3;
  the deterministic leaks = 1 (leak on the first run).
- time per run with vs without instrumentation: the probe cost. Measured within
  run-to-run noise on tabby and zed.
- time to first leak: for zed's race, about 0.5 s.

## Limitations

- Only zed provides a deterministic scheduler natively. The Tokio targets (tabby,
  bionic, AppFlowy) were single-run reproductions; sweeping schedules on them would
  require a deterministic runtime simulator (madsim), which none of them build under.
  AFG's own scheduler with madsim replay is validated on a controlled demo
  (`scheduler-demo-repro/results/RESULTS.md`): it generates 2 alternative interleavings
  and reproduces the write-then-read cache leak on the second (1/2 schedules), each
  replay about 23 ms.
- zed's test database is SQLite, which serializes the two racing transactions, so each
  seed resolves cleanly to leak or clean. On Postgres (production) the window could be
  wider, so this does not overstate the effect.
- The persistent and schedule-dependent forms of the zed leak share one root cause
  (missing eviction plus no recipient recheck); the race only decides whether the
  victim enters the collaborator set. It is one bug with two manifestations.

## Source files

- `zed-repro/results/RESULTS.md`: full zed write-up (join guard, persistent leak, race
  leak, project control, role-downgrade variant).
- `zed-repro/results/race2/`: the 40-seed race sweep (CSV and traces).
- `zed-repro/results/projleave/`: the project-control sweep.
- `zed-repro/DISCLOSURE.md`: the maintainer report.
- `afg_metrics_table.tex`: the cross-app metrics table (the schedule-dependent leak is
  footnote m).
- `schedule-driven-testing-section.tex`: the paper section (algorithm and figure).
