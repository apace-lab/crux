# AppFlowy-Cloud: static pass

Running the CRUX producer statically on AppFlowy, to see if it flags the missing
check on its own. Target: AppFlowy-Cloud commit `c5bcfd3`. Run date 2026-09-16.

## What we found

The producer finds the shared-store reads and writes, but not the casbin guard,
so it cannot yet auto-prove the missing check on this app.

We emitted IR for the `appflowy-collaborate` crate (98 MB; rustc 1.86 emits LLVM
19, which the producer reads) and ran `afg --static-only`. Result: 11 data-access
sites matched (sqlx `fetch_one` / `fetch_optional` / `execute`, dashmap `get` /
`insert`, redis `get`), and 0 access-control points.

The AC points are missing because AppFlowy holds access control as
`Arc<dyn CollabAccessControl>` and calls `enforce_action` through it. That is
dynamic dispatch: the call goes through a vtable, so there is no static callee name
to match against the catalog. The names appear in the IR (34 times) but only as
the dyn call site and as type names, and the concrete impl that actually calls
`casbin::CoreApi::enforce` lives in a different crate (`libs/access-control`) not
present in this IR. Adding the trait methods to the catalog does not help, because
the call is indirect.

## What it would take

Two capabilities, both of which points-to analysis is the right foundation for
(this is where a points-to approach beats symbol or MIR matching):

1. Devirtualize the trait-object call: use the PAG points-to set of the
   `Arc<dyn CollabAccessControl>` receiver to resolve the concrete impl, then
   match that impl (which does call casbin) as the AC point.
2. Analyze the whole program so the concrete enforce and casbin are present, and
   attribute the monomorphized library data-access back to the app handler.

With those, the dominance check becomes: for each data-access site, is there an AC
point that dominates it on the path from the handler. The single-get read would be
dominated, the batch read would not, which is the dynamic result reached
statically.

## How to reproduce

```sh
# emit IR for the crate (rustc 1.86 / LLVM 19; SQLX_OFFLINE=true)
cargo rustc -p appflowy-collaborate --lib -- --emit=llvm-ir -Cdebuginfo=1 -Ccodegen-units=1

# run the producer on it (lib crate -> CRUX_APP_CRATE)
CRUX_APP_CRATE=appflowy_collaborate LLVM_SYS_191_PREFIX=/opt/homebrew/opt/llvm@19 \
  afg --static-only --llvm-ir <the .ll> \
  --project .../services/appflowy-collaborate \
  --ac .../signatures/ac_functions.json \
  --data-access .../signatures/data_access_functions.json \
  --run-dir /tmp/afc_static
```

Expected: about 11 data-access sites, 0 auth, 0 AC points.

## Bottom line

Static CRUX runs on AppFlowy and finds the shared reads, but cannot see the casbin
guard because it is behind dynamic dispatch across a crate boundary, so it cannot
auto-prove the missing check here. The dynamic run (dynamic.md) does prove it.
Pairing the two on AppFlowy is blocked on devirtualization, not on the toolchain.
On an app that calls its access check by a concrete, statically dispatched
function, the producer matches it directly, as it does for jsonwebtoken and sqlx
here and in tabby.
