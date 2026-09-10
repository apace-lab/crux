// AFG dynamic cross-user check against TabbyML/tabby's REAL database code.
//
// AFG's static producer flagged tabby-db's thread store (ee/tabby-db/src/threads.rs:
// create_thread_message = data-write, list_thread_messages = data-read) as a shared
// data-access site, and confirmed those queries key on thread_id with NO user_id
// scope. This harness drives that real code as two users and records the accesses
// so afg_observe can see the cross-user overlap + leak.
//
// The store node id (THREADS_NODE) and with_afg_context are the hand-added AFG
// scaffolding (the per-request principal wrapping AFG does not auto-insert, and a
// single node standing for the shared thread_messages table). Everything else is
// tabby's own code + schema, run for real on an in-memory SQLite.
use afg_runtime::{with_afg_context, AfgContext};
use tabby_db::DbConn;

// The shared thread_messages table (what AFG flagged in threads.rs).
const THREADS_NODE: u64 = 7000;
const HANDLER_FN: u64 = 770077;

fn ctx(principal: &str) -> AfgContext {
    AfgContext {
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

    // Alice: create a persisted thread and post a private message. This is the
    // data-WRITE to the shared thread_messages store.
    let alice_thread = with_afg_context(ctx("alice@example.com"), async {
        let thread = db.create_thread(alice, false).await.expect("alice thread");
        afg_runtime::afg_monitor!(function = HANDLER_FN);
        afg_runtime::afg_access!(node = THREADS_NODE, kind = afg_runtime::AccessKind::Write, function = HANDLER_FN);
        db.create_thread_message(thread, "user", "ALICE-PRIVATE: quarterly numbers", None, None, None, false)
            .await
            .expect("alice message");
        thread
    })
    .await;

    // Bob: read Alice's thread by id. list_thread_messages scopes only by
    // thread_id (no user_id), so Bob is served Alice's message. This is the
    // data-READ from the same shared store, by a different principal.
    with_afg_context(ctx("bob@example.com"), async {
        afg_runtime::afg_monitor!(function = HANDLER_FN);
        afg_runtime::afg_access!(node = THREADS_NODE, kind = afg_runtime::AccessKind::Read, function = HANDLER_FN);
        let messages = db
            .list_thread_messages(alice_thread, None, None, false)
            .await
            .expect("bob reads alice's thread");
        let _ = bob;
        for m in &messages {
            if m.content.contains("ALICE-PRIVATE") {
                afg_runtime::afg_leak!(owner = "alice@example.com", detail = m.content.as_str());
                println!("[leak] bob was served alice's thread message: {}", m.content);
            }
        }
    })
    .await;

    println!("done");
}
