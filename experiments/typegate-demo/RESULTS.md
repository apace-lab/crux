# Debug-type gate: real-IR verdict flip (typegate-demo)

This demo proves the debug-info type gate does real work: on identical compiled LLVM-19 IR
it flips a data-access site from wrongly dominated to correctly flagged, catching a leak that
type-blind points-to misses. It is the vaultwarden shape in miniature (an organization-level
check standing in for a per-cipher check).

## The program (`typegate_demo.rs`)

One context struct holds two different resource types:

```rust
struct Org    { id: u64 }
struct Cipher { secret: u64 }
struct Ctx    { org: Org, cipher: Cipher }

#[inline(never)] fn authorize(o: &Org) -> bool { ... }      // cataloged: authorization
#[inline(never)] fn read_cipher(c: &Cipher) -> u64 { ... }  // cataloged: data-read

#[inline(never)] fn handler(ctx: &Ctx) -> u64 {
    if authorize(&ctx.org) {       // check guards the Org
        read_cipher(&ctx.cipher)   // read touches the Cipher (a DIFFERENT type)
    } else { 0 }
}
```

Compiled to LLVM-19 IR (rustc 1.86, `-C opt-level=0 -C debuginfo=2`), the handler is:

```
authorize(ptr %ctx)                                  ; &ctx.org is offset 0, so %ctx is passed directly
%_4 = getelementptr inbounds i8, ptr %ctx, i64 8     ; &ctx.cipher (cipher is at offset 8)
read_cipher(ptr %_4)
```

Under opaque pointers the Org-check argument (`%ctx`) and the Cipher-read argument
(`%_4`, a byte-offset GEP temporary) both trace to the same `ctx` base. A type-blind
points-to therefore treats them as the same resource, so the dominating Org-check appears to
cover the Cipher-read.

## The result: the gate flips the verdict (`ab_output.txt`)

Same IR, the debug-type gate toggled with `CRUX_NO_TYPE_GATE`:

```
GATE OFF (points-to only):  1 data-access, 1 DOMINATED, 0 candidates   <- leak hidden (false negative)
GATE ON  (debug types):     1 data-access, 0 dominated, 1 CANDIDATE    <- leak caught
                            1 check and 1 access carry a recovered struct type
```

- **Gate off:** points-to merged `%ctx` and `%_4` into one resource, so the Org-check
  wrongly covered the Cipher-read and the access was cleared. This is the precision loss the
  opaque-pointer caveat describes.
- **Gate on:** the propagated debug types are `Ctx` for the check argument and `Cipher` for
  the access argument. They are disjoint, so the check is not bound to the access's resource
  (`dominance::type_disjoint`), and the access is correctly a candidate.

The access argument `%_4` is a compiler-generated **temporary** (a GEP result), not a named
source variable. It is typed only because `DebugTypes::propagate_types` propagates the
recovered struct types through the SSA dataflow (here: `%ctx : &Ctx` -> GEP at offset 8 ->
`Cipher`). This is what connects the type recovery to real access sites, whose resource
pointer is almost always a temporary.

## Reproduce

```sh
cd experiments/typegate-demo
rustc +1.86.0 --edition 2021 --crate-type bin --emit=llvm-ir \
  -C opt-level=0 -C debuginfo=2 -C codegen-units=1 typegate_demo.rs -o typegate_demo_dbg.ll
cd ../../
# gate off:
LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 CRUX_APP_CRATE=typegate_demo CRUX_NO_TYPE_GATE=1 \
  ./target/release/afg --llvm-ir experiments/typegate-demo/typegate_demo_dbg.ll \
  --ac experiments/typegate-demo/demo_ac.json \
  --data-access experiments/typegate-demo/demo_data.json \
  --llm-api experiments/typegate-demo/demo_llm.json --static-only
# gate on: drop CRUX_NO_TYPE_GATE.
```

Unit/integration coverage: `rail-rs` `debuginfo::tests::real_propagation` (ignored, run with
`CRUX_TYPEGATE_LL` pointing at this IR) asserts the temporary `%_4` types to `Cipher` and
`%ctx` to `Ctx`; the dominance type-gate logic is covered by
`dominance::tests::type_disjoint_check_is_candidate` and siblings.
