//! Route source #2: axum `Router` registrations recovered from the app's Rust source.
//!
//! For apps that ship no OpenAPI spec (atuin, vaultwarden), we recover the endpoint
//! model straight from the route macros. We parse every `.rs` file in the target tree
//! with `syn` and collect:
//!   - `.route("<path>", <method-router>)`  -> one endpoint per HTTP method found in
//!     the method-router expression, so `get(a).post(b)` yields GET and POST.
//!   - `.route_service("<path>", ...)`      -> treated as GET (a served resource).
//! HTTP methods are read from any `get(..)`, `post(..)`, ... call or builder method in
//! the second argument, and from `on(MethodFilter::POST, ..)` filters.
//!
//! The output is the same `Endpoint` type the OpenAPI path emits, so the rest of
//! crux_workload (producer/consumer classification, cross-user replay, crux_observe) is
//! reused unchanged.
//!
//! Honest limits (degrade gracefully, never guess):
//!   - Path parameter syntax is normalized for both axum 0.6/0.7 (`:id`, `*rest`) and
//!     axum 0.8 (`{id}`, `{*rest}`) in `endpoint::normalize_path`.
//!   - `.nest("<prefix>", <router>)` prefixes are NOT auto-joined onto the inner routes
//!     when the inner router is a separate variable or function result (the common
//!     case, e.g. atuin nests on the runtime `settings.path`). Routes are emitted at
//!     their literal path; a static prefix can be supplied with `--base-path`. Nest
//!     prefixes that are string literals are reported for visibility.
use crate::endpoint::{Endpoint, Method};
use std::collections::BTreeSet;
use std::path::Path;
use syn::visit::Visit;

const METHOD_FNS: &[&str] = &["get", "post", "put", "patch", "delete", "head", "options", "trace"];

#[derive(Default)]
pub struct Extraction {
    pub endpoints: Vec<Endpoint>,
    /// String-literal nest prefixes seen, for operator visibility.
    pub nest_prefixes: BTreeSet<String>,
    /// Count of `.rs` files that parsed successfully.
    pub files_parsed: usize,
    pub files_seen: usize,
}

/// Extract axum routes from every `.rs` file under `dir` (recursively), skipping
/// `target/` build output.
pub fn extract_dir(dir: &Path) -> Extraction {
    let mut ex = Extraction::default();
    let mut raw: Vec<(Method, String)> = Vec::new();
    visit_tree(dir, &mut raw, &mut ex);

    // dedup identical (method, path) pairs, keep source order
    let mut seen = BTreeSet::new();
    for (m, p) in raw {
        let key = format!("{} {}", m.as_str(), p);
        if seen.insert(key) {
            ex.endpoints.push(Endpoint::new(m, &p));
        }
    }
    ex
}

fn visit_tree(dir: &Path, raw: &mut Vec<(Method, String)>, ex: &mut Extraction) {
    let Ok(rd) = std::fs::read_dir(dir) else { return };
    for entry in rd.flatten() {
        let path = entry.path();
        if path.is_dir() {
            let name = path.file_name().and_then(|s| s.to_str()).unwrap_or("");
            if name == "target" || name == ".git" {
                continue;
            }
            visit_tree(&path, raw, ex);
        } else if path.extension().and_then(|s| s.to_str()) == Some("rs") {
            ex.files_seen += 1;
            if let Ok(text) = std::fs::read_to_string(&path) {
                if let Ok(file) = syn::parse_file(&text) {
                    ex.files_parsed += 1;
                    let mut v = RouteVisitor { raw, nest_prefixes: &mut ex.nest_prefixes };
                    v.visit_file(&file);
                }
            }
        }
    }
}

struct RouteVisitor<'a> {
    raw: &'a mut Vec<(Method, String)>,
    nest_prefixes: &'a mut BTreeSet<String>,
}

impl<'ast, 'a> Visit<'ast> for RouteVisitor<'a> {
    fn visit_expr_method_call(&mut self, call: &'ast syn::ExprMethodCall) {
        let name = call.method.to_string();
        if (name == "route" || name == "route_service") && !call.args.is_empty() {
            if let Some(path) = string_lit(&call.args[0]) {
                let methods = if name == "route_service" {
                    vec![Method::Get]
                } else if call.args.len() >= 2 {
                    methods_in_expr(&call.args[1])
                } else {
                    Vec::new()
                };
                for m in methods {
                    self.raw.push((m, path.clone()));
                }
            }
        } else if (name == "nest" || name == "nest_service") && !call.args.is_empty() {
            if let Some(prefix) = string_lit(&call.args[0]) {
                if !prefix.is_empty() {
                    self.nest_prefixes.insert(prefix);
                }
            }
        }
        syn::visit::visit_expr_method_call(self, call);
    }
}

/// Get the string value of an expression if it is a string literal.
fn string_lit(expr: &syn::Expr) -> Option<String> {
    if let syn::Expr::Lit(lit) = expr {
        if let syn::Lit::Str(s) = &lit.lit {
            return Some(s.value());
        }
    }
    None
}

/// Last identifier of a path expression, e.g. `axum::routing::get` -> `get`.
fn last_path_ident(path: &syn::Path) -> Option<String> {
    path.segments.last().map(|s| s.ident.to_string())
}

/// Collect every HTTP method named inside a method-router expression. Handles:
///   - `get(h)` / `axum::routing::post(h)`           (free-function form)
///   - `get(h).post(h2)`                             (builder chaining)
///   - `MethodRouter::new().on(MethodFilter::GET, h)` (explicit filter)
/// We walk the whole sub-expression with a visitor so arbitrary chaining works.
fn methods_in_expr(expr: &syn::Expr) -> Vec<Method> {
    let mut v = MethodVisitor { methods: Vec::new() };
    v.visit_expr(expr);
    v.methods
}

struct MethodVisitor {
    methods: Vec<Method>,
}

impl MethodVisitor {
    fn push(&mut self, m: Method) {
        if m != Method::Other && !self.methods.contains(&m) {
            self.methods.push(m);
        }
    }
}

impl<'ast> Visit<'ast> for MethodVisitor {
    fn visit_expr_call(&mut self, call: &'ast syn::ExprCall) {
        if let syn::Expr::Path(p) = call.func.as_ref() {
            if let Some(id) = last_path_ident(&p.path) {
                if METHOD_FNS.contains(&id.as_str()) {
                    self.push(Method::parse(&id));
                }
                if id == "on" || id == "on_service" {
                    if let Some(first) = call.args.first() {
                        self.push(method_from_filter(first));
                    }
                }
            }
        }
        syn::visit::visit_expr_call(self, call);
    }

    fn visit_expr_method_call(&mut self, call: &'ast syn::ExprMethodCall) {
        let name = call.method.to_string();
        if METHOD_FNS.contains(&name.as_str()) {
            self.push(Method::parse(&name));
        }
        if name == "on" || name == "on_service" {
            if let Some(first) = call.args.first() {
                self.push(method_from_filter(first));
            }
        }
        syn::visit::visit_expr_method_call(self, call);
    }
}

/// `MethodFilter::POST` / `MethodFilter::GET` -> the method.
fn method_from_filter(expr: &syn::Expr) -> Method {
    if let syn::Expr::Path(p) = expr {
        if let Some(id) = last_path_ident(&p.path) {
            return Method::parse(&id);
        }
    }
    Method::Other
}

#[cfg(test)]
mod tests {
    use super::*;

    fn methods_of(src: &str) -> Extraction {
        let file = syn::parse_file(src).unwrap();
        let mut ex = Extraction::default();
        let mut raw = Vec::new();
        {
            let mut v = RouteVisitor { raw: &mut raw, nest_prefixes: &mut ex.nest_prefixes };
            v.visit_file(&file);
        }
        let mut seen = BTreeSet::new();
        for (m, p) in raw {
            if seen.insert(format!("{} {}", m.as_str(), p)) {
                ex.endpoints.push(Endpoint::new(m, &p));
            }
        }
        ex
    }

    #[test]
    fn extracts_simple_routes() {
        let src = r#"
            fn router() -> Router {
                Router::new()
                    .route("/register", post(handlers::register))
                    .route("/user/{username}", get(handlers::user::get))
                    .route("/account", delete(handlers::user::delete))
            }
        "#;
        let ex = methods_of(src);
        let got: BTreeSet<String> =
            ex.endpoints.iter().map(|e| format!("{} {}", e.method.as_str(), e.path)).collect();
        assert!(got.contains("POST /register"));
        assert!(got.contains("GET /user/{username}"));
        assert!(got.contains("DELETE /account"));
    }

    #[test]
    fn same_path_two_methods() {
        let src = r#"
            fn r() -> Router {
                Router::new().route("/api/v0/record", post(a)).route("/api/v0/record", get(b))
            }
        "#;
        let ex = methods_of(src);
        let got: BTreeSet<String> =
            ex.endpoints.iter().map(|e| format!("{} {}", e.method.as_str(), e.path)).collect();
        assert!(got.contains("POST /api/v0/record"));
        assert!(got.contains("GET /api/v0/record"));
    }

    #[test]
    fn chained_method_router() {
        let src = r#"fn r() -> Router { Router::new().route("/x", get(a).post(b)) }"#;
        let ex = methods_of(src);
        let got: BTreeSet<String> =
            ex.endpoints.iter().map(|e| format!("{} {}", e.method.as_str(), e.path)).collect();
        assert!(got.contains("GET /x"), "{got:?}");
        assert!(got.contains("POST /x"), "{got:?}");
    }

    #[test]
    fn colon_param_axum07() {
        let src = r#"fn r() -> Router { Router::new().route("/history/:id", get(h)) }"#;
        let ex = methods_of(src);
        assert_eq!(ex.endpoints[0].path, "/history/{id}");
        assert!(ex.endpoints[0].is_consumer());
    }

    #[test]
    fn on_methodfilter() {
        let src = r#"fn r() -> Router { Router::new().route("/y", on(MethodFilter::PUT, h)) }"#;
        let ex = methods_of(src);
        let got: BTreeSet<String> =
            ex.endpoints.iter().map(|e| format!("{} {}", e.method.as_str(), e.path)).collect();
        assert!(got.contains("PUT /y"), "{got:?}");
    }

    #[test]
    fn records_nest_prefix() {
        let src = r#"fn r() -> Router { Router::new().nest("/api", inner) } "#;
        let ex = methods_of(src);
        assert!(ex.nest_prefixes.contains("/api"));
    }
}
