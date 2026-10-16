//! The endpoint model shared by every route source (OpenAPI and axum-source
//! extraction). The driver's cross-user replay consumes `Vec<Endpoint>` and knows
//! nothing about where the endpoints came from, so a new source only has to produce
//! this type. See `openapi.rs` and `axum_routes.rs` for the two producers.
use serde_json::Value;
use std::collections::HashMap;
use std::rc::Rc;

/// Path-parameter names that address a resource by a human NAME rather than an opaque id.
/// A consumer whose final parameter is one of these (or ends in `_name`/`name`) is not an
/// IDOR-by-opaque-id surface, so the replay deprioritizes it. See `is_name_or_me_scoped`.
const NAME_PARAMS: &[&str] =
    &["name", "username", "user", "slug", "login", "email", "handle", "key", "label_name"];

/// Path segments that mark a self-scoped resource (the caller's own data), which is not a
/// cross-principal id-replay surface.
const ME_SEGMENTS: &[&str] = &["me", "self", "_self", "current"];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Method {
    Get,
    Post,
    Put,
    Patch,
    Delete,
    Head,
    Options,
    Other,
}

impl Method {
    pub fn parse(s: &str) -> Method {
        match s.to_ascii_lowercase().as_str() {
            "get" => Method::Get,
            "post" => Method::Post,
            "put" => Method::Put,
            "patch" => Method::Patch,
            "delete" => Method::Delete,
            "head" => Method::Head,
            "options" => Method::Options,
            _ => Method::Other,
        }
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Method::Get => "GET",
            Method::Post => "POST",
            Method::Put => "PUT",
            Method::Patch => "PATCH",
            Method::Delete => "DELETE",
            Method::Head => "HEAD",
            Method::Options => "OPTIONS",
            Method::Other => "OTHER",
        }
    }
}

/// One HTTP endpoint recovered from a route source. Paths are normalized so a path
/// parameter is always `{name}`, regardless of whether the source wrote it as axum's
/// `:name` / `*name` (axum 0.6/0.7) or `{name}` / `{*name}` (axum 0.8) or OpenAPI's
/// `{name}`.
#[derive(Debug, Clone)]
pub struct Endpoint {
    pub method: Method,
    pub path: String,
    pub path_params: Vec<String>,
    /// OpenAPI request body schema (top-level `$ref`-resolved), if the source knew it.
    /// `None` for source extraction, which has no schema; body synthesis then degrades
    /// to an empty object. NESTED `$ref`s inside this schema are resolved at synthesis time
    /// against `schema_root`.
    pub body_schema: Option<Value>,
    /// The spec document, shared (cheap `Rc` clone) across all endpoints, so body synthesis
    /// can resolve nested `$ref`s (`#/components/schemas/..`). `None` for source extraction.
    pub schema_root: Option<Rc<Value>>,
    /// OpenAPI-only: whether the 200 response object carries an `id`. `None` means the
    /// source could not tell (axum extraction), and producer detection falls back to
    /// the HTTP method.
    pub response_has_id: Option<bool>,
}

impl Endpoint {
    pub fn new(method: Method, raw_path: &str) -> Endpoint {
        let path = normalize_path(raw_path);
        let path_params = extract_params(&path);
        Endpoint {
            method,
            path,
            path_params,
            body_schema: None,
            schema_root: None,
            response_has_id: None,
        }
    }

    /// A producer creates a resource whose id we can capture: a POST/PUT. When the
    /// source knows the response shape (OpenAPI) we additionally require an `id` in the
    /// 200 body; when it does not (source extraction) we treat every POST/PUT as a
    /// candidate and simply skip it at replay time if the response carries no id.
    pub fn is_producer(&self) -> bool {
        matches!(self.method, Method::Post | Method::Put) && self.response_has_id.unwrap_or(true)
    }

    /// A consumer reads a resource addressed by an id in the path: a GET with at least
    /// one path parameter. This is the IDOR surface the driver replays cross-user.
    pub fn is_consumer(&self) -> bool {
        self.method == Method::Get && !self.path_params.is_empty()
    }

    /// A consumer that addresses its resource by a human name, or is self-scoped (`/me`,
    /// `/self`). These are NOT IDOR-by-opaque-id surfaces: a name lookup is usually public
    /// and a `/me` path serves the caller's own data, so the cross-principal id replay has
    /// nothing to cross. The replay deprioritizes (skips) these.
    pub fn is_name_or_me_scoped(&self) -> bool {
        // self-scoped: any segment is me/self/current (as a whole segment, not a prefix)
        for seg in self.path.split('/') {
            let s = seg.trim_matches(|c| c == '{' || c == '}').to_ascii_lowercase();
            if ME_SEGMENTS.contains(&s.as_str()) {
                return true;
            }
        }
        // name-keyed: the LAST path parameter (the one the id would fill) is a name
        if let Some(last) = self.path_params.last() {
            let l = last.to_ascii_lowercase();
            if NAME_PARAMS.contains(&l.as_str()) || l.ends_with("_name") || l == "name" {
                return true;
            }
        }
        false
    }

    /// The consumer path the cross-user replay should actually hit: the captured id fills
    /// the LAST path parameter (the resource id), and every earlier parameter (a tenant
    /// prefix such as `{org_id}`) is filled from `known`. Returns `None` if an earlier
    /// parameter is not in `known`, so the driver skips a path it cannot address rather
    /// than guessing. With an empty `known` and a single-parameter path this is the old
    /// first-parameter substitution.
    pub fn fill_consumer(&self, id: &str, known: &HashMap<String, String>) -> Option<String> {
        let Some(last) = self.path_params.last().cloned() else {
            return None;
        };
        self.substitute(known, Some((&last, id)))
    }

    /// The producer path to POST to: every parameter must be known (a tenant prefix like
    /// `{org_id}`). Returns `None` if any parameter is unknown.
    pub fn fill_producer(&self, known: &HashMap<String, String>) -> Option<String> {
        self.substitute(known, None)
    }

    /// The collection a CONSUMER's id addresses: the path up to (but not including) the segment
    /// that is the LAST path parameter, with earlier parameters filled from `known`. A consumer
    /// reads a resource created by the producer whose filled path equals this collection, so the
    /// driver replays a created id only on the consumers of that same collection (not a settings
    /// id on a dashboards reader). `/api/{org_id}/dashboards/{dashboard_id}` and
    /// `/api/{org_id}/dashboards/{dashboard_id}/annotations` both collapse to
    /// `/api/default/dashboards`, matching the `POST /api/{org_id}/dashboards` producer. Returns
    /// `None` if an earlier parameter is not in `known`, or there is no path parameter.
    pub fn id_collection(&self, known: &HashMap<String, String>) -> Option<String> {
        let last = self.path_params.last()?;
        let last_seg = format!("{{{last}}}");
        let mut out = String::new();
        for (i, seg) in self.path.split('/').enumerate() {
            if seg == last_seg {
                break; // stop right before the id segment
            }
            if i > 0 {
                out.push('/');
            }
            if seg.starts_with('{') && seg.ends_with('}') && seg.len() >= 2 {
                match known.get(&seg[1..seg.len() - 1]) {
                    Some(v) => out.push_str(v),
                    None => return None,
                }
            } else {
                out.push_str(seg);
            }
        }
        Some(out)
    }

    /// Shared segment substitution. `id_target = Some((name, value))` forces that one
    /// parameter to `value`; all other parameters must be present in `known`.
    fn substitute(&self, known: &HashMap<String, String>, id_target: Option<(&str, &str)>) -> Option<String> {
        let mut out = String::new();
        for (i, seg) in self.path.split('/').enumerate() {
            if i > 0 {
                out.push('/');
            }
            if seg.starts_with('{') && seg.ends_with('}') && seg.len() >= 2 {
                let name = &seg[1..seg.len() - 1];
                if let Some((tname, tval)) = id_target {
                    if name == tname {
                        out.push_str(tval);
                        continue;
                    }
                }
                match known.get(name) {
                    Some(v) => out.push_str(v),
                    None => return None,
                }
            } else {
                out.push_str(seg);
            }
        }
        Some(out)
    }

    /// Back-compatible single-parameter substitution (first `{..}` becomes `id`).
    pub fn concrete_path(&self, id: &str) -> String {
        if let (Some(start), Some(end)) = (self.path.find('{'), self.path.find('}')) {
            format!("{}{}{}", &self.path[..start], id, &self.path[end + 1..])
        } else {
            self.path.clone()
        }
    }

    /// Synthesize a request body from the OpenAPI schema, resolving nested `$ref`s and
    /// composition (`oneOf`/`anyOf`/`allOf`) against the spec root and building every required
    /// property recursively. See `crate::schema`. Degrades to `{}` when the source carried no
    /// schema (axum extraction).
    pub fn synth_body(&self, marker: &str) -> String {
        let Some(schema) = &self.body_schema else {
            return "{}".to_string();
        };
        crate::schema::synthesize(schema, self.schema_root.as_deref(), marker).to_string()
    }
}

/// Pull an id out of a producer's JSON response. Handles integer and string/UUID ids, and
/// ids nested inside the response (OpenObserve returns the dashboard id at
/// `v5.dashboardId`, not at the top level). Preference order: a top-level `id`, then the
/// first `*id`/`*Id`/`*_id` scalar found anywhere in the tree (breadth-first on the top
/// level first, then recursing), returned verbatim so a string/UUID id is replayed as-is.
pub fn extract_id(v: &Value) -> Option<String> {
    extract_id_skipping(v, &std::collections::HashSet::new())
}

/// Like `extract_id`, but id-ish keys whose NAME is in `skip` are ignored. The driver passes the
/// known tenant path-parameter names (such as `org_id`), so a create response that echoes both
/// `org_id` and the resource's own `view_id` yields the resource id, not the tenant id.
pub fn extract_id_skipping(v: &Value, skip: &std::collections::HashSet<String>) -> Option<String> {
    if let Some(id) = v.get("id") {
        if let Some(s) = scalar_id(id) {
            return Some(s);
        }
    }
    find_id_skipping(v, skip)
}

fn scalar_id(v: &Value) -> Option<String> {
    if let Some(n) = v.as_u64() {
        return Some(n.to_string());
    }
    if let Some(s) = v.as_str() {
        if !s.is_empty() {
            return Some(s.to_string());
        }
    }
    None
}

pub(crate) fn key_is_id(k: &str) -> bool {
    let k = k.to_ascii_lowercase();
    k == "id" || k.ends_with("id") || k.ends_with("_id")
}

/// Recursively search for an id-ish scalar: prefer an id-keyed scalar at the current level
/// (skipping keys named in `skip`, e.g. the tenant `org_id`), otherwise recurse into children.
fn find_id_skipping(v: &Value, skip: &std::collections::HashSet<String>) -> Option<String> {
    if let Some(obj) = v.as_object() {
        for (k, val) in obj {
            if key_is_id(k) && !skip.contains(k) {
                if let Some(s) = scalar_id(val) {
                    return Some(s);
                }
            }
        }
        for (_, val) in obj {
            if let Some(s) = find_id_skipping(val, skip) {
                return Some(s);
            }
        }
    } else if let Some(arr) = v.as_array() {
        for val in arr {
            if let Some(s) = find_id_skipping(val, skip) {
                return Some(s);
            }
        }
    }
    None
}

/// Convert a raw route path from any source into the canonical `{name}` form.
pub fn normalize_path(p: &str) -> String {
    let mut out = String::new();
    for (i, seg) in p.split('/').enumerate() {
        if i > 0 {
            out.push('/');
        }
        if let Some(rest) = seg.strip_prefix(':') {
            // axum 0.6/0.7 named param
            out.push('{');
            out.push_str(rest);
            out.push('}');
        } else if let Some(rest) = seg.strip_prefix('*') {
            // axum 0.6/0.7 wildcard
            out.push('{');
            out.push_str(rest);
            out.push('}');
        } else if seg.starts_with('{') && seg.ends_with('}') && seg.len() >= 2 {
            // axum 0.8 / OpenAPI: {name} or {*name}
            let inner = &seg[1..seg.len() - 1];
            let inner = inner.strip_prefix('*').unwrap_or(inner);
            out.push('{');
            out.push_str(inner);
            out.push('}');
        } else {
            out.push_str(seg);
        }
    }
    out
}

/// Collect the `{name}` parameter names from a normalized path, in order.
pub fn extract_params(normalized: &str) -> Vec<String> {
    let mut params = Vec::new();
    let mut rest = normalized;
    while let Some(start) = rest.find('{') {
        if let Some(end) = rest[start..].find('}') {
            params.push(rest[start + 1..start + end].to_string());
            rest = &rest[start + end + 1..];
        } else {
            break;
        }
    }
    params
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalizes_axum_07_colon_params() {
        assert_eq!(normalize_path("/history/:id"), "/history/{id}");
        assert_eq!(normalize_path("/files/*path"), "/files/{path}");
    }

    #[test]
    fn normalizes_axum_08_brace_params() {
        assert_eq!(normalize_path("/user/{username}"), "/user/{username}");
        assert_eq!(normalize_path("/files/{*path}"), "/files/{path}");
    }

    #[test]
    fn extracts_params_and_classifies() {
        let c = Endpoint::new(Method::Get, "/notes/{id}");
        assert_eq!(c.path_params, vec!["id".to_string()]);
        assert!(c.is_consumer());
        assert!(!c.is_producer());

        let p = Endpoint::new(Method::Post, "/notes");
        assert!(p.is_producer());
        assert!(!p.is_consumer());

        // a GET with no path param is neither a producer nor an id-in-path consumer
        let idx = Endpoint::new(Method::Get, "/api/v0/record");
        assert!(!idx.is_consumer());
        assert!(!idx.is_producer());
    }

    #[test]
    fn concrete_path_substitutes_first_param() {
        let c = Endpoint::new(Method::Get, "/notes/{id}/owned");
        assert_eq!(c.concrete_path("7"), "/notes/7/owned");
    }

    #[test]
    fn fill_consumer_puts_id_in_last_param_and_tenant_prefix_from_known() {
        // OpenObserve shape: tenant prefix {org_id} then resource id {dashboard_id}
        let c = Endpoint::new(Method::Get, "/api/{org_id}/dashboards/{dashboard_id}");
        let mut known = HashMap::new();
        known.insert("org_id".to_string(), "default".to_string());
        assert_eq!(
            c.fill_consumer("7516047333927157760", &known).as_deref(),
            Some("/api/default/dashboards/7516047333927157760")
        );
        // unknown tenant prefix -> cannot address -> None (skip, do not guess)
        assert_eq!(c.fill_consumer("7516047333927157760", &HashMap::new()), None);
        // single-param path with empty known still works (back-compat)
        let n = Endpoint::new(Method::Get, "/notes/{id}");
        assert_eq!(n.fill_consumer("9", &HashMap::new()).as_deref(), Some("/notes/9"));
    }

    #[test]
    fn fill_producer_requires_all_params_known() {
        let p = Endpoint::new(Method::Post, "/api/{org_id}/dashboards");
        let mut known = HashMap::new();
        known.insert("org_id".to_string(), "default".to_string());
        assert_eq!(p.fill_producer(&known).as_deref(), Some("/api/default/dashboards"));
        assert_eq!(p.fill_producer(&HashMap::new()), None);
        // no params -> trivially the literal path
        let q = Endpoint::new(Method::Post, "/notes");
        assert_eq!(q.fill_producer(&HashMap::new()).as_deref(), Some("/notes"));
    }

    #[test]
    fn id_collection_matches_producer_collection() {
        let mut known = HashMap::new();
        known.insert("org_id".to_string(), "default".to_string());
        // producer POST /api/{org_id}/dashboards fills to the collection path
        let prod = Endpoint::new(Method::Post, "/api/{org_id}/dashboards");
        let coll = prod.fill_producer(&known).unwrap();
        assert_eq!(coll, "/api/default/dashboards");
        // the by-id consumer collapses to the same collection -> matches
        let c1 = Endpoint::new(Method::Get, "/api/{org_id}/dashboards/{dashboard_id}");
        assert_eq!(c1.id_collection(&known).as_deref(), Some("/api/default/dashboards"));
        // a sub-resource addressed by the same id also belongs to the collection
        let c2 = Endpoint::new(Method::Get, "/api/{org_id}/dashboards/{dashboard_id}/annotations");
        assert_eq!(c2.id_collection(&known).as_deref(), Some("/api/default/dashboards"));
        // a different collection does NOT match
        let c3 = Endpoint::new(Method::Get, "/api/{org_id}/folders/{folder_id}");
        assert_eq!(c3.id_collection(&known).as_deref(), Some("/api/default/folders"));
        assert_ne!(c3.id_collection(&known).as_deref(), Some(coll.as_str()));
        // unknown tenant prefix -> cannot address
        assert_eq!(c1.id_collection(&HashMap::new()), None);
        // single-param back-compat (notes): collection is the static parent
        let n = Endpoint::new(Method::Get, "/notes/{id}");
        assert_eq!(n.id_collection(&HashMap::new()).as_deref(), Some("/notes"));
        let no = Endpoint::new(Method::Get, "/notes/{id}/owned");
        assert_eq!(no.id_collection(&HashMap::new()).as_deref(), Some("/notes"));
    }

    #[test]
    fn name_and_me_scoped_consumers_are_skipped() {
        // name-keyed last param
        assert!(Endpoint::new(Method::Get, "/user/{username}").is_name_or_me_scoped());
        assert!(Endpoint::new(Method::Get, "/api/{org_id}/functions/{name}").is_name_or_me_scoped());
        assert!(Endpoint::new(Method::Get, "/api/{org_id}/alerts/templates/{template_name}").is_name_or_me_scoped());
        // self-scoped segment
        assert!(Endpoint::new(Method::Get, "/api/v0/me").is_name_or_me_scoped());
        assert!(Endpoint::new(Method::Get, "/users/me/tokens").is_name_or_me_scoped());
        // genuine opaque-id resources are NOT skipped
        assert!(!Endpoint::new(Method::Get, "/api/{org_id}/dashboards/{dashboard_id}").is_name_or_me_scoped());
        assert!(!Endpoint::new(Method::Get, "/api/{org_id}/savedviews/{view_id}").is_name_or_me_scoped());
        assert!(!Endpoint::new(Method::Get, "/notes/{id}").is_name_or_me_scoped());
    }

    #[test]
    fn extract_id_handles_int_string_and_nested() {
        // top-level integer id
        assert_eq!(extract_id(&serde_json::json!({"id": 7})).as_deref(), Some("7"));
        // top-level string / uuid id, returned verbatim
        let uuid = "62ce74d1-b5e4-4744-acee-23b3222e71ca";
        assert_eq!(extract_id(&serde_json::json!({"id": uuid})).as_deref(), Some(uuid));
        // *_id fallback
        assert_eq!(extract_id(&serde_json::json!({"note_id": 42})).as_deref(), Some("42"));
        // nested id (OpenObserve dashboard: v5.dashboardId as a numeric string)
        let oo = serde_json::json!({
            "v1": null, "v5": {"dashboardId": "7516047333927157760", "title": "x"}, "version": 5
        });
        assert_eq!(extract_id(&oo).as_deref(), Some("7516047333927157760"));
        // empty string id is ignored
        assert_eq!(extract_id(&serde_json::json!({"id": ""})), None);
        // no id anywhere
        assert_eq!(extract_id(&serde_json::json!({"title": "x"})), None);
    }

    #[test]
    fn extract_id_skips_tenant_id_keys() {
        use std::collections::HashSet;
        // OpenObserve savedview create echoes org_id ("default") AND the resource's view_id.
        // Alphabetically org_id sorts first, so without a skip set it would be captured wrongly.
        let resp = serde_json::json!({
            "org_id": "default", "view_id": "3Kg7rmsTOtq", "view_name": "x"
        });
        assert_eq!(extract_id(&resp).as_deref(), Some("default")); // naive: wrong tenant id
        let skip: HashSet<String> = ["org_id".to_string()].into_iter().collect();
        assert_eq!(extract_id_skipping(&resp, &skip).as_deref(), Some("3Kg7rmsTOtq")); // resource id
    }

    #[test]
    fn producer_requires_id_when_response_known() {
        let mut p = Endpoint::new(Method::Post, "/login");
        p.response_has_id = Some(false);
        assert!(!p.is_producer());
        p.response_has_id = Some(true);
        assert!(p.is_producer());
    }
}
