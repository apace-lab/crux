use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    fs,
    path::{Path, PathBuf},
};
use walkdir::WalkDir;

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum AccessKind {
    Read,
    Write,
}

/// What to inject at a site.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SiteAction {
    /// Record an access to a static PANode (monitor + access macros). If
    /// `call_name` is set, the macros are inserted right after the line where
    /// that call appears (searching from the site line), which is more reliable
    /// than a raw debug line for call results.
    Access {
        panode: u64,
        function_id: Option<u64>,
        access: AccessKind,
        call_name: Option<String>,
        /// If set (and `call_name` is set, i.e. an async call site), an
        /// `afg_schedule_point!(site = ..)` gate is inserted just before the
        /// access so a replay schedule can order this access across principals.
        schedule_site: Option<u64>,
        /// Resource id of the shared store this access touches: the points-to
        /// target the data-access call's store argument aliases. Two data-access
        /// sites on the same store (e.g. a write via `execute` and a read via
        /// `fetch_one`) get the SAME resource id even though their per-callsite
        /// PANodes differ, so the write-then-read leak can be linked across them.
        /// None for accesses with no identifiable shared store (e.g. LLM calls).
        #[serde(default)]
        resource: Option<u64>,
        /// Operand index (receiver-inclusive, matching `request_index`) of the
        /// call argument that names the resource INSTANCE at runtime (the file
        /// path for `File::open(path)`, the id for `PrivateMessage::read(pool,
        /// id)`). When set, the instrumenter captures that argument's runtime
        /// value and records it as the access resource, so the oracle can tell
        /// instance pm:1 from pm:2 (what separates a real leak from a benign
        /// shared-store access). None -> fall back to the static store resource.
        #[serde(default)]
        resource_arg: Option<usize>,
        /// Short label prefixed to the captured runtime id (e.g. "file", "pm").
        #[serde(default)]
        resource_prefix: Option<String>,
        /// When true, the resource instance id comes from the call's RETURN value
        /// (an ORM `create` returning the row with its generated id), so the call is
        /// wrapped to capture its result and read the id from it via `resource_expr`.
        #[serde(default)]
        resource_from_return: Option<bool>,
        /// Template to reach the id from the captured return value (`{}` = the value),
        /// e.g. `{}.id`. Default `{}`.
        #[serde(default)]
        resource_expr: Option<String>,
    },
    /// Establish the runtime principal for the current task. Injected before the
    /// auth call line; the instrumenter extracts the auth call's first argument
    /// from the source as the principal (convention: first arg = the user).
    Auth {
        /// The auth function's short name to locate in the source line (e.g. "decode").
        call_name: String,
        /// When true, the principal is the call's RETURN value, not an argument (e.g.
        /// dufs's `guard(...) -> (Option<String>, _)` returns the username). The call
        /// is then wrapped to capture its result and establish the principal from it.
        #[serde(default)]
        principal_from_return: Option<bool>,
        /// Expression template applied to the captured value (`{}` = the value) to
        /// reach the principal, e.g. `{}.0` for the first tuple element. Default `{}`.
        #[serde(default)]
        principal_expr: Option<String>,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InstrumentSite {
    pub file: PathBuf,
    pub line: usize,
    pub action: SiteAction,
    pub reason: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct InstrumentationPlan {
    pub sites: Vec<InstrumentSite>,
}

/// A declarative SOURCE-level DAO capture rule, loaded from a JSON catalog. It
/// recovers a per-instance resource that the IR cannot see because the DAO method
/// is erased by `#[async_trait]` boxing (the concrete type and id are captured into
/// a `dyn Future`), by matching the plain SOURCE call `let <b> = <..call..>;` and
/// recording the instance id from the bound value. All app/library specifics live
/// here as data, not in code.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SourceDaoRule {
    /// Qualified call to match, `Type::method` (e.g. "PrivateMessage::read").
    pub call: String,
    /// "Read" or "Write".
    pub kind: String,
    /// Resource label prefix (e.g. "pm").
    pub prefix: String,
    /// Expression appended to the bound value to reach the instance id (e.g. ".id").
    /// Used only when `resource_id_expr` is absent.
    #[serde(default)]
    pub id_expr: String,
    /// Full expression for the resource instance id, with `{binding}` substituted by
    /// the let binding. Overrides `id_expr` when present. Lets the resource be an
    /// in-scope value other than a field of the bound result -- e.g. at a SERVE point
    /// (a call that runs only after the authorization check passes) the id is a
    /// handler variable like `private_message_id`, not a field of the serve call's
    /// result. Capturing at the serve point (not the earlier DB read) is what makes
    /// a patched handler, which denies after reading, correctly show no leak.
    #[serde(default)]
    pub resource_id_expr: Option<String>,
    /// Rows this access yields (a non-owner read with count>0 is the leak; a write
    /// that establishes ownership is 0).
    #[serde(default)]
    pub count: u64,
    /// Optional expression (a `Vec<String>`) declaring the resource's additional
    /// authorized principals, with `{binding}` substituted by the bound value
    /// (e.g. "vec![format!(\"{:?}\", {binding}.recipient_id)]"). None = no extras.
    #[serde(default)]
    pub authorized_expr: Option<String>,
    /// Name of the handler parameter that carries the principal (e.g.
    /// "local_user_view"); the principal is established only in functions that have
    /// it, so non-handler call sites still compile. None = never establish here.
    #[serde(default)]
    pub principal_param: Option<String>,
    /// Expression for the principal, evaluated in the handler (e.g.
    /// "local_user_view.person.id"). Required when `principal_param` is set.
    #[serde(default)]
    pub principal_expr: Option<String>,
}

/// Load SOURCE-DAO rules from a JSON catalog: `{ "_schema_notes": {...}, "<group>":
/// [ {rule}, ... ], ... }` (the `_schema_notes` key is skipped), mirroring the other
/// catalogs. Returns an empty vec if the file is absent.
pub fn load_source_dao_rules(path: &Path) -> Result<Vec<SourceDaoRule>> {
    if !path.exists() {
        return Ok(Vec::new());
    }
    let content = fs::read_to_string(path)?;
    let data: std::collections::BTreeMap<String, serde_json::Value> =
        serde_json::from_str(&content)?;
    let mut rules = Vec::new();
    for (group, entries) in data {
        if group == "_schema_notes" {
            continue;
        }
        if let Some(arr) = entries.as_array() {
            for e in arr {
                rules.push(serde_json::from_value::<SourceDaoRule>(e.clone())?);
            }
        }
    }
    Ok(rules)
}

pub fn instrument_project(
    src: &Path,
    dst: &Path,
    plan: &InstrumentationPlan,
    runtime_crate_path: &Path,
    source_dao: &[SourceDaoRule],
) -> Result<()> {
    if dst.exists() {
        fs::remove_dir_all(dst)?;
    }
    copy_tree(src, dst)?;

    let mut by_file: HashMap<PathBuf, Vec<&InstrumentSite>> = HashMap::new();
    for site in &plan.sites {
        by_file.entry(site.file.clone()).or_default().push(site);
    }

    // Crates we actually rewrite; the afg_runtime dep is added to each of these (a
    // real app can be a cargo workspace, so the dep must go in each member crate,
    // not the workspace root).
    let mut runtime_manifests: std::collections::HashSet<PathBuf> = std::collections::HashSet::new();

    for (rel, sites) in by_file {
        let path = match resolve_target_file(dst, &rel) {
            Some(p) => p,
            None => {
                eprintln!(
                    "[instrument] warning: could not locate {} under {}",
                    rel.display(),
                    dst.display()
                );
                continue;
            }
        };

        if let Some(manifest) = nearest_crate_manifest(&path, dst) {
            runtime_manifests.insert(manifest);
        }

        let text = fs::read_to_string(&path)?;
        let mut lines: Vec<String> = text.lines().map(str::to_owned).collect();

        // Compute (insert_index, injected_text) for every site, then apply
        // bottom-up so earlier insertions don't shift later indices.
        let mut inserts: Vec<(usize, String)> = Vec::new();
        // Expression-position sites: (1-based line, call short name, probe macros).
        let mut expr_wraps: Vec<(usize, String, String)> = Vec::new();
        for site in &sites {
            if site.line == 0 || site.line > lines.len() {
                continue;
            }
            match &site.action {
                SiteAction::Access {
                    panode,
                    function_id,
                    access,
                    call_name,
                    schedule_site,
                    resource,
                    resource_arg,
                    resource_prefix,
                    resource_from_return,
                    resource_expr,
                } => {
                    let fn_id = function_id.unwrap_or(0);
                    let kind = match access {
                        AccessKind::Read => "Read",
                        AccessKind::Write => "Write",
                    };
                    // Resource id from the call's RETURN value (an ORM `create` whose
                    // row id is generated): wrap the call to capture its result and
                    // record the id from it. Reuses the expression-wrap machinery.
                    if resource_from_return.unwrap_or(false) {
                        if let Some(name) = call_name {
                            let prefix = resource_prefix.clone().unwrap_or_else(|| "res".to_string());
                            let tmpl = resource_expr.clone().unwrap_or_else(|| "{}".to_string());
                            let id_access = tmpl.replace("{}", "__afg_v");
                            let macros = format!(
                                "afg_runtime::afg_monitor!(function = {fn_id}); afg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id}, resource = format!(\"{prefix}:{{:?}}\", {id_access}));"
                            );
                            expr_wraps.push((site.line, name.clone(), macros));
                            continue;
                        }
                    }
                    // Prefer a RUNTIME per-instance resource: capture the value of
                    // the call's resource-id argument (the file path, the row id),
                    // so the oracle can tell instance pm:1 from pm:2. Fall back to
                    // the static store resource id, then to no resource.
                    let runtime_resource = match (resource_arg, call_name) {
                        (Some(rarg), Some(name)) => {
                            extract_call_arg(&text, site.line, name, *rarg).map(|arg_src| {
                                let prefix = resource_prefix.clone().unwrap_or_else(|| "res".to_string());
                                // Apply resource_expr to the captured operand so a
                                // resource can be a field of the arg (e.g. "{}.uuid"
                                // for a row handle), not just the bare argument.
                                let id_expr = match resource_expr {
                                    Some(t) => t.replace("{}", &arg_src),
                                    None => arg_src.clone(),
                                };
                                format!("format!(\"{prefix}:{{:?}}\", {id_expr})")
                            })
                        }
                        _ => None,
                    };
                    let access_call = match (runtime_resource, resource) {
                        (Some(expr), _) => format!(
                            "afg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id}, resource = {expr});"
                        ),
                        (None, Some(r)) => format!(
                            "afg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id}, resource = \"res:{r}\");"
                        ),
                        (None, None) => format!(
                            "afg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id});"
                        ),
                    };
                    // Insert before the enclosing STATEMENT, not the call line.
                    // A data-access call is usually the tail of a multi-line method
                    // chain (`let x = q()\n.bind(..)\n.fetch_all(..)\n.await?;`), and
                    // inserting between the chain lines splits the expression and
                    // fails to compile. `statement_start` walks up to the first line
                    // of the statement so the macros land before the whole thing.
                    let idx = match call_name {
                        Some(name) => {
                            let call_idx =
                                find_call_line(&lines, site.line - 1, name).unwrap_or(site.line - 1);
                            match statement_start(&lines, call_idx) {
                                Some(s) => s,
                                None => {
                                    // Expression position (match arm / argument): no statement
                                    // boundary exists, so rewrite the call expression itself into
                                    // a block that fires the probe and returns the value. Done
                                    // after the per-site loop (inline, preserving line numbers).
                                    let macros_inline = format!(
                                        "afg_runtime::afg_monitor!(function = {fn_id}); {access_call}"
                                    );
                                    expr_wraps.push((site.line, name.to_string(), macros_inline));
                                    continue;
                                }
                            }
                        }
                        None => site.line - 1,
                    };
                    // A schedule gate uses `.await`, so it is only valid inside an async
                    // context. Emit it only when the insertion point is inside an `async fn`
                    // / `async` block; in a sync function inject just the monitor + access so
                    // the instrumented code still compiles.
                    // AST-precise async check (falls back to the line heuristic if
                    // the file does not parse), so a sync function that merely
                    // contains a spawned async block does not get an illegal
                    // `.await` gate on its sync-body accesses.
                    let is_async = line_in_async_context(&text, site.line)
                        .unwrap_or_else(|| enclosing_is_async(&lines, idx));
                    let gate = match (schedule_site, call_name) {
                        (Some(sched), Some(_)) if is_async => {
                            format!("afg_runtime::afg_schedule_point!(site = {sched}).await;\n")
                        }
                        _ => String::new(),
                    };
                    let injected = format!(
                        "{gate}afg_runtime::afg_monitor!(function = {fn_id});\n{access_call}"
                    );
                    inserts.push((idx, injected));
                }
                SiteAction::Auth {
                    call_name,
                    principal_from_return,
                    principal_expr,
                } => {
                    // Principal from the call's RETURN value (e.g. dufs's
                    // `guard(...) -> (Option<String>, _)`): wrap the call to capture
                    // its result and establish the principal from it, reusing the
                    // expression-wrap machinery.
                    if principal_from_return.unwrap_or(false) {
                        let tmpl = principal_expr.clone().unwrap_or_else(|| "{}".to_string());
                        let principal_access = tmpl.replace("{}", "__afg_v");
                        let auth_macro = format!(
                            "afg_runtime::afg_auth!(principal = format!(\"{{:?}}\", {principal_access}), method = \"afg-static\", permissions = [\"*\".to_string()], duration_ms = None);"
                        );
                        expr_wraps.push((site.line, call_name.clone(), auth_macro));
                        continue;
                    }
                    // Otherwise the principal is the auth call's first argument. The
                    // producer already classifies which auth points establish a
                    // principal (credential checks like argon2/bcrypt get no Auth
                    // site), so this is a backstop: only inject when the first
                    // argument is a string-like identity, and skip anything else.
                    match extract_first_arg(&lines[site.line - 1], call_name) {
                        Some(principal) if looks_like_string_principal(&principal) => {
                            let injected = format!(
                                "afg_runtime::afg_auth!(principal = {principal}, method = \"afg-static\", permissions = [\"*\".to_string()], duration_ms = None);"
                            );
                            inserts.push((site.line - 1, injected));
                        }
                        other => {
                            eprintln!(
                                "[instrument] note: skipping afg_auth! at {}:{} ({call_name}): first argument {:?} is not a string principal",
                                path.display(),
                                site.line,
                                other.as_deref().unwrap_or("<none>")
                            );
                        }
                    }
                }
            }
        }

        // Apply expression-position rewrites first. Each is an inline byte-splice
        // that preserves line numbers, so the line-based statement inserts below
        // still line up against the same `lines` indices.
        if !expr_wraps.is_empty() {
            // Multiple PANodes can map to the same physical call (same line, same
            // callee); wrap it once, or the second wrap nests inside the first.
            let mut seen: std::collections::HashSet<(usize, String)> = std::collections::HashSet::new();
            expr_wraps.retain(|(l, n, _)| seen.insert((*l, n.clone())));
            let mut cur = lines.join("\n") + "\n";
            for (line_no, name, macros) in &expr_wraps {
                match wrap_expr_access(&cur, *line_no, name, macros) {
                    Some(next) => cur = next,
                    None => eprintln!(
                        "[instrument] note: could not wrap expression-position access at {}:{} ({name}); skipped",
                        path.display(),
                        line_no
                    ),
                }
            }
            lines = cur.lines().map(str::to_owned).collect();
        }

        inserts.sort_by(|a, b| b.0.cmp(&a.0));
        for (idx, text) in inserts {
            let idx = idx.min(lines.len());
            lines.insert(idx, text);
        }

        fs::write(path, lines.join("\n") + "\n")?;
    }

    // SOURCE-level DAO resource capture (for async_trait-erased ORM calls the IR
    // cannot see) and tokio::spawn principal propagation. Both walk the whole copied
    // tree; EVERY crate that receives an injection is recorded so it gets the
    // afg_runtime dependency below. (This also fixes the earlier bug where a crate
    // that only got a spawn-wrap, or only a source-DAO capture, was left without the
    // dep because the dep was added before these passes ran.)
    let mut source_dao_total = 0usize;
    let mut wrapped_total = 0usize;
    for entry in WalkDir::new(dst).into_iter().flatten() {
        if !(entry.file_type().is_file()
            && entry.path().extension().and_then(|e| e.to_str()) == Some("rs"))
        {
            continue;
        }
        let path = entry.path().to_path_buf();
        let Ok(mut text) = fs::read_to_string(&path) else {
            continue;
        };
        let mut touched = false;
        if !source_dao.is_empty() {
            let (rewritten, n) = inject_source_dao_accesses(&text, source_dao);
            if n > 0 {
                text = rewritten;
                source_dao_total += n;
                touched = true;
            }
        }
        let (rewritten, n) = wrap_spawns(&text);
        if n > 0 {
            text = rewritten;
            wrapped_total += n;
            touched = true;
        }
        if touched {
            fs::write(&path, &text)?;
            if let Some(manifest) = nearest_crate_manifest(&path, dst) {
                runtime_manifests.insert(manifest);
            }
        }
    }
    if source_dao_total > 0 {
        println!("[instrument] source-DAO: captured {source_dao_total} per-instance resource access(es)");
    }
    if wrapped_total > 0 {
        println!("[instrument] wrapped {wrapped_total} tokio::spawn site(s) with with_current_context");
    }

    // Make the afg_runtime macros available in EVERY crate we injected into (plan
    // sites + source-DAO + spawn-wraps, all collected in runtime_manifests above).
    // Fall back to the project root for a single-crate app with no recorded member.
    if runtime_manifests.is_empty() {
        ensure_runtime_dependency(&dst.join("Cargo.toml"), runtime_crate_path)?;
    } else {
        for manifest in &runtime_manifests {
            ensure_runtime_dependency(manifest, runtime_crate_path)?;
        }
    }

    Ok(())
}

/// Wrap the future argument of `tokio::spawn(...)` and `tokio::task::spawn(...)`
/// with `afg_runtime::with_current_context(...)`, so the spawned task carries the
/// current principal (task-locals are not inherited across a spawn). Returns the
/// rewritten source and the number of wraps applied.
///
/// Conservative by design: only these two fully-qualified spawns are targeted
/// (not `spawn_blocking`, which takes a sync closure, nor bare `spawn`); patterns
/// inside strings/chars/comments are skipped; and a call whose closing paren
/// cannot be matched, or that is already wrapped, is left untouched.
fn wrap_spawns(text: &str) -> (String, usize) {
    const PATTERNS: [&str; 2] = ["tokio::spawn(", "tokio::task::spawn("];
    let bytes = text.as_bytes();
    let mut out = String::with_capacity(text.len() + 64);
    let mut i = 0usize;
    let mut count = 0usize;

    while i < bytes.len() {
        // Skip over strings / chars / comments verbatim so we never match (or
        // mis-balance parens) inside them.
        if let Some(end) = skip_token(bytes, i) {
            out.push_str(&text[i..end]);
            i = end;
            continue;
        }

        let mut matched = false;
        for pat in PATTERNS {
            let p = pat.as_bytes();
            if bytes[i..].starts_with(p) {
                // require an identifier boundary before the pattern
                let boundary = i == 0 || !is_ident_byte(bytes[i - 1]);
                let open = i + p.len() - 1; // index of the '(' in the pattern
                if boundary {
                    if let Some(close) = matching_paren(bytes, open) {
                        let inner = &text[open + 1..close];
                        let already = inner
                            .trim_start()
                            .starts_with("afg_runtime::with_current_context");
                        if !already && !inner.trim().is_empty() {
                            out.push_str(pat); // "...spawn("
                            out.push_str("afg_runtime::with_current_context(");
                            out.push_str(inner);
                            out.push(')'); // close with_current_context
                            out.push(')'); // close spawn
                            i = close + 1;
                            count += 1;
                            matched = true;
                            break;
                        }
                    }
                }
            }
        }
        if matched {
            continue;
        }

        // Copy one UTF-8 char and advance.
        let ch_len = utf8_len(bytes[i]);
        let end = (i + ch_len).min(bytes.len());
        out.push_str(&text[i..end]);
        i = end;
    }

    (out, count)
}

fn is_ident_byte(b: u8) -> bool {
    b == b'_' || b.is_ascii_alphanumeric()
}

fn utf8_len(first: u8) -> usize {
    match first {
        b if b < 0x80 => 1,
        b if b >> 5 == 0b110 => 2,
        b if b >> 4 == 0b1110 => 3,
        _ => 4,
    }
}

/// If a string, char, or comment token starts at `i`, return the index just past
/// it; otherwise `None`. Handles line/block (nested) comments, normal/byte/raw
/// strings, and char literals (but not lifetimes, which contain no parens).
fn skip_token(bytes: &[u8], i: usize) -> Option<usize> {
    let n = bytes.len();
    match bytes[i] {
        b'/' if i + 1 < n && bytes[i + 1] == b'/' => {
            let mut j = i + 2;
            while j < n && bytes[j] != b'\n' {
                j += 1;
            }
            Some(j)
        }
        b'/' if i + 1 < n && bytes[i + 1] == b'*' => {
            let mut j = i + 2;
            let mut depth = 1;
            while j + 1 < n && depth > 0 {
                if bytes[j] == b'/' && bytes[j + 1] == b'*' {
                    depth += 1;
                    j += 2;
                } else if bytes[j] == b'*' && bytes[j + 1] == b'/' {
                    depth -= 1;
                    j += 2;
                } else {
                    j += 1;
                }
            }
            Some(if depth == 0 { j } else { n })
        }
        b'"' => Some(skip_string(bytes, i + 1)),
        b'r' | b'b' => skip_raw_or_byte_string(bytes, i),
        b'\'' => skip_char_literal(bytes, i),
        _ => None,
    }
}

// End of a normal string literal, given the index just after the opening quote.
fn skip_string(bytes: &[u8], mut j: usize) -> usize {
    let n = bytes.len();
    while j < n {
        match bytes[j] {
            b'\\' => j += 2,
            b'"' => return j + 1,
            _ => j += 1,
        }
    }
    n
}

// Raw strings (r"..", r#".."#, br"..") and byte strings (b".."). Returns None if
// `i` is just an identifier starting with r/b (e.g. `redis`, `bob`).
fn skip_raw_or_byte_string(bytes: &[u8], i: usize) -> Option<usize> {
    let n = bytes.len();
    let mut j = i;
    if bytes[j] == b'b' {
        j += 1;
        if j < n && bytes[j] == b'"' {
            return Some(skip_string(bytes, j + 1)); // byte string b".."
        }
    }
    if j < n && bytes[j] == b'r' {
        let mut k = j + 1;
        let mut hashes = 0;
        while k < n && bytes[k] == b'#' {
            hashes += 1;
            k += 1;
        }
        if k < n && bytes[k] == b'"' {
            // raw string: closing is '"' followed by `hashes` '#'
            let mut m = k + 1;
            while m < n {
                if bytes[m] == b'"' && bytes[m + 1..].iter().take(hashes).filter(|&&c| c == b'#').count() == hashes {
                    return Some(m + 1 + hashes);
                }
                m += 1;
            }
            return Some(n);
        }
    }
    None
}

// Char literal like 'a', '(', '\n', '\''. Returns None for lifetimes ('a in a
// generic), which contain no parens so are safe to treat as ordinary bytes.
fn skip_char_literal(bytes: &[u8], i: usize) -> Option<usize> {
    let n = bytes.len();
    if i + 1 >= n {
        return None;
    }
    if bytes[i + 1] == b'\\' {
        // ' \ X ... ' : the closing quote is at i+3 or later (past the escape),
        // so start the search there (this handles '\'' and '\\' correctly).
        let mut j = i + 3;
        while j < n && bytes[j] != b'\'' {
            j += 1;
        }
        return if j < n { Some(j + 1) } else { None };
    }
    if i + 2 < n && bytes[i + 2] == b'\'' && bytes[i + 1] != b'\'' {
        return Some(i + 3);
    }
    None
}

// Index of the ')' matching the '(' at `open`, or None if unbalanced.
fn matching_paren(bytes: &[u8], open: usize) -> Option<usize> {
    let n = bytes.len();
    let mut depth = 1usize;
    let mut j = open + 1;
    while j < n {
        if let Some(end) = skip_token(bytes, j) {
            j = end;
            continue;
        }
        match bytes[j] {
            b'(' => depth += 1,
            b')' => {
                depth -= 1;
                if depth == 0 {
                    return Some(j);
                }
            }
            _ => {}
        }
        j += 1;
    }
    None
}

/// Walk up from `file` to `root`, returning the nearest Cargo.toml that defines a
/// package (`[package]`) -- the crate that owns this file, not a workspace root.
fn nearest_crate_manifest(file: &Path, root: &Path) -> Option<PathBuf> {
    let mut dir = file.parent();
    while let Some(d) = dir {
        let manifest = d.join("Cargo.toml");
        if manifest.exists() {
            if let Ok(text) = fs::read_to_string(&manifest) {
                if text.contains("[package]") {
                    return Some(manifest);
                }
            }
        }
        if d == root {
            break;
        }
        dir = d.parent();
    }
    None
}

/// Index of the first line at/after `start` containing a call `call_name(`.
/// Whether the insertion point at `idx` is inside an `async` context (so an `.await` schedule
/// gate is valid). Scans upward to the nearest enclosing function definition or async block:
/// the first `async fn` / `async {` / `async move {` seen means async; the first plain `fn`
/// definition means sync. Conservative: defaults to `false` (no gate) when unsure.
fn enclosing_is_async(lines: &[String], idx: usize) -> bool {
    for i in (0..=idx.min(lines.len().saturating_sub(1))).rev() {
        let l = lines[i].trim_start();
        if l.contains("async fn ") || l.starts_with("async ") || l.contains("|| async") || l.contains("async move") {
            return true;
        }
        // a sync function definition encloses us (and no async block was seen below it)
        if l.starts_with("fn ") || l.starts_with("pub fn ") || l.starts_with("pub(crate) fn ")
            || l.contains(" fn ") && l.contains('(')
        {
            return false;
        }
    }
    false
}

fn find_call_line(lines: &[String], start: usize, call_name: &str) -> Option<usize> {
    let pat = format!("{call_name}(");
    lines
        .iter()
        .enumerate()
        .skip(start)
        .find(|(_, l)| l.contains(&pat))
        .map(|(i, _)| i)
}

/// Strip a trailing `//` line comment from a source line, leaving string literals
/// and `://` (as in a URL) intact. Best-effort: used only to see the real last
/// character of a line for statement-boundary detection.
fn strip_line_comment(line: &str) -> &str {
    let bytes = line.as_bytes();
    let mut in_str = false;
    let mut prev = b' ';
    let mut i = 0;
    while i + 1 < bytes.len() {
        let c = bytes[i];
        if c == b'"' && prev != b'\\' {
            in_str = !in_str;
        }
        if !in_str && c == b'/' && bytes[i + 1] == b'/' && prev != b':' {
            return &line[..i];
        }
        prev = c;
        i += 1;
    }
    line
}

/// Index of the first line of the statement that contains the call at `call_idx`.
///
/// A data-access call is usually the tail of a multi-line method chain, so the
/// macros must be inserted before the statement, not between chain lines. This
/// walks up from the call line while each line above is a continuation of the same
/// statement, and stops at a clean statement or block boundary (a line ending in
/// `;`, `{`, `}`, or a blank line). It returns `None` when the call is in an
/// expression position where a statement cannot be inserted (a match arm without a
/// block, or an argument list), so the caller can skip rather than emit code that
/// will not compile.
fn statement_start(lines: &[String], call_idx: usize) -> Option<usize> {
    // The candidate start line must itself be a place a statement can go: not a
    // match arm (`pat => expr`), which reads as a boundary below (its previous line
    // ends in `{` or `,`) but is not a statement slot.
    let is_statement_slot = |idx: usize| !strip_line_comment(&lines[idx]).contains("=>");

    let mut start = call_idx;
    while start > 0 {
        let prev = strip_line_comment(&lines[start - 1]).trim_end();
        if prev.is_empty() {
            return if is_statement_slot(start) { Some(start) } else { None };
        }
        if prev.ends_with("=>") {
            // match arm whose expression starts on the next line: not a slot.
            return None;
        }
        match prev.as_bytes()[prev.len() - 1] {
            // clean statement / block boundary: the statement starts at `start`.
            b';' | b'{' | b'}' => {
                return if is_statement_slot(start) { Some(start) } else { None };
            }
            // tuple / array / or-pattern element position: a statement inserted
            // here would be inside an expression, so bail.
            b',' | b'[' | b'|' => return None,
            // `(`, `)`, an operator, `?`, a chained `.`, an identifier: a
            // continuation of the same statement, so keep walking up. A leading `(`
            // means the call is an argument, but `foo(...)` is itself a statement,
            // so we continue to its start.
            _ => start -= 1,
        }
    }
    if is_statement_slot(0) {
        Some(0)
    } else {
        None
    }
}

/// Whether an extracted first argument looks like a string principal (a token or
/// username) rather than, e.g., the password bytes passed to argon2/bcrypt.
fn looks_like_string_principal(arg: &str) -> bool {
    let a = arg.trim();
    if a.is_empty() {
        return false;
    }
    // Byte-typed arguments (password material) are never the principal.
    !(a.contains(".as_bytes(") || a.starts_with("b\"") || a.starts_with("&["))
}

/// Extract the first argument expression of a call to `call_name` from a source
/// line (used as the runtime principal). Returns the trimmed argument text.
fn extract_first_arg(line: &str, call_name: &str) -> Option<String> {
    let pat = format!("{call_name}(");
    let start = line.find(&pat)? + pat.len();
    let rest = &line[start..];
    let mut depth = 0i32;
    let mut end = rest.len();
    for (i, c) in rest.char_indices() {
        match c {
            '(' | '[' => depth += 1,
            ')' | ']' => {
                if depth == 0 {
                    end = i;
                    break;
                }
                depth -= 1;
            }
            ',' if depth == 0 => {
                end = i;
                break;
            }
            _ => {}
        }
    }
    let arg = rest[..end].trim();
    if arg.is_empty() {
        None
    } else {
        Some(arg.to_string())
    }
}

/// Append an `afg_runtime` path dependency to the instrumented app's Cargo.toml
/// (idempotent), so the injected macros resolve.
fn ensure_runtime_dependency(manifest: &Path, runtime_crate_path: &Path) -> Result<()> {
    let mut text = fs::read_to_string(manifest).with_context(|| {
        format!("instrumented app has no Cargo.toml at {}", manifest.display())
    })?;
    if text.contains("afg_runtime") {
        return Ok(());
    }
    let abs = fs::canonicalize(runtime_crate_path)
        .unwrap_or_else(|_| runtime_crate_path.to_path_buf());
    if !text.ends_with('\n') {
        text.push('\n');
    }
    text.push_str(&format!(
        "\n[dependencies.afg_runtime]\npath = {:?}\n",
        abs.display().to_string()
    ));
    fs::write(&manifest, text)?;
    Ok(())
}

// ---------------------------------------------------------------------------
// SOURCE-level DAO resource capture (generalized, catalog-driven).
//
// `#[async_trait]` boxes an ORM DAO method into `Pin<Box<dyn Future>>` at the call
// site, erasing the concrete type and the id argument from the IR, so the IR
// producer cannot flag the access or capture the per-instance resource. But the
// SOURCE call is plain text with the id in scope. For each `SourceDaoRule` (loaded
// from a JSON catalog, so app/library specifics are DATA not code) we match
// `let <binding> = <..Type::method(..)..>;` in the source and inject, right after
// it, a resource-linked access recording `<prefix>:<binding><id_expr>`, plus the
// principal (when the enclosing fn exposes the rule's principal parameter) and any
// declared authorized parties.
// ---------------------------------------------------------------------------

/// Inject a per-instance resource access after each `let <binding> = <..DAO call..>;`
/// whose call matches a rule. Returns (rewritten_text, count).
fn inject_source_dao_accesses(text: &str, rules: &[SourceDaoRule]) -> (String, usize) {
    let mut inserts: Vec<(usize, String)> = Vec::new();
    for rule in rules {
        let principal_param = rule.principal_param.as_deref();
        for (binding, end_line, has_principal) in
            find_dao_let_bindings(text, &rule.call, principal_param)
        {
            let fid = {
                use std::hash::{Hash, Hasher};
                let mut h = std::collections::hash_map::DefaultHasher::new();
                (&rule.call, &binding, end_line).hash(&mut h);
                h.finish()
            };
            let node = fid ^ 0x9600;
            let kind = if rule.kind.eq_ignore_ascii_case("write") {
                "Write"
            } else {
                "Read"
            };
            // Authorized parties (declared at write time from the resource's data
            // model) and the principal are passed on the access macro itself.
            let authz_clause = match &rule.authorized_expr {
                Some(a) if !a.is_empty() => {
                    format!(", authorized = {}", a.replace("{binding}", &binding))
                }
                _ => String::new(),
            };
            // Principal captured DIRECTLY at the access from the in-scope handler
            // value (robust: no task-local/task-id propagation, works on any tokio).
            // Only when the enclosing fn exposes the principal parameter.
            let principal_clause = match (has_principal, &rule.principal_expr) {
                (true, Some(pexpr)) => format!(", principal = {pexpr}"),
                _ => String::new(),
            };
            let (prefix, count) = (&rule.prefix, rule.count);
            // The resource instance id: either a full expression (serve-point capture,
            // referencing an in-scope var) or the bound value plus `id_expr`.
            let resource_val = match &rule.resource_id_expr {
                Some(e) => e.replace("{binding}", &binding),
                None => format!("{binding}{}", rule.id_expr),
            };
            let stmt = format!(
                "afg_runtime::afg_monitor!(function = {fid}); afg_runtime::afg_access!(node = {node}, kind = afg_runtime::AccessKind::{kind}, function = {fid}, resource = format!(\"{prefix}:{{:?}}\", {resource_val}), count = {count}{authz_clause}{principal_clause});"
            );
            inserts.push((end_line, stmt));
        }
    }
    if inserts.is_empty() {
        return (text.to_string(), 0);
    }
    let n = inserts.len();
    let mut lines: Vec<String> = text.lines().map(str::to_owned).collect();
    inserts.sort_by(|a, b| b.0.cmp(&a.0));
    for (idx, stmt) in inserts {
        let i = idx.min(lines.len());
        lines.insert(i, stmt);
    }
    (lines.join("\n") + "\n", n)
}

/// True if a function signature has a parameter named `param`.
fn sig_has_param(sig: &syn::Signature, param: &str) -> bool {
    sig.inputs.iter().any(|arg| {
        if let syn::FnArg::Typed(pt) = arg {
            if let syn::Pat::Ident(pi) = &*pt.pat {
                return pi.ident == param;
            }
        }
        false
    })
}

/// Find `let <binding> = <expr containing a call to Type::method>...;` bindings.
/// Returns (binding_ident, 1-based end line of the let, enclosing-fn-has-`principal_param`).
fn find_dao_let_bindings(
    text: &str,
    qualified: &str,
    principal_param: Option<&str>,
) -> Vec<(String, usize, bool)> {
    use syn::spanned::Spanned;
    use syn::visit::Visit;
    let Some((ty, method)) = qualified.split_once("::") else {
        return vec![];
    };
    let Ok(file) = syn::parse_file(text) else {
        return vec![];
    };
    fn contains_call(e: &syn::Expr, ty: &str, method: &str) -> bool {
        let hit = |p: &syn::Path| {
            let segs: Vec<String> = p.segments.iter().map(|x| x.ident.to_string()).collect();
            segs.len() >= 2 && segs[segs.len() - 1] == method && segs[segs.len() - 2] == ty
        };
        match e {
            syn::Expr::Call(c) => {
                if let syn::Expr::Path(p) = &*c.func {
                    if hit(&p.path) {
                        return true;
                    }
                }
                c.args.iter().any(|a| contains_call(a, ty, method))
            }
            syn::Expr::MethodCall(m) => {
                contains_call(&m.receiver, ty, method)
                    || m.args.iter().any(|a| contains_call(a, ty, method))
            }
            syn::Expr::Try(t) => contains_call(&t.expr, ty, method),
            syn::Expr::Await(a) => contains_call(&a.base, ty, method),
            syn::Expr::Paren(p) => contains_call(&p.expr, ty, method),
            syn::Expr::Reference(r) => contains_call(&r.expr, ty, method),
            _ => false,
        }
    }
    struct V<'a> {
        ty: &'a str,
        method: &'a str,
        param: Option<&'a str>,
        cur_principal: bool,
        out: Vec<(String, usize, bool)>,
    }
    impl<'ast, 'a> Visit<'ast> for V<'a> {
        fn visit_item_fn(&mut self, f: &'ast syn::ItemFn) {
            let prev = self.cur_principal;
            self.cur_principal = self.param.is_some_and(|p| sig_has_param(&f.sig, p));
            syn::visit::visit_item_fn(self, f);
            self.cur_principal = prev;
        }
        fn visit_impl_item_fn(&mut self, f: &'ast syn::ImplItemFn) {
            let prev = self.cur_principal;
            self.cur_principal = self.param.is_some_and(|p| sig_has_param(&f.sig, p));
            syn::visit::visit_impl_item_fn(self, f);
            self.cur_principal = prev;
        }
        fn visit_local(&mut self, l: &'ast syn::Local) {
            if let Some(init) = &l.init {
                if contains_call(&init.expr, self.ty, self.method) {
                    if let syn::Pat::Ident(pi) = &l.pat {
                        self.out
                            .push((pi.ident.to_string(), l.span().end().line, self.cur_principal));
                    }
                }
            }
            syn::visit::visit_local(self, l);
        }
    }
    let mut v = V {
        ty,
        method,
        param: principal_param,
        cur_principal: false,
        out: Vec::new(),
    };
    v.visit_file(&file);
    v.out
}

/// Resolve a plan file path against the instrumented tree. Falls back to a
/// unique basename match when the exact relative path does not line up (LLVM
/// debug paths and the project layout can differ).
fn resolve_target_file(dst: &Path, rel: &Path) -> Option<PathBuf> {
    let direct = dst.join(rel);
    if direct.exists() {
        return Some(direct);
    }
    let base = rel.file_name()?;
    let mut matches: Vec<PathBuf> = Vec::new();
    for entry in WalkDir::new(dst).into_iter().flatten() {
        if entry.file_type().is_file() && entry.path().file_name() == Some(base) {
            matches.push(entry.path().to_path_buf());
        }
    }
    if matches.len() == 1 {
        Some(matches.remove(0))
    } else {
        None
    }
}

fn copy_tree(src: &Path, dst: &Path) -> Result<()> {
    fs::create_dir_all(dst)?;
    for entry in WalkDir::new(src) {
        let entry = entry?;
        let from = entry.path();
        let rel = from.strip_prefix(src)?;
        if rel.as_os_str().is_empty() {
            continue;
        }
        if rel.components().next().map(|c| c.as_os_str()) == Some("target".as_ref()) {
            continue;
        }

        let to = dst.join(rel);
        if entry.file_type().is_dir() {
            fs::create_dir_all(&to)?;
        } else if entry.file_type().is_file() {
            if let Some(parent) = to.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::copy(from, to)?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod spawn_wrap_tests {
    use super::wrap_spawns;

    #[test]
    fn wraps_simple_and_qualified() {
        let (out, n) = wrap_spawns("let h = tokio::spawn(fut);");
        assert_eq!(n, 1);
        assert_eq!(out, "let h = tokio::spawn(afg_runtime::with_current_context(fut));");

        let (out, n) = wrap_spawns("tokio::task::spawn(async move { work().await; });");
        assert_eq!(n, 1);
        assert_eq!(
            out,
            "tokio::task::spawn(afg_runtime::with_current_context(async move { work().await; }));"
        );
    }

    #[test]
    fn one_wrap_for_whole_argument_with_inner_parens_and_commas() {
        let (out, n) = wrap_spawns("tokio::spawn(handle(a, b))");
        assert_eq!(n, 1);
        assert_eq!(out, "tokio::spawn(afg_runtime::with_current_context(handle(a, b)))");
    }

    #[test]
    fn parens_in_strings_and_chars_do_not_break_matching() {
        let src = r#"tokio::spawn(async { let s = ")x("; let c = ')'; go().await })"#;
        let (out, n) = wrap_spawns(src);
        assert_eq!(n, 1);
        assert!(out.starts_with("tokio::spawn(afg_runtime::with_current_context(async {"));
        assert!(out.ends_with("go().await }))"));
    }

    #[test]
    fn pattern_inside_string_or_comment_is_ignored() {
        assert_eq!(wrap_spawns("let s = \"tokio::spawn(\";").1, 0);
        assert_eq!(wrap_spawns("// tokio::spawn(x)\n").1, 0);
    }

    #[test]
    fn spawn_blocking_and_bare_spawn_are_not_wrapped() {
        assert_eq!(wrap_spawns("tokio::task::spawn_blocking(|| heavy());").1, 0);
        assert_eq!(wrap_spawns("tokio::spawn_blocking(|| heavy());").1, 0);
        assert_eq!(wrap_spawns("spawn(fut);").1, 0);
    }

    #[test]
    fn not_matched_when_preceded_by_ident() {
        assert_eq!(wrap_spawns("mytokio::spawn(fut)").1, 0);
    }

    #[test]
    fn already_wrapped_is_left_alone() {
        let src = "tokio::spawn(afg_runtime::with_current_context(fut))";
        let (out, n) = wrap_spawns(src);
        assert_eq!(n, 0);
        assert_eq!(out, src);
    }
}

#[cfg(test)]
mod async_gate_tests {
    use super::enclosing_is_async;

    fn lines(src: &str) -> Vec<String> {
        src.lines().map(str::to_owned).collect()
    }

    #[test]
    fn sync_fn_is_not_async() {
        let l = lines("fn main() {\n    let r = load();\n    serve(r);");
        assert!(!enclosing_is_async(&l, 2));
    }

    #[test]
    fn async_fn_is_async() {
        let l = lines("async fn handler() {\n    let r = load().await;\n    serve(r).await;");
        assert!(enclosing_is_async(&l, 2));
    }

    #[test]
    fn async_block_in_sync_fn_is_async() {
        let l = lines("fn spawn() {\n    rt.block_on(async move {\n        serve(r);");
        assert!(enclosing_is_async(&l, 2));
    }
}

#[cfg(test)]
mod statement_start_tests {
    use super::{statement_start, strip_line_comment};

    fn lines(src: &str) -> Vec<String> {
        src.lines().map(str::to_owned).collect()
    }

    // The tabby / bionic shape: a multi-line method chain bound with `let`. The
    // call is on line 3 (the `.fetch_all` line); the statement starts at the `let`.
    #[test]
    fn multiline_chain_returns_let_line() {
        let src = "\
fn h() {
    let history = db::queries::history()
        .bind(&t, &id)
        .fetch_all(&self.pool)
        .await?;
}";
        let l = lines(src);
        // .fetch_all is index 3; statement starts at the `let history` line, index 1.
        assert_eq!(statement_start(&l, 3), Some(1));
    }

    // A single-line statement: start is the line itself.
    #[test]
    fn single_line_statement() {
        let src = "\
fn h() {
    let x = q().fetch_one(&p).await?;
}";
        let l = lines(src);
        assert_eq!(statement_start(&l, 1), Some(1));
    }

    // Tail expression of a block (no `let`, no trailing `;`): still a statement slot.
    #[test]
    fn tail_expression_after_block_open() {
        let src = "\
fn h() -> X {
    db::query()
        .fetch_one(&p)
        .await
}";
        let l = lines(src);
        assert_eq!(statement_start(&l, 2), Some(1));
    }

    // Call inside a match arm without a block: not a statement slot, so bail.
    #[test]
    fn match_arm_expression_bails() {
        let src = "\
fn h() {
    match x {
        A => db::query()
            .fetch_one(&p)
            .await?,
    }
}";
        let l = lines(src);
        // the .fetch_one line is index 3; walking up hits `A => db::query()`.
        assert_eq!(statement_start(&l, 3), None);
    }

    // Call inside a function argument: the enclosing `foo(...)` is itself a
    // statement, so inserting before it is safe.
    #[test]
    fn call_as_function_argument_is_a_statement() {
        let src = "\
fn h() {
    foo(bar()
        .fetch_one(&p)
        .await?);
}";
        let l = lines(src);
        assert_eq!(statement_start(&l, 2), Some(1));
    }

    // Call inside an array/vec element (comma-separated): not a statement slot.
    #[test]
    fn array_element_bails() {
        let src = "\
fn h() {
    let v = vec![
        q().fetch_one(&p)
            .await?,
        other,
    ];
}";
        let l = lines(src);
        // the fetch_one line is index 2; the line above ends with `vec![`.
        assert_eq!(statement_start(&l, 2), None);
    }

    #[test]
    fn strip_line_comment_keeps_url_and_strings() {
        assert_eq!(strip_line_comment("let x = 5; // note").trim_end(), "let x = 5;");
        assert_eq!(strip_line_comment("let u = \"http://x\";"), "let u = \"http://x\";");
        assert_eq!(strip_line_comment("let s = \"a // b\";"), "let s = \"a // b\";");
    }
}

// ---------------------------------------------------------------------------
// Expression-position instrumentation (AST-based).
//
// The line-based inserter can only place a statement before a statement
// boundary. Real data accesses often sit in expression position (a match arm, a
// function argument, a tuple element), e.g. dufs's
// `(fs::File::create(path).await?, StatusCode::CREATED)`, where no statement can
// be inserted. For those sites we rewrite the call EXPRESSION itself into a block
// that fires the probe and returns the value:
//
//   fs::File::create(path)        ->  { let __afg_v = fs::File::create(path); <macros> __afg_v }
//
// so any trailing `.await?` still applies to the block. The edit is a byte-range
// splice guided by syn spans, so the rest of the file keeps its exact formatting
// (no reformat), which is what lets it compose with the line-based inserter.
// ---------------------------------------------------------------------------

/// Short name (method name, or last path segment of a free/associated call) of a
/// call expression, or None if `e` is not directly a call.
fn call_expr_short_name(e: &syn::Expr) -> Option<String> {
    match e {
        syn::Expr::Call(c) => match &*c.func {
            syn::Expr::Path(p) => p.path.segments.last().map(|s| s.ident.to_string()),
            _ => None,
        },
        syn::Expr::MethodCall(m) => Some(m.method.to_string()),
        _ => None,
    }
}

/// The short name of the call at the core of an expression, digging through the
/// `?` (`Try`) and `.await` wrappers that usually sit on top of a data-access
/// call. Returns None if the expression is not a call (possibly awaited/tried).
fn innermost_call_name(e: &syn::Expr) -> Option<String> {
    match e {
        syn::Expr::Try(t) => innermost_call_name(&t.expr),
        syn::Expr::Await(a) => innermost_call_name(&a.base),
        syn::Expr::Call(_) | syn::Expr::MethodCall(_) => call_expr_short_name(e),
        _ => None,
    }
}

/// Byte offset in `text` for a proc-macro2 `LineColumn` (1-based line, 0-based
/// column counted in chars).
fn line_col_to_byte(text: &str, lc: proc_macro2::LineColumn) -> Option<usize> {
    if lc.line == 0 {
        return None;
    }
    let mut line_start = 0usize;
    if lc.line > 1 {
        let mut cur = 1usize;
        let mut found = false;
        for (i, ch) in text.char_indices() {
            if ch == '\n' {
                cur += 1;
                if cur == lc.line {
                    line_start = i + 1;
                    found = true;
                    break;
                }
            }
        }
        if !found {
            return None;
        }
    }
    let mut col = 0usize;
    for (i, ch) in text[line_start..].char_indices() {
        if col == lc.column {
            return Some(line_start + i);
        }
        if ch == '\n' {
            break;
        }
        col += 1;
    }
    if col == lc.column {
        let eol = text[line_start..]
            .find('\n')
            .map(|p| line_start + p)
            .unwrap_or(text.len());
        return Some(eol);
    }
    None
}

/// Rewrite the call named `call_name` on 1-based source `line` (which sits in
/// expression position) into a block that runs `macros` after the call and
/// returns its value. `macros` is probe text ending in `;` (e.g. the monitor +
/// access macros). Returns the rewritten file text, or None if no matching call
/// expression was found or the result would not parse (caller then falls back to
/// skipping the site, as before).
pub fn wrap_expr_access(text: &str, line: usize, call_name: &str, macros: &str) -> Option<String> {
    use syn::spanned::Spanned;
    use syn::visit::Visit;

    let file = syn::parse_file(text).ok()?;

    struct Finder<'a> {
        line: usize,
        name: &'a str,
        span: Option<(proc_macro2::LineColumn, proc_macro2::LineColumn)>,
    }
    impl<'ast, 'a> Visit<'ast> for Finder<'a> {
        fn visit_expr(&mut self, e: &'ast syn::Expr) {
            if self.span.is_some() {
                return;
            }
            // Match the OUTERMOST call-bearing expression (the `?` / `.await`
            // wrapper around the call), so the await happens inside the block we
            // create and any temporary the future borrows stays alive. Preorder
            // traversal visits the outer `Try`/`Await` before the inner call, so
            // the first match is the outermost.
            if matches!(
                e,
                syn::Expr::Try(_) | syn::Expr::Await(_) | syn::Expr::Call(_) | syn::Expr::MethodCall(_)
            ) {
                if let Some(n) = innermost_call_name(e) {
                    let start = e.span().start();
                    let end = e.span().end();
                    if n == self.name && start.line <= self.line && self.line <= end.line {
                        self.span = Some((start, end));
                        return;
                    }
                }
            }
            syn::visit::visit_expr(self, e);
        }
    }

    let mut f = Finder {
        line,
        name: call_name,
        span: None,
    };
    f.visit_file(&file);
    let (start, end) = f.span?;

    let bstart = line_col_to_byte(text, start)?;
    let bend = line_col_to_byte(text, end)?;
    if bend <= bstart || bend > text.len() {
        return None;
    }
    let orig = &text[bstart..bend];
    // Parenthesize the block. A bare `{ .. }` is valid in most expression positions
    // (match arm, tuple, argument), but NOT as a let-else scrutinee: `let Ok(x) = {
    // .. } else {}` is rejected by the parser. `({ .. })` is valid everywhere a
    // block expression is, so wrapping in parens fixes let-else uniformly without
    // special-casing the context.
    let replacement = format!("({{ let __afg_v = {orig}; {macros} __afg_v }})");
    let mut out = String::with_capacity(text.len() + replacement.len());
    out.push_str(&text[..bstart]);
    out.push_str(&replacement);
    out.push_str(&text[bend..]);
    // Only accept the rewrite if the result still parses as Rust.
    syn::parse_file(&out).ok()?;
    Some(out)
}

/// Source text of the `operand`-th argument (receiver-inclusive, matching the
/// `request_index` convention) of the call named `call_name` on 1-based `line`.
/// For a free/associated call `f(a, b)` operand 0 is `a`; for a method call
/// `recv.m(a, b)` operand 0 is `recv`, operand 1 is `a`. Returns the exact source
/// slice (so `data.recipient_id` comes back verbatim), or None if not found.
fn extract_call_arg(text: &str, line: usize, call_name: &str, operand: usize) -> Option<String> {
    use syn::spanned::Spanned;
    use syn::visit::Visit;

    struct F<'a> {
        line: usize,
        name: &'a str,
        operand: usize,
        found: Option<(proc_macro2::LineColumn, proc_macro2::LineColumn)>,
    }
    impl<'ast, 'a> Visit<'ast> for F<'a> {
        fn visit_expr(&mut self, e: &'ast syn::Expr) {
            if self.found.is_some() {
                return;
            }
            let arg_span = match e {
                syn::Expr::Call(c) => {
                    if call_expr_short_name(e).as_deref() == Some(self.name) {
                        c.args.iter().nth(self.operand).map(|a| a.span())
                    } else {
                        None
                    }
                }
                syn::Expr::MethodCall(mc) => {
                    if mc.method == self.name {
                        if self.operand == 0 {
                            Some(mc.receiver.span())
                        } else {
                            mc.args.iter().nth(self.operand - 1).map(|a| a.span())
                        }
                    } else {
                        None
                    }
                }
                _ => None,
            };
            if let Some(sp) = arg_span {
                let cs = e.span().start();
                let ce = e.span().end();
                if cs.line <= self.line && self.line <= ce.line {
                    self.found = Some((sp.start(), sp.end()));
                    return;
                }
            }
            syn::visit::visit_expr(self, e);
        }
    }

    let file = syn::parse_file(text).ok()?;
    let mut f = F {
        line,
        name: call_name,
        operand,
        found: None,
    };
    f.visit_file(&file);
    let (s, e) = f.found?;
    let b0 = line_col_to_byte(text, s)?;
    let b1 = line_col_to_byte(text, e)?;
    if b1 <= b0 || b1 > text.len() {
        return None;
    }
    Some(text[b0..b1].to_string())
}

/// Whether 1-based source `line` sits in an async context, decided by the
/// INNERMOST enclosing callable/async construct: an `async fn` / `async {}` /
/// `async` closure is async; a plain `fn` or a plain closure is sync. This is
/// AST-precise, unlike a line scan that wrongly reports async when a sync
/// function merely contains a spawned `async move {}` block somewhere above the
/// site (dufs's `fn serve` with a `std::fs::remove_file` in its sync body).
/// Returns None if the file does not parse (caller falls back to the heuristic).
fn line_in_async_context(text: &str, line: usize) -> Option<bool> {
    use syn::spanned::Spanned;
    use syn::visit::Visit;

    struct V {
        line: usize,
        // tightest enclosing construct so far: (start_line, end_line, is_async)
        best: Option<(usize, usize, bool)>,
    }
    impl V {
        fn consider(&mut self, span: proc_macro2::Span, is_async: bool) {
            let s = span.start().line;
            let e = span.end().line;
            if s <= self.line && self.line <= e {
                let better = match self.best {
                    None => true,
                    // tighter = starts later, or same start but ends earlier
                    Some((bs, be, _)) => s > bs || (s == bs && e < be),
                };
                if better {
                    self.best = Some((s, e, is_async));
                }
            }
        }
    }
    impl<'ast> Visit<'ast> for V {
        fn visit_item_fn(&mut self, f: &'ast syn::ItemFn) {
            self.consider(f.span(), f.sig.asyncness.is_some());
            syn::visit::visit_item_fn(self, f);
        }
        fn visit_impl_item_fn(&mut self, f: &'ast syn::ImplItemFn) {
            self.consider(f.span(), f.sig.asyncness.is_some());
            syn::visit::visit_impl_item_fn(self, f);
        }
        fn visit_expr_closure(&mut self, c: &'ast syn::ExprClosure) {
            self.consider(c.span(), c.asyncness.is_some());
            syn::visit::visit_expr_closure(self, c);
        }
        fn visit_expr_async(&mut self, a: &'ast syn::ExprAsync) {
            self.consider(a.span(), true);
            syn::visit::visit_expr_async(self, a);
        }
    }

    let file = syn::parse_file(text).ok()?;
    let mut v = V { line, best: None };
    v.visit_file(&file);
    v.best.map(|(_, _, is_async)| is_async)
}

#[cfg(test)]
mod expr_wrap_tests {
    use super::wrap_expr_access;

    // dufs's exact shape: a file-op call inside a match-arm tuple, trailing .await?.
    #[test]
    fn wraps_call_in_match_arm_tuple() {
        let src = "fn f() -> std::io::Result<()> {\n    \
                   let (a, b) = match x {\n        \
                   None => (fs::File::create(path).await?, 1),\n        \
                   _ => (other(), 2),\n    };\n    Ok(())\n}\n";
        let out = wrap_expr_access(src, 3, "create", "afg_access!();").expect("should wrap");
        // The whole `.await?` is pulled INSIDE the block so the borrowed temporary
        // stays alive and the await runs in the original async context.
        assert!(
            out.contains("let __afg_v = fs::File::create(path).await?;"),
            "got: {out}"
        );
        assert!(out.contains("afg_access!();"));
        assert!(!out.contains("__afg_v }.await?"), "await must be inside: {out}");
        assert!(syn::parse_file(&out).is_ok());
    }

    // A method-call chain in argument position wraps the whole receiver chain,
    // await included.
    #[test]
    fn wraps_method_chain_in_argument() {
        let src = "async fn h() {\n    \
                   serve(q.bind(id).fetch_one(pool).await?);\n}\n";
        let out = wrap_expr_access(src, 2, "fetch_one", "m!();").expect("should wrap");
        assert!(
            out.contains("let __afg_v = q.bind(id).fetch_one(pool).await?;"),
            "got: {out}"
        );
        assert!(syn::parse_file(&out).is_ok());
    }

    // A bare `?` call with no await (sync std::fs) pulls the `?` inside too.
    #[test]
    fn wraps_sync_try_call() {
        let src = "fn f() -> std::io::Result<String> {\n    \
                   Ok(std::fs::read_to_string(p)?)\n}\n";
        let out = wrap_expr_access(src, 2, "read_to_string", "m!();").expect("should wrap");
        assert!(
            out.contains("let __afg_v = std::fs::read_to_string(p)?;"),
            "got: {out}"
        );
        assert!(!out.contains("__afg_v }?"), "the ? must be inside: {out}");
        assert!(syn::parse_file(&out).is_ok());
    }

    #[test]
    fn none_when_no_matching_call() {
        let src = "fn f() { let x = g(); }\n";
        assert!(wrap_expr_access(src, 1, "create", "m!();").is_none());
    }

    #[test]
    fn extracts_resource_arg() {
        use super::extract_call_arg;
        // free/associated call: operand 0 is the first arg
        let s1 = "fn f() { let x = fs::File::create(path); }\n";
        assert_eq!(extract_call_arg(s1, 1, "create", 0).as_deref(), Some("path"));
        // method call: operand 0 is the receiver, operand 1 the first arg
        let s2 = "fn f() { let x = fs::OpenOptions::new().append(true).open(p2); }\n";
        assert_eq!(extract_call_arg(s2, 1, "open", 1).as_deref(), Some("p2"));
        // a field-access argument comes back verbatim
        let s3 = "fn f() { let m = PrivateMessage::read(pool, data.pm_id); }\n";
        assert_eq!(extract_call_arg(s3, 1, "read", 1).as_deref(), Some("data.pm_id"));
    }

    // let-else scrutinee: the wrap must be parenthesized or the parser rejects it
    // (`let Ok(x) = { .. } else {}` is invalid; `let Ok(x) = ({ .. }) else {}` is ok).
    #[test]
    fn wraps_let_else_scrutinee() {
        let src = "fn f() -> R {\n    \
                   let Ok(claims) = decode_login(token) else { return; };\n    \
                   go()\n}\n";
        let out = wrap_expr_access(src, 2, "decode_login", "m!();").expect("should wrap");
        assert!(
            out.contains("let Ok(claims) = ({ let __afg_v = decode_login(token); m!(); __afg_v }) else"),
            "let-else wrap not parenthesized: {out}"
        );
        assert!(syn::parse_file(&out).is_ok(), "let-else result must parse: {out}");
    }
}

#[cfg(test)]
mod async_context_tests {
    use super::line_in_async_context;

    // dufs's shape: a SYNC `fn serve` whose body spawns an async block. A line in
    // the sync body is sync; a line inside the async block is async.
    #[test]
    fn sync_fn_with_inner_async_block() {
        let src = "fn serve() {\n    \
                   let x = std::fs::remove_file(p);\n    \
                   tokio::spawn(async move {\n        \
                   let y = load().await;\n    });\n}\n";
        assert_eq!(line_in_async_context(src, 2), Some(false)); // remove_file: sync body
        assert_eq!(line_in_async_context(src, 4), Some(true)); // inside async block
    }

    #[test]
    fn async_fn_body_is_async() {
        let src = "async fn h() {\n    let r = db().await;\n}\n";
        assert_eq!(line_in_async_context(src, 2), Some(true));
    }

    #[test]
    fn plain_fn_body_is_sync() {
        let src = "fn h() {\n    let r = db();\n}\n";
        assert_eq!(line_in_async_context(src, 2), Some(false));
    }
}

#[cfg(test)]
mod source_dao_tests {
    use super::{inject_source_dao_accesses, SourceDaoRule};

    fn rule(call: &str, kind: &str, count: u64, authorized: Option<&str>) -> SourceDaoRule {
        SourceDaoRule {
            call: call.into(),
            kind: kind.into(),
            prefix: "pm".into(),
            id_expr: ".id".into(),
            resource_id_expr: None,
            count,
            authorized_expr: authorized.map(str::to_string),
            principal_param: Some("local_user_view".into()),
            principal_expr: Some("local_user_view.person.id".into()),
        }
    }

    // Serve-point rule: the resource id is a full in-scope expression (not a field of
    // the bound result), captured at a call that runs after the authorization check.
    #[test]
    fn serve_point_resource_id_expr() {
        let mut r = rule("PrivateMessageReport::report", "Read", 1, None);
        r.resource_id_expr = Some("private_message_id".into());
        let src = "async fn report(local_user_view: LocalUserView) -> R {\n    \
                   let report = PrivateMessageReport::report(&mut pool, &form).await?;\n    \
                   Ok(())\n}\n";
        let (out, n) = inject_source_dao_accesses(src, &[r]);
        assert_eq!(n, 1, "should capture the serve: {out}");
        // resource id is the in-scope var, NOT report.id
        assert!(out.contains("resource = format!(\"pm:{:?}\", private_message_id)"), "got: {out}");
        assert!(out.contains("principal = local_user_view.person.id"));
        assert!(syn::parse_file(&out).is_ok());
    }

    // A read DAO call inside a handler that has the principal param: the injected
    // access carries the per-instance resource from the bound row AND the principal.
    #[test]
    fn read_in_handler_captures_resource_and_principal() {
        let src = "async fn report(local_user_view: LocalUserView, id: i32) -> R {\n    \
                   let pm = PrivateMessage::read(&mut pool, id).await?;\n    \
                   Ok(())\n}\n";
        let (out, n) = inject_source_dao_accesses(src, &[rule("PrivateMessage::read", "Read", 1, None)]);
        assert_eq!(n, 1, "should capture one read: {out}");
        assert!(out.contains("resource = format!(\"pm:{:?}\", pm.id)"), "got: {out}");
        assert!(out.contains("kind = afg_runtime::AccessKind::Read"), "got: {out}");
        assert!(out.contains("count = 1"), "got: {out}");
        // The principal is passed DIRECTLY on the access (not via a separate afg_auth).
        assert!(out.contains("principal = local_user_view.person.id"), "principal missing: {out}");
        assert!(!out.contains("afg_auth!"), "principal should be on afg_access, not afg_auth: {out}");
        assert!(syn::parse_file(&out).is_ok(), "result must parse: {out}");
    }

    // A create DAO call: owner write (count 0) that declares the recipient as an
    // authorized party via the authorized_expr with {binding} substituted.
    #[test]
    fn create_declares_authorized_recipient() {
        let src = "async fn send(local_user_view: LocalUserView) -> R {\n    \
                   let pm = PrivateMessage::create(&mut pool, &form).await?;\n    \
                   Ok(())\n}\n";
        let rules = [rule(
            "PrivateMessage::create",
            "Write",
            0,
            Some("vec![format!(\"{:?}\", {binding}.recipient_id)]"),
        )];
        let (out, n) = inject_source_dao_accesses(src, &rules);
        assert_eq!(n, 1);
        assert!(out.contains("count = 0"), "got: {out}");
        assert!(out.contains("authorized = vec![format!(\"{:?}\", pm.recipient_id)]"), "authorized missing/unsubstituted: {out}");
        assert!(out.contains("principal = local_user_view.person.id"), "principal missing: {out}");
        assert!(syn::parse_file(&out).is_ok());
    }

    // A matching call in a function WITHOUT the principal param: resource still
    // captured, but no afg_auth injected (so non-handler call sites compile).
    #[test]
    fn no_principal_outside_handler() {
        let src = "async fn migrate() -> R {\n    \
                   let pm = PrivateMessage::read(&mut pool, id).await?;\n    \
                   Ok(())\n}\n";
        let (out, n) = inject_source_dao_accesses(src, &[rule("PrivateMessage::read", "Read", 1, None)]);
        assert_eq!(n, 1);
        assert!(out.contains("resource = format!(\"pm:{:?}\", pm.id)"));
        assert!(!out.contains("principal ="), "no principal param -> no principal clause: {out}");
        assert!(syn::parse_file(&out).is_ok());
    }
}
