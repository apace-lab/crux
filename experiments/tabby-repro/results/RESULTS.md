# tabby: captured results

Target: TabbyML/tabby commit `21b2904` (branch `nightly`), ~45k lines of Rust, the
`ee/` multi-user tier. Toolchain: rustc 1.85.0 (LLVM 19), macOS, 16 GB RAM. Run
date 2026-09-09.

## What we found

tabby leaks chat threads across users. `list_thread_messages`
(ee/tabby-db/src/threads.rs) builds `WHERE thread_id = {id}` with no `user_id`
filter. The static pass flags this shared thread store; the dynamic run reproduces
a cross-user read.

IMPORTANT (corrected 2026-09-23, see results/ACCESS_CONTROL_ENFORCEMENT.md): the leak is
path-sensitive. The normal read path, `Query::thread_messages`, IS guarded by
`AccessPolicy::check_read_thread`. The real leak is the thread-to-page conversion
path (`Mutation::create_thread_to_page_run` ->
`PageService::convert_thread_to_page`, ee/tabby-webserver/src/service/page.rs),
which calls `list_thread_messages` with NO ownership check and embeds the messages
in a page owned by the caller. So any authenticated user can exfiltrate any thread,
including private (ephemeral) ones. Our first demo drove `tabby-db` directly, which
bypassed the resolver and attributed the leak to the wrong place; the corrected demo
below drives tabby's real access-control code. Reported to maintainers: DISCLOSURE.md.

## Static

Producer on `tabby-webserver` (379 MB .ll). PAG built in ~12s, peak RSS ~4 GB,
`112 semantic points, 8 principals`. Sites: 2 auth, 4 llm-access, 105 data-access,
111 total (1 credential-check skipped). Matched by symbol:

```
 73  sqlx::query::Query::execute             data-write
 16  sqlx::query_as::QueryAs::fetch_all       data-read
  9  sqlx::query_as::QueryAs::fetch_optional  data-read
  7  sqlx::query_as::QueryAs::fetch_one       data-read
  4  async_openai::...::CreateChatCompletionRequestArgs::messages  llm-api-prompt
  2  jsonwebtoken::decoding::decode           authentication   (jwt.rs:37, license.rs:48)
  1  argon2::PasswordVerifier::verify_password  authentication (credential check, skipped)
  1  llm_chain::traits::Executor::execute     (category None, skipped)
```

Static overlap is 0 (per-request auth is a single principal class statically). The
cross-user overlap shows up dynamically.

## Dynamic (corrected, path-sensitive)

The harness drives tabby's REAL access-control code on a PRIVATE (ephemeral) thread:
it uses the real `AccessPolicy::check_read_thread` (the guard) and the real
`list_thread_messages` (the read `convert_thread_to_page` performs). Harness output:

```
[guarded path]     check_read_thread REFUSES bob (correct)
[conversion path]  bob served alice's PRIVATE thread (no check_read_thread): ALICE-PRIVATE: quarterly numbers
```

So the same read is dominated by the ownership check on the resolver path (bob
refused) but not on the conversion path (bob served) -- the un-dominated path is the
bug. CRUX trace (trace.jsonl):

```
access  alice@example.com  node 7000  Write  thread:1  count 1
access  bob@example.com    node 7000  Read   thread:1  count 1
leak    bob@example.com    owner alice@example.com
```

`crux_observe` (resource-linked, same as bionic/appflowy/zed):

```
coarse PANode overlaps: 1   alice <-> bob on nodes {7000}
resource-linked leak verdict: 1 confirmed leak(s)
  LEAK: bob read alice's thread:1 (node 7000) and was served 1 row(s)
```

Note: `check_read_thread` only restricts *ephemeral* threads; persisted threads are
readable by non-owners (apparently intended "sharing"). Our earlier demo used a
persisted thread, which is why it was ambiguous. This corrected demo uses an
ephemeral (unambiguously private) thread and drives it through the unguarded
conversion path, so the leak is real and end-to-end through tabby's own policy code.

## Real tabby vs CRUX scaffolding

Real tabby: the schema and 49 migrations, `DbConn::new_in_memory`, `create_user`,
`create_thread`, `create_thread_message`, `list_thread_messages`, the unscoped
query, AND `tabby_schema::policy::AccessPolicy::check_read_thread` (the real
ownership guard), and the leak. The corrected harness reproduces the exact read
sequence of `convert_thread_to_page` (existence check, then `list_thread_messages`
with no `check_read_thread`) rather than driving the DB blind. Hand-added: the
per-request `with_crux_context` wrap and node id 7000 standing for the shared
`thread_messages` table. Not run: the LLM page generation that follows the read
(irrelevant to the access-control leak; the data is exfiltrated at the read).

## How to reproduce

See the kit README. In short: build the producer (LLVM 19), then run
scripts/01_schema_db.sh, scripts/02_static.sh, scripts/03_dynamic.sh. Outputs land
in out/.
