# CRUX on TabbyML/tabby

Runs CRUX against TabbyML/tabby, a real self-hosted AI coding assistant (~45k lines
of Rust), and reproduces a cross-user data leak: one user can read another user's
chat thread. Target: tabby commit `21b2904` (branch `nightly`). Of CRUX's three
targets this is the leak case (bionic-gpt and AppFlowy-Cloud are the clean ones).

## What we found

tabby stores chat threads in a shared sqlx table, and the query that lists a
thread's messages does not filter by user. So any logged-in user who supplies
another user's thread id is served that thread's messages.

In `ee/tabby-db/src/threads.rs`, `list_thread_messages` builds
`WHERE thread_id = {id}` with no `user_id` in the predicate. There is no ownership
check on the read. In plain terms: ask for someone else's thread by id and you get
their messages.

Static: the producer finds the instrumentation sites by symbol from the catalogs,
about 2 auth, 4 llm, and 105 data-access (the sqlx reads and writes on the thread
store, plus `jsonwebtoken::decode` at jwt.rs). Full counts in results/RESULTS.md.

Dynamic: two users through tabby's real tabby-db code. The trace
(results/trace.jsonl):

```
access  alice  node 7000  Write     alice creates a thread + message
access  bob    node 7000  Read      bob reads alice's thread
leak    bob    owner alice          bob served "ALICE-PRIVATE: quarterly numbers"
```

`crux_observe` over that trace:

```
overlap: alice <-> bob on node 7000
leak: bob read alice's thread (the unscoped list_thread_messages)
```

What it means: alice and bob both reach the shared thread store (node 7000), and
bob's read returns alice's data, so it is a confirmed cross-user leak. Contrast the
other two apps: bionic-gpt puts the ownership check in the SQL and Postgres
row-level security, AppFlowy-Cloud puts it in casbin; tabby has neither.

## How to reproduce

Prerequisites: this CRUX checkout with the producer built (rustc 1.85 emits LLVM 19
IR, LLVM 19 at `/opt/homebrew/opt/llvm@19`), the sqlite3 CLI, and a tabby checkout
at `$TABBY` (`cargo fetch`-ed). Put the absolute path of `afg_prototype/crux_r4_runtime`
in the harness Cargo.toml. Build the producer once:

```sh
cd ../..                      # $CRUX_ROOT/afg_prototype
LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 cargo build --bin crux
```

Then run the three stages:

```sh
cd afg_prototype/experiments/tabby-repro
bash scripts/01_schema_db.sh     # schema-only sqlite DB from tabby's 49 migrations
bash scripts/02_static.sh        # emit tabby-webserver IR + run the producer
bash scripts/03_dynamic.sh       # drive tabby's real DB code as two users -> trace + leak
```

Outputs land in `out/` (gitignored). Paths are configurable in `scripts/config.sh`
(or via env: `CRUX_ROOT`, `TABBY`, `LLVM_SYS_191_PREFIX`, `RUST`, `DB`). View the
trace in the dashboard:

```sh
cd ../../crux_dashboard
cargo run -- --trace ../experiments/tabby-repro/out/trace.jsonl   # http://127.0.0.1:8090
```

What each stage does: 01 applies tabby's `*.up.sql` migrations to a throwaway
sqlite file (sqlx's compile-time `query!` macros need a live schema); 02 emits
`tabby-webserver` to IR on rustc 1.85 and runs `crux --static-only`
(`CRUX_APP_CRATE=tabby_webserver`, a lib crate with no `main`); 03 copies the
harness into the tabby workspace, runs it, and restores the checkout.

## What is real tabby vs CRUX scaffolding

Real tabby: the schema and 49 migrations, `new_in_memory`, `create_user`,
`create_thread`, `create_thread_message`, `list_thread_messages`, the unscoped
query, and the leak. Hand-added: the per-request `with_crux_context` wrap and the
node id 7000 standing for the shared `thread_messages` table the static pass
flagged. This db-crate harness was the early approach; the bionic and AppFlowy
experiments instrument the real app end to end instead. The instrumenter now
inserts before the enclosing statement, so it handles tabby's multi-line sqlx
chains (the old blocker), validated on `rail-rs/examples/demo_data_access`.
