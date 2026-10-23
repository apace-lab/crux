# vaultwarden: static pass on the real whole-binary IR

This is the static producer run on the **real** vaultwarden binary IR, built with
vaultwarden's own pinned toolchain (rustc 1.84.1 -> LLVM 19.1.5, sqlite backend, debug +
`-C debuginfo=2`). It settles two things: the pipeline scales to a real large app, and the
static dominance / debug-type gate hits a real limitation on framework-guard auth.

Run on the lab server (`afg` built there against the installed LLVM-19 dev libs). IR size:
909 MB (`vaultwarden-*.ll`). Catalogs: `Membership::find_*` as authorization checks,
`Cipher::find_*` as data reads (`vw_ac.json`, `vw_data.json`).

## It scales (limit "the static pass cannot run on large apps" is false)

```
debug-info: 87192 struct type(s), 403664 value->type link(s) recovered
PAG solver: 1,608,027 nodes, 1,666,735 edges, converged in ~30 iterations
peak memory: 7.26 GB,  wall clock: 1m30s
```

The earlier claim that vaultwarden was "LLVM-20, static pass cannot run" was a
toolchain-selection error: vaultwarden pins rustc 1.84.1, which emits LLVM-19. Built that
way, the whole-binary IR processes in 90 seconds using 7 GB.

## Catalog coverage works: it finds the real CVE endpoints

41 semantic points matched: 21 authorization checks (`Membership::find_by_user_and_org`,
`find_confirmed_by_user_and_org`, `find_confirmed_by_user`) and 20 cipher reads
(`Cipher::find_by_user`, `find_by_org`, `find_by_uuid`, ...). The flagged data-access
candidates include the real CVE-2026-26012 surface:

```
[candidate] ...organizations::get_org_details   (the org-details cipher enumeration CVE)
[candidate] ...ciphers::get_cipher
[candidate] ...ciphers::get_ciphers
[candidate] ...ciphers::get_attachment, share_cipher_by_uuid, sync, ...
```

So the same catalog-matching approach used for the original large apps (tabby, AppFlowy,
zed) locates vaultwarden's security-relevant sites, including the vulnerable endpoint.

## Type tags now populate on the real async sites (step 1, done)

```
dominance (debug-types): 21 check(s) and 20 access(es) carry a recovered struct type
```

Initially this was `0 check(s) and 0 access(es)`, because the resource pointers at these
sites live inside async-state-machine closures (`...{{closure}}`) as coroutine captures or
spill temporaries, not named source `let`s, and two bugs kept them untyped. Both are fixed:

1. **Coroutine-env capture typing.** rustc stores an async fn's locals in a coroutine env
   and describes them with `#dbg_declare(ptr %env, !var, DIExpression(DW_OP_deref,
   DW_OP_plus_uconst, N))` (the captured variable lives at byte offset `N` in the env).
   `DebugTypes` now parses that DIExpression, records the env captures, and
   `propagate_types` types `getelementptr i8, env, N` + the loads off it, so captured
   resources get their type.
2. **Function-name normalization.** The textual `define` keeps the quotes around special
   symbols (`@"_ZN...$u7b$...E"`), so capture/declare records for async closures were keyed
   with quotes while the PAG's `SSAValue.function` (and the consumer lookup) use the
   normalized, unquoted name. The recovery now normalizes names the same way
   (`util::normalize_function_name`), so the keys match.

The tokens are the real resource types, for example at `Cipher::find_by_user`:
`%user_uuid -> UserId`, `%conn -> DbConn`; and at `Membership::find_by_user_and_org`:
`%_24 -> OrganizationId`. So the type gate now has real type information to bind on at
vaultwarden's async access sites, where it previously had none (same fix applies to any
async/framework target).

## The real enforcement pattern, and two characterized static-precision limits

Reading the actual handlers (not guesses), vaultwarden's per-cipher access control is an
**in-body check that dominates the serve**, not a Rocket guard:

- Safe `get_cipher`: `Cipher::find_by_uuid` (load) -> `cipher.is_accessible_to_user(user)`
  (per-cipher check) -> `Cipher::to_json` (serve). The check dominates the serve.
- CVE `get_org_details` -> `_get_org_details`: `Cipher::find_by_org` (loads all org ciphers)
  -> `Cipher::to_json` on each, with no per-cipher `is_accessible_to_user` (only a coarse
  `OrgMemberHeaders` guard). This is the CVE-2026-26012 enumeration leak.

So the invariant that fits is "every cipher serve (`to_json`) is dominated by a per-cipher
`is_accessible_to_user` bound to that Cipher." Cataloged that way (serve = `Cipher::to_json`,
check = `Cipher::is_accessible_to_user`), the pass flags `get_org_details` (correct). But a
*precise* verdict that also clears the safe `get_cipher` is blocked by two concrete, evidenced
issues, both specific to async Rust:

1. **Async method check calls were not matched by the catalog (now fixed).** Initially
   `is_accessible_to_user` matched 0 times: inside an async handler the call resolves to the
   coroutine form `Cipher::is_accessible_to_user::{{closure}}`, whose last-two-segments
   (`is_accessible_to_user::{{closure}}`) miss the `Cipher::is_accessible_to_user` entry. The
   matcher (`signature.rs`) now strips trailing compiler-generated segments (`::{{closure}}`,
   `::{async_fn#0}`, `::{closure#N}`, ...) when building candidate paths, so the coroutine
   body matches its user-named method. After the fix the per-cipher checks are located
   (`is_accessible_to_user` 6, `is_write_accessible_to_user` 22), and `get_cipher` now
   carries its checks (2 AccessControl) where it had none. Caveat: a logical async call can
   now match both its bare and its coroutine-body form (`Cipher::to_json` went 13 -> 46), so
   raw site counts over-count async calls; dedup by logical callsite is left for when exact
   counts are reported.

2. **Async coroutine state machines break CFG dominance (now resolved).** The `get_cipher`
   closure begins with a resume dispatch `switch i32 %_82, label ...`; every post-`await`
   block is reached from that switch, so a pre-`await` check block does not dominate the
   post-`await` serve block in the raw CFG. This is fixed by three parts working together:
   - **Coroutine-aware dominance** (`control_flow_graph.rs` `coroutine_rewiring` +
     `dominator_tree_coroutine`): detect the resume dispatch and rewire `entry -> resume` into
     `suspend -> resume`, so pre-`await` code dominates the resume.
   - **Body-form dedup** (`main.rs` `is_redundant_body`): an async call appears as both the
     construction `method(sret, &resource)` and the coroutine-body driver
     `method::{{closure}}(sret, env)`; the body form's arguments are the frame, not the
     resource, so when both exist for a method+category the body form is dropped as spurious.
   - **Env-capture resource identity** (`DebugTypes::capture_offset`): the captured resource is
     reloaded at the check and the serve into distinct points-to objects, so a per-capture
     token (by env offset) binds them as one instance (bypassing the shared-infra exclusion).

   With all three, vaultwarden's dominance goes from `0 dominated, 46 sites` to
   `6 dominated, 27 candidates`, the safe `get_cipher` is now **cleared** (0 candidates), and
   the CVE endpoint `get_org_details` stays **flagged**. The precise discrimination between the
   safe handler and the vulnerable one holds on real async framework code. The controlled
   demonstrations are `experiments/async-dominance-demo` (coroutine dominance flip) and
   `experiments/async-complex-demo` (the full load/check/serve shape, `get_cipher` cleared vs
   `get_cipher_leak` flagged). The rewiring and the capture identity are heuristic
   reconstructions of the coroutine structure; across all tests they improved precision without
   unsoundly clearing a known leak, but soundness on arbitrary coroutine shapes is not formally
   guaranteed.

## Decision and interpretation (coverage + dynamic)

Given those two limits are intrinsic to async framework code, vaultwarden is handled the same
way as the original large apps (tabby, AppFlowy, zed): the **static stage provides coverage**
(catalog-locates the security-relevant sites, including the real CVE endpoint
`get_org_details`), and the **leak verdict comes from the dynamic stage** (probe +
`crux_observe`), which is how vaultwarden's leak was confirmed in the dynamic datapoint. The
static dominance pass and the debug-type gate are a precision enhancement demonstrated to
flip a verdict on direct-call dominance (`experiments/typegate-demo`); making them precise on
async framework handlers requires async-method matching and coroutine-aware dominance, which
are recorded here as characterized future work rather than claimed. The step-2 catalogs used
for this analysis are on the lab server (`~/afg/vw_ac2.json`, `~/afg/vw_data2.json`).
