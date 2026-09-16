# bionic-gpt: does it leak conversations across users?

Short answer: no. A second logged-in user cannot read someone else's chat
conversation. bionic-gpt is a clean negative case for AFG (a real app that gets
access control right), which we use as the contrast to tabby (which leaks).

Run date: 2026-09-09 (re-confirmed while building the dynamic run 2026-09-16).

## What we found

alice creates a conversation and sends a message. bob then asks for that same
conversation by its id. bob gets an empty page, not alice's message. alice, of
course, sees her own message. So the shared chat store is not exposed across
users.

This is the opposite of tabby, where a second user who supplies another user's
thread id is served that thread's messages.

## How it happens

Two guards, both keyed to the user making the request:

1. Every request that touches the console goes through
   `authz::get_permisisons` (crates/db/authz.rs) before any query runs. That
   function does `SET LOCAL row_level_security.user_id = <the user's id>`, which
   sets what `current_app_user()` returns for the rest of the transaction.

2. The query that loads chats (crates/db/queries/chats.sql) has the ownership
   check written into the SQL itself:

   ```sql
   WHERE
       conversation_id IN (SELECT id FROM llm.conversations WHERE user_id = current_app_user())
   AND
       conversation_id = :conversation_id
   ```

So the read is filtered to conversations the current user owns, and Postgres
row-level security backs it up. When bob asks for alice's conversation,
`current_app_user()` is bob, the subquery returns nothing, and he gets zero rows.
In AFG terms: the read of the shared chat store is dominated on every path by an
ownership check for the current user, so the leak invariant never fires.

## How we tested it

Against the real deployment, not a stub. bionic's own docker-compose (postgres,
migrations, rag-engine, the app on :3000), with `DANGER_JWT_OVERRIDE` unset so
the real reverse-proxy auth path is exercised (X-Forwarded-User /
X-Forwarded-Email). Two users, alice and bob, each on their own team, auto
registered on first authenticated request.

The stock compose ships no model or prompt, and the console refuses to render
without one, so we seeded one model plus one Company-visible prompt first. That
is deployment config an admin normally adds; it is not the security boundary.

We drove it two ways and they agree:

HTTP (the real request path):

| who   | request                              | result                       |
| ----- | ------------------------------------ | ---------------------------- |
| alice | GET her own conversation             | 200, her message is present  |
| bob   | GET alice's conversation (his team)  | 200, empty, message absent   |
| bob   | GET alice's conversation (her team)  | 422, team check rejects him  |

SQL (running the exact chats predicate under each user's RLS binding):

```
alice (current_app_user = 2): 1 row
bob   (current_app_user = 3): 0 rows
```

## How to reproduce

Bring bionic up from infra-as-code/docker-compose.yml with DANGER_JWT_OVERRIDE
unset, seed a model + a Company-visible Model prompt, then:

```sh
A=(-H "X-Forwarded-User: alice-sub" -H "X-Forwarded-Email: alice@acme.org")
B=(-H "X-Forwarded-User: bob-sub"   -H "X-Forwarded-Email: bob@acme.org")

# alice creates a conversation with a message
curl -s -D- -o /dev/null "${A[@]}" -F message=ALICE_SECRET -F prompt_id=1 \
  http://localhost:3000/o/gbHJdm/send_message | grep -i location   # -> /o/gbHJdm/console/1

# control, then the probe
curl -s "${A[@]}" http://localhost:3000/o/gbHJdm/console/1 | grep -c ALICE_SECRET   # 1
curl -s "${B[@]}" http://localhost:3000/o/EfhxLZ/console/1 | grep -c ALICE_SECRET   # 0
```

The dynamic (instrumented) run of the same app is written up in dynamic.md.
