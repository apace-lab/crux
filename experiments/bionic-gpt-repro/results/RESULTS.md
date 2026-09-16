# bionic-gpt: live-app leak/no-leak result (2026-09-16)

## Verdict

bionic-gpt is a **clean true negative** (a positive control for AFG). A second
authenticated user CANNOT read another user's conversation by id. The shared
`llm.chats` store read is dominated on every path by an ownership check bound to
the current principal.

This is the deliberate contrast to TabbyML/tabby, where
`list_thread_messages` runs `WHERE thread_id = {id}` with no user filter and
leaks cross-user (see `../../tabby-repro`).

## Setup (real full app)

- Real deployment: `bionic-gpt/infra-as-code/docker-compose.yml`
  (`ghcr.io/bionic-gpt/bionicgpt:1.12.12`, `ankane/pgvector`, migrations,
  rag-engine). App on `localhost:3000`, postgres internal only.
- `DANGER_JWT_OVERRIDE` unset (scratch override), so auth is the real
  `X-Forwarded-User` / `X-Forwarded-Email` reverse-proxy path from
  `crates/web-server/jwt.rs`.
- Two real users auto-registered through the real request path:
  - alice: sub `alice-sub`, email `alice@acme.org`, db user_id 2, team public `gbHJdm`
  - bob:   sub `bob-sub`,   email `bob@acme.org`,   db user_id 3, team public `EfhxLZ`
- Deployment config (an admin normally adds this; the stock compose ships no
  model, so it was seeded once): one `LLM` model + one `Company`-visible `Model`
  prompt. This is config, not the security boundary.

## The enforcement (why there is no leak)

`crates/web-server/handlers/console/conversation.rs` reads chats by id, but
before any query it calls `authz::get_permisisons(...)`
(`crates/db/authz.rs`), which runs
`SET LOCAL row_level_security.user_id = <authenticated user.id>`. That binds
`current_app_user()`. The chats query then carries an explicit ownership
predicate (`crates/db/queries/chats.sql`):

```sql
WHERE
    -- Make sure the chat belongs to the user
    conversation_id IN (SELECT id FROM llm.conversations WHERE user_id = current_app_user())
AND
    conversation_id = :conversation_id
```

So the access is guarded twice: the app-level predicate and Postgres RLS, both
keyed to the per-request principal. In AFG terms the shared-resource access is
dominated by an ownership check for the current principal, so the leak invariant
does not fire.

## Empirical proof

### HTTP (real request path)

alice creates conversation id 1 with message `ALICE_SECRET_9f3b_do_not_leak`
via `POST /o/gbHJdm/send_message` (303 -> `/o/gbHJdm/console/1`).

| actor | request | result | alice's secret in response |
| ----- | ------- | ------ | -------------------------- |
| alice | `GET /o/gbHJdm/console/1` (own)          | 200 | present (control passes) |
| bob   | `GET /o/EfhxLZ/console/1` (own team, alice's conv id) | 200, empty console | absent |
| bob   | `GET /o/gbHJdm/console/1` (alice's team url)          | 422 (team-membership authz rejects) | absent |

bob's IDOR probe returns a valid but empty "AI Chat Console" page: the handler
runs, the ownership predicate filters alice's rows out. The cross-team URL is
rejected even earlier by the team lookup in `get_permisisons`.

### SQL (RLS + predicate, corroboration)

Running the app's exact chats predicate as `application_user` under each
principal's RLS binding:

```
alice (current_app_user=2) conv1_rows = 1
bob   (current_app_user=3) conv1_rows = 0
```

## Reproduce

App up (from `bionic-gpt/infra-as-code`, with DANGER_JWT_OVERRIDE unset).
Then, with alice/bob headers as above:

```sh
A=(-H "X-Forwarded-User: alice-sub" -H "X-Forwarded-Email: alice@acme.org")
B=(-H "X-Forwarded-User: bob-sub"   -H "X-Forwarded-Email: bob@acme.org")
# alice writes
curl -s -D- -o /dev/null "${A[@]}" -F message=ALICE_SECRET_9f3b_do_not_leak -F prompt_id=1 \
  http://localhost:3000/o/gbHJdm/send_message | grep -i location   # -> /o/gbHJdm/console/1
# control + probe
curl -s "${A[@]}" http://localhost:3000/o/gbHJdm/console/1 | grep -c ALICE_SECRET_9f3b   # 1
curl -s "${B[@]}" http://localhost:3000/o/EfhxLZ/console/1 | grep -c ALICE_SECRET_9f3b   # 0
```

## What this means for AFG

bionic-gpt confirms the enforcement side of the dominance invariant: when every
shared-resource access is dominated by an ownership check for the principal
(here RLS + an in-query predicate), AFG should report no leak. tabby is the
violation of the same invariant. The pair (tabby leaks, bionic does not) is the
evaluation contrast for the missing-ownership-check contribution.
