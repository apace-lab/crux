//! JSON Schema body synthesis for the producer.
//!
//! Real apps (OpenObserve, Rauthy, Trustify) describe a create body with a richly typed
//! JSON Schema: `$ref`s into `components/schemas`, `oneOf`/`anyOf`/`allOf` composition,
//! nested required objects, arrays of objects, enums, and typed string formats. The prior
//! synthesizer only filled top-level scalar properties, so the producer could not build such
//! a body and fell back to a trivial POST. This module synthesizes a MINIMAL valid instance:
//!
//!   * `$ref` is resolved against the spec root (`#/components/schemas/Foo`), cycle-safe.
//!   * `allOf` is merged (the union of every subschema's object fields), nesting-safe so an
//!     `allOf` of `allOf` of `oneOf` (OpenObserve's Slo) still collects every required field.
//!   * an object builds every `required` property recursively (and, when a schema lists no
//!     `required`, every property, which is the old behavior the notes demo relies on).
//!   * an array yields `minItems` elements (at least one) of its `items` schema.
//!   * `const`/`default`/`example`/`enum` short-circuit to the concrete value.
//!   * string `format` is honored (date-time, date, uuid, email, and the numeric formats), and
//!     `minLength`/`maxLength` fit the free-form marker to a required length.
//!   * numeric `minimum`/`maximum`/`exclusiveMinimum`/`exclusiveMaximum` yield an in-range value
//!     instead of always `1`.
//!   * `oneOf`/`anyOf` prefers the first SUBSTANTIVE variant (non-null, non-empty), which skips
//!     the common `null` arm and an unresolved-`$ref` arm that collapsed to `{}`.
//!   * a map-typed object (`additionalProperties`) with `minProperties >= 1` gets one entry.
//!
//! The goal is only to PASS server-side validation so the create returns an id, not to be a
//! faithful instance generator.
use serde_json::{Map, Value};
use std::collections::HashSet;

/// Synthesize a minimal valid JSON instance for `schema`. `root` is the spec document used to
/// resolve `$ref` (pass the whole spec; `None` disables ref resolution). `marker` is the
/// string planted into free-form string fields so the response oracle can recognize it.
pub fn synthesize(schema: &Value, root: Option<&Value>, marker: &str) -> Value {
    let mut seen = HashSet::new();
    build(schema, root, marker, &mut seen)
}

fn build(schema: &Value, root: Option<&Value>, marker: &str, seen: &mut HashSet<String>) -> Value {
    // $ref: resolve against the spec root, cycle-safe.
    if let Some(r) = schema.get("$ref").and_then(Value::as_str) {
        if seen.contains(r) {
            return Value::Object(Map::new()); // a cycle: stop expanding here
        }
        if let Some(target) = resolve_ref(root, r) {
            seen.insert(r.to_string());
            let out = build(&target, root, marker, seen);
            seen.remove(r);
            return out;
        }
        return Value::Object(Map::new());
    }

    // Hard constraints always win: a `const` allows exactly one value, an `enum` requires a
    // member. (`default`/`example` are only hints and are handled below, after type, so they do
    // NOT override the marker in a free-form string field, which the oracle needs to see.)
    if let Some(c) = schema.get("const") {
        return c.clone();
    }
    if let Some(first) = schema.get("enum").and_then(Value::as_array).and_then(|a| a.first()) {
        return first.clone();
    }

    // allOf: merge every subschema's object fields (plus the schema's own fields).
    if let Some(all) = schema.get("allOf").and_then(Value::as_array) {
        let mut map = object_map(schema, root, marker, seen);
        for sub in all {
            if let Value::Object(m) = build(sub, root, marker, seen) {
                for (k, v) in m {
                    map.insert(k, v);
                }
            }
        }
        return Value::Object(map);
    }

    // oneOf / anyOf: prefer the first SUBSTANTIVE variant (non-null and not an empty
    // object/array), since in a discriminated union an empty object or a bare `null` is almost
    // always the "none"/placeholder arm (e.g. the common `oneOf[{null}, {$ref Real}]`), and a
    // variant whose `$ref` did not resolve collapses to `{}`. Fall back to the first non-null,
    // then the first, so a genuinely empty-object variant is still produced if nothing better.
    for key in ["oneOf", "anyOf"] {
        if let Some(variants) = schema.get(key).and_then(Value::as_array) {
            let mut first_non_null: Option<Value> = None;
            let mut first_any: Option<Value> = None;
            for v in variants {
                let built = build(v, root, marker, seen);
                if first_any.is_none() {
                    first_any = Some(built.clone());
                }
                if built.is_null() {
                    continue;
                }
                if first_non_null.is_none() {
                    first_non_null = Some(built.clone());
                }
                if !is_empty_instance(&built) {
                    return built;
                }
            }
            return first_non_null.or(first_any).unwrap_or(Value::Null);
        }
    }

    let ty = effective_type(schema);

    // A free-form string field carries the marker (honoring `format`) so the oracle can see it
    // served back; `default`/`example` are deliberately NOT used here for strings.
    if ty == "string" {
        return Value::String(string_for(schema, marker));
    }

    // For non-string scalars/objects, a concrete `default`/`example` is a valid instance and is
    // preferred (it satisfies any shape the schema is too terse to describe).
    if let Some(d) = schema.get("default") {
        if !d.is_null() {
            return d.clone();
        }
    }
    if let Some(e) = schema.get("example") {
        if !e.is_null() {
            return e.clone();
        }
    }

    match ty {
        "object" => Value::Object(object_map(schema, root, marker, seen)),
        "array" => build_array(schema, root, marker, seen),
        "integer" => number_for(schema, false),
        "number" => number_for(schema, true),
        "boolean" => Value::Bool(true),
        "null" => Value::Null,
        _ => Value::Object(Map::new()),
    }
}

/// Whether a built instance is "empty" (an empty object or empty array), used by `oneOf`/`anyOf`
/// variant selection to prefer a substantive variant.
fn is_empty_instance(v: &Value) -> bool {
    match v {
        Value::Object(m) => m.is_empty(),
        Value::Array(a) => a.is_empty(),
        _ => false,
    }
}

/// An in-range number honoring `minimum`/`maximum`/`exclusiveMinimum`/`exclusiveMaximum`, so a
/// field that requires (say) a value `>= 10` or in a bounded range passes validation instead of
/// always sending `1`. Defaults to 1. For `type: integer` the result is always an integer; for
/// `type: number` a whole value is emitted as an integer (so an unconstrained number stays `1`,
/// a valid JSON number) and only a fractional bound yields a JSON float.
fn number_for(schema: &Value, as_float: bool) -> Value {
    let get = |k: &str| schema.get(k).and_then(Value::as_f64);
    let mut n: f64 = 1.0;
    if let Some(min) = get("minimum") {
        if n < min {
            n = min;
        }
    }
    if let Some(exc) = get("exclusiveMinimum") {
        if n <= exc {
            n = exc + 1.0;
        }
    }
    if let Some(max) = get("maximum") {
        if n > max {
            n = max;
        }
    }
    if let Some(exc) = get("exclusiveMaximum") {
        if n >= exc {
            n = exc - 1.0;
        }
    }
    if as_float && n.fract() != 0.0 {
        Value::from(n)
    } else {
        Value::from(n as i64)
    }
}

/// Resolve a local `#/...` reference against the spec root via a JSON pointer.
fn resolve_ref(root: Option<&Value>, r: &str) -> Option<Value> {
    let root = root?;
    let ptr = r.strip_prefix('#')?;
    root.pointer(ptr).cloned()
}

/// Decide the schema's type when it is stated, otherwise infer from its shape. A body with no
/// `type` but `properties`/`required` is an object; one with `items` is an array; a bare schema
/// degrades to an (empty) object, which is the safe neutral body.
fn effective_type(schema: &Value) -> &str {
    if let Some(t) = schema.get("type").and_then(Value::as_str) {
        return t;
    }
    // "type" may be an array (nullable unions); take the first non-null.
    if let Some(arr) = schema.get("type").and_then(Value::as_array) {
        for t in arr {
            if let Some(s) = t.as_str() {
                if s != "null" {
                    return match s {
                        "object" => "object",
                        "array" => "array",
                        "string" => "string",
                        "integer" => "integer",
                        "number" => "number",
                        "boolean" => "boolean",
                        _ => "object",
                    };
                }
            }
        }
    }
    if schema.get("properties").is_some() || schema.get("required").is_some() {
        "object"
    } else if schema.get("items").is_some() {
        "array"
    } else {
        // A truly structureless leaf (no type, no properties/items/composition) is most often a
        // scalar the spec left underspecified (OpenObserve's savedview `data` is a typeless
        // base64 string). A marker string is valid JSON for an arbitrary-body endpoint too, and
        // it keeps the oracle's marker in the created object.
        "string"
    }
}

/// Build an object's fields: every `required` property recursively, or (when none is listed)
/// every property, so a schema that relies on optional-but-expected fields still gets them.
fn object_map(
    schema: &Value,
    root: Option<&Value>,
    marker: &str,
    seen: &mut HashSet<String>,
) -> Map<String, Value> {
    let mut map = Map::new();
    let props = schema.get("properties").and_then(Value::as_object);
    let required: Vec<&str> = schema
        .get("required")
        .and_then(Value::as_array)
        .map(|a| a.iter().filter_map(Value::as_str).collect())
        .unwrap_or_default();

    if !required.is_empty() {
        for name in required {
            let val = match props.and_then(|p| p.get(name)) {
                Some(s) => build(s, root, marker, seen),
                None => Value::String(marker.to_string()),
            };
            map.insert(name.to_string(), val);
        }
    } else if let Some(props) = props {
        for (k, v) in props {
            map.insert(k.clone(), build(v, root, marker, seen));
        }
    }

    // A map-typed object (no declared `properties`, values described by `additionalProperties`)
    // that REQUIRES at least one entry (`minProperties >= 1`) gets one synthesized entry; an
    // optional map is left empty, since `{}` is a valid instance the server will accept.
    if map.is_empty() {
        let min_props = schema.get("minProperties").and_then(Value::as_u64).unwrap_or(0);
        if min_props >= 1 {
            if let Some(addl) = schema.get("additionalProperties") {
                if addl.is_object() {
                    map.insert("crux_key".to_string(), build(addl, root, marker, seen));
                }
            }
        }
    }
    map
}

/// Build an array of `minItems` (at least one) element(s) of the `items` schema.
fn build_array(
    schema: &Value,
    root: Option<&Value>,
    marker: &str,
    seen: &mut HashSet<String>,
) -> Value {
    let n = schema.get("minItems").and_then(Value::as_u64).unwrap_or(1).max(1);
    let elem = match schema.get("items") {
        Some(items) => build(items, root, marker, seen),
        None => Value::String(marker.to_string()),
    };
    Value::Array((0..n).map(|_| elem.clone()).collect())
}

/// A string value honoring `format`. Free-form strings get the marker so the oracle can see it.
fn string_for(schema: &Value, marker: &str) -> String {
    match schema.get("format").and_then(Value::as_str) {
        Some("date-time") => "2020-01-01T00:00:00Z".to_string(),
        Some("date") => "2020-01-01".to_string(),
        Some("time") => "00:00:00".to_string(),
        Some("uuid") => "00000000-0000-4000-8000-000000000000".to_string(),
        Some("email") => "crux@example.com".to_string(),
        Some("uri") | Some("url") => "https://example.com".to_string(),
        Some("hostname") => "example.com".to_string(),
        Some("ipv4") => "127.0.0.1".to_string(),
        // numeric formats carried on a string type
        Some("int32") | Some("int64") | Some("integer") => "1".to_string(),
        _ => fit_length(marker, schema),
    }
}

/// Fit a free-form string to `minLength`/`maxLength` when the schema constrains them, so a field
/// that demands (say) at least 8 characters passes validation. Only applied to the free-form
/// marker case; a formatted value (uuid, email, ...) already has a fixed valid shape.
fn fit_length(marker: &str, schema: &Value) -> String {
    let mut s = marker.to_string();
    if let Some(min) = schema.get("minLength").and_then(Value::as_u64) {
        while (s.len() as u64) < min {
            s.push('a');
        }
    }
    if let Some(max) = schema.get("maxLength").and_then(Value::as_u64) {
        if (s.len() as u64) > max {
            s.truncate(max as usize);
        }
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn syn(schema: &Value, root: Option<&Value>) -> Value {
        synthesize(schema, root, "MARK")
    }

    #[test]
    fn scalars_and_formats() {
        assert_eq!(syn(&json!({"type": "string"}), None), json!("MARK"));
        assert_eq!(syn(&json!({"type": "integer"}), None), json!(1));
        assert_eq!(syn(&json!({"type": "number"}), None), json!(1));
        assert_eq!(syn(&json!({"type": "boolean"}), None), json!(true));
        assert_eq!(syn(&json!({"type": "string", "format": "date-time"}), None), json!("2020-01-01T00:00:00Z"));
        assert_eq!(syn(&json!({"type": "string", "format": "uuid"}), None), json!("00000000-0000-4000-8000-000000000000"));
        assert_eq!(syn(&json!({"type": "string", "format": "email"}), None), json!("crux@example.com"));
    }

    #[test]
    fn enum_picks_first() {
        let s = json!({"type": "string", "enum": ["dashboard", "alert", "function"]});
        assert_eq!(syn(&s, None), json!("dashboard"));
    }

    #[test]
    fn const_and_enum_always_win_but_string_default_yields_marker() {
        // const is a hard constraint and wins even for a string.
        assert_eq!(syn(&json!({"const": "fixed"}), None), json!("fixed"));
        assert_eq!(syn(&json!({"type": "string", "enum": ["x", "y"]}), None), json!("x"));
        // default/example win for NON-string scalars (valid concrete instances)...
        assert_eq!(syn(&json!({"type": "integer", "example": 42}), None), json!(42));
        assert_eq!(syn(&json!({"type": "integer", "default": 7}), None), json!(7));
        // ...but a free-form string takes the MARKER, not its default, so the oracle sees it.
        // (OpenObserve's Dashboard.title/description both carry default "".)
        assert_eq!(syn(&json!({"type": "string", "default": ""}), None), json!("MARK"));
    }

    #[test]
    fn nested_required_object_only_builds_required() {
        // required `name` and nested required object `owner{id}`; optional `note` is omitted.
        let s = json!({
            "type": "object",
            "required": ["name", "owner"],
            "properties": {
                "name": {"type": "string"},
                "note": {"type": "string"},
                "owner": {
                    "type": "object",
                    "required": ["id"],
                    "properties": {"id": {"type": "integer"}, "extra": {"type": "string"}}
                }
            }
        });
        assert_eq!(syn(&s, None), json!({"name": "MARK", "owner": {"id": 1}}));
    }

    #[test]
    fn no_required_fills_all_properties() {
        // notes_app NewNote shape: no `required`, so every property is filled (back-compat).
        let s = json!({"type": "object", "properties": {"body": {"type": "string"}}});
        assert_eq!(syn(&s, None), json!({"body": "MARK"}));
    }

    #[test]
    fn array_of_object_yields_one_element() {
        let s = json!({
            "type": "array",
            "items": {"type": "object", "required": ["k"], "properties": {"k": {"type": "string"}}}
        });
        assert_eq!(syn(&s, None), json!([{"k": "MARK"}]));
        // minItems honored
        let s2 = json!({"type": "array", "minItems": 2, "items": {"type": "integer"}});
        assert_eq!(syn(&s2, None), json!([1, 1]));
    }

    #[test]
    fn one_of_picks_first_viable_variant() {
        // a nullable oneOf: the null variant is skipped for the first object variant.
        let s = json!({
            "oneOf": [
                {"type": "null"},
                {"type": "object", "required": ["title"], "properties": {"title": {"type": "string"}}}
            ]
        });
        assert_eq!(syn(&s, None), json!({"title": "MARK"}));
    }

    #[test]
    fn any_of_picks_first() {
        let s = json!({"anyOf": [{"type": "integer"}, {"type": "string"}]});
        assert_eq!(syn(&s, None), json!(1));
    }

    #[test]
    fn all_of_merges_subschemas() {
        let s = json!({
            "allOf": [
                {"type": "object", "required": ["a"], "properties": {"a": {"type": "string"}}},
                {"type": "object", "required": ["b"], "properties": {"b": {"type": "integer"}}}
            ]
        });
        assert_eq!(syn(&s, None), json!({"a": "MARK", "b": 1}));
    }

    #[test]
    fn ref_is_resolved_against_root() {
        let root = json!({
            "components": {"schemas": {
                "Dashboard": {
                    "type": "object",
                    "required": ["title", "panels"],
                    "properties": {
                        "title": {"type": "string"},
                        "panels": {"type": "array", "items": {"$ref": "#/components/schemas/Panel"}}
                    }
                },
                "Panel": {"type": "object", "required": ["id"], "properties": {"id": {"type": "string"}}}
            }}
        });
        let body = json!({"$ref": "#/components/schemas/Dashboard"});
        let out = syn(&body, Some(&root));
        assert_eq!(out, json!({"title": "MARK", "panels": [{"id": "MARK"}]}));
    }

    #[test]
    fn one_of_of_refs_like_openobserve_dashboard() {
        // Mirrors OpenObserve's Dashboard body: a oneOf over versioned variants, each a $ref.
        let root = json!({
            "components": {"schemas": {
                "DashboardV1": {
                    "type": "object",
                    "required": ["title", "version"],
                    "properties": {
                        "title": {"type": "string"},
                        "version": {"type": "integer"},
                        "dashboardId": {"type": "string"}
                    }
                }
            }}
        });
        let body = json!({"oneOf": [{"$ref": "#/components/schemas/DashboardV1"}]});
        let out = syn(&body, Some(&root));
        assert_eq!(out, json!({"title": "MARK", "version": 1}));
    }

    #[test]
    fn recursive_ref_is_cycle_safe() {
        // A self-referential required field must not recurse forever; the cycle stops as {}.
        let root = json!({
            "components": {"schemas": {
                "Node": {
                    "type": "object",
                    "required": ["child"],
                    "properties": {"child": {"$ref": "#/components/schemas/Node"}}
                }
            }}
        });
        let out = syn(&json!({"$ref": "#/components/schemas/Node"}), Some(&root));
        // one level then the cycle breaks to an empty object
        assert_eq!(out, json!({"child": {}}));
    }

    #[test]
    fn typeless_with_properties_is_object() {
        let s = json!({"required": ["x"], "properties": {"x": {"type": "boolean"}}});
        assert_eq!(syn(&s, None), json!({"x": true}));
    }

    #[test]
    fn number_honors_min_max_bounds() {
        // a field requiring value >= 10 gets 10, not 1
        assert_eq!(syn(&json!({"type": "integer", "minimum": 10}), None), json!(10));
        // exclusiveMinimum: strictly greater
        assert_eq!(syn(&json!({"type": "integer", "exclusiveMinimum": 5}), None), json!(6));
        // clamp to maximum when the default already exceeds it
        assert_eq!(syn(&json!({"type": "integer", "maximum": 0}), None), json!(0));
        // a whole-valued number is emitted as an integer (valid JSON for a number field)
        assert_eq!(syn(&json!({"type": "number", "minimum": 50.0, "maximum": 100.0}), None), json!(50));
        // a fractional bound forces a JSON float
        assert_eq!(syn(&json!({"type": "number", "minimum": 0.5}), None), json!(1));
        assert_eq!(syn(&json!({"type": "number", "exclusiveMaximum": 1}), None), json!(0));
        // unconstrained still defaults to 1
        assert_eq!(syn(&json!({"type": "integer"}), None), json!(1));
    }

    #[test]
    fn string_fits_min_and_max_length() {
        // marker padded up to minLength
        let out = syn(&json!({"type": "string", "minLength": 64}), None);
        assert!(out.as_str().unwrap().len() >= 64);
        assert!(out.as_str().unwrap().starts_with("MARK"));
        // marker truncated to maxLength
        assert_eq!(syn(&json!({"type": "string", "maxLength": 2}), None), json!("MA"));
        // a formatted value is not length-mangled
        assert_eq!(syn(&json!({"type": "string", "format": "email", "maxLength": 2}), None), json!("crux@example.com"));
    }

    #[test]
    fn one_of_prefers_substantive_over_empty_variant() {
        // an empty-object variant first, a real object second: the real one wins.
        let s = json!({
            "oneOf": [
                {"type": "object"},
                {"type": "object", "required": ["x"], "properties": {"x": {"type": "string"}}}
            ]
        });
        assert_eq!(syn(&s, None), json!({"x": "MARK"}));
        // but if every variant is an empty object, one is still produced (fallback).
        let s2 = json!({"oneOf": [{"type": "object"}, {"type": "object"}]});
        assert_eq!(syn(&s2, None), json!({}));
        // a variant whose $ref does not resolve (collapses to {}) is skipped for a real one.
        let s3 = json!({"oneOf": [{"$ref": "#/components/schemas/Missing"}, {"type": "integer"}]});
        assert_eq!(syn(&s3, Some(&json!({"components": {"schemas": {}}}))), json!(1));
    }

    #[test]
    fn map_object_with_min_properties_gets_one_entry() {
        // a required map value (additionalProperties) that must be non-empty gets one entry...
        let s = json!({
            "type": "object", "minProperties": 1,
            "additionalProperties": {"type": "string"}
        });
        assert_eq!(syn(&s, None), json!({"crux_key": "MARK"}));
        // ...but an optional map stays empty (a valid instance).
        let s2 = json!({"type": "object", "additionalProperties": {"type": "string"}});
        assert_eq!(syn(&s2, None), json!({}));
    }

    #[test]
    fn nested_all_of_of_all_of_merges_all_required() {
        // Mirrors OpenObserve's Slo: allOf[ SloDefinition(=allOf[SliConfig(oneOf), {window_secs}]),
        // {name, target} ]. Every required field across the nesting must appear, and the oneOf
        // discriminator (an enum) must be set to a member.
        let root = json!({
            "components": {"schemas": {
                "SliConfig": {
                    "oneOf": [
                        {
                            "type": "object",
                            "required": ["sli_type", "config"],
                            "properties": {
                                "sli_type": {"type": "string", "enum": ["count"]},
                                "config": {"type": "object", "required": ["source"],
                                    "properties": {"source": {"type": "string"}}}
                            }
                        }
                    ]
                },
                "SloDefinition": {
                    "allOf": [
                        {"$ref": "#/components/schemas/SliConfig"},
                        {"type": "object", "required": ["window_secs"],
                            "properties": {"window_secs": {"type": "integer"}}}
                    ]
                }
            }}
        });
        let body = json!({
            "allOf": [
                {"$ref": "#/components/schemas/SloDefinition"},
                {"type": "object", "required": ["name", "target"],
                    "properties": {"name": {"type": "string"},
                                   "target": {"type": "number", "minimum": 1.0}}}
            ]
        });
        let out = syn(&body, Some(&root));
        assert_eq!(out, json!({
            "sli_type": "count",
            "config": {"source": "MARK"},
            "window_secs": 1,
            "name": "MARK",
            "target": 1
        }));
    }

    #[test]
    fn typeless_leaf_is_marker_string() {
        // OpenObserve savedview `data`: a required property with only a description, no type.
        let s = json!({
            "type": "object",
            "required": ["data", "view_name"],
            "properties": {
                "data": {"description": "Base64 encoded string."},
                "view_name": {"type": "string"}
            }
        });
        assert_eq!(syn(&s, None), json!({"data": "MARK", "view_name": "MARK"}));
    }
}
