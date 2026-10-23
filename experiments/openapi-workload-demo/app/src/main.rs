// A tiny multi-user notes service that ships an OpenAPI spec (via utoipa). It has a
// deliberate IDOR cross-user leak: GET /notes/{id} returns any note regardless of owner,
// while GET /notes/{id}/owned enforces ownership. The crux_workload driver reads the spec,
// drives two users, and replays user A's created id under user B to find the leak.
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::io::Write;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Mutex;
use utoipa::OpenApi;

// Emit an CRUX resource-linked access event (the same JSONL format crux_runtime produces and
// crux_observe consumes). In a tokio app, crux_instrument + crux_runtime inject these
// automatically with the task-local principal; this sync server emits them directly, tagging
// the principal from the request. `count` is the rows served (0 = denied/empty = dominated).
static SEQ: AtomicU64 = AtomicU64::new(1);
fn crux_access(principal: &str, kind: &str, resource: &str, count: u64) {
    let Some(path) = std::env::var_os("CRUX_TRACE_PATH") else { return };
    let seq = SEQ.fetch_add(1, Ordering::SeqCst);
    let line = serde_json::json!({
        "event": "access", "seq": seq, "principal": principal,
        "node": 7000u64, "kind": kind, "function_id": 42u64,
        "resource": resource, "count": count
    });
    if let Ok(mut f) = std::fs::OpenOptions::new().create(true).append(true).open(&path) {
        let _ = writeln!(f, "{line}");
    }
}

#[derive(Serialize, Deserialize, Clone, utoipa::ToSchema)]
struct Note {
    id: u64,
    owner: String,
    text: String,
}

#[derive(Deserialize, utoipa::ToSchema)]
struct CreateNote {
    text: String,
}

#[derive(Serialize, utoipa::ToSchema)]
struct CreatedId {
    id: u64,
}

#[utoipa::path(post, path = "/notes", request_body = CreateNote,
    responses((status = 200, description = "created", body = CreatedId)))]
fn create_note() {}

#[utoipa::path(get, path = "/notes/{id}", params(("id" = u64, Path, description = "note id")),
    responses((status = 200, description = "note", body = Note)))]
fn get_note() {}

#[utoipa::path(get, path = "/notes/{id}/owned", params(("id" = u64, Path, description = "note id")),
    responses((status = 200, description = "note", body = Note)))]
fn get_note_owned() {}

#[derive(OpenApi)]
#[openapi(paths(create_note, get_note, get_note_owned),
    components(schemas(Note, CreateNote, CreatedId)))]
struct ApiDoc;

fn main() {
    let store: Mutex<HashMap<u64, Note>> = Mutex::new(HashMap::new());
    let next: Mutex<u64> = Mutex::new(1);
    let addr = std::env::var("ADDR").unwrap_or_else(|_| "127.0.0.1:8085".to_string());
    let server = tiny_http::Server::http(&addr).unwrap();
    eprintln!("notes_app listening on {addr}");

    for mut req in server.incoming_requests() {
        let method = req.method().as_str().to_string();
        let url = req.url().to_string();
        let user = req
            .headers()
            .iter()
            .find(|h| h.field.as_str().as_str().eq_ignore_ascii_case("Authorization"))
            .map(|h| h.value.as_str().trim_start_matches("Bearer ").to_string())
            .unwrap_or_default();
        let mut body = String::new();
        let _ = std::io::Read::read_to_string(req.as_reader(), &mut body);

        let (code, out) = route(&method, &url, &user, &body, &store, &next);
        let resp = tiny_http::Response::from_string(out).with_status_code(code);
        let _ = req.respond(resp);
    }
}

fn route(
    method: &str,
    url: &str,
    user: &str,
    body: &str,
    store: &Mutex<HashMap<u64, Note>>,
    next: &Mutex<u64>,
) -> (u16, String) {
    let path = url.split('?').next().unwrap_or(url);
    match (method, path) {
        ("GET", "/api-docs/openapi.json") => (200, ApiDoc::openapi().to_json().unwrap()),
        ("POST", "/notes") => {
            let c: CreateNote = match serde_json::from_str(body) {
                Ok(c) => c,
                Err(_) => return (400, "bad body".into()),
            };
            let mut id_guard = next.lock().unwrap();
            let id = *id_guard;
            *id_guard += 1;
            drop(id_guard);
            store.lock().unwrap().insert(
                id,
                Note { id, owner: user.to_string(), text: c.text },
            );
            crux_access(user, "Write", &format!("note:{id}"), 1);
            (200, serde_json::to_string(&CreatedId { id }).unwrap())
        }
        ("GET", p) if p.starts_with("/notes/") && p.ends_with("/owned") => {
            let id: u64 = p.trim_start_matches("/notes/").trim_end_matches("/owned").parse().unwrap_or(0);
            match store.lock().unwrap().get(&id) {
                // SAFE: ownership enforced. Served -> count 1; denied -> count 0 (dominated).
                Some(n) if n.owner == user => {
                    crux_access(user, "Read", &format!("note:{id}"), 1);
                    (200, serde_json::to_string(n).unwrap())
                }
                Some(_) => {
                    crux_access(user, "Read", &format!("note:{id}"), 0);
                    (403, "forbidden".into())
                }
                None => (404, "not found".into()),
            }
        }
        ("GET", p) if p.starts_with("/notes/") => {
            let id: u64 = p.trim_start_matches("/notes/").parse().unwrap_or(0);
            match store.lock().unwrap().get(&id) {
                // VULNERABLE: no ownership check (IDOR cross-user leak). Always serves -> count 1.
                Some(n) => {
                    crux_access(user, "Read", &format!("note:{id}"), 1);
                    (200, serde_json::to_string(n).unwrap())
                }
                None => (404, "not found".into()),
            }
        }
        _ => (404, "no route".into()),
    }
}
