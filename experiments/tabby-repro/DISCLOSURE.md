# Security disclosure draft - tabby: cross-user thread disclosure via thread-to-page conversion

Status: DRAFT for the TabbyML maintainers. Do not publish or file publicly until they
have been contacted privately and given time to remediate. Report through TabbyML's
security policy (SECURITY.md / a private GitHub advisory), not a public issue.

## Summary

In tabby's enterprise web server, any authenticated user can read another user's chat
thread messages -- including private (ephemeral) threads -- by invoking the
`createThreadToPageRun` GraphQL mutation with the victim's thread id. The
thread-to-page conversion path reads the thread's messages without the ownership check
that the normal `threadMessages` query enforces, and embeds them in a page owned by
the caller.

- Component: `ee/tabby-webserver`, `ee/tabby-schema` (GraphQL API + services).
- Version examined: commit `21b2904` (analysis date 2026-09-23).
- Type: broken access control / missing authorization on one code path
  (CWE-285, CWE-639 authorization bypass through user-controlled key).
- Impact: confidentiality -- cross-user disclosure of private chat thread contents.

## Impact

Chat threads are per-user. The `threadMessages` query enforces this
(`AccessPolicy::check_read_thread`). But the thread-to-page conversion does not, so a
logged-in user can supply another user's thread id and receive that thread's messages
in a page they own. Thread ids are sequential integer rowids, so they are trivially
enumerable. Preconditions: any authenticated account (no special role).

## Technical details

Three facts combine:

1. The underlying query is unscoped. `DbConn::list_thread_messages`
   (`ee/tabby-db/src/threads.rs`) filters only by `thread_id`
   (`condition = "thread_id = {thread_id}"`), with no `user_id` predicate.

2. The normal read path guards it. `Query::thread_messages`
   (`ee/tabby-schema/src/schema/mod.rs`) calls
   `user.policy.check_read_thread(&thread.user_id, thread.is_ephemeral)` before the
   read. (Note: `check_read_thread` only restricts *ephemeral* threads; non-ephemeral
   "persisted" threads are intentionally readable by non-owners per the code comment
   and `setThreadPersisted`. That may be an intended sharing feature and is not the
   subject of this report.)

3. The conversion path does not guard it. `Mutation::create_thread_to_page_run`
   (guarded only by `check_user`, i.e. any authenticated user) calls
   `PageService::convert_thread_to_page` (`ee/tabby-webserver/src/service/page.rs`):

   ```rust
   async fn convert_thread_to_page(&self, policy, author_id, thread_id) -> ... {
       let _thread = self.thread.get(thread_id).await?          // existence check only
           .ok_or_else(|| CoreError::NotFound("Thread not found"))?;
       let thread_messages = self.thread
           .list_thread_messages(thread_id, None, None, None, None).await?;  // no ownership check
       self.page_run(policy, author_id, None, None, Some(&thread_messages)).await
   }
   ```

   It fetches the thread only to check existence, never calls `check_read_thread`, and
   passes the messages into a page owned by `author_id` (the caller). So the ownership
   check present on the `threadMessages` path is absent here, and this path exposes
   even private ephemeral threads.

## Reproduction

As user B (any authenticated account), issue the `createThreadToPageRun` mutation with
user A's `threadId` (an ephemeral/private thread). The resulting page run is built from
A's thread messages, disclosing them to B. (A minimal service-level reproduction that
drives the real `convert_thread_to_page` and records the unguarded read via an
instrumentation probe accompanies this report.)

## Suggested remediation

Add the same ownership check to the conversion path, before reading the messages, in
the same place the thread is fetched:

```rust
let thread = self.thread.get(thread_id).await?.ok_or(...)?;
policy.check_read_thread(&thread.user_id, thread.is_ephemeral)?;   // add this
let thread_messages = self.thread.list_thread_messages(thread_id, ...).await?;
```

More broadly: audit every caller of `list_thread_messages` (and other per-user reads)
to ensure each is dominated by `check_read_thread` / the appropriate ownership check --
the guard should not live only on the primary query path.

## Credit / context

Found while evaluating a research access-flow analysis tool on real Rust applications.
Happy to coordinate on timing and to verify a fix.
