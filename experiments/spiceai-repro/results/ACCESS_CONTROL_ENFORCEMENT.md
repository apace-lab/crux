# Access-control enforcement - spiceai

Enforcement pass on spiceai commit `94ed7f5a`. Done dynamically plus code audit because
rustc 1.97 -> LLVM 20 blocks the static producer. This is the second true negative in
the set, and it is safe for the opposite reason to bionic: bionic fails closed, spiceai
folds the access scope into the cache key so no serve path can skip it.

## Mechanism (verified in code)

The shared resource is the per-principal query-result cache. spiceai has two cache
surfaces and both are scoped the same way:

1. **Cache-key namespacing, folded into every read and write.** Each request carries a
   `CacheNamespace` (`crates/runtime-request-context/src/cache_namespace.rs`, enum around
   L40): `Public` (no or anonymous principal, shared), `Principal(stable_id)` (one
   authenticated principal), or `System` (internal traffic). Every cache lookup folds the
   namespace into the hash key via `CacheKey::as_raw_key_in_namespace`. The SQL results
   cache does this in `try_get_cached_result`
   (`crates/runtime/src/datafusion/query/cache.rs`, around L353); the caching accelerator
   stores a hidden `__spice_cache_namespace` column and re-applies a strict `FilterExec`
   on it so an accelerator that ignores the pushed-down predicate still cannot serve
   another principal's rows. Two principals therefore hash to two disjoint cache scopes
   for otherwise-identical inputs.
2. **Per-request principal.** The SQL query endpoints set `auth_principal` on the request
   context in-handler, so the namespace is derived from the real principal on the cache
   path. The namespace itself is computed centrally in `cache_namespace()`
   (`crates/runtime-request-context/src/context.rs`, around L314).
3. **Stable principal id.** The two shipping authenticated principal types both derive a
   real `stable_id()` (`crates/runtime-auth/src/traits.rs`): `ApiKey` is the SHA-256 of
   the key material (around L88); the trait default is `None` (around L44), which
   `Anonymous` uses and which maps to the shared `Public` scope.

## The one caveat: the derivation is fail-open

`cache_namespace()` falls back to `Public` (shared) when the principal is missing or its
`stable_id()` is `None`, rather than failing closed. So the isolation depends on the
discipline that every authenticated principal type overrides `stable_id()` and every
cache-consuming endpoint sets `auth_principal`. Both hold at this commit. This is the
opposite of bionic-gpt, whose check is fail-closed (a missing principal errors). spiceai
is safe not because it errors on a missing principal, but because when a principal is
present the scope is baked into the key on every path, so there is no serve path that
skips it.

## Verdict: TRUE NEGATIVE, confirmed by CRUX's probe and analyzer

We instrumented spiceai's real cache code with an CRUX probe (an off-by-default
`crux-probe` cargo feature) at both cache serve sites: `get_plan_or_cached` (results
cache, PANode 9100) and `CachingAccelerationScanExec::execute` (accelerator scan, PANode
9200). The probe reads the principal from `RequestContext::cache_namespace()`, not a
Tokio task-local, on purpose: DataFusion not propagating task-locals across
`scan`/`execute` was one of the two cross-principal collapse bugs spiceai already fixed.

Driving spiceai's own two-principal (alice/bob) isolation scenario with the probe active
produced a 12-event trace (`afg_trace.jsonl`). CRUX's analyzer `crux_observe`
(`afg_observe_verdict.txt`) reports:

- 1 coarse PANode overlap (both principals reach the cache nodes 9100 and 9200, the
  static-style shared-resource signal);
- 0 confirmed resource leaks.

The refinement is visible in the trace: the two principals' namespaced cache keys are
disjoint instances (alice `qkey:f7f0...` vs bob `qkey:6ae8...`; the accelerator resources
differ only by the `__ns=` suffix), and bob's cold scan of the shared accelerator returns
`count = 0` because the namespace filter dominated his cross-principal read. A fail-open
collapse to the shared namespace would make the two principals' keys identical, turning
bob's read into a non-owner read with `count > 0`, which `crux_observe` would report as a
confirmed leak. So the probe has real discriminating power and does not assume the answer.

## Provenance: the leak class is real, mapped to the dominance criterion

spiceai ships `crates/runtime/tests/acceleration/caching_mode_per_principal.rs` as a
regression gate. Its header documents two cross-principal leaks the developers already
hit and fixed, both of which are exactly what the enforcement view targets:

1. Filters passed to `TableProvider::scan` are a hint, not a contract; an accelerator
   returning `Inexact`/`Unsupported` would serve another principal's rows. Fixed with a
   strict `FilterExec` re-application. In CRUX terms: the cache scan was not dominated by
   the namespace filter.
2. DataFusion does not propagate Tokio task-locals across `scan`/`execute`, so reading
   the namespace fell back to the internal context with no principal, collapsing every
   caller to one namespace. Fixed by pulling the request context from the
   `SessionConfig`/`TaskContext` extension. In CRUX terms: the fail-open namespace
   collapse described above.

## Where spiceai sits in the enforcement-style taxonomy

The five targets enforce at different points, and that predicts their failure modes:

| app | where the check lives | omittable per-path? | outcome |
|---|---|---|---|
| tabby | HTTP resolver (`check_read_thread`) | yes -> `convert_thread_to_page` omits it | LEAK |
| AppFlowy | storage method (`get_full_encode_collab`) | yes -> `batch_get_collab` omits it | LEAK |
| bionic | embedded in the query (`user_id = current_app_user()`), fail-closed | no | no leak |
| zed | membership check at join; live-session delivery | yes -> removal/downgrade not revalidated | LEAK |
| **spiceai** | **cache-key namespace** (`cache_namespace()` folded into every cache key) | **no** (fail-open default) | **no leak** |

bionic and spiceai are the two targets whose check cannot be omitted by a stray path.
bionic embeds it in the query and makes the principal mandatory (fail-closed). spiceai
folds the scope into every cache key, so identical inputs from two principals land in
disjoint cache entries (fail-open default, but skip-free in practice). The other three
leak exactly where the check is a separable step some path or point in time skips.

## Note

Full static automation would need the LLVM-19 producer (blocked here) plus modeling
`cache_namespace()` as the ownership scope folded into the cache key. Done as a code
audit plus the CRUX probe run, the pass confirms both cache surfaces namespace their keys
and that no cross-principal read is served rows.

## How to reproduce

Run these from the spiceai repo root (`cd spiceai`).

1. Confirm the cache namespace is folded into the key on the read path:
   `grep -n "as_raw_key_in_namespace\|cache_namespace" crates/runtime/src/datafusion/query/cache.rs`.
2. Confirm the accelerator stores and re-filters on the namespace column:
   `grep -n "__spice_cache_namespace\|FilterExec" crates/runtime-table/src/accelerated/caching.rs`.
3. Confirm the fail-open derivation and the stable ids:
   `grep -n "fn cache_namespace" crates/runtime-request-context/src/context.rs` and
   `grep -n "fn stable_id" crates/runtime-auth/src/traits.rs`.
4. CRUX-native dynamic confirmation (produces `afg_trace.jsonl` and the verdict):
   ```sh
   CRUX_TRACE_PATH=/tmp/spiceai_afg_trace.jsonl \
     cargo test -p runtime --test integration --features duckdb,crux-probe -- \
     acceleration::caching_mode_per_principal::caching_accelerator_isolates_per_principal_e2e --nocapture
   cd ../AFG/crux
   cargo run --example analyze_trace -- /tmp/spiceai_afg_trace.jsonl
   ```

Expect: both cache surfaces namespace their keys, the principal is derived per request,
`crux_observe` reports 1 coarse overlap and 0 confirmed leaks, and bob's cross-namespace
cold scan returns 0 rows (true negative).
