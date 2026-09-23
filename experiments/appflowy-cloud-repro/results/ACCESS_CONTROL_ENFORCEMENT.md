# Access-control enforcement - AppFlowy-Cloud

Second application of the access-control-enforcement analysis (for every data-access
site, is it dominated by an access-control check?), on AppFlowy-Cloud commit
`c5bcfd3`. Confirms the known leak precisely and reinforces the path-sensitivity
lesson from the tabby analysis.

## Method

1. Static producer catalog (`static.md`): 11 data-access sites in
   `appflowy-collaborate`, and 0 access-control points resolved -- AppFlowy holds
   access control as `Arc<dyn CollabAccessControl>` and calls `enforce_action`
   through it (dynamic dispatch), so the static pass cannot see the AC points
   without devirtualization.
2. Key structural fact: AppFlowy pushes the access check DOWN into the storage layer
   (`services/appflowy-collaborate/src/collab/collab_store.rs`). Each collab read is
   a method there, and the enforcement question is whether that method calls
   `access_control.enforce_action(..., Action::Read)` before serving. So the analysis
   must be traced into the storage methods (the check is not in the HTTP handlers).

## Output: enforcement over collab-read storage methods

| collab read storage method | enforces access? | verdict |
|---|---|---|
| `get_full_encode_collab` | yes (`access_control.enforce_action(workspace_id, uid, object_id, Action::Read)`) | OK (dominated) |
| `batch_get_collab` | **no** -- takes `_uid` (unused) and calls `batch_get_full_collab(...)` with no enforce | **UNSCOPED -> leak** |

Sibling write/delete methods (`delete_collab`, `upsert_collab`) do enforce
(`enforce_access_level` / `enforce_action`), which makes `batch_get_collab` the clear
outlier: the developer pushed the check into every storage method except this one.

## The leak (path-sensitive, same shape as tabby)

The same collab store is read by two paths with different enforcement:
- `GET /api/workspace/{ws}/collab/{id}` -> `get_collab_handler` ->
  `collab_storage.get_full_encode_collab(...)` -- **dominated** (enforces Read).
- `GET /api/workspace/{ws}/collab_list` (batch) -> `batch_get_collab_handler` ->
  `collab_storage.batch_get_collab(_uid, ...)` -- **not dominated** (uid ignored, no
  enforce).

So a non-member is refused on the single-get path and served the document on the
batch path. This matches the dynamic reproduction (`dynamic.md`): a non-member was
served 4393 bytes of another user's document through the batch endpoint. `afg_observe`
on that trace: 1 confirmed resource-linked leak.

## Reinforced lessons for the analysis design

- The enforcement check can live at different layers in different apps: at the HTTP
  resolver (tabby's `check_read_thread`) or pushed into the data/storage layer
  (AppFlowy's `get_full_encode_collab`). The analysis must follow into whichever layer
  holds the check.
- It is inherently **path-sensitive**: the leak is a sibling read path/method that
  omits the check its neighbors all have (tabby: `convert_thread_to_page`; AppFlowy:
  `batch_get_collab`).
- A cheap, high-signal heuristic for the data-layer case: a read method whose
  principal parameter is ignored (`_uid`) and that performs no `enforce_*` call is a
  strong candidate. `batch_get_collab` is exactly that.
- Full static automation is blocked here by dynamic dispatch (`Arc<dyn
  CollabAccessControl>`); resolving the AC points needs devirtualization via the
  receiver's points-to set (the case the static.md write-up already flagged).

## How to reproduce

1. Enumerate collab-read storage methods:
   `grep -n "async fn get_full_encode_collab\|async fn batch_get_collab" ../../../../AppFlowy-Cloud/services/appflowy-collaborate/src/collab/collab_store.rs`.
2. Check each method body for an access-control call before the read:
   `get_full_encode_collab` calls `access_control.enforce_action(workspace_id, uid, object_id, Action::Read)`;
   `batch_get_collab` takes `_uid` (unused) and calls `batch_get_full_collab(...)` with
   no enforce. Sibling `delete_collab` / upsert do enforce, so `batch_get_collab` is the
   outlier.
3. Dynamic confirmation: see `dynamic.md` (a non-member is served 4393 bytes of another
   user's document through the batch endpoint); `afg_observe` on `trace.jsonl` reports 1
   resource-linked leak.

Expect: `get_full_encode_collab` = dominated, `batch_get_collab` = unscoped (the leak),
matching the dynamic result.
