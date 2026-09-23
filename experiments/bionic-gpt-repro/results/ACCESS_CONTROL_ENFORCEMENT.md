# Access-control enforcement - bionic-gpt

Enforcement pass on bionic-gpt commit `6a82275`. Done dynamically/manually because
rustc 1.97 -> LLVM 20 blocks the static producer. This is the clean case: the pass
confirms bionic's tenant reads are dominated and explains why it is structurally
robust (the strongest enforcement style of the four targets).

## Mechanism (verified in code)

bionic does not use Postgres `CREATE POLICY` RLS (grep for it finds none). Its tenant
isolation is three parts:

1. **In-query ownership predicate, embedded in each read.** Sensitive read queries
   carry the ownership check in the SQL itself. E.g. `crates/db/queries/chats.sql`
   (lines 38/70/103/116): `... conversation_id IN (SELECT id FROM llm.conversations
   WHERE user_id = current_app_user())`; `crates/db/queries/conversations.sql`
   (22/52/62): `... WHERE user_id = current_app_user()` (plus a team-scoped variant
   `team_id IN (SELECT team_id FROM iam.team_users WHERE user_id = current_app_user())`).
2. **Fail-closed principal.** `current_app_user()`
   (`migrations/20220728091159_rls_setup.sql`) is
   `current_setting('row_level_security.user_id', false)::integer` -- the `false`
   makes it ERROR if the GUC is unset. So a query that runs without a principal set
   fails; it does not return other users' rows.
3. **Per-request principal set.** `authz::set_rls_and_encryption_keys` /
   `get_permisisons` (`crates/db/authz.rs`) run `SET LOCAL row_level_security.user_id
   = {uid}` at the start of each request's transaction.

## Verdict: TRUE NEGATIVE, structurally enforced

For every tenant read, the ownership check is *part of the query* (`user_id =
current_app_user()`), and `current_app_user()` is fail-closed. Two consequences:

- There is no "sibling path that omits the check" -- the check is not a separable
  pre-call that one code path can forget; it is baked into the query text, so every
  caller of that query gets it.
- A handler that forgets to set the principal does not leak; its queries error
  (fail-closed).

This matches the earlier dynamic result (`dynamic.md`, `trace.jsonl`): bob's read of
alice's conversation returned 0 rows, and `afg_observe` reported 0 leaks. The
enforcement pass explains the "why": the read is dominated in-query, on every path.

## Where bionic sits in the enforcement-style taxonomy

The four targets enforce at different points, and that predicts their failure modes:

| app | where the check lives | omittable per-path? | outcome |
|---|---|---|---|
| tabby | HTTP resolver (`check_read_thread`) | yes -> `convert_thread_to_page` omits it | LEAK |
| AppFlowy | storage method (`get_full_encode_collab`) | yes -> `batch_get_collab` omits it | LEAK |
| **bionic** | **embedded in the query** (`user_id = current_app_user()`), fail-closed | **no** | **no leak** |
| zed | membership check at join; live-session delivery | yes -> removal/downgrade not revalidated | LEAK |

bionic is the one target whose check cannot be omitted by a stray path, because it is
inside the query and the principal is mandatory (fail-closed). That is why the
enforcement pass clears it while flagging the others.

## Note

Full static automation would need the LLVM-19 producer (blocked here) plus modeling
`current_app_user()` as the ownership predicate. Done manually, the pass is a query
audit: every tenant read query embeds `current_app_user()`, and none was found
without it.

## How to reproduce

1. Confirm there is no `CREATE POLICY` RLS:
   `grep -rc "CREATE POLICY" ../../../../bionic-gpt/crates/db/migrations/*.sql` (all 0).
2. Confirm the fail-closed principal:
   `grep -n "current_app_user\|current_setting" ../../../../bionic-gpt/crates/db/migrations/20220728091159_rls_setup.sql`
   (`current_app_user()` = `current_setting('row_level_security.user_id', false)`, which
   errors if the setting is unset).
3. Confirm the in-query ownership predicate on tenant reads:
   `grep -n "current_app_user" ../../../../bionic-gpt/crates/db/queries/conversations.sql ../../../../bionic-gpt/crates/db/queries/chats.sql`.
4. Confirm the principal is set per request:
   `grep -n "SET LOCAL row_level_security.user_id" ../../../../bionic-gpt/crates/db/authz.rs`.
5. Dynamic confirmation: see `dynamic.md` / `RESULTS.md` (bob's read of alice's
   conversation returns 0 rows; `afg_observe` on `trace.jsonl` reports 0 leaks).

Expect: every tenant read query embeds `current_app_user()`, the principal is
mandatory, and no unguarded tenant read is found (true negative).
