# Security disclosure draft - zed collab: removed channel member keeps receiving channel notes

Status: DRAFT for the zed maintainers. Do not publish or file publicly until the
maintainers have been contacted privately and given time to remediate. Report via
zed's security policy (SECURITY.md / security@zed.dev or a private GitHub advisory),
not a public issue.

## Summary

In the zed collaboration server (`crates/collab`), removing a user from a channel
does not disconnect them from that channel's collaborative document ("channel
notes"). The server continues to broadcast every subsequent edit of the document
to the removed user's open connection. A user who is removed from a channel while
they have the notes open can keep reading the channel's private notes in real time
for as long as their client keeps the buffer open; a modified/passive client that
never sends `LeaveChannelBuffer` retains access indefinitely.

- Component: `crates/collab` (collaboration server), channel buffers.
- Version examined: commit `739fdbe` (analysis date 2026-09-22).
- Type: broken access control / missing session teardown on privilege revocation
  (CWE-613 Insufficient Session Expiration, CWE-281 Improper Preservation of
  Permissions).
- Impact: confidentiality - disclosure of channel notes to a user whose channel
  access was revoked.

## Impact

Channel notes are meant to be readable only by channel participants. After an admin
removes a member, that member should lose access. Instead, the removed member's
existing channel-buffer session stays alive server-side and is fed every new edit.
Realistic scenario: a person is removed from a sensitive channel but keeps their
editor open and continues to see notes typed after their removal. Preconditions:
the attacker was a channel participant and has the channel notes open (or holds a
live buffer session) at the time of removal. No special privileges are needed.

## Technical details

Three facts combine into the leak (all in `crates/collab/src`):

1. Removal deletes channel membership but not buffer collaboration.
   `Database::remove_channel_member` (`db/queries/channels.rs`) deletes the
   `channel_member` row and computes a membership update, but never deletes the
   user's `channel_buffer_collaborator` row.

2. The removal RPC handler does not tear down the buffer session.
   `remove_channel_member` (`rpc.rs`) calls `notify_membership_updated`, which
   unsubscribes the connection from channel pub/sub and sends the client an
   `UpdateChannels{ delete_channels }` (a client-side hint), and sends a
   `DeleteNotification`. It does not evict the user from the channel buffer and does
   not send anything that forces the server to drop their buffer collaborator entry.
   Server-side eviction only happens via the client's own `LeaveChannelBuffer`
   request, connection loss (`leave_channel_buffers_for_session`), or server-restart
   stale cleanup (`clear_stale_channel_buffer_collaborators`).

3. Edit broadcast rechecks only the writer.
   `Database::update_channel_buffer` (`db/queries/buffers.rs`) checks that the
   *author* of the edit is a channel member/participant, then returns every
   connection in `channel_buffer_collaborator` for the channel. The handler
   `update_channel_buffer` (`rpc.rs`) broadcasts the edit operations to that set
   (minus the sender). Recipients are never revalidated against current membership.

Consequently a removed member's connection remains in the broadcast set and receives
all subsequent edit operations (the actual document content), until that connection
leaves or drops.

## Reproduction

Against `crates/collab` integration harness (real `TestServer`/`TestClient`, real
RPC, SQLite), the following minimal scenario reproduces it. A and B are channel
members; both open the notes; A removes B; A then edits. Every edit A makes after
removal is delivered to B's connection.

```rust
// A and B are members; both open the channel buffer.
// A removes B, fully drained, then A edits three times.
// Result: B's connection is delivered all three post-removal edits.
```

(Full test: `channel_buffer_tests::test_afg_removed_member_persistent_leak` in the
reproduction kit; traces in `zed-repro/results/afg_trace_persistent.jsonl` show
three post-removal edits by A, each delivered to removed-B's connection.)

Note: zed's own reference client happens to drop the channel from its UI on removal,
so a stock client may not display the incoming edits, but the server still transmits
them over the removed user's connection. The vulnerability is server-side; it does
not depend on client behavior, and a client that ignores the removal reads the data.

## Suggested remediation

Either of these closes it; doing both is defense in depth.

1. Evict the buffer session on removal (primary fix). In `remove_channel_member`
   (and any role change that removes read access), delete the affected user's
   `channel_buffer_collaborator` rows for the channel and notify their connections
   so the buffer session is torn down server-side (the same effect as
   `leave_channel_buffer_internal` for each of the user's connections on that
   channel). This should run inside the same transaction as the membership deletion.

2. Revalidate recipients on broadcast (defense in depth). In
   `update_channel_buffer`, filter the collaborator set to connections whose user is
   a current channel participant before broadcasting, so a stale collaborator entry
   cannot receive edits even if eviction is missed.

The same gap applies to role *downgrade*, not just removal (verified). Demoting a
member to `Banned` (which `check_user_is_channel_participant` treats as no read
access) via `set_channel_member_role` also fails to evict the buffer session: like
removal, the handler calls `notify_membership_updated` but never removes the
`channel_buffer_collaborator` row, so the banned user keeps receiving edits. AFG
reproduces this (`channel_buffer_tests::test_afg_banned_member_still_receives_edits`,
1 confirmed leak). So the fix must cover every access-losing membership transition
(removal and downgrade to Banned), not only `remove_channel_member`.

Note on adjacent paths (verified safe): the initial `join_channel_buffer` and the
reconnect path `rejoin_channel_buffers` both correctly recheck
`check_user_is_channel_participant`, so they are not affected; the gap is specific to
the live session not being torn down on revocation and the broadcast not
revalidating recipients.

## Schedule-dependent variant

The leak also has a race form. If a user opens the channel notes at the same moment
an admin removes them, and the join transaction wins the write lock (its participant
check still sees them as a member), they are inserted as a buffer collaborator and
the subsequent removal does not evict them -- so they persistently receive edits. In
a deterministic-executor sweep this occurred in 15 of 40 schedules (~38%). Fix #1
(evicting on removal, in the same transaction) closes this too; fix #2 (revalidating
recipients on broadcast) closes the delivery regardless.

## Credit / context

Found while evaluating a research access-flow analysis tool on real Rust
applications. Happy to coordinate on timing and to verify a fix.
