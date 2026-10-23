# vaultwarden: captured results

Target: `dani-garcia/vaultwarden` tag `1.33.1`, the server binary (a Bitwarden-compatible
password-manager server: Rocket web framework, diesel over SQLite, Tokio). Toolchain
rustc 1.99 (LLVM 20), so the LLVM-19 static producer is blocked and this is a
dynamic-plus-code target, like bionic-gpt, zed, and spiceai. This is a non-LLM target:
vaultwarden makes no LLM API calls. Run date 2026-10-02 on the lab server.

## Verdict: CONFIRMED CROSS-USER LEAK, confirmed by CRUX's own probe and analyzer

A regular organization member is served ciphers from collections they have no access to.
This is a real, published vulnerability: **CVE-2026-26012 / GHSA-h265-g7rm-h337**
("Full Cipher Enumeration Ignoring Organization Collection Permissions"), affecting
vaultwarden <= 1.35.2 and fixed in 1.35.3. Our pinned `1.33.1` is affected. This mirrors
AppFlowy: the evaluated source version leaks, a later release fixes it.

## The mechanism (verified in code)

- The shared resource is an organization's ciphers, which are meant to be scoped by
  collection: a member sees only the ciphers in collections they belong to.
- The endpoint `GET /ciphers/organization-details`
  ([organizations.rs](https://github.com/dani-garcia/vaultwarden/blob/1.33.1/src/api/core/organizations.rs#L821),
  `get_org_details` -> `_get_org_details`) is guarded only by `OrgMemberHeaders`, which
  checks that the caller is a *member* of the organization. It then calls
  `Cipher::find_by_org(org_id, conn)`
  ([cipher.rs](https://github.com/dani-garcia/vaultwarden/blob/1.33.1/src/db/models/cipher.rs#L874)),
  which returns **every** cipher in the organization, and serializes each with
  `CipherSyncType::Organization` with no collection-access filter.
- The correct, collection-scoped reads exist and are used elsewhere:
  `Cipher::find_by_user` / `find_by_user_visible` and `Cipher::is_accessible_to_user`
  (`get_access_restrictions(...).is_some()`). The vulnerable endpoint simply does not
  apply them.

In CRUX terms this is the dominance criterion violated on one path: the cipher read is
dominated by an org-*membership* check, but **not** by the collection-access check
(`is_accessible_to_user`) that should dominate it. It is the same "separable check,
omitted on one endpoint" shape as tabby and AppFlowy, now in a password manager.

## CRUX instrumentation and dynamic verdict

We instrumented vaultwarden's real serve path with an CRUX probe behind an off-by-default
`crux-probe` cargo feature (not part of a normal build):

- A probe module `src/crux_probe.rs` emits the CRUX JSONL event format
  (`crux_runtime`'s `EventEnvelope` / `Event::Access`).
- Two probe sites on PANode 9300: `_get_org_details` (the vulnerable path,
  `function_id` 930001) and the `sync` handler (the collection-scoped
  `find_by_user_visible` path, `function_id` 930002, used as the control; reached by
  `GET /sync`).
- For each cipher served to a user, the probe consults vaultwarden's own
  `is_accessible_to_user`: an authorized serve is recorded as `Write(user, cipher:<id>)`
  (the resource owner), an unauthorized serve as `Read(user, cipher:<id>, count=1)` (a
  non-owner read that returns a row, which is `crux_observe`'s definition of a leak).

Scenario (no Bitwarden crypto required: vaultwarden re-hashes whatever
`masterPasswordHash` string the client sends, so register and login use arbitrary
consistent strings; the organization graph is seeded directly into SQLite):

- organization with collections A and B;
- `alice` = Owner (access to all collections);
- `bob` = confirmed regular member with access to **collection B only**;
- `cipherA` (marker `ALICE-SECRET-A`) in collection A; `cipherB` (`SHARED-B`) in
  collection B.

Driving the scenario (alice org-details, bob org-details, bob `/sync`) with the probe
active produced a 5-event trace (`results/afg_trace.jsonl`). `crux_observe`
(`results/afg_observe_verdict.txt`, via `cargo run --example analyze_trace`) reports:

```
coarse PANode overlaps (static-style signal): 1
  alice <-> bob on node {9300}
resource-linked leak verdict: 1 confirmed leak
  LEAK: bob read alice's cipher:ca000000-...-000000000001 (node 9300), served 1 row
```

The trace itself:

```
seq1 Write alice cipher:ca...A1   930001 org-details  (alice accessible -> owner)
seq2 Write alice cipher:cb...B2   930001 org-details  (alice accessible -> owner)
seq3 Read  bob   cipher:ca...A1   930001 org-details  count=1  <-- LEAK (bob has no access to collection A)
seq4 Write bob   cipher:cb...B2   930001 org-details  (bob accessible to collection B)
seq5 Write bob   cipher:cb...B2   930002 sync         (control: collection-scoped; cipher:ca...A1 never served)
```

The two-path contrast is explicit: on the vulnerable path (930001) bob is served
`cipher:ca...A1` he cannot access (the leak); on the collection-scoped control path
(930002, `find_by_user_visible`) bob is served only `cipher:cb...B2`, and
`cipher:ca...A1` never appears, so the control produces no leak.

crux_scheduler additionally emits the leak schedule (alice writes before bob reads, linked
on the resource).

## Behavioral confirmation and control

At the HTTP level in the same run:

- `bob -> GET /ciphers/organization-details` (vulnerable): response contains
  `ALICE-SECRET-A` (collection A, which bob cannot access) **and** `SHARED-B`.
- `bob -> GET /sync` (control, `find_by_user_visible`): response contains `SHARED-B`
  but **not** `ALICE-SECRET-A`.

So the same user, on the collection-scoped endpoint, is correctly denied the cipher that
the organization-details endpoint leaks. Both the leak and the control are present in the
CRUX trace (seq3 vs seq5 above), so the two-path contrast is captured by `crux_observe`,
not only behaviorally.

## How to reproduce

Prerequisites: rustc (stable), a C toolchain (bundled SQLite via libsqlite3-sys), and
python3 (for seeding, since no sqlite3 CLI is needed).

```sh
cd vaultwarden
# 1. Build with the CRUX probe.
cargo build --release --features sqlite,crux-probe

# 2. First run: create schema and register two users (arbitrary password hashes).
env DATA_FOLDER=/tmp/vw_data DATABASE_URL=/tmp/vw_data/db.sqlite3 \
    ROCKET_ADDRESS=127.0.0.1 ROCKET_PORT=8080 WEB_VAULT_ENABLED=false \
    SIGNUPS_ALLOWED=true ./target/release/vaultwarden &
#   POST /api/accounts/register for alice@example.com (masterPasswordHash "alicehash")
#   and bob@example.com ("bobhash"), then stop the server.

# 3. Seed the org graph into SQLite with python3 (see scripts: vw_seed.py):
#   org, collections A+B, alice=Owner(access_all), bob=User(collection B only),
#   cipherA in A, cipherB in B.

# 4. Second run with the trace active, then drive the scenario:
env ... CRUX_TRACE_PATH=/tmp/vw_afg.jsonl ./target/release/vaultwarden &
#   login alice+bob (POST /identity/connect/token), then
#   GET /api/ciphers/organization-details?organizationId=<org> as alice, then as bob,
#   then GET /api/sync as bob (the collection-scoped control).

# 5. Reach the verdict with CRUX's analyzer.
cd ../AFG/crux
cargo run --example analyze_trace -- /tmp/vw_afg.jsonl
```

## What to expect

- bob's organization-details response contains `ALICE-SECRET-A` (the leak); bob's
  `/sync` response does not.
- `crux_observe` reports 1 coarse overlap and 1 confirmed resource leak (owner alice,
  reader bob, 1 row).
- On vaultwarden >= 1.35.3 the endpoint filters by collection access and the leak is gone.
