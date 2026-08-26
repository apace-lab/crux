// Two users through the SAME handler (the real-app shape the static model can't
// distinguish), sharing one LLM endpoint. AFG auto-instrumentation adds
// afg_auth! (per-user principal) + afg_access!; the dynamic run distinguishes
// the users at runtime and flags the shared access.
use afg_runtime::{with_afg_context, AfgContext};

pub mod jsonwebtoken {
    #[inline(never)]
    pub fn decode(user: &str) -> bool {
        !user.is_empty()
    }
}

pub mod async_openai {
    pub mod chat {
        pub struct Chat;
        impl Chat {
            #[inline(never)]
            pub fn create(&self, request: &str) -> String {
                format!("(answer for '{}')", request)
            }
        }
    }
}

#[inline(never)]
fn handle_request(user: &str, prompt: &str) -> String {
    if !jsonwebtoken::decode(user) {
        return String::new();
    }
    let client = async_openai::chat::Chat;
    client.create(prompt)
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let a = tokio::spawn(with_afg_context(AfgContext::default(), async move {
        let _ = handle_request("alice", "alice private prompt");
    }));
    let b = tokio::spawn(with_afg_context(AfgContext::default(), async move {
        let _ = handle_request("bob", "bob private prompt");
    }));
    let _ = tokio::join!(a, b);
}
