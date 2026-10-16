//! Route source #1: an OpenAPI 3 spec. This is the original crux_workload path,
//! refactored to emit the common `Endpoint` model. An app that ships a spec
//! (utoipa / paperclip) needs no source access.
use crate::endpoint::{Endpoint, Method};
use serde_json::Value;
use std::rc::Rc;

fn resolve<'a>(spec: &'a Value, schema: &'a Value) -> &'a Value {
    if let Some(r) = schema.get("$ref").and_then(Value::as_str) {
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

/// Whether the response object declares an id-ish property at its top level: a literal `id`, or
/// any `*_id`/`*Id` key (OpenObserve's savedview create returns `view_id`, not `id`). This mirrors
/// the runtime id extractor (`endpoint::extract_id`), so the producer CLASSIFICATION agrees with
/// what the capture can actually find. Returns:
///   * `Some(true)`  the response enumerates properties and one is id-ish,
///   * `Some(false)` it enumerates properties and NONE is id-ish (a genuine no-id body),
///   * `None`        the schema is OPAQUE (no `properties`, or an empty `properties`), so we
///                   cannot tell and must let the runtime id extraction decide. Many real
///                   handlers (OpenObserve's pipelines/roles/alerts) declare only `type: object`
///                   for their 200, which the old `false` default wrongly rejected as a producer.
fn id_presence(schema: &Value) -> Option<bool> {
    match schema.pointer("/properties").and_then(Value::as_object) {
        Some(props) if !props.is_empty() => Some(props.keys().any(|k| crate::endpoint::key_is_id(k))),
        _ => None,
    }
}

const METHOD_KEYS: &[&str] = &["get", "post", "put", "patch", "delete", "head", "options"];

/// Parse every path/operation in the spec into the common endpoint model.
pub fn extract(spec: &Value) -> Vec<Endpoint> {
    let mut out = Vec::new();
    let Some(paths) = spec.get("paths").and_then(Value::as_object) else {
        return out;
    };
    // Shared once; each endpoint keeps a cheap Rc clone so body synthesis can resolve nested
    // `$ref`s (`#/components/schemas/..`) against the whole document.
    let root = Rc::new(spec.clone());
    for (path, item) in paths {
        for key in METHOD_KEYS {
            let Some(op) = item.get(*key) else { continue };
            let mut ep = Endpoint::new(Method::parse(key), path);
            if let Some(s) = op.pointer("/requestBody/content/application~1json/schema") {
                ep.body_schema = Some(resolve(spec, s).clone());
                ep.schema_root = Some(root.clone());
            }
            // When the op declares a 200 JSON schema we trust it (id present or not); when it
            // declares none (OpenObserve's dashboard create has a null 200 schema), we cannot
            // tell, so leave it UNKNOWN (`None`) and let the runtime id extraction decide,
            // exactly as the axum source treats every POST/PUT as a candidate.
            ep.response_has_id = response_schema(spec, op).and_then(id_presence);
            out.push(ep);
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::endpoint::Method;

    fn notes_spec() -> Value {
        serde_json::json!({
            "paths": {
                "/notes": {
                    "post": {
                        "requestBody": {"content": {"application/json": {"schema": {"$ref": "#/components/schemas/NewNote"}}}},
                        "responses": {"200": {"content": {"application/json": {"schema": {"$ref": "#/components/schemas/CreatedId"}}}}}
                    }
                },
                "/notes/{id}": {"get": {"responses": {"200": {"content": {"application/json": {"schema": {"type": "object"}}}}}}},
                "/notes/{id}/owned": {"get": {"responses": {"200": {}}}}
            },
            "components": {"schemas": {
                "NewNote": {"type": "object", "properties": {"body": {"type": "string"}}},
                "CreatedId": {"type": "object", "properties": {"id": {"type": "integer"}}}
            }}
        })
    }

    #[test]
    fn opaque_200_object_leaves_producer_unknown_so_it_is_attempted() {
        // OpenObserve's pipelines/roles/alerts declare only `type: object` for the 200 (no
        // enumerated properties). The old `has_id_property` returned false and REJECTED these as
        // producers; now an opaque body is UNKNOWN so the runtime id capture decides.
        let spec = serde_json::json!({
            "paths": {
                "/api/{org_id}/pipelines": {
                    "post": {"responses": {"200": {"content": {"application/json": {"schema": {"type": "object"}}}}}}
                },
                "/api/{org_id}/roles": {
                    "post": {"responses": {"200": {"content": {"application/json": {"schema": {"type": "object", "properties": {}}}}}}}
                },
                "/login": {
                    "post": {"responses": {"200": {"content": {"application/json": {"schema": {"type": "object", "properties": {"token": {"type": "string"}}}}}}}}
                }
            }
        });
        let eps = extract(&spec);
        let prod = |p: &str| eps.iter().find(|e| e.path == p).unwrap().is_producer();
        assert!(prod("/api/{org_id}/pipelines"), "opaque 200 -> candidate");
        assert!(prod("/api/{org_id}/roles"), "empty-properties 200 -> candidate");
        // a 200 that enumerates properties with no id-ish key is still a genuine non-producer
        assert!(!prod("/login"), "enumerated no-id body -> not a producer");
    }

    #[test]
    fn extracts_producer_and_consumers_from_spec() {
        let eps = extract(&notes_spec());
        let producers: Vec<_> = eps.iter().filter(|e| e.is_producer()).collect();
        let consumers: Vec<_> = eps.iter().filter(|e| e.is_consumer()).collect();
        assert_eq!(producers.len(), 1, "one POST with an id in the 200 body");
        assert_eq!(producers[0].path, "/notes");
        assert_eq!(consumers.len(), 2, "two GET-with-{{id}} endpoints");
        // body synthesis uses the schema: the string prop becomes the marker
        let body = producers[0].synth_body("MARK");
        assert!(body.contains("MARK"));
        assert_eq!(producers[0].method, Method::Post);
    }
}
