# Results captured 2026-09-09

Target: TabbyML/tabby @ `21b2904` (branch `nightly`), ~45k LOC Rust, `ee/` multi-user tier.
Toolchain: rustc 1.85.0 (LLVM 19), macOS, 16 GB RAM.

## Static (AFG producer on tabby-webserver, 379M .ll)

PAG built in ~12s, peak RSS ~4 GB. `112 semantic points, 8 principals`.

Instrumentation sites: **2 auth, 4 llm-access, 105 data-access, 111 total** (1 credential-check skipped).

Matched by symbol:
```
 73  sqlx::query::Query::execute            data-write
 16  sqlx::query_as::QueryAs::fetch_all      data-read
  9  sqlx::query_as::QueryAs::fetch_optional data-read
  7  sqlx::query_as::QueryAs::fetch_one      data-read
  4  async_openai::types::chat::CreateChatCompletionRequestArgs::messages  llm-api-prompt
  2  jsonwebtoken::decoding::decode          authentication   (-> jwt.rs:37, license.rs:48)
  1  argon2::PasswordVerifier::verify_password  authentication (credential check -> skipped, not a principal)
  1  llm_chain::traits::Executor::execute    (category None -> skipped)
```
0 static overlap (0 tagged nodes) is expected: per-request auth is one principal
class statically. The cross-user overlap is dynamic (below).

## Dynamic (two users through tabby's real tabby-db code)

Harness output:
```
[leak] bob was served alice's thread message: ALICE-PRIVATE: quarterly numbers
done
```

AFG trace (`trace.jsonl`):
```
monitor   alice@example.com
access    alice@example.com  node=7000  Write
monitor   bob@example.com
access    bob@example.com    node=7000  Read
leak      bob@example.com    owner=alice@example.com
```

`afg_observe::analyze_traces` over the trace:
```
principals: [alice@example.com, bob@example.com]
overlaps  : alice@example.com <-> bob@example.com  shared_nodes [7000]
scopes    : alice writes[7000]; bob reads[7000]
leaks     : { reader: bob@example.com, owner: alice@example.com,
              detail: "ALICE-PRIVATE: quarterly numbers" }
```

**The leak is real**: tabby's `list_thread_messages` (ee/tabby-db/src/threads.rs)
builds `WHERE thread_id = {id}` with no user_id filter, so any authenticated user
reading another user's thread id is served their messages.

## What is tabby's real code vs. AFG scaffolding

Real tabby: the schema + 49 migrations, `DbConn::new_in_memory`, `create_user`,
`create_thread`, `create_thread_message`, `list_thread_messages`, the unscoped
query, the leak. Hand-added AFG scaffolding (as in every AFG demo): the per-request
`with_afg_context` wrap (AFG does not auto-insert it) and the single node id 7000
standing for the shared `thread_messages` table AFG flagged in threads.rs.
