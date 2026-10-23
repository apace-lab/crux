// CRUX dynamic cross-user check against TabbyML/tabby's REAL access-control code.
//
// This is the corrected, path-sensitive demonstration. The earlier version drove
// tabby-db's list_thread_messages directly, which bypasses the resolver layer. The
// access-control-enforcement analysis (results/ACCESS_CONTROL_ENFORCEMENT.md) showed that the
// normal read path (Query::thread_messages) IS guarded by
// AccessPolicy::check_read_thread, but the thread-to-page conversion path
// (Mutation::create_thread_to_page_run -> PageService::convert_thread_to_page) reads
// the same thread with NO ownership check. So the leak is real, but it lives on the
// conversion path, not the direct read.
//
// This harness uses tabby's REAL AccessPolicy and REAL list_thread_messages to show
// the contrast on a PRIVATE (ephemeral) thread:
//   - guarded path: check_read_thread refuses bob (correct).
//   - conversion path: the exact read sequence convert_thread_to_page performs
//     (get-for-existence, then list_thread_messages, no check) serves bob alice's
//     private thread.
// It does not run the LLM page generation that follows the read; the data is already
// exfiltrated at the read, which is what the CRUX probe records.
use crux_runtime::{with_crux_context, CruxContext};
use tabby_db::DbConn;
use tabby_schema::policy::AccessPolicy;
use tabby_schema::AsID;

// The shared thread_messages store (what CRUX flagged in threads.rs).
const THREADS_NODE: u64 = 7000;
const HANDLER_FN: u64 = 770077;

fn ctx(principal: &str) -> CruxContext {
    CruxContext {
        principal: Some(principal.to_string()),
        auth: None,
    }
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let db = DbConn::new_in_memory().await.expect("open in-memory tabby db");
    let alice = db
        .create_user("alice@example.com".into(), Some("x".into()), true, None)
        .await
        .expect("create alice");
    let bob = db
        .create_user("bob@example.com".into(), Some("x".into()), false, None)
        .await
        .expect("create bob");

    // Alice creates a PRIVATE (ephemeral) thread and posts a private message.
    // is_ephemeral = true means the thread is NOT shared: check_read_thread must
    // refuse non-owners. This is the data-WRITE to the shared thread store.
    let alice_thread = with_crux_context(ctx("alice@example.com"), async {
        let thread = db.create_thread(alice, true).await.expect("alice thread");
        crux_runtime::crux_monitor!(function = HANDLER_FN);
        crux_runtime::crux_access!(node = THREADS_NODE, kind = crux_runtime::AccessKind::Write, function = HANDLER_FN, resource = format!("thread:{thread}"), count = 1u64);
        db.create_thread_message(thread, "user", "ALICE-PRIVATE: quarterly numbers", None, None, None, false)
            .await
            .expect("alice message");
        thread
    })
    .await;

    // Bob's REAL access policy (a normal, non-admin authenticated user).
    let bob_policy = AccessPolicy::new(db.clone(), &bob.as_id(), false);

    // --- Path 1: the GUARDED read path (Query::thread_messages resolver logic) ---
    // The resolver calls user.policy.check_read_thread(thread.user_id, is_ephemeral)
    // before reading. For alice's private ephemeral thread, bob must be refused.
    let guarded = bob_policy.check_read_thread(&alice.as_id(), true);
    match &guarded {
        Err(_) => println!("[guarded path] check_read_thread REFUSES bob (correct)"),
        Ok(()) => println!("[guarded path] check_read_thread ALLOWED bob (unexpected!)"),
    }

    // --- Path 2: the CONVERSION read path (convert_thread_to_page logic) ---
    // convert_thread_to_page fetches the thread only to confirm existence, then calls
    // list_thread_messages with NO check_read_thread, and embeds the messages in a
    // page owned by the caller. Reproduce that exact read sequence as bob.
    with_crux_context(ctx("bob@example.com"), async {
        crux_runtime::crux_monitor!(function = HANDLER_FN);
        // convert_thread_to_page: `let _thread = self.thread.get(thread_id)...;`  (existence only)
        // convert_thread_to_page: `let thread_messages = self.thread.list_thread_messages(...)` (no check)
        let messages = db
            .list_thread_messages(alice_thread, None, None, false)
            .await
            .expect("conversion path reads alice's thread");
        crux_runtime::crux_access!(node = THREADS_NODE, kind = crux_runtime::AccessKind::Read, function = HANDLER_FN, resource = format!("thread:{alice_thread}"), count = messages.len() as u64);
        for m in &messages {
            if m.content.contains("ALICE-PRIVATE") {
                crux_runtime::crux_leak!(owner = "alice@example.com", detail = m.content.as_str());
                println!(
                    "[conversion path] bob served alice's PRIVATE thread (no check_read_thread): {}",
                    m.content
                );
            }
        }
    })
    .await;

    // The invariant: the same underlying read is dominated by check_read_thread on the
    // resolver path (bob refused) but NOT on the conversion path (bob served). The
    // un-dominated path is the bug.
    assert!(
        guarded.is_err(),
        "the guarded path should refuse bob on a private thread"
    );
    println!("done: guarded path refuses bob; convert_thread_to_page path serves him -> un-dominated path is the leak");
}
