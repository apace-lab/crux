# AFG on TabbyML/tabby: reproduction kit

Runs AFG against **TabbyML/tabby** (a real, ~45k-LOC self-hosted AI coding
assistant) and shows both:

1. **Static**: the AFG producer finds tabby's MUMP instrumentation sites
   (auth + LLM + data-access), including the sqlx thread/message store.
2. **Dynamic**: two users through tabby's **real** database code produce a
   cross-user data leak that `afg_observe` detects (overlap + leak).

See `results/RESULTS.md` for the numbers captured on 2026-09-09, and
`results/trace.jsonl` for the exact AFG trace that run produced.

Tabby is the strongest real-world MUMP target found: its auth (`jsonwebtoken` +
`argon2`), LLM (`async-openai`/`ollama-rs`), and data store (`sqlx`) all match
AFG's catalogs, and it builds on the LLVM-19 toolchain with no nightly features.

## Why this is interesting

Tabby's `ee/tabby-db/src/threads.rs::list_thread_messages` builds
`WHERE thread_id = {id}` with **no user_id filter**, and the policy layer treats
persisted threads as "public within an instance". So any authenticated user who
supplies another user's thread id is served their messages. AFG flags the shared
store statically and reproduces the cross-user read dynamically.

## What is / isn't bundled

Bundled in this kit: the two-user harness, the scripts, and the captured
`results/`. NOT bundled (referenced by path, so you provide them):

- the **tabby** source tree (~9 GB) at `$TABBY`,
- the **AFG** repo (producer + rail-rs/ll_parser + catalogs) at `$AFG_ROOT`,
- the built **`afg`** binary.

Paths are absolute and configurable; the kit does NOT require tabby and AFG to be
siblings. The only two knobs that matter are `$AFG_ROOT` and `$TABBY` (see
`scripts/config.sh`); `03_dynamic.sh` rewrites the harness's afg-runtime path from
`$AFG_ROOT` automatically. Note that AFG's own internal layout is unchanged:
`afg_prototype` still path-depends on `../ll_parser` (rail-rs), so those stay
siblings inside the AFG repo as they already are.

## Prerequisites

- **This AFG checkout**, with the data-access catalog integration and the
  `AFG_APP_CRATE` override present (both are in `ll_parser` + `afg_prototype`).
  Build the producer once:
  ```sh
  cd ../..                      # $AFG_ROOT/afg_prototype
  LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 cargo build --bin afg
  ```
- **rustc 1.85** (`rustup toolchain install 1.85.0`) -- emits LLVM-19 IR, no GEP fix needed.
- **LLVM 19** (`/opt/homebrew/opt/llvm@19` by default).
- **sqlite3 CLI** (for the schema DB).
- A **tabby checkout** at `$TABBY` (default `/Users/sanjib/codes/apace_lab/tabby`),
  `cargo fetch`-ed. Tabby needs no nightly features; `cargo +nightly` in its
  Makefile is only for formatting.

All paths are configurable in `scripts/config.sh` (or via env: `AFG_ROOT`,
`TABBY`, `LLVM_SYS_191_PREFIX`, `RUST`, `DB`).

## Run it

```sh
cd afg_prototype/experiments/tabby-repro
bash scripts/01_schema_db.sh     # build a schema-only sqlite DB from tabby's migrations
bash scripts/02_static.sh        # emit tabby-webserver .ll + run the producer (finds ~111 sites)
bash scripts/03_dynamic.sh       # drive tabby's real DB code as two users -> AFG trace + leak
```

Outputs land in `out/` (gitignored): `static/instrumentation.json`, `static.log`,
`trace.jsonl`.

To view the dynamic result in the dashboard:
```sh
cd ../../afg-dashboard
cargo run -- --trace ../experiments/tabby-repro/out/trace.jsonl   # http://127.0.0.1:8090
```

## What each stage does

**01_schema_db.sh** -- tabby's `ee/tabby-db` uses sqlx compile-time `query!`
macros, which need a live schema to typecheck. This applies the 49 `*.up.sql`
migrations to a throwaway sqlite file via the `sqlite3` CLI (no Postgres/Docker),
and exports `DATABASE_URL=sqlite://$DB`.

**02_static.sh** -- emits `tabby-webserver` to LLVM IR on rustc 1.85
(`-Cdebuginfo=1 -Ccodegen-units=1`, ~380M) and runs `afg --static-only`.
`AFG_APP_CRATE=tabby_webserver` tells the producer to analyze a library crate
(tabby-webserver has no `main`); it seeds that crate's functions as roots.
Expected: ~2 auth, ~4 llm-access, ~105 data-access sites (see RESULTS.md).

**03_dynamic.sh** -- copies `harness/` into the tabby workspace as a member,
runs it, and restores the checkout. The harness (`harness/src/main.rs`) opens an
in-memory tabby DB (`DbConn::new_in_memory`, which runs the migrations), creates
two users, has **alice** create a persisted thread + message (data-write), then
has **bob** read alice's thread via `list_thread_messages` (data-read, unscoped) --
each wrapped in `with_afg_context` so the AFG trace attributes the access to the
right principal. It prints the leak and writes the trace `afg_observe` analyzes.

## Honest scope

Real tabby code exercised end to end: the schema + migrations, `new_in_memory`,
`create_user`, `create_thread`, `create_thread_message`, `list_thread_messages`,
the unscoped query, and the actual leak. Hand-added AFG scaffolding (as in every
AFG demo): the per-request `with_afg_context` wrap (AFG does not auto-insert it)
and a single node id (`7000`) standing for the shared `thread_messages` table
that AFG flagged in `threads.rs`.

## Known limitation surfaced here

Fully automated instrumentation of tabby (`afg --instrument-only`) currently
does not compile: the instrumenter inserts its macros before the *call line*,
which splits tabby's **multi-line** sqlx method chains
(`...\n.fetch_all(&self.pool)\n.await?`). The fix is to insert before the
enclosing statement, not the call line. Until then, the dynamic result uses the
harness above (which marks the shared store by hand, guided by AFG's static
findings). The workspace-aware afg-runtime injection needed for a cargo workspace
is already in `afg_instrument`.
