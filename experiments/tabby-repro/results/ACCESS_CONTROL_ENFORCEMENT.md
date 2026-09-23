# Access-control enforcement - tabby

The access-control-enforcement analysis (the comprehensive dominance
check: for every data-access site, is it dominated by an access-control check?) on
tabby, commit `21b2904`. Method + output + a significant finding that corrects our
earlier tabby framing.

## Method

1. Take the static producer's catalog of data-access sites (`out/static/static/
   instrumentation.json`): 105 data-access + 4 LLM + 2 auth. All 105 data-access
   sites are in `tabby-db` (the data layer); both auth points are at the
   `tabby-webserver` edge (JWT decode). There are zero access-control checks in the
   data layer itself.
2. For each READ site attributed to `tabby-db` (19 of them; the other reads were
   attributed to sqlx-internal frames by monomorphization), classify whether the
   query is scoped by the requesting user (an in-query ownership predicate).
3. Then do the path-sensitive part manually: for each unscoped read, follow its
   caller paths up to the GraphQL resolvers and check whether an ownership/role
   check dominates it on every path.

## Output: DB-layer scoping (step 2)

19 tabby-db read sites; 2 scoped in-query, 17 unscoped:

| verdict | reads |
|---|---|
| scoped in-query (user_id predicate) | `list_threads`, `list_notifications_within_7days` |
| UNSCOPED (candidate) | 17, incl. `list_thread_messages`, `list_pages`, `list_users_with_filter`, `list_integrations`, `list_job_runs_with_filter`, `compute_daily_stats`, ... |

The DB-layer view alone over-flags: 17/19. That is expected -- scoping is only one of
several enforcement mechanisms. The path-sensitive step is what makes it precise.

## Triage: resolver-layer authorization (step 3)

Cross-referencing each unscoped read with the guard on its GraphQL resolver
(`ee/tabby-schema/src/schema/mod.rs`):

- Most unscoped reads are **admin-only** (`integrations`, `invitations`, `job_runs`,
  `git_repositories`, `*_setting`, `custom/preset_web_documents`) -- guarded by
  `check_admin`. Not cross-user data; the DB-layer flag is a false positive.
- Analytics/user-directory reads (`users`, `daily_stats`) are `check_user` but pass
  the caller's identity / a policy check (`check_read_analytic`).
- **Thread reads are the interesting case**, below.

So the enforcement question is not "is there ANY check" but "is the read dominated by
an *authorization* check (ownership or the right role) on *every* path" -- authentication
alone is insufficient.

## Key finding: a real leak via an un-dominated path

`list_thread_messages` (the read our earlier experiment flagged) is reached by two
paths with *different* enforcement:

1. `Query::thread_messages` resolver -- **dominated**: it calls
   `user.policy.check_read_thread(&thread.user_id, thread.is_ephemeral)` before the
   read.
2. `Mutation::create_thread_to_page_run` -> `PageService::convert_thread_to_page`
   (`ee/tabby-webserver/src/service/page.rs:68`) -- **NOT dominated**: it fetches the
   thread only to check existence (`let _thread = ...get(thread_id)`), then calls
   `list_thread_messages(thread_id)` with no ownership check, and embeds the messages
   in a page owned by the caller. Guard is only `check_user` (any authenticated user).

So any authenticated user can exfiltrate ANY thread's messages -- including private
ephemeral threads -- by converting another user's thread (by id; ids are sequential
rowids) into their own page. This is a genuine cross-user data leak, and it is exactly
what the dominance analysis is for: the same data-access site is dominated by an
ownership check on one path and not on another; the un-dominated path is the bug.

## Correction to our earlier tabby framing (important)

Our first tabby experiment drove `tabby-db::list_thread_messages` **directly**, which
bypasses the resolver layer. That demonstrated the DB-layer read is unscoped, but it
did not show an end-to-end API leak, and it attributed the leak to the wrong place.
The path-sensitive enforcement analysis corrects this:

- The direct `thread_messages` API path IS guarded by `check_read_thread`. Note that
  `check_read_thread` only restricts *ephemeral* threads (persisted threads are
  readable by non-owners -- apparently intended "sharing"; the code comment says
  "unless it has been shared" and `set_thread_persisted` is described as converting
  ephemeral to persisted). So the persisted-thread read we demonstrated earlier is
  plausibly intended behavior, not a clear vulnerability.
- The REAL, unambiguous API-level leak is `convert_thread_to_page`, which has no
  ownership check at all and exposes even private ephemeral threads.

Net: tabby IS still a valid leak target, but the precise, defensible leak is the
page-conversion path, not the direct thread read. The paper's tabby section should use
this path, and we should disclose it to the tabby maintainers (same as the zed gap).

## Takeaways for the analysis design

- Enforcement = dominance by an *authorization* check on *every* path, not just an
  in-query predicate and not mere authentication.
- It must be **path-sensitive**: a data-access site guarded on one call path can be
  unguarded on another (the tabby page-conversion path). This is the crux.
- The static catalog + resolver-guard map got us 90% of the way by inspection; full
  automation needs call-path dominance from the producer's call graph (and, for the
  data-layer reads attributed to sqlx frames, mapping monomorphized calls back to the
  tabby-db caller).

## How to reproduce

1. Data-access catalog (static): run the LLVM-19 producer on tabby
   (`scripts/02_static.sh`), or read the existing catalog
   `out/static/static/instrumentation.json` (105 data-access, 2 auth, 4 llm).
2. Confirm the unscoped read at the DB layer:
   `grep -n "list_thread_messages" ../../../../tabby/ee/tabby-db/src/threads.rs`
   (the query builds `condition = "thread_id = {}"`, no `user_id`).
3. Path-sensitive triage: map each read to its GraphQL resolver guard:
   `grep -n "check_admin\|check_user\|check_read_thread" ../../../../tabby/ee/tabby-schema/src/schema/mod.rs`.
   The `thread_messages` resolver calls `check_read_thread`; the conversion path does not:
   `grep -n "list_thread_messages\|check_read_thread" ../../../../tabby/ee/tabby-webserver/src/service/page.rs`.
4. Dynamic confirmation: `bash scripts/03_dynamic.sh` (drives the real
   `check_read_thread` and the unguarded `convert_thread_to_page` read on an ephemeral
   thread), then `cd ../../afg_observe && cargo run --example analyze -- <trace>`.

Expect: the enforcement enumeration flags `list_thread_messages` as unscoped at the DB
layer; the triage shows it is guarded on the `thread_messages` path but not on the
`convert_thread_to_page` path; the dynamic run prints "guarded path REFUSES bob" and
"conversion path bob served alice's PRIVATE thread", and `afg_observe` reports 1
confirmed leak.
