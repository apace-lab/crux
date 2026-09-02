// AFG live demo: a runnable chat service instrumented by the real AFG pipeline.
// This source carries NO hand-written AFG macros; it uses catalog-matching stubs
// (`jsonwebtoken::decode`, `async_openai::chat::Chat::create`) so the AFG
// producer finds the auth + LLM sites and the instrumenter inserts
// afg_auth!/afg_access!/afg_schedule_point! (with the real PANode id). See run.sh:
// compile -> `afg --instrument-only` -> run the instrumented copy live. Two AFG
// pieces are added by hand: `with_afg_context` (per-request context), and the
// accesses to the app's OWN shared cache (a Write on store, a Read on hit) --
// the cache is not a cataloged SDK call, so the pipeline cannot find it; a
// developer marks their app's shared resources.
//
// UI: `/` is a single-user chat (open it in two browsers, sign in as alice and
// bob); `/admin` is the AFG console (sign in as afg@example.com).
use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};
use std::sync::{Mutex, OnceLock};

use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use axum::{
    extract::Query,
    http::StatusCode,
    response::{Html, IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};

use afg_observe::analyze_traces;
use afg_runtime::{with_afg_context, AfgContext};
use afg_scheduler::generate_schedules;

// The application's OWN shared cache. It is not a cataloged SDK call, so AFG's
// producer cannot find it; the developer marks its accesses by hand (Write when
// caching an answer, Read when serving from cache). Auth + the LLM call are still
// instrumented automatically by the pipeline.
const CACHE_NODE: u64 = 5000;
const HANDLER_FN: u64 = 424242;

// Bearer-token authentication. Deterministic stand-in for the real crate; AFG
// matches jsonwebtoken::decode (authentication) and takes its first argument as
// the principal.
mod jsonwebtoken {
    pub struct DecodingKey;
    pub struct Validation;
    pub struct Claims {
        pub sub: String,
    }
    pub struct TokenData<T> {
        pub claims: T,
    }
    #[inline(never)]
    pub fn decode(
        token: &str,
        _key: &DecodingKey,
        _validation: &Validation,
    ) -> Result<TokenData<Claims>, ()> {
        if token.is_empty() {
            return Err(());
        }
        Ok(TokenData {
            claims: Claims {
                sub: token.to_string(),
            },
        })
    }
}

// The LLM endpoint. Deterministic stand-in for async_openai; AFG matches
// async_openai::chat::Chat::create and marks its result as a per-user access.
mod async_openai {
    pub struct Client;
    impl Client {
        pub fn new() -> Self {
            Client
        }
        pub fn chat(&self) -> chat::Chat {
            chat::Chat
        }
    }
    pub mod chat {
        pub struct Chat;
        impl Chat {
            // Kept name-compatible with the catalog so AFG's producer still finds
            // and instruments this call; the body now calls a real LLM.
            #[inline(never)]
            pub async fn create(&self, request: &str) -> String {
                crate::llm_backend(request).await
            }
        }
    }
}

// Pluggable LLM backend: use GEMINI_API_KEY if set, else GROQ_API_KEY, else fall
// back to a canned answer so the demo runs with no key. Model names are
// overridable via GEMINI_MODEL / GROQ_MODEL.
async fn llm_backend(prompt: &str) -> String {
    if let Ok(key) = std::env::var("GEMINI_API_KEY") {
        if !key.trim().is_empty() {
            return match gemini(key.trim(), prompt).await {
                Ok(answer) => answer,
                Err(e) => format!("(gemini error: {e})"),
            };
        }
    }
    if let Ok(key) = std::env::var("GROQ_API_KEY") {
        if !key.trim().is_empty() {
            return match groq(key.trim(), prompt).await {
                Ok(answer) => answer,
                Err(e) => format!("(groq error: {e})"),
            };
        }
    }
    format!("Here is the assistant's answer to: \"{prompt}\"")
}

async fn gemini(key: &str, prompt: &str) -> Result<String, String> {
    let model = std::env::var("GEMINI_MODEL").unwrap_or_else(|_| "gemini-3.6-flash".to_string());
    let url = format!(
        "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
    );
    let body = serde_json::json!({ "contents": [{ "parts": [{ "text": prompt }] }] });
    let v: serde_json::Value = reqwest::Client::new()
        .post(&url)
        .json(&body)
        .send()
        .await
        .map_err(|e| e.to_string())?
        .json()
        .await
        .map_err(|e| e.to_string())?;
    v["candidates"][0]["content"]["parts"][0]["text"]
        .as_str()
        .map(str::to_string)
        .ok_or_else(|| format!("unexpected gemini response: {v}"))
}

async fn groq(key: &str, prompt: &str) -> Result<String, String> {
    let model = std::env::var("GROQ_MODEL").unwrap_or_else(|_| "llama-3.3-70b-versatile".to_string());
    let body = serde_json::json!({
        "model": model,
        "messages": [{ "role": "user", "content": prompt }],
    });
    let v: serde_json::Value = reqwest::Client::new()
        .post("https://api.groq.com/openai/v1/chat/completions")
        .bearer_auth(key)
        .json(&body)
        .send()
        .await
        .map_err(|e| e.to_string())?
        .json()
        .await
        .map_err(|e| e.to_string())?;
    v["choices"][0]["message"]["content"]
        .as_str()
        .map(str::to_string)
        .ok_or_else(|| format!("unexpected groq response: {v}"))
}

#[derive(Clone)]
struct User {
    id: u64,
    email: String,
    password_hash: String,
    role: String, // "user" | "admin"
}

#[derive(Clone, Serialize)]
struct CacheEntry {
    owner_id: u64,
    owner_email: String,
    answer: String,
}

#[derive(Clone, Serialize)]
struct Leak {
    reader: String,
    owner: String,
    prompt: String,
}

fn hash_password(password: &str) -> String {
    let salt = SaltString::generate(&mut OsRng);
    Argon2::default()
        .hash_password(password.as_bytes(), &salt)
        .expect("argon2 hashing failed")
        .to_string()
}

fn verify_password(password: &str, password_hash: &str) -> bool {
    let Ok(parsed) = PasswordHash::new(password_hash) else {
        return false;
    };
    Argon2::default()
        .verify_password(password.as_bytes(), &parsed)
        .is_ok()
}

static USERS: OnceLock<HashMap<String, User>> = OnceLock::new();
fn users() -> &'static HashMap<String, User> {
    USERS.get_or_init(|| {
        let list = [
            (1, "alice@example.com", "alicepass", "user"),
            (2, "bob@example.com", "bobpass", "user"),
            (3, "afg@example.com", "afgpass", "admin"),
        ];
        list.into_iter()
            .map(|(id, email, pw, role)| {
                (
                    email.to_string(),
                    User {
                        id,
                        email: email.to_string(),
                        password_hash: hash_password(pw),
                        role: role.to_string(),
                    },
                )
            })
            .collect()
    })
}

// VULNERABILITY: one global cache keyed by prompt only, shared by every user.
static CACHE: OnceLock<Mutex<HashMap<String, CacheEntry>>> = OnceLock::new();
fn cache() -> &'static Mutex<HashMap<String, CacheEntry>> {
    CACHE.get_or_init(|| Mutex::new(HashMap::new()))
}
fn cache_get(key: &str) -> Option<CacheEntry> {
    cache().lock().unwrap().get(key).cloned()
}
fn cache_put(key: String, entry: CacheEntry) {
    cache().lock().unwrap().insert(key, entry);
}

static LEAKS: OnceLock<Mutex<Vec<Leak>>> = OnceLock::new();
fn leaks() -> &'static Mutex<Vec<Leak>> {
    LEAKS.get_or_init(|| Mutex::new(Vec::new()))
}

// admin session tokens (gate the /afg console); separate from chat tokens.
static ADMIN_TOKENS: OnceLock<Mutex<HashSet<String>>> = OnceLock::new();
fn admin_tokens() -> &'static Mutex<HashSet<String>> {
    ADMIN_TOKENS.get_or_init(|| Mutex::new(HashSet::new()))
}
static ADMIN_SEQ: OnceLock<Mutex<u64>> = OnceLock::new();

static TRACE: OnceLock<PathBuf> = OnceLock::new();
fn trace_path() -> PathBuf {
    TRACE
        .get()
        .cloned()
        .unwrap_or_else(|| std::env::temp_dir().join("afg_live_demo_trace.jsonl"))
}

#[derive(Deserialize)]
struct LoginReq {
    email: String,
    password: String,
}
#[derive(Default, Serialize)]
struct LoginResp {
    ok: bool,
    token: String,
    email: String,
    role: String,
    error: Option<String>,
}

// argon2 credential check for a chat user. AFG classifies this as a credential
// check (not a principal source), so it carries no afg_auth!. The token returned
// stands in for a signed JWT whose subject is the user's email.
async fn login(Json(req): Json<LoginReq>) -> Json<LoginResp> {
    match users().get(&req.email) {
        Some(u) if u.role == "user" && verify_password(&req.password, &u.password_hash) => {
            Json(LoginResp {
                ok: true,
                token: u.email.clone(),
                email: u.email.clone(),
                role: u.role.clone(),
                error: None,
            })
        }
        _ => Json(LoginResp {
            error: Some("invalid credentials".into()),
            ..Default::default()
        }),
    }
}

// admin sign-in for the /afg console.
async fn admin_login(Json(req): Json<LoginReq>) -> Json<LoginResp> {
    match users().get(&req.email) {
        Some(u) if u.role == "admin" && verify_password(&req.password, &u.password_hash) => {
            let token = {
                let mut seq = ADMIN_SEQ.get_or_init(|| Mutex::new(0)).lock().unwrap();
                *seq += 1;
                format!("admintok-{}", *seq)
            };
            admin_tokens().lock().unwrap().insert(token.clone());
            Json(LoginResp {
                ok: true,
                token,
                email: u.email.clone(),
                role: "admin".into(),
                error: None,
            })
        }
        _ => Json(LoginResp {
            error: Some("invalid admin credentials".into()),
            ..Default::default()
        }),
    }
}

#[derive(Deserialize)]
struct ChatReq {
    token: String,
    prompt: String,
}
#[derive(Default, Serialize)]
struct ChatResp {
    ok: bool,
    answer: String,
    cache_hit: bool,
    leaked_from: Option<String>,
    error: Option<String>,
}

// The request handler. AFG auto-inserts afg_auth! before the token decode and
// afg_schedule_point!/afg_monitor!/afg_access! before the LLM call.
async fn chat(Json(req): Json<ChatReq>) -> Json<ChatResp> {
    let token = req.token.clone();
    let prompt = req.prompt.clone();
    let resp = with_afg_context(AfgContext::default(), async move {
        // single line: the instrumenter extracts the first argument (principal).
        let sub = match jsonwebtoken::decode(token.as_str(), &jsonwebtoken::DecodingKey, &jsonwebtoken::Validation) {
            Ok(data) => data.claims.sub,
            Err(_) => {
                return ChatResp {
                    error: Some("not logged in".into()),
                    ..Default::default()
                }
            }
        };
        let Some(user) = users().get(&sub) else {
            return ChatResp {
                error: Some("unknown user".into()),
                ..Default::default()
            };
        };
        let uid = user.id;

        if let Some(entry) = cache_get(&prompt) {
            // developer-marked: reading the app's shared cache.
            afg_runtime::afg_monitor!(function = HANDLER_FN);
            afg_runtime::afg_access!(node = CACHE_NODE, kind = afg_runtime::AccessKind::Read, function = HANDLER_FN);
            let leaked_from = if entry.owner_id != uid {
                Some(entry.owner_email.clone())
            } else {
                None
            };
            if let Some(owner) = &leaked_from {
                leaks().lock().unwrap().push(Leak {
                    reader: sub.clone(),
                    owner: owner.clone(),
                    prompt: prompt.clone(),
                });
            }
            return ChatResp {
                ok: true,
                answer: entry.answer,
                cache_hit: true,
                leaked_from,
                error: None,
            };
        }

        let client = async_openai::Client::new();
        let answer = client.chat().create(&prompt).await;
        // developer-marked: writing the answer into the app's shared cache.
        afg_runtime::afg_monitor!(function = HANDLER_FN);
        afg_runtime::afg_access!(node = CACHE_NODE, kind = afg_runtime::AccessKind::Write, function = HANDLER_FN);
        cache_put(
            prompt.clone(),
            CacheEntry {
                owner_id: uid,
                owner_email: sub.clone(),
                answer: answer.clone(),
            },
        );
        ChatResp {
            ok: true,
            answer,
            cache_hit: false,
            leaked_from: None,
            error: None,
        }
    })
    .await;
    Json(resp)
}

#[derive(Serialize)]
struct Event {
    seq: u64,
    kind: String,
    principal: String,
    node: Option<u64>,
    site: Option<u64>,
    function_id: Option<u64>,
    file: Option<String>,
    line: Option<u64>,
}
#[derive(Serialize)]
struct AfgState {
    events: Vec<Event>,
    principals: Vec<String>,
    scopes: serde_json::Value, // per-principal read/write nodes + functions
    overlaps: serde_json::Value,
    schedules: serde_json::Value,
    leaks: Vec<Leak>,
    trace_path: String,
}

fn read_events(path: &Path) -> Vec<Event> {
    let mut out = Vec::new();
    let Ok(text) = std::fs::read_to_string(path) else {
        return out;
    };
    for line in text.lines() {
        if line.trim().is_empty() {
            continue;
        }
        let Ok(v) = serde_json::from_str::<serde_json::Value>(line) else {
            continue;
        };
        let s = |k: &str| v.get(k).and_then(|x| x.as_str()).map(|x| x.to_string());
        let u = |k: &str| v.get(k).and_then(|x| x.as_u64());
        out.push(Event {
            seq: u("seq").unwrap_or(0),
            kind: s("event").unwrap_or_default(),
            principal: s("principal").unwrap_or_else(|| "?".into()),
            node: u("node"),
            site: u("site"),
            function_id: u("function_id"),
            file: s("file"),
            line: u("line"),
        });
    }
    out
}

#[derive(Deserialize)]
struct TokenQuery {
    token: Option<String>,
}
fn is_admin(token: &Option<String>) -> bool {
    token
        .as_ref()
        .map(|t| admin_tokens().lock().unwrap().contains(t))
        .unwrap_or(false)
}

// The AFG console data. Admin-only: requires a valid admin token.
async fn afg_state(Query(q): Query<TokenQuery>) -> Response {
    if !is_admin(&q.token) {
        return (StatusCode::FORBIDDEN, Json(serde_json::json!({"error":"admin token required"}))).into_response();
    }
    let tp = trace_path();
    let obs = analyze_traces(&[tp.clone()]).unwrap_or_default();
    let schedules = generate_schedules(&obs, 20);
    Json(AfgState {
        events: read_events(&tp),
        principals: obs.principals.keys().cloned().collect(),
        scopes: serde_json::to_value(&obs.principals).unwrap_or_default(),
        overlaps: serde_json::to_value(&obs.overlaps).unwrap_or_default(),
        schedules: serde_json::to_value(&schedules).unwrap_or_default(),
        leaks: leaks().lock().unwrap().clone(),
        trace_path: tp.display().to_string(),
    })
    .into_response()
}

async fn reset(Query(q): Query<TokenQuery>) -> Response {
    if !is_admin(&q.token) {
        return (StatusCode::FORBIDDEN, Json(serde_json::json!({"error":"admin token required"}))).into_response();
    }
    cache().lock().unwrap().clear();
    leaks().lock().unwrap().clear();
    Json(serde_json::json!({ "ok": true })).into_response()
}

async fn chat_page() -> Html<&'static str> {
    Html(include_str!("../static/chat.html"))
}
async fn admin_page() -> Html<&'static str> {
    Html(include_str!("../static/admin.html"))
}

#[tokio::main]
async fn main() {
    // Load .env (GEMINI_API_KEY / GROQ_API_KEY / *_MODEL) if present.
    let _ = dotenvy::dotenv();

    let tp = std::env::temp_dir().join("afg_live_demo_trace.jsonl");
    let _ = std::fs::remove_file(&tp);
    std::env::set_var("AFG_TRACE_PATH", &tp);
    let _ = TRACE.set(tp.clone());
    let _ = users(); // hash passwords up front

    let backend = if std::env::var("GEMINI_API_KEY").map(|k| !k.trim().is_empty()).unwrap_or(false) {
        "gemini"
    } else if std::env::var("GROQ_API_KEY").map(|k| !k.trim().is_empty()).unwrap_or(false) {
        "groq"
    } else {
        "stub (no API key; set GEMINI_API_KEY or GROQ_API_KEY in .env)"
    };
    println!("LLM backend: {backend}");

    let router = Router::new()
        .route("/", get(chat_page))
        .route("/admin", get(admin_page))
        .route("/login", post(login))
        .route("/admin/login", post(admin_login))
        .route("/chat", post(chat))
        .route("/afg", get(afg_state))
        .route("/reset", post(reset));

    let addr = "127.0.0.1:8080";
    let listener = tokio::net::TcpListener::bind(addr).await.expect("bind");
    println!("AFG live demo running on http://{addr}  (chat: /, console: /admin)");
    println!("trace: {}", tp.display());
    axum::serve(listener, router).await.expect("serve");
}
