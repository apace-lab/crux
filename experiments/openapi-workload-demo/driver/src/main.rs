//! crux_workload: a two-user cross-user-access driver.
//!
//! It recovers an app's endpoints from a ROUTE SOURCE, infers producer endpoints (a
//! POST/PUT that yields an `id`) and consumer endpoints (a GET with an `{id}` path
//! parameter), then: user A creates a resource and we capture its id; user B replays
//! that id on every consumer (IDOR-style cross-user access). A cross-user leak shows up
//! when B receives A's data (the self-contained response oracle), and, when the app is
//! instrumented, in the resource-linked trace read back by `crux_observe`.
//!
//! Two route sources behind one `Endpoint` model (`endpoint.rs`):
//!   * `openapi`     -- an app's OpenAPI spec (utoipa/paperclip apps).
//!   * `axum_routes` -- axum `Router` registrations parsed from the app's Rust source,
//!                      for apps that ship no spec (atuin, vaultwarden).
//! The replay below consumes `Vec<Endpoint>` and does not care which source produced it.
//!
//! Usage:
//!   crux_workload <base_url> [trace_path]
//!       OpenAPI mode (default). The spec URL is resolved by, in order: `--spec <url>`,
//!       `CRUX_SPEC_PATH`, then probing common locations under <base_url>
//!       (/api-doc/openapi.json, /api/openapi.json, /api-docs/openapi.json,
//!       /openapi.json, /swagger.json, /swagger/v1/swagger.json). The spec fetch carries
//!       user A's auth, since some apps gate the spec behind auth.
//!   crux_workload --routes <source_dir> [--list] [--base <base_url>] [trace_path]
//!       axum source-extraction mode. `--list` prints the recovered endpoints and
//!       exits (offline). With `--base` it runs the cross-user replay.
//!
//! Auth seed (the only per-app manual input besides the base URL): the scheme and the two
//! users' credentials. CRUX_AUTH_SCHEME selects the mode (Bearer default, Basic,
//! Header:<Name>, Cookie:<Name>, or any other word used as the Authorization scheme), and
//! CRUX_USER_A / CRUX_USER_B carry the per-user credential (a token, a `user:pass` for
//! Basic, or a session value for Cookie). See `auth.rs`.
//!
//! Known path parameters (for tenant-prefixed APIs): CRUX_PATH_PARAM_<name>=<value> fills a
//! non-resource path parameter such as `{org_id}`. OpenObserve addresses every resource as
//! `/api/{org_id}/dashboards/{dashboard_id}`; set CRUX_PATH_PARAM_org_id=<victim org> so the
//! captured resource id fills `{dashboard_id}` while the victim's org fills `{org_id}` (the
//! cross-tenant replay). The resource id (the last path parameter) is always supplied by
//! the producer capture, never from env.
mod auth;
mod axum_routes;
mod endpoint;
mod openapi;
mod schema;

use auth::Auth;
use endpoint::{extract_id_skipping, Endpoint};
use serde_json::Value;
use std::collections::{HashMap, HashSet};
use std::path::PathBuf;

/// Spec locations probed under the base URL, most specific first.
const SPEC_PROBE_PATHS: &[&str] = &[
    "/api-doc/openapi.json",
    "/api/openapi.json",
    "/api-docs/openapi.json",
    "/openapi.json",
    "/swagger.json",
    "/swagger/v1/swagger.json",
];

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();

    if args.first().map(String::as_str) == Some("--routes") {
        run_routes_mode(&args[1..]);
        return;
    }

    // OpenAPI mode (backward compatible).
    let base = args
        .iter()
        .find(|a| !a.starts_with("--") && !a.ends_with(".jsonl"))
        .cloned()
        .unwrap_or_else(|| "http://127.0.0.1:8085".into());
    let trace_path = args.iter().find(|a| a.ends_with(".jsonl")).cloned();
    let spec_override = flag_value(&args, "--spec").or_else(|| std::env::var("CRUX_SPEC_PATH").ok());

    let auth = Auth::from_env();
    let spec = fetch_spec(&base, spec_override.as_deref(), &auth)
        .expect("could not fetch an OpenAPI spec (set --spec <url> or CRUX_SPEC_PATH)");
    let endpoints = openapi::extract(&spec);
    println!("source: OpenAPI spec ({} endpoint(s))", endpoints.len());
    let leaks = replay(&base, &endpoints, &auth, &known_path_params());
    finish(trace_path, leaks);
}

/// Resolve and fetch the OpenAPI spec. An override may be an absolute URL or a path to join
/// onto the base; otherwise the common locations are probed. The request carries user A's
/// auth so an auth-gated spec (OpenObserve) is reachable.
fn fetch_spec(base: &str, override_path: Option<&str>, auth: &Auth) -> Option<Value> {
    let candidates: Vec<String> = match override_path {
        Some(p) if p.starts_with("http://") || p.starts_with("https://") => vec![p.to_string()],
        Some(p) => vec![format!("{base}{}", if p.starts_with('/') { p.to_string() } else { format!("/{p}") })],
        None => SPEC_PROBE_PATHS.iter().map(|p| format!("{base}{p}")).collect(),
    };
    for url in &candidates {
        let mut req = ureq::get(url);
        for (k, v) in auth.headers_a() {
            req = req.set(&k, &v);
        }
        if let Ok(resp) = req.call() {
            if resp.status() == 200 {
                if let Ok(v) = resp.into_json::<Value>() {
                    if v.get("paths").is_some() {
                        println!("spec: {url}");
                        return Some(v);
                    }
                }
            }
        }
    }
    None
}

/// Collect CRUX_PATH_PARAM_<name>=<value> env vars into a known-parameter map.
fn known_path_params() -> HashMap<String, String> {
    let mut m = HashMap::new();
    for (k, v) in std::env::vars() {
        if let Some(name) = k.strip_prefix("CRUX_PATH_PARAM_") {
            m.insert(name.to_string(), v);
        }
    }
    m
}

fn flag_value(args: &[String], flag: &str) -> Option<String> {
    args.iter().position(|a| a == flag).and_then(|i| args.get(i + 1)).cloned()
}

fn run_routes_mode(args: &[String]) {
    let Some(dir) = args.first() else {
        eprintln!("usage: crux_workload --routes <source_dir> [--list] [--base <url>] [trace]");
        std::process::exit(2);
    };
    let ex = axum_routes::extract_dir(&PathBuf::from(dir));
    println!(
        "source: axum route extraction over {} ({}/{} .rs files parsed, {} endpoint(s))",
        dir, ex.files_parsed, ex.files_seen, ex.endpoints.len()
    );
    if !ex.nest_prefixes.is_empty() {
        println!("  nest prefixes seen (not auto-joined): {:?}", ex.nest_prefixes);
    }

    let list = args.iter().any(|a| a == "--list");
    let base = flag_value(args, "--base");
    let trace_path = args.iter().skip(1).find(|a| a.ends_with(".jsonl")).cloned();

    print_endpoints(&ex.endpoints);

    if list || base.is_none() {
        let producers = ex.endpoints.iter().filter(|e| e.is_producer()).count();
        let consumers = ex.endpoints.iter().filter(|e| e.is_consumer()).count();
        println!(
            "\n{} producer (POST/PUT) and {} id-in-path consumer (GET {{id}}) endpoint(s)",
            producers, consumers
        );
        if consumers == 0 {
            println!(
                "no id-in-path GET consumer: this app exposes no IDOR-by-path-id read surface; \
                 reads are addressed by query/body and scoped server-side (e.g. by user_id)."
            );
        }
        if base.is_none() {
            println!("(offline: pass --base <url> to run the cross-user replay)");
        }
        return;
    }

    let base = base.unwrap();
    let leaks = replay(&base, &ex.endpoints, &Auth::from_env(), &known_path_params());
    finish(trace_path, leaks);
}

fn print_endpoints(endpoints: &[Endpoint]) {
    println!("\nrecovered endpoints:");
    for e in endpoints {
        let role = if e.is_producer() {
            " [producer]"
        } else if e.is_consumer() {
            if e.is_name_or_me_scoped() {
                " [consumer: name/me-scoped, skipped]"
            } else {
                " [consumer]"
            }
        } else {
            ""
        };
        println!("  {:6} {}{}", e.method.as_str(), e.path, role);
    }
}

/// The source-agnostic cross-user replay. User A creates a resource at every producer
/// COLLECTION that has a matching by-id consumer; user B then replays each created id only on
/// the consumers of that same collection (so a dashboard id is read back on a dashboards
/// reader, not on an unrelated folders reader). Returns the number of response-oracle leaks.
fn replay(base: &str, endpoints: &[Endpoint], auth: &Auth, known: &HashMap<String, String>) -> usize {
    let label_a = auth.label_a();
    let label_b = auth.label_b();
    let marker = format!("CRUX_SECRET_{}", label_a);

    // Addressable, non-skipped consumers grouped by the collection their id addresses.
    let consumers: Vec<(&Endpoint, String)> = endpoints
        .iter()
        .filter(|e| e.is_consumer() && !e.is_name_or_me_scoped())
        .filter_map(|e| e.id_collection(known).map(|c| (e, c)))
        .collect();

    // Tenant path-parameter names (e.g. org_id) are skipped by the id extractor so a create
    // response echoing both org_id and the resource's own *_id yields the resource id.
    let skip_ids: HashSet<String> = known.keys().cloned().collect();

    // Producers whose filled collection path has at least one matching consumer. User A creates
    // one resource per such collection (the first producer that yields an id).
    let mut created: HashMap<String, (String, String)> = HashMap::new(); // collection -> (id, producer_path)
    for ep in endpoints.iter().filter(|e| e.is_producer()) {
        let Some(path) = ep.fill_producer(known) else { continue };
        if created.contains_key(&path) {
            continue; // already made a resource for this collection
        }
        if !consumers.iter().any(|(_, c)| *c == path) {
            continue; // no by-id consumer reads this collection: creating it proves nothing
        }
        let body = ep.synth_body(&marker);
        let url = format!("{base}{path}");
        let mut req = ureq::post(&url).set("Content-Type", "application/json");
        for (k, v) in auth.headers_a() {
            req = req.set(&k, &v);
        }
        let resp = match req.send_string(&body) {
            Ok(r) => Some(r),
            Err(ureq::Error::Status(_, r)) => Some(r),
            Err(_) => None,
        };
        if let Some(r) = resp {
            if let Ok(v) = r.into_json::<Value>() {
                if let Some(id) = extract_id_skipping(&v, &skip_ids) {
                    println!("[producer] {} {} {} -> id={id}", label_a, ep.method.as_str(), path);
                    created.insert(path.clone(), (id, path));
                }
            }
        }
    }

    if created.is_empty() {
        println!("no producer endpoint created a resource with a matching by-id consumer; nothing to cross-read");
        return 0;
    }

    // User B replays each created id on the consumers of that collection only.
    let mut leaks = 0;
    let mut checked = 0;
    let mut skipped = 0;
    for (ep, coll) in &consumers {
        let Some((id, producer_path)) = created.get(coll) else {
            skipped += 1; // no resource created for this collection
            continue;
        };
        let Some(concrete) = ep.fill_consumer(id, known) else {
            skipped += 1;
            continue;
        };
        let url = format!("{base}{concrete}");
        let mut req = ureq::get(&url);
        for (k, v) in auth.headers_b() {
            req = req.set(&k, &v);
        }
        checked += 1;
        let (status, text) = match req.call() {
            Ok(r) => (r.status(), r.into_string().unwrap_or_default()),
            Err(ureq::Error::Status(code, r)) => (code, r.into_string().unwrap_or_default()),
            Err(_) => (0, String::new()),
        };
        let leaked = status == 200 && text.contains(&marker);
        if leaked {
            leaks += 1;
            println!(
                "[LEAK] {} GET {concrete} -> served {}'s data (status {status}); producer was {producer_path}",
                label_b, label_a
            );
        } else {
            println!("[ok]   {} GET {concrete} -> status {status}, no cross-user data", label_b);
        }
    }

    println!(
        "\ncrux_workload (response oracle): {} resource(s) created by {label_a}, \
         {checked} consumer endpoint(s) replayed cross-user as {label_b}, \
         {skipped} skipped (no matching producer or unaddressable), {leaks} leak(s) found",
        created.len()
    );
    leaks
}

/// Apply the CRUX-native resource-linked verdict if the instrumented app wrote a trace,
/// then exit non-zero on any leak.
fn finish(trace_path: Option<String>, response_leaks: usize) {
    if let Some(tp) = trace_path {
        let p = PathBuf::from(&tp);
        if p.exists() {
            match crux_observe::analyze_traces(&[p]) {
                Ok(res) => {
                    println!("\ncrux_observe (CRUX-native resource-linked verdict):");
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
                Err(e) => eprintln!("crux_observe error: {e}"),
            }
        } else {
            eprintln!("trace {tp} not found (did the app run with CRUX_TRACE_PATH set?)");
        }
    }
    std::process::exit(if response_leaks > 0 { 1 } else { 0 });
}
