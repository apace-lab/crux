# tabby: captured results

Target: TabbyML/tabby commit `21b2904` (branch `nightly`), ~45k lines of Rust, the
`ee/` multi-user tier. Toolchain: rustc 1.85.0 (LLVM 19), macOS, 16 GB RAM. Run
date 2026-09-09.

## What we found

tabby leaks chat threads across users. `list_thread_messages`
(ee/tabby-db/src/threads.rs) builds `WHERE thread_id = {id}` with no `user_id`
filter, so any authenticated user who reads another user's thread id gets their
messages. The static pass flags the shared thread store; the dynamic run
reproduces the actual read (bob is served alice's private message).

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

## Dynamic

Two users through tabby's real tabby-db code. Harness output:

```
[leak] bob was served alice's thread message: ALICE-PRIVATE: quarterly numbers
```

AFG trace (trace.jsonl):

```
access  alice@example.com  node 7000  Write
access  bob@example.com    node 7000  Read
leak    bob@example.com    owner alice@example.com
```

`afg_observe::analyze_traces`:

```
overlaps : alice <-> bob  shared_nodes [7000]
scopes   : alice writes[7000]; bob reads[7000]
leak     : reader bob, owner alice, "ALICE-PRIVATE: quarterly numbers"
```

## Real tabby vs AFG scaffolding

Real tabby: the schema and 49 migrations, `DbConn::new_in_memory`, `create_user`,
`create_thread`, `create_thread_message`, `list_thread_messages`, the unscoped
query, and the leak. Hand-added: the per-request `with_afg_context` wrap and the
node id 7000 standing for the shared `thread_messages` table the static pass
flagged.

## How to reproduce

See the kit README. In short: build the producer (LLVM 19), then run
scripts/01_schema_db.sh, scripts/02_static.sh, scripts/03_dynamic.sh. Outputs land
in out/.
