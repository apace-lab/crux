use afg_runtime::{
    afg_access, afg_auth, afg_monitor, afg_schedule_point, with_afg_context, AccessKind, AfgContext,
};
use std::sync::{Arc, Mutex};

// These IDs are emitted by your static AFG/source-instrumentation pass.
const FN_CHAT: u64 = 210;
const NODE_SHARED_CACHE: u64 = 1308;
const SITE_BEFORE_CACHE_WRITE: u64 = 401;
const SITE_BEFORE_CACHE_READ: u64 = 782;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let cache = Arc::new(Mutex::new(None::<String>));

    let alice_cache = cache.clone();
    let alice = tokio::spawn(with_afg_context(AfgContext::default(), async move {
        afg_auth!(
            principal = "alice",
            method = "oauth+mfa",
            permissions = ["chat.write", "cache.write"],
            duration_ms = Some(30 * 60 * 1000),
        );

        chat_write(alice_cache, "alice prompt".to_string()).await;
    }));

    let bob_cache = cache.clone();
    let bob = tokio::spawn(with_afg_context(AfgContext::default(), async move {
        afg_auth!(
            principal = "bob",
            method = "password",
            permissions = ["chat.read", "cache.read"],
            duration_ms = Some(8 * 60 * 60 * 1000),
        );

        let _ = chat_read(bob_cache).await;
    }));

    let _ = tokio::join!(alice, bob);
}

async fn chat_write(cache: Arc<Mutex<Option<String>>>, value: String) {
    afg_monitor!(function = FN_CHAT);

    afg_schedule_point!(site = SITE_BEFORE_CACHE_WRITE).await;

    afg_access!(
        node = NODE_SHARED_CACHE,
        kind = AccessKind::Write,
        function = FN_CHAT,
    );

    *cache.lock().unwrap() = Some(value);
}

async fn chat_read(cache: Arc<Mutex<Option<String>>>) -> Option<String> {
    afg_monitor!(function = FN_CHAT);

    afg_schedule_point!(site = SITE_BEFORE_CACHE_READ).await;

    afg_access!(
        node = NODE_SHARED_CACHE,
        kind = AccessKind::Read,
        function = FN_CHAT,
    );

    cache.lock().unwrap().clone()
}
