//! afg_workload: an OpenAPI-driven two-user cross-user-access driver.
//!
//! Reads an app's OpenAPI spec, infers producer endpoints (a POST whose response carries an
//! `id`) and consumer endpoints (a GET with an `{id}` path parameter), then: user A creates a
//! resource and we capture its id; user B replays that id on every consumer (IDOR-style
//! cross-user access). A cross-user leak shows up when B receives A's data. In AFG-native use
//! the leak is instead detected by the injected probes + afg_observe from the trace; here we
//! use the response as a self-contained oracle to prove the driver finds the overlap with no
//! hand-coded scenario.
use serde_json::Value;

fn resolve<'a>(spec: &'a Value, schema: &'a Value) -> &'a Value {
    if let Some(r) = schema.get("$ref").and_then(Value::as_str) {
        // e.g. "#/components/schemas/CreatedId"
        let name = r.rsplit('/').next().unwrap_or("");
        if let Some(s) = spec.pointer(&format!("/components/schemas/{name}")) {
            return s;
        }
    }
    schema
}

fn response_schema<'a>(spec: &'a Value, op: &'a Value) -> Option<&'a Value> {
    let s = op.pointer("/responses/200/content/application~1json/schema")?;
    Some(resolve(spec, s))
}

fn has_id_property(schema: &Value) -> bool {
    schema
        .pointer("/properties/id")
        .is_some()
}

/// Synthesize a request body from a schema: each string property gets `marker`, numbers 1.
fn synth_body(spec: &Value, op: &Value, marker: &str) -> String {
    let Some(s) = op.pointer("/requestBody/content/application~1json/schema") else {
        return "{}".to_string();
    };
    let schema = resolve(spec, s);
    let mut obj = serde_json::Map::new();
    if let Some(props) = schema.get("properties").and_then(Value::as_object) {
        for (k, v) in props {
            let ty = v.get("type").and_then(Value::as_str).unwrap_or("string");
            obj.insert(
                k.clone(),
                match ty {
                    "integer" | "number" => Value::from(1),
                    "boolean" => Value::from(true),
                    _ => Value::from(marker),
                },
            );
        }
    }
    Value::Object(obj).to_string()
}

fn main() {
    let base = std::env::args().nth(1).unwrap_or_else(|| "http://127.0.0.1:8085".to_string());
    // optional: an AFG trace the instrumented app wrote, for the native resource-linked verdict
    let trace_path = std::env::args().nth(2);
    let user_a = "alice";
    let user_b = "bob";
    let marker = "AFG_SECRET_alice";

    let spec: Value = ureq::get(&format!("{base}/api-docs/openapi.json"))
        .call()
        .expect("fetch spec")
        .into_json()
        .expect("parse spec");

    let paths = spec.get("paths").and_then(Value::as_object).cloned().unwrap_or_default();

    // 1) producers: POST whose 200 response has an `id`
    let mut created_id: Option<u64> = None;
    let mut producer_path = String::new();
    for (path, item) in &paths {
        if let Some(op) = item.get("post") {
            if response_schema(&spec, op).map(has_id_property).unwrap_or(false) {
                let body = synth_body(&spec, op, marker);
                let url = format!("{base}{path}");
                let resp = ureq::post(&url)
                    .set("Authorization", &format!("Bearer {user_a}"))
                    .set("Content-Type", "application/json")
                    .send_string(&body);
                if let Ok(r) = resp {
                    if let Ok(v) = r.into_json::<Value>() {
                        if let Some(id) = v.get("id").and_then(Value::as_u64) {
                            println!("[producer] {user_a} POST {path} -> id={id}");
                            created_id = Some(id);
                            producer_path = path.clone();
                        }
                    }
                }
            }
        }
    }
    let Some(id) = created_id else {
        println!("no producer endpoint yielded an id; nothing to cross-read");
        return;
    };

    // 2) consumers: GET with an `{id}` path param; user B replays A's id
    let mut leaks = 0;
    let mut checked = 0;
    for (path, item) in &paths {
        if item.get("get").is_none() || !path.contains('{') {
            continue;
        }
        // substitute the first path param with A's id
        let concrete = {
            let start = path.find('{').unwrap();
            let end = path.find('}').unwrap();
            format!("{}{}{}", &path[..start], id, &path[end + 1..])
        };
        let url = format!("{base}{concrete}");
        let resp = ureq::get(&url)
            .set("Authorization", &format!("Bearer {user_b}"))
            .call();
        checked += 1;
        let (status, text) = match resp {
            Ok(r) => (r.status(), r.into_string().unwrap_or_default()),
            Err(ureq::Error::Status(code, r)) => (code, r.into_string().unwrap_or_default()),
            Err(_) => (0, String::new()),
        };
        let leaked = status == 200 && text.contains(marker);
        if leaked {
            leaks += 1;
            println!(
                "[LEAK] {user_b} GET {concrete} -> served {user_a}'s data (status {status}); producer was POST {producer_path}"
            );
        } else {
            println!("[ok]   {user_b} GET {concrete} -> status {status}, no cross-user data");
        }
    }

    println!("\nafg_workload (response oracle): {checked} consumer endpoint(s) replayed cross-user, {leaks} leak(s) found");

    // AFG-native verdict: if the instrumented app wrote a resource-linked trace, apply the
    // afg_observe verdict (owner = first writer; a non-owner read with rows > 0 = leak).
    if let Some(tp) = trace_path {
        let p = std::path::PathBuf::from(&tp);
        if p.exists() {
            match afg_observe::analyze_traces(&[p]) {
                Ok(res) => {
                    println!("\nafg_observe (AFG-native resource-linked verdict):");
                    if res.resource_leaks.is_empty() {
                        println!("  no cross-user resource leak in the trace");
                    }
                    for l in &res.resource_leaks {
                        println!(
                            "  LEAK: {} read {} (owned by {}), served {} row(s)",
                            l.reader, l.resource, l.owner, l.rows
                        );
                    }
                    if !res.resource_leaks.is_empty() {
                        std::process::exit(1);
                    }
                }
                Err(e) => eprintln!("afg_observe error: {e}"),
            }
        } else {
            eprintln!("trace {tp} not found (did the app run with AFG_TRACE_PATH set?)");
        }
    }
    std::process::exit(if leaks > 0 { 1 } else { 0 });
}
