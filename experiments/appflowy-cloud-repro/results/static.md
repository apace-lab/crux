# AppFlowy-Cloud: the static pass (and where it stops)

We wanted the static side to pair with the dynamic leak: run the AFG producer on
AppFlowy and have it flag, on its own, that the batch collab read is not guarded
by a casbin check. That did not fully work, and the reason is worth writing down
because it is about real-world code shape, not a bug.

Run date: 2026-09-16.

## What we did

AppFlowy pins rustc 1.86, which emits LLVM 19 IR, and the AFG producer is built
against LLVM 19, so the toolchains match (this is the one target where they do;
bionic needs 1.97 / LLVM 22, which the producer's IR parser does not read). We
emitted IR for the `appflowy-collaborate` crate (98 MB, the crate that holds both
the guarded read `get_full_encode_collab` and the unguarded `batch_get_collab`)
and ran `afg --static-only` with the catalogs. casbin's `enforce` is already in
the AC catalog, and we added the AppFlowy trait methods (`enforce_action`,
`enforce_access_level`) too.

## What we found

The producer auto-found the data-access sites: 11 of them, matching sqlx
(`fetch_one`, `fetch_optional`, `execute`), the dashmap cache (`get`, `insert`),
and redis (`get`). So AFG does locate the shared-store reads and writes.

It found zero access-control points. That is the gap.

## Why the guard is invisible to the static pass

AppFlowy holds its access control as `Arc<dyn CollabAccessControl>` and calls
`enforce_action` through it. That is a trait object, so the call is dynamic
dispatch: at the call site the IR loads the function pointer from a vtable and
calls it indirectly. There is no static callee name to match against the catalog.
The names `enforce_action` / `CollabAccessControl` do appear in the IR (34 times),
but only as the dyn call site and as type names, not as a resolvable call to a
known AC function. On top of that, the concrete implementation that actually calls
`casbin::CoreApi::enforce` lives in a different crate (`libs/access-control`), so
it is not even present in this crate's IR.

The data-access sites have the same shape problem from the other direction: they
resolve down into the library internals (sqlx's `query_as.rs`, the cache's
`mem_cache.rs`, etc.) rather than back to the handler methods, so the producer
cannot yet say "this specific read in the batch handler."

## What it would take to close the gap

Two capabilities, both of which the pointer analysis is the right foundation for,
and both of which are exactly where a points-to approach beats symbol or MIR
matching:

1. Devirtualize the trait-object AC call. Use the PAG points-to set of the
   `Arc<dyn CollabAccessControl>` receiver to resolve which concrete impl the call
   lands in, then match that impl (which does call `casbin::CoreApi::enforce`) as
   the AC point. This turns the invisible dyn guard into a real, matched AC site.

2. Analyze the whole program (the bin IR) so the concrete enforce impl and casbin
   are present, and attribute the monomorphized library data-access back to the
   app handler that issued it, so a read can be tied to the function it is in.

With those, the dominance check becomes: for each data-access site, is there an AC
point that dominates it on the path from the request handler. The single-get read
would be dominated, the batch read would not, which is the dynamic result reached
statically.

## Bottom line

Static AFG runs on AppFlowy and finds the shared-store accesses, but it cannot yet
see the casbin guard because the guard is behind dynamic dispatch across a crate
boundary, so it cannot auto-prove the missing check on this app. The dynamic run
(dynamic.md) does prove it. Pairing the two on AppFlowy is blocked on
devirtualization, not on the toolchain. On an app that calls its access check by a
concrete, statically dispatched function, the current producer would match it
directly (as it matches jsonwebtoken and sqlx here and in tabby).
