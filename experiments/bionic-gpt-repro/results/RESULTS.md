# bionic-gpt: live-app run

The real bionic-gpt deployment, driven with two users. Target: bionic-gpt commit
`6a82275` (2026-07-24). Run date 2026-09-09, re-confirmed 2026-09-16. Access
control here is Postgres row-level security plus an in-query ownership predicate,
a different mechanism from AppFlowy (casbin) and tabby (no check).

## What we found

A second logged-in user cannot read another user's chat conversation. alice
creates a conversation with a message; bob then asks for that conversation by id
and gets an empty page, not alice's message. alice sees her own message. So the
shared chat store is not exposed across users.

```
alice  GET her own conversation             200, her message present
bob    GET alice's conversation (his team)  200, empty, message absent
bob    GET alice's conversation (her team)  422, team check rejects him
```

What it means: two guards, both keyed to the requesting user. Every console
request runs `authz::get_permisisons` (crates/db/authz.rs) before any query, and
that does `SET LOCAL row_level_security.user_id = <the user's id>`, which sets
what `current_app_user()` returns. The chats query (crates/db/queries/chats.sql)
then carries the ownership check in the SQL:

```sql
WHERE conversation_id IN (SELECT id FROM llm.conversations WHERE user_id = current_app_user())
  AND conversation_id = :conversation_id
```

So when bob asks for alice's conversation, `current_app_user()` is bob, the
subquery returns nothing, and he gets zero rows. The shared read is dominated on
every path by an ownership check for the current user. Confirmed at the SQL layer
too: the same predicate returns 1 row for alice (user 2), 0 rows for bob (user 3).

## How to reproduce

```sh
# bring bionic up from infra-as-code/docker-compose.yml, DANGER_JWT_OVERRIDE unset
# (so the real X-Forwarded-User / X-Forwarded-Email auth path runs)
# seed one model + one Company-visible Model prompt (the console needs a prompt)

A=(-H "X-Forwarded-User: alice-sub" -H "X-Forwarded-Email: alice@acme.org")
B=(-H "X-Forwarded-User: bob-sub"   -H "X-Forwarded-Email: bob@acme.org")

# alice creates a conversation with a message
curl -s -D- -o /dev/null "${A[@]}" -F message=ALICE_SECRET -F prompt_id=1 \
  http://localhost:3000/o/gbHJdm/send_message | grep -i location   # -> /o/gbHJdm/console/1

# control, then the probe
curl -s "${A[@]}" http://localhost:3000/o/gbHJdm/console/1 | grep -c ALICE_SECRET   # 1
curl -s "${B[@]}" http://localhost:3000/o/EfhxLZ/console/1 | grep -c ALICE_SECRET   # 0
```

Expected: alice sees her message, bob does not.

The instrumented (dynamic) run of the same app is in dynamic.md.
