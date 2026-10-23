# atuin: captured results

Target: `atuinsh/atuin` tag `v18.6.1`, the sync server (`atuin-server` +
`atuin-server-postgres`): a shell-history and key-value sync service. Many users sync
end-to-end-encrypted history and store records to one shared server process over HTTP,
backed by PostgreSQL, on Tokio. Toolchain rustc 1.86 (pinned in `rust-toolchain.toml`),
which emits LLVM 19, so atuin is also a candidate for the static producer (unlike dufs
and vaultwarden, which are LLVM 20). This is a non-LLM target. Run date 2026-10-02.

## Verdict: TRUE NEGATIVE (no cross-user leak)

Every data-access query in the server is scoped to the authenticated user with a
`where user_id = $1` predicate, so one user is never served another user's records. The
code audit is conclusive; a dynamic CRUX-native run (below) confirms it.

## The mechanism (verified in code)

- Each request carries the authenticated principal via the `UserAuth(user)` extractor
  (`crates/atuin-server/src/handlers/v0/record.rs`), which resolves the session token to a
  `user` and is threaded into every database call: `add_records(&user, ...)`,
  `status(&user)`, `next_records(&user, ...)`.
- The PostgreSQL backend (`crates/atuin-server-postgres/src/lib.rs`) binds `user.id` into
  every query. The record-sync read, `next_records`, is:

  ```sql
  select client_id, host, idx, timestamp, version, tag, data, cek from store
      where user_id = $1
        and tag = $2
        and host = $3
        and idx >= $4
      order by idx asc
      limit $5
  ```

  The client-supplied `host` and `tag` are always AND-ed with `user_id = $1`
  (`.bind(user.id)`), so a user cannot fetch another user's records by supplying a
  different host or tag. The history reads (`history`), session reads, counts, and the
  key-value `store` reads/writes are all scoped the same way (`where user_id = $1`), and
  the deletes likewise.

In CRUX terms the record read is dominated, on every path, by the `user_id = $1` predicate
that is part of the query itself. This is the same enforcement shape as bionic-gpt (the
ownership check is embedded in the SQL, not a separable pre-call), here on a non-LLM
service. It contrasts with dufs (separable check, consistently applied) and with
vaultwarden (separable check, omitted on one endpoint, which leaks).

## CRUX instrumentation and dynamic verdict

We instrumented atuin's real database layer with an CRUX probe behind an off-by-default
`crux-probe` cargo feature (not part of a normal build), using `serde_json` to serialize
the trace:

- A probe module `crates/atuin-server-postgres/src/crux_probe.rs`.
- Two probe sites on PANode 9400 in `atuin-server-postgres`: `add_records` (a record a
  user uploads, `function_id` 940001, recorded as `Write(user, store:<record-id>)`, the
  owner) and `next_records` (each record served to a user, `function_id` 940002, recorded
  as `Read(user, store:<record-id>, count=1)`). The store's stable per-record identity is
  the record's `client_id` (`= i.id`), so a write and a later read of the same record
  share one resource string.
- Built with `cargo build -p atuin --features atuin-server-postgres/crux-probe` on the
  pinned rustc 1.86; the server ran against a PostgreSQL 16 instance (Docker), which the
  server migrates automatically on start.

Scenario (driven over HTTP; no client crypto needed, record blobs are opaque to the
server): register `alice` and `bob`; alice uploads a record under host `Ha`
(`POST /api/v0/record`); bob uploads a record under host `Hb`; bob reads his own host
(`GET /api/v0/record/next?host=Hb`), then attempts bob reads alice's host
(`GET /api/v0/record/next?host=Ha`).

The probe produced a 3-event trace (`results/afg_trace.jsonl`):

```
seq1 Write user:1(alice) store:94b5...  940001 add_records   (alice owns her record)
seq2 Write user:2(bob)   store:50a3...  940001 add_records   (bob owns his record)
seq3 Read  user:2(bob)   store:50a3...  940002 next_records  count=1  (bob reads his OWN record)
```

bob's cross-user request (`next?host=Ha`) returned an empty list, so `next_records` served
zero rows and emitted no read event: the `where user_id = $1` predicate dominated the
read. `crux_observe` (`results/afg_observe_verdict.txt`) reports:

```
coarse PANode overlaps (static-style signal): 1   (alice and bob both reach node 9400)
resource-linked leak verdict: 0 confirmed leaks
```

This is the CRUX-native true negative: both principals reach the record-store node (the
coarse overlap), but each only ever touches records it owns (0 resource leaks), because
every query is scoped by `user_id`. A broken `next_records` that dropped the `user_id`
predicate would serve alice's `store:94b5...` to bob, which the probe would record as
`Read(bob, store:94b5..., count=1)` against owner alice, and `crux_observe` would report as
a confirmed cross-user leak. So the probe has real discriminating power and does not
assume the answer.

## Behavioral confirmation

In the same run, bob's `next(host=Hb)` returned his own record (`BOB-REC-B`) and not
`ALICE-REC-A`, and bob's `next(host=Ha)` (alice's host) returned an empty list, so a user
cannot fetch another user's records even by supplying another user's host id.

## Static datapoint (LLVM-19)

atuin pins rustc 1.86, which emits LLVM 19, so unlike dufs and vaultwarden (LLVM 20) the
CRUX static producer runs on it. We generated LLVM-19 IR for `atuin-server-postgres` (the
data-access crate) and ran the producer in static-only mode
(`afg --static-only --llvm-ir atuin_server_postgres.ll`, with `CRUX_APP_CRATE=
atuin_server_postgres`), using a local LLVM 19. Results:

- The PAG + inclusion-based points-to solver runs and reaches a fixed point: **31,754 PAG
  nodes, 33,286 edges, 26 iterations**. So the static engine scales on a real non-LLM
  application.
- The catalog locates **35 data-access sites** (23 reads, 12 writes), correctly attributed
  to atuin's real `Database` methods: `add_records`, `next_records`, `status`, `get_user`,
  `add_user`, `get_session`, `get_session_user`, `count_history`, `delete_user`,
  `update_user_password`, `user_verification_token`, and others, plus the underlying
  `sqlx_core::query_as::QueryAs::fetch_one` sites.
- **0 auth points, 0 principals, 0 static cross-user overlaps.** atuin's principal is
  established by a custom session lookup (`get_session_user`) and password hashing that
  lives in `atuin-server`, not by a cataloged auth library, so the static pass finds no
  principal-establishing site in this crate. With no static principal, there is no static
  cross-user overlap to report.

Two methodology notes. First, the IR must be built unoptimized (debug): a release build
inlines the sqlx calls and the catalog then matches 0 data-access sites; the debug IR
preserves the calls (same approach as the other LLVM-19 targets). Second, the
single-crate IR has no real `main`, so the app-crate heuristic must be overridden with
`CRUX_APP_CRATE` (otherwise it latches onto a monomorphized `core::slice::sort` function
and scopes the catalog to `core`). The opaque-pointer GEP warnings in the log are the
known LLVM-19 field-sensitivity limitation.

Interpretation: the static stage provides coverage (it locates atuin's data-access sites),
but the cross-user verdict comes from the dynamic stage above, which confirmed the
`user_id` scoping is a true negative. This matches the general finding that a real app
identifies every user at one shared extraction point (here a session lookup), so a single
static principal cannot distinguish two runtime users on the same handler path, and the
cross-user question is a runtime one.

## How to reproduce (audit)

```sh
cd atuin
# The record-sync read is scoped by user_id:
grep -n "where user_id" crates/atuin-server-postgres/src/lib.rs
# and the handlers thread the authenticated user into every DB call:
grep -n "UserAuth(user)\|&user" crates/atuin-server/src/handlers/v0/record.rs
```

Expect: every history/store/session query carries `where user_id = $1`, and no
record-serving query omits it (true negative).

## Debug-info type recovery datapoint (static, LLVM-19)

Re-run on the real `atuin-server-postgres` debug IR built with `-C debuginfo=2` (the
`target/debug` artifact on the lab server, 15 MB, 4050 `DICompositeType` nodes), using the
debug-info type recoverer (`rail_rs::debuginfo`):

```
debug-info: 4050 struct type(s), 6989 value->type link(s) recovered
dominance (debug-types): 0 check(s) and 0 access(es) carry a recovered struct type
```

The recoverer scales on a real application (4050 struct layouts, 6989 value-to-type links).
But no access site carries a type tag, for two structural reasons (not a bug): atuin has 0
cataloged access-control checks (its principal is a custom session lookup), so no resource
binding happens; and atuin's resource is the `where user_id = $1` predicate inside the SQL
string, not a typed struct pointer at the `fetch_one` call site. So atuin validates the
recoverer at scale, but its in-SQL enforcement style structurally cannot exercise the
debug-type binding gate. The gate applies to targets whose resource is a typed object reached
through a pointer (the vaultwarden shape), demonstrated in `experiments/typegate-demo`.
