# Coroutine-aware dominance: real-IR verdict flip (async-dominance-demo)

This demo proves coroutine-aware dominance: on identical compiled async IR it clears a safe
`async fn` that the plain dominator tree wrongly flags, because an `await` sits between the
check and the read. It is the async analog of `typegate-demo`.

## The program (`async_demo.rs`)

```rust
#[inline(never)] async fn authorize(r: &Resource) -> bool { ... }   // cataloged: authorization
#[inline(never)] async fn db_read(r: &Resource) -> u64 { ... }      // cataloged: data-read

#[inline(never)] async fn guarded(r: &Resource) -> u64 {
    if authorize(r).await {   // check (an await -> suspend point)
        db_read(r).await      // read sits in a post-await RESUME block
    } else { 0 }
}
#[inline(never)] async fn unguarded(r: &Resource) -> u64 { db_read(r).await }
```

Compiled to LLVM-19 IR (rustc 1.86, `-C opt-level=0 -C debuginfo=2`), each `async fn` is a
coroutine whose entry block dispatches on a state discriminant:

```
%3 = load i8, ptr (getelementptr i8, ptr %frame, i64 16)   ; the state field
switch i32 %state, label %bb7 [ i32 0,%bb1  i32 1,%resume1  i32 2,%resume2  ... ]
```

Because `db_read`'s call is in a resume block reached only from that switch, a plain
dominator tree does not see `authorize`'s block dominating it: the `await` breaks dominance.

## The result: coroutine normalization flips the verdict (`ab_output.txt`)

Same IR, toggled with `AFG_NO_COROUTINE_DOM`:

```
OFF (plain dominance):      4 data-access, 1 dominated, 3 candidates   <- guarded wrongly flagged (FP)
ON  (coroutine-aware):      4 data-access, 2 dominated, 2 candidates   <- guarded cleared; unguarded still flagged
```

- Gate off: `guarded`'s `db_read` (a resume block) is not dominated by `authorize`, so it is
  a false-positive candidate.
- Gate on: the recovery rewires the resume dispatch so the suspend block (where the state is
  stored before the `await` returns) flows to its resume block. Now `authorize`'s block
  dominates `db_read`'s block across the `await`, and `guarded` is cleared. The real
  `unguarded` leak stays flagged.

## How it works

`control_flow_graph.rs` `coroutine_rewiring` detects the async state machine: the entry block
loads a state discriminant from a fixed frame offset and `switch`es on it. A resume state is
one that some block stores into that field (just before suspending); that storing block is
the suspend whose continuation is the resume block (the start/unresumed state is never stored
inside the poll function, so it stays attached to the entry). Rewiring `entry -> resume` into
`suspend -> resume` makes pre-`await` code dominate the resume. `FunctionAnalysis::
dominator_tree_coroutine` builds the dominator tree over this normalized CFG; the dominance
pass uses it. For a non-coroutine function the detection returns `None` and the CFG is
unchanged (verified: `typegate-demo` and `dominance-demo` are identical with the feature on).

## Reproduce

```sh
cd experiments/async-dominance-demo
rustc +1.86.0 --edition 2021 --crate-type bin --emit=llvm-ir \
  -C opt-level=0 -C debuginfo=2 -C codegen-units=1 async_demo.rs -o async_demo_dbg.ll
cd ../../
# plain dominance (await breaks it):
LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 AFG_APP_CRATE=async_demo AFG_NO_COROUTINE_DOM=1 \
  ./target/release/afg --llvm-ir experiments/async-dominance-demo/async_demo_dbg.ll \
  --ac experiments/async-dominance-demo/demo_ac.json \
  --data-access experiments/async-dominance-demo/demo_data.json \
  --llm-api experiments/async-dominance-demo/demo_llm.json --static-only
# coroutine-aware: drop AFG_NO_COROUTINE_DOM.
```

Unit coverage: `rail-rs` `control_flow_graph::coroutine_tests` (detects the async coroutine,
skips a plain fn, and checks suspend-dominates-resume in the normalized CFG) against the
committed fixture `rail-rs/tests/fixtures/async_demo_dbg.ll`.

## On real applications (vaultwarden)

With coroutine dominance plus the async-method check matching, vaultwarden's static dominance
goes from 0 to 6 serves dominated, and the CVE endpoint `get_org_details` stays flagged (no
unsound clearing of the known leak). The safe `get_cipher` remains a residual false positive:
its real coroutine is far more complex than this demo (several awaits, `let-else`, nested
branches, drop glue), so the heuristic rewiring only partially linearizes it. So the feature
is a real precision improvement, demonstrated to flip cleanly on a controlled case and to
recover real check-before-serve dominance at scale, but it does not fully clear every complex
real handler. The rewiring is a heuristic reconstruction; across these tests it improved
precision without unsoundly clearing a known leak, but soundness on arbitrary coroutine
shapes is not formally guaranteed.
