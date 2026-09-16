# tabby: captured results

Run date: 2026-09-09. Target: TabbyML/tabby @ `21b2904` (branch `nightly`),
~45k lines of Rust, the `ee/` multi-user tier. Toolchain: rustc 1.85.0 (LLVM 19),
macOS, 16 GB RAM.

## What we found

tabby leaks chat threads across users. The static pass flags the shared thread
store, and the dynamic run reproduces the actual read: bob is served alice's
private thread message. Both are recorded below.

## How it happens

`list_thread_messages` (ee/tabby-db/src/threads.rs) builds
`WHERE thread_id = {id}` with no `user_id` filter, so any authenticated user who
reads another user's thread id gets their messages. The read of the shared store
has no ownership check tied to the requesting user.

## How we tested it: static

The AFG producer on `tabby-webserver` (379M .ll). PAG built in ~12s, peak RSS
~4 GB, `112 semantic points, 8 principals`.

Instrumentation sites: 2 auth, 4 llm-access, 105 data-access, 111 total (1
credential-check skipped). Matched by symbol:

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

Static overlap is 0 (0 tagged nodes), which is expected: per-request auth is a
single principal class statically. The cross-user overlap only shows up
dynamically, below.

## How we tested it: dynamic

Two users through tabby's real tabby-db code. Harness output:

```
[leak] bob was served alice's thread message: ALICE-PRIVATE: quarterly numbers
done
```

AFG trace (trace.jsonl):

```
monitor   alice@example.com
access    alice@example.com  node=7000  Write
monitor   bob@example.com
access    bob@example.com    node=7000  Read
leak      bob@example.com    owner=alice@example.com
```

afg_observe::analyze_traces over that trace:

```
principals: [alice@example.com, bob@example.com]
overlaps  : alice@example.com <-> bob@example.com  shared_nodes [7000]
scopes    : alice writes[7000]; bob reads[7000]
leaks     : { reader: bob@example.com, owner: alice@example.com,
              detail: "ALICE-PRIVATE: quarterly numbers" }
```

## Real tabby vs AFG scaffolding

Real tabby: the schema and 49 migrations, `DbConn::new_in_memory`, `create_user`,
`create_thread`, `create_thread_message`, `list_thread_messages`, the unscoped
query, and the leak. Hand-added AFG scaffolding (as in every AFG demo of this
vintage): the per-request `with_afg_context` wrap, which AFG does not auto-insert,
and the single node id 7000 standing for the shared `thread_messages` table the
static pass flagged in threads.rs.

## How to reproduce

See the README in the kit root. In short: build the producer (LLVM 19), then run
scripts/01_schema_db.sh, scripts/02_static.sh, scripts/03_dynamic.sh. Outputs land
in out/.
