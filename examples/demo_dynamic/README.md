# afg_dyn_demo

A runnable MadSim demo that exhibits a cross-user data leak in the *real-app
shape*: two users (alice, bob) flow through the **same** handler and share one
LLM endpoint. The static model can't distinguish them (one auth call site), so
this exercises AFG's **dynamic per-user** path end-to-end.

## Run the full AFG pipeline on it

```sh
# 1) compile the demo to LLVM IR with debug info
cd demo_dynamic
cargo +1.85.0 rustc --bin afg_dyn_demo -- --emit=llvm-ir -Cdebuginfo=2
LL=$(ls -t target/debug/deps/afg_dyn_demo-*.ll | head -1)

# 2) run afg_engine -> instrument -> observe (MadSim) -> analyze -> schedule
cd ../../afg_prototype
LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 \
  ./target/debug/afg --llvm-ir "../afg/demo_dynamic/$LL" \
  --project ../afg/demo_dynamic --run-dir /tmp/afg_dyn --cargo-cmd run --seeds 1
```

Expected: the analyzer reports `overlaps: [{left: alice, right: bob, shared_nodes: [..]}]`
and the scheduler writes a replay schedule. AFG auto-inserts `afg_auth!` (principal
from the auth call's first argument) and `afg_access!`; the app itself is uninstrumented.
