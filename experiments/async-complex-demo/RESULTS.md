# Complex async handler: load, check, serve (filling the coroutine gap)

This demo mirrors vaultwarden `get_cipher`'s real shape, which plain coroutine dominance alone
did not fully clear. It is what closed the last gap: the combination of coroutine-aware
dominance, body-form dedup, and env-capture resource identity now clears the safe handler
while flagging the leak, and the same fix clears the real `get_cipher` on vaultwarden.

## The program (`complex.rs`)

```rust
async fn find(id: u64) -> Option<Cipher> { ... }     // load (not cataloged)
async fn is_accessible(c: &Cipher) -> bool { ... }   // cataloged: authorization
async fn to_json(c: &Cipher) -> u64 { ... }          // cataloged: data-read (the serve/leak point)

// SAFE: load (let-else) -> check (if-branch) -> serve, each across its own `.await`.
async fn get_cipher(id: u64) -> u64 {
    let Some(c) = find(id).await else { return 0 };
    if !is_accessible(&c).await { return 0; }
    to_json(&c).await
}
// LEAK: load -> serve, no check (the CVE shape).
async fn get_cipher_leak(id: u64) -> u64 {
    let Some(c) = find(id).await else { return 0 };
    to_json(&c).await
}
```

## Result (`ab_output.txt`)

```
coroutine dominance OFF:   0 dominated, 2 candidates  (get_cipher wrongly flagged + the leak)
full (dom + capture + dedup): 1 dominated, 1 candidate  (get_cipher cleared; only the leak flagged)
```

So the safe `get_cipher` is cleared and the leaking `get_cipher_leak` stays flagged.

## Why plain coroutine dominance was not enough, and the three parts that fix it

With coroutine-aware dominance alone, `get_cipher` still had a residual false positive. The
diagnosis (via a per-site dominance dump) showed the cause was not linearization but two
async-lowering artifacts:

1. **Body-form double-counting.** An `async fn` call appears both as the construction
   `to_json(sret, &c)` (which carries the Cipher) and, after suffix-stripped matching, as the
   coroutine-body driver `to_json::{{closure}}(sret, env)` (whose arguments are the coroutine
   frame, not the Cipher). The body-form site is a spurious access. Fix: when a caller has
   both forms for the same method+category, drop the body form (`main.rs` `is_redundant_body`).

2. **Resource binding on captured variables.** The construction check `is_accessible(&c)` does
   dominate the construction serve `to_json(&c)` after coroutine normalization, but `c` is a
   coroutine capture reloaded at each site into distinct points-to objects, so their points-to
   sets do not intersect and `bound()` fails. Fix: **env-capture resource identity**
   (`DebugTypes::capture_offset`): a value that resolves to a given env capture offset carries
   a per-capture resource token; two sites using the same capture (same offset) share it and
   bind. The token bypasses the shared-infra exclusion (with few sites it would otherwise look
   ubiquitous).

3. **Coroutine-aware dominance** (the earlier `async-dominance-demo` result): the check block
   dominates the serve block across the `await`.

All three are needed: (3) gives dominance, (1) removes the spurious site, (2) binds the real
resource across reloads.

## On real vaultwarden

With all three, vaultwarden's safe `get_cipher` is now **cleared** (0 candidates) while the
CVE endpoint `get_org_details` stays **flagged**, and overall dominance goes to
`6 dominated, 27 candidates` (from `0 dominated, 46 sites`). So the precise static
discrimination between the safe handler and the vulnerable one holds on real async framework
code. The env-capture identity and the rewiring are heuristic reconstructions of the coroutine
structure; across all tests they improved precision without unsoundly clearing a known leak
(both demo leaks and the real CVE stay flagged), but soundness on arbitrary coroutine shapes
is not formally guaranteed.

## Reproduce

```sh
cd experiments/async-complex-demo
rustc +1.86.0 --edition 2021 --crate-type bin --emit=llvm-ir \
  -C opt-level=0 -C debuginfo=2 -C codegen-units=1 complex.rs -o complex_dbg.ll
cd ../../
LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 AFG_APP_CRATE=complex ./target/release/afg \
  --llvm-ir experiments/async-complex-demo/complex_dbg.ll \
  --ac experiments/async-complex-demo/demo_ac.json \
  --data-access experiments/async-complex-demo/demo_data.json \
  --llm-api experiments/async-complex-demo/demo_llm.json --static-only
# AFG_NO_COROUTINE_DOM=1 disables coroutine dominance for the A/B.
```

Unit coverage: `rail-rs` `debuginfo::tests::recovers_coroutine_capture_identity` (the captured
cipher is reloaded at multiple sites with a shared env offset) against the committed fixture
`rail-rs/tests/fixtures/complex_dbg.ll`.
