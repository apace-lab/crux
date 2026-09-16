# AFG on TabbyML/tabby: reproduction kit

tabby is a real, self-hosted AI coding assistant (~45k lines of Rust). This kit
runs AFG against it and shows a genuine cross-user data leak: one user can read
another user's chat thread. Unlike the bionic-gpt and AppFlowy-Cloud experiments,
this one is a leak, not a clean app, so it is the positive example in the set.

Of the three targets it is also the best fit for AFG's catalogs: tabby's auth
(jsonwebtoken + argon2), LLM calls (async-openai / ollama-rs), and data store
(sqlx) all match, and it builds on rustc 1.85 / LLVM 19 with no nightly features.

## What we found

tabby stores chat threads in a shared sqlx table. The query that lists a thread's
messages does not filter by user. So any logged-in user who supplies another
user's thread id is served that thread's messages. AFG flags the shared store
statically and reproduces the actual cross-user read dynamically.

## How it happens

In `ee/tabby-db/src/threads.rs`, `list_thread_messages` builds
`WHERE thread_id = {id}` with no `user_id` in the predicate, and the policy layer
treats persisted threads as public within an instance. There is simply no
ownership check on the read. In AFG's terms, the read of the shared thread store
is not dominated by any check tied to the requesting user, which is exactly the
condition for a leak.

Contrast with the other two: bionic-gpt puts the ownership check in the SQL and in
Postgres row-level security, and AppFlowy-Cloud puts it in casbin. tabby has none.

## How we tested it

Two stages, both against tabby's real code.

Static: emit `tabby-webserver` to LLVM IR and run the AFG producer. It finds the
instrumentation sites by symbol from the catalogs: about 2 auth, 4 llm, and 105
data-access sites, including the sqlx reads and writes on the thread store, and
`jsonwebtoken::decode` at jwt.rs. See results/RESULTS.md for the exact counts.

Dynamic: drive tabby's real tabby-db code as two users. alice creates a thread
and a message, then bob reads alice's thread through `list_thread_messages` (the
unscoped query). Each user's calls are wrapped so the AFG trace attributes the
access to the right person. The run prints the leak and writes the trace that
afg_observe then analyzes into an overlap plus a leak on the shared thread node.

What is real tabby and what is AFG scaffolding, stated plainly: the schema, the
49 migrations, `new_in_memory`, `create_user`, `create_thread`,
`create_thread_message`, `list_thread_messages`, the unscoped query, and the leak
are all real tabby. The hand-added parts (as in every AFG demo of this vintage)
are the per-request `with_afg_context` wrap, which AFG does not auto-insert, and a
single node id (7000) standing for the shared `thread_messages` table that the
static pass flagged. This db-crate harness was the early approach; later
experiments (bionic, AppFlowy) instrument the real app end to end instead.

## How to reproduce

Prerequisites:

- This AFG checkout, with the data-access catalog and the `AFG_APP_CRATE`
  override (both are in rail-rs + afg_prototype). Build the producer once:
  ```sh
  cd ../..                      # $AFG_ROOT/afg_prototype
  LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 cargo build --bin afg
  ```
- rustc 1.85 (`rustup toolchain install 1.85.0`), which emits LLVM 19 IR.
- LLVM 19 (`/opt/homebrew/opt/llvm@19` by default).
- sqlite3 CLI (for the schema DB).
- A tabby checkout at `$TABBY` (default `/Users/sanjib/codes/apace_lab/tabby`),
  `cargo fetch`-ed. tabby needs no nightly features; the `cargo +nightly` in its
  Makefile is only for formatting.
- Put the absolute path of your `afg_prototype/afg_runtime` in the harness
  Cargo.toml.

Then run the three stages:

```sh
cd afg_prototype/experiments/tabby-repro
bash scripts/01_schema_db.sh     # schema-only sqlite DB from tabby's migrations
bash scripts/02_static.sh        # emit tabby-webserver .ll + run the producer
bash scripts/03_dynamic.sh       # drive tabby's real DB code as two users -> trace + leak
```

Outputs land in `out/` (gitignored): `static/instrumentation.json`, `static.log`,
`trace.jsonl`. All other paths are configurable in `scripts/config.sh` (or via
env: `AFG_ROOT`, `TABBY`, `LLVM_SYS_191_PREFIX`, `RUST`, `DB`).

To view the dynamic result in the dashboard:
```sh
cd ../../afg_dashboard
cargo run -- --trace ../experiments/tabby-repro/out/trace.jsonl   # http://127.0.0.1:8090
```

What each stage does:

- 01_schema_db.sh: tabby's `ee/tabby-db` uses sqlx compile-time `query!` macros,
  which need a live schema to typecheck. This applies the 49 `*.up.sql` migrations
  to a throwaway sqlite file with the sqlite3 CLI (no Postgres, no Docker) and
  exports `DATABASE_URL=sqlite://$DB`.
- 02_static.sh: emits `tabby-webserver` to IR on rustc 1.85
  (`-Cdebuginfo=1 -Ccodegen-units=1`, ~380M) and runs `afg --static-only`.
  `AFG_APP_CRATE=tabby_webserver` tells the producer to analyze a library crate
  that has no `main`, seeding that crate's functions as roots.
- 03_dynamic.sh: copies `harness/` into the tabby workspace as a member, runs it,
  and restores the checkout.

## What is and isn't bundled

Bundled: the two-user harness, the scripts, and the captured `results/`. Not
bundled (referenced by path, so you provide them): the tabby source tree (~9 GB)
at `$TABBY`, the AFG repo (producer + rail-rs + catalogs) at `$AFG_ROOT`, and the
built `afg` binary. Paths are absolute and configurable; the kit does not require
tabby and AFG to be siblings. AFG's own layout is unchanged: `afg_prototype` still
path-depends on `../rail-rs`, so those stay siblings inside the AFG repo.

## Known limitation

Fully automated instrumentation of tabby (`afg --instrument-only`) does not
compile yet: the instrumenter inserts its macros before the call line, which
splits tabby's multi-line sqlx method chains (`...\n.fetch_all(&self.pool)\n
.await?`). The fix is to insert before the enclosing statement, not the call line.
Until then the dynamic result uses the harness above, which marks the shared store
by hand, guided by the static findings. The workspace-aware afg_runtime injection
needed for a cargo workspace is already in afg_instrument.
