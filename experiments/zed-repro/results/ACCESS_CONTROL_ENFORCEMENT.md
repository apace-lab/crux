# Access-control enforcement - zed

Enforcement pass on zed collab commit `739fdbe`. Dynamic/manual (rustc 1.98 -> LLVM 20
blocks the static producer). This ties the zed findings (RESULTS.md) into the
enforcement framing: enumerate the shared-resource accesses and check whether each is
dominated by an access-control check on every path. zed is path/subsystem-sensitive:
one access is un-dominated (the leak), two are dominated.

## Shared-resource accesses and their enforcement

| access site | check that should dominate it | dominated? | verdict |
|---|---|---|---|
| channel buffer read at join (`join_channel_buffer`) | `check_user_is_channel_participant` (runs before the read) | yes | OK |
| channel buffer edit delivery (`update_channel_buffer` broadcast) | recipients come from `channel_buffer_collaborator`; only the *writer* is rechecked; recipients are never revalidated, and removal / role-downgrade do not evict them | **no** | **LEAK** |
| project worktree delivery (`update_worktree` broadcast) | recipients come from `project_collaborator`, whose lifecycle is atomically coupled to room membership (`join_project` checks+inserts in one tx; `leave_room` deletes participant+collaborator in one tx) | yes | OK |

## The un-dominated access (the leak)

`update_channel_buffer` broadcasts the document edits to every connection in
`channel_buffer_collaborator` for the channel, rechecking only the edit's author. The
recipients are not revalidated against current membership, and neither
`remove_channel_member` nor `set_channel_member_role` (downgrade to Banned) evicts the
buffer collaborator. So a removed/downgraded member keeps receiving edits -- the read
of the shared buffer is not dominated by a membership check for the recipient. AFG
confirms this dynamically (persistent leak; also a schedule-dependent join/removal
race), and it is the one place the invariant fails. Full detail + traces + the seed
sweep are in RESULTS.md; the maintainer report is in DISCLOSURE.md.

## The dominated accesses (why they are clean)

- The buffer *join* read is dominated by `check_user_is_channel_participant`, which runs
  before serving. A non-member is refused (verified across 21 join-race interleavings).
- The project worktree delivery is dominated because the collaborator set is kept in
  lock-step with room membership inside single transactions, so a departed guest is
  evicted and never in the broadcast set (verified: 0/20 seeds delivered post-leave).

## Enforcement style

zed enforces with a check that runs at the *edge of a session* (membership check at
join) but is not re-evaluated for the life of the session, and whose broadcast
recipient set is a separate table. That makes it omittable exactly where the session's
collaborator set is not kept in sync with membership -- which is the channel-buffer
case (decoupled, not evicted) but not the project case (coupled, evicted). This is the
same "path-sensitive omission" pattern as tabby (resolver check omitted on the
conversion path) and AppFlowy (storage check omitted on the batch path); in zed the
omission is temporal (during-session, after revocation) rather than a sibling call
path. Contrast bionic, where the check is embedded in the query and cannot be omitted.

## Note

The static producer is blocked (LLVM 20), so this pass is done from the trace and code:
the broadcast recipient set (`channel_buffer_collaborator` vs `project_collaborator`)
and whether each membership transition (removal, downgrade, leave) maintains it. The
AFG delivery probes on both broadcast paths make the "who was served" question
observable directly.

## How to reproduce

1. Confirm removal and role-downgrade do not evict the buffer collaborator:
   `grep -rn "channel_buffer_collaborator::Entity::delete" ../../../../zed/crates/collab/src/db/queries/*.rs`
   (only in `leave_channel_buffer`, connection-loss, and server-restart cleanup, not in
   `remove_channel_member` or `set_channel_member_role`).
2. Confirm the broadcast rechecks only the writer: `update_channel_buffer` in
   `crates/collab/src/db/queries/buffers.rs` reads `channel_buffer_collaborator` for the
   channel after checking only `user` (the edit author).
3. Confirm the project control couples the lifecycle: `join_project` (access check plus
   collaborator insert) and `leave_room` (delete participant plus collaborator) are each
   single transactions (`db/queries/projects.rs`, `db/queries/rooms.rs`).
4. Dynamic confirmation and sweeps: run the tests
   `channel_buffer_tests::{test_afg_removed_member_persistent_leak, test_afg_banned_member_still_receives_edits, test_afg_join_removal_race, test_afg_project_leave_no_leak}`
   with `AFG_TRACE_PATH` set, then take the verdict with `afg_observe`. Commands and
   sweep scripts are in `RESULTS.md`.

Expect: the buffer edit broadcast delivers to a removed or banned member (leak,
`afg_observe` reports it); the project worktree broadcast never delivers to a departed
guest (control, no leak).
