# spiceai: captured results

Target: `spiceai/spiceai` commit `94ed7f5a`, the `runtime` crate (a data-and-AI query
engine: federated SQL plus LLM/inference over accelerated data). Toolchain rustc 1.97
(LLVM 20), so the LLVM-19 static producer is blocked and this is a dynamic-plus-code
target, like bionic-gpt and zed. Run date 2026-09-30.

## Verdict: TRUE NEGATIVE (no cross-user leak), confirmed by CRUX's own probe

The shared resource is the per-principal query-result cache (both the SQL results cache
and the caching accelerator). spiceai isolates cached results per principal by folding a
cache namespace into the cache key, and a non-member is never served another principal's
cached row. Three independent lines of evidence agree: the code audit, spiceai's own
end-to-end regression test, and, most directly, CRUX's own dynamic probe and analyzer run
on spiceai's real cache code (see "CRUX instrumentation and dynamic verdict" below).

This is the 5th real target and a new enforcement mechanism: per-principal
cache-key namespacing (distinct from tabby's missing check, bionic's in-query
predicate, AppFlowy's casbin, and zed's membership check).

## The mechanism

- `CacheNamespace` (crates/runtime-request-context/src/cache_namespace.rs) is either
  `Public` (no or anonymous principal, entries shared) or `Principal(stable_id)`
  (scoped to one authenticated principal's opaque stable id).
- On every cache read, `try_get_cached_result`
  (crates/runtime/src/datafusion/query/cache.rs) folds the namespace into the key via
  `CacheKey::as_raw_key_in_namespace(hasher, ns_tag, ns_id)`. The write path uses the
  same namespaced key. Two principals therefore hash to two disjoint cache scopes.
- Client-supplied cache keys are double-scoped: `scoped_client_supplied_cache_key`
  prefixes an auth-header fingerprint, and `try_get_cached_result` then namespaces by
  the principal as well.
- The persistent accelerator stores a hidden `__spice_cache_namespace` column and the
  scan re-applies a strict `FilterExec` on the namespace so an accelerator that ignores
  the pushed-down predicate cannot leak another principal's rows.

## Why it holds (code audit)

- The two shipping authenticated principal types both derive a real `stable_id()`:
  `ApiKey` (SHA-256 of the key material, `apikey:<hex>`) and `MtlsPrincipal` (subject
  DN, with a certificate-fingerprint fallback). `Anonymous` uses the trait default
  `None`, which maps to `Public`, which is the intended shared scope.
- The SQL query endpoints (the cache consumers) set `auth_principal` on the request
  context in-handler, so the namespace is derived from the real principal on the cache
  path.

## The one caveat: the derivation is fail-open

`cache_namespace()` falls back to `Public` (shared) when the principal is missing or
its `stable_id()` is `None`, rather than failing closed. So the isolation depends on
the discipline that every authenticated principal type overrides `stable_id()` and
every cache-consuming endpoint sets `auth_principal`. Both hold in this commit, but a
future auth type that forgets `stable_id()`, or a new cache-consuming endpoint that
forgets to set the principal, would silently fall back to the shared namespace. This is
the opposite of bionic-gpt, whose check is fail-closed (a missing principal errors).

## Provenance: the leak class is real, and the failure modes match the CRUX criterion

spiceai ships `crates/runtime/tests/acceleration/caching_mode_per_principal.rs` as a
regression gate for this exact isolation. Its header documents two cross-principal
leaks the developers already hit and fixed, both of which are precisely what CRUX's
dominance/enforcement view targets:

1. Filters passed to `TableProvider::scan` are a hint, not a contract; an accelerator
   returning `Inexact`/`Unsupported` would serve another principal's rows. Fixed with a
   strict `FilterExec` re-application. In CRUX terms: the cache scan was not dominated by
   the namespace filter.
2. DataFusion does not propagate Tokio task-locals across `scan`/`execute`, so reading
   the namespace fell back to the internal context with no principal, collapsing every
   caller to one namespace. Fixed by pulling the request context from the
   `SessionConfig`/`TaskContext` extension. In CRUX terms: the fail-open namespace
   collapse described above.

## CRUX instrumentation and dynamic verdict

Rather than rely only on spiceai's own assertion, we instrumented spiceai's real cache
code with an CRUX probe and let CRUX's analyzer (`crux_observe`) reach the verdict from the
trace. The probe is added behind an off-by-default `crux-probe` cargo feature and is not
part of the shipped runtime:

- A shared probe module `crates/runtime-request-context/src/crux_probe.rs` emits the CRUX
  JSONL event format (`crux_runtime`'s `EventEnvelope` / `Event::Access`). It lives in
  `runtime-request-context` because both cache surfaces depend on that crate; it does not
  pull in `crux_runtime` itself (whose `madsim-tokio` dependency would conflict with
  spiceai's real Tokio).
- Two probe sites, one per principal-scoped cache surface:
  - the SQL results cache: `Query::get_plan_or_cached`
    (`crates/runtime/src/datafusion/query/cache.rs`), PANode 9100;
  - the caching accelerator: `CachingAccelerationScanExec::execute`
    (`crates/runtime-table/src/accelerated/caching.rs`), PANode 9200.
- The probe reads the principal directly from `RequestContext::cache_namespace()` (its
  `storage_id`), not a Tokio task-local. This matters: DataFusion does not propagate
  task-locals across `scan`/`execute`, and reading the principal from a task-local there
  is exactly one of the two cross-principal collapse bugs spiceai already fixed.
- Each cache access is recorded on its cache PANode with `resource` = the real
  namespaced cache key and `count` = rows served to the current principal. A hit is a
  `Read` with `count > 0`; a cross-namespace cold scan is a `Read` with `count = 0` (the
  namespace filter dominated it); a miss is followed by a `Write` that makes the
  principal the owner of that namespaced instance.

Driving spiceai's own two-principal e2e scenario with the probe active
(`CRUX_TRACE_PATH` set) produced a 12-event trace (`results/afg_trace.jsonl`) with two
API-key principals. `crux_observe` (via `cargo run --example analyze_trace`) reports:

```
principals: 2
coarse PANode overlaps (static-style signal): 1
  apikey:53b2... <-> apikey:8179... on nodes {9100, 9200}
resource-linked leak verdict: 0 confirmed leak(s)
  none: every cross-principal read of a shared instance returned no rows
        (dominated by an ownership check)
```

This is the full CRUX refinement in one run: the coarse overlap flags the cache as a
shared resource both principals reach (the static-style signal); the resource-linked
dynamic verdict then clears it, because the two principals' namespaced cache keys are
disjoint instances (alice `qkey:f7f0...` vs bob `qkey:6ae8...`; accelerator resources
differ only by the `__ns=` suffix) and bob's cold scan of the shared accelerator returns
`count = 0` (the namespace filter dominated his cross-principal read). A fail-open
collapse to the shared namespace would make the two principals' keys identical, turning
bob's later read into a non-owner read with `count > 0`, which `crux_observe` would report
as a confirmed leak; the probe therefore has real discriminating power and does not
assume the answer.

## Dynamic confirmation (spiceai's own regression test)

The same e2e regression test exercises the full pipeline (auth principal ->
RequestContext -> `Query::run_internal` -> `TableProvider::scan` ->
`CachingAccelerationScanExec::execute` -> DuckDB) with two API-key principals
(`alice-key-...`, `bob-key-...`) and asserts that bob never receives alice's cached
row. It passes:

```
running 1 test
test acceleration::caching_mode_per_principal::caching_accelerator_isolates_per_principal_e2e ... ok
test result: ok. 1 passed; 0 failed; ...; finished in 5.40s
```

Full output in `results/dynamic_test_output.txt`. Cold build 36m14s (rustc 1.97
auto-fetch plus bundled DuckDB); test 5.40s.

## How to reproduce

Prerequisites: a C++ toolchain and cmake (for bundled DuckDB), and enough disk (the
cold build produces tens of GiB of artifacts). The API keys are arbitrary strings
defined in the test; no external or LLM key is needed.

CRUX-native run (instrumented, produces the trace + verdict above):

```sh
cd spiceai
# 1. Drive spiceai's real cache code with the CRUX probe active.
CRUX_TRACE_PATH=/tmp/spiceai_afg_trace.jsonl \
  cargo test -p runtime --test integration --features duckdb,crux-probe -- \
  acceleration::caching_mode_per_principal::caching_accelerator_isolates_per_principal_e2e --nocapture

# 2. Reach the verdict with CRUX's analyzer.
cd ../AFG/crux
cargo run --example analyze_trace -- /tmp/spiceai_afg_trace.jsonl
```

Plain regression run (no CRUX instrumentation, spiceai's own assertion only):

```sh
cd spiceai
cargo test -p runtime --test integration --features duckdb -- \
  acceleration::caching_mode_per_principal::caching_accelerator_isolates_per_principal_e2e --nocapture
```

The `crux-probe` feature is off by default; with `CRUX_TRACE_PATH` unset the probe is a
no-op, so the instrumented binary and the plain binary behave identically otherwise.

## What to expect

- The build fetches rustc 1.97 and compiles bundled DuckDB (slow), then the `runtime`
  crate and the `integration` test binary.
- The test starts a mock upstream server, runs the 5-step alice/bob scenario, and
  prints `test result: ok. 1 passed`. bob's query in step 3 fetches upstream (a cache
  miss in bob's namespace) rather than reusing alice's cached row, and alice's step-5
  read is untouched by bob.
- With the probe active, `CRUX_TRACE_PATH` receives a 12-event JSONL trace and
  `analyze_trace` prints `1` coarse PANode overlap and `0` confirmed resource leaks.
- A failure would mean a cross-principal cache leak (bob served alice's row); this
  commit passes.
