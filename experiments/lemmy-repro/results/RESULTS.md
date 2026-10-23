# lemmy: captured results

Target: `LemmyNet/lemmy` tag `0.19.0`, the sync/API server (`lemmy_server`, actix-web +
diesel over PostgreSQL, Tokio): a federated link-aggregator / forum where many users
share one instance. This is a non-LLM target. Run date 2026-10-03 on the lab server.

We evaluate `0.19.0` deliberately: it is the version where the private-message-report
cross-user leak (CVE / GHSA-r64r) is live. The later-pinned `0.19.11` fixes it, and that
fix is the dominating guard this result points at (see "Before/after" below). This mirrors
AppFlowy (the evaluated source version leaks, a later release fixes it).

## Verdict: CONFIRMED CROSS-USER LEAK, confirmed by CRUX's own probe and analyzer

Any authenticated user can read any other user's private message by "reporting" it: the
report-create endpoint reads the private message and returns its contents without checking
that the reporter is a participant. This is **GHSA-r64r-5h43-26qv** (affecting
`>= 0.17.0, < 0.19.1`).

## The mechanism (verified in code)

The shared resource is a private message, which should be readable only by its sender and
recipient. The endpoint `POST /api/v3/private_message/report`
([private_message_report/create.rs](https://github.com/LemmyNet/lemmy/blob/0.19.0/crates/api/src/private_message_report/create.rs))
does:

```rust
let person_id = local_user_view.person.id;
let private_message = PrivateMessage::read(&mut context.pool(), private_message_id).await?;
let report_form = PrivateMessageReportForm {
  creator_id: person_id,
  private_message_id,
  original_pm_text: private_message.content,  // <-- the PM content
  reason,
};
// ... creates the report and returns PrivateMessageReportView (which includes the content)
```

There is no check that `person_id` is the message's `recipient_id` (or `creator_id`), so
any authenticated user can report an arbitrary message id and receive its content in the
report view. In CRUX terms the private-message read is dominated by nothing on this path:
the ownership check that should dominate it is absent.

## Before/after (the dominating guard)

lemmy 0.19.1 and later (including the originally-pinned 0.19.11) add exactly the missing
check at the top of the handler:

```rust
if person_id != private_message.recipient_id {
  Err(LemmyErrorType::CouldntCreateReport)?
}
```

So at 0.19.11 a non-participant's report errors before the PM is read, the read is
dominated, and the leak is gone. The fix is the dominance restored.

## CRUX instrumentation and dynamic verdict

We instrumented lemmy's real handlers with an CRUX probe placed in `lemmy_utils`
(`crates/utils/src/crux_probe.rs`) so both `lemmy_api` and `lemmy_api_crud` can reach it.
The probe is always compiled but inert unless `CRUX_TRACE_PATH` is set, and serializes the
trace with `serde_json`. Two probe sites on PANode 9600:

- PM create (`crates/api_crud/src/private_message/create.rs`, `function_id` 960001):
  `Write(sender, pm:<id>)`, establishing the sender as the owner.
- PM report (`crates/api/src/private_message_report/create.rs`, `function_id` 960002):
  after the PM is read, the probe checks whether the reporter is a participant
  (`person_id == creator_id || person_id == recipient_id`). A participant is recorded as
  `Write(user, pm:<id>)` (authorized); a non-participant as `Read(user, pm:<id>, count=1)`
  (a non-owner read that returns the message, which is crux_observe's definition of a leak).

Scenario (driven over the `/api/v3` API; lemmy hashes passwords server-side, so no client
crypto is needed): an admin is created by the config setup, then registration is opened;
`alice`, `bob`, `carol` register; alice sends a private message to bob; carol (a
non-participant) reports it; bob (the recipient, a participant) reports it as the control.

The probe produced a 3-event trace (`results/afg_trace.jsonl`):

```
seq1 Write person:3(alice) pm:1  960001 create        (alice sends the PM -> owner)
seq2 Read  person:5(carol) pm:1  960002 report count=1 (carol is NOT a participant -> LEAK)
seq3 Write person:4(bob)   pm:1  960002 report        (bob is the recipient -> authorized)
```

`crux_observe` (`results/afg_observe_verdict.txt`) reports:

```
coarse PANode overlaps (static-style signal): 3   (alice, bob, carol all reach node 9600)
resource-linked leak verdict: 1 confirmed leak
  LEAK: person:5 (carol) read person:3 (alice)'s pm:1, served 1 row
```

The trace contrasts the attacker and the legitimate participant on the same endpoint:
carol's report is a non-owner read that returns the message (the leak), while bob's report
(as the recipient) is an authorized access. At 0.19.11 the recipient check would make
carol's report error before the read, so there would be no `Read` event and no leak.

## Behavioral confirmation

In the same run, carol's report response contained the private message content
(`ALICE-PM-SECRET-xyz`), confirming at the HTTP level that a non-participant obtained
another user's private message.

## Build / environment notes

lemmy 0.19.0 is from late 2023 and needs its contemporary toolchain: we built with rustc
1.75.0 (rustc 1.99 rejects diesel 2.1.4's glob `max` re-export). The shallow clone needed
the i18n translations submodule fetched at the commit 0.19.0 pins, and the diesel
PostgreSQL backend links against `libpq`.

## How to reproduce

```sh
cd lemmy019   # LemmyNet/lemmy at tag 0.19.0, translations submodule at its pinned commit
cargo +1.75.0 build --release --bin lemmy_server --locked
# postgres (Docker) on :5433; config.hjson with the db uri and an admin setup block
LEMMY_CONFIG_LOCATION=config.hjson CRUX_TRACE_PATH=/tmp/lemmy_afg.jsonl ./target/release/lemmy_server &
# admin login -> open registration; register alice/bob/carol; alice PMs bob;
# carol (non-participant) POST /api/v3/private_message/report -> receives the content;
# bob (recipient) reports as the control.
cd ../AFG/crux
cargo run --example analyze_trace -- /tmp/lemmy_afg.jsonl
```

Expect: carol's report returns alice's PM content, and `crux_observe` reports 1 confirmed
resource leak (carol read alice's pm, 1 row). On lemmy >= 0.19.1 the recipient check makes
carol's report error and the leak is gone.
