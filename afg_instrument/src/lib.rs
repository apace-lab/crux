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
    },
    /// Establish the runtime principal for the current task. Injected before the
    /// auth call line; the instrumenter extracts the auth call's first argument
    /// from the source as the principal (convention: first arg = the user).
    Auth {
        /// The auth function's short name to locate in the source line (e.g. "decode").
        call_name: String,
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

pub fn instrument_project(
    src: &Path,
    dst: &Path,
    plan: &InstrumentationPlan,
    runtime_crate_path: &Path,
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
                } => {
                    let fn_id = function_id.unwrap_or(0);
                    let kind = match access {
                        AccessKind::Read => "Read",
                        AccessKind::Write => "Write",
                    };
                    // A schedule gate is only inserted for located call sites
                    // (`call_name` set), which sit in an async fn where `.await`
                    // is valid; a replay schedule then orders this access.
                    let gate = match (schedule_site, call_name) {
                        (Some(site), Some(_)) => {
                            format!("afg_runtime::afg_schedule_point!(site = {site}).await;\n")
                        }
                        _ => String::new(),
                    };
                    // When the producer resolved the shared store this access
                    // touches, tag the access with that resource id so a write and a
                    // read on the same store link even though their PANodes differ.
                    let access_call = match resource {
                        Some(r) => format!(
                            "afg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id}, resource = \"res:{r}\");"
                        ),
                        None => format!(
                            "afg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id});"
                        ),
                    };
                    let injected = format!(
                        "{gate}afg_runtime::afg_monitor!(function = {fn_id});\n{access_call}"
                    );
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
                                    eprintln!(
                                        "[instrument] note: skipping access at {}:{} ({name}): the call sits in an expression position (match arm / argument) where a statement cannot be inserted safely",
                                        path.display(),
                                        site.line
                                    );
                                    continue;
                                }
                            }
                        }
                        None => site.line - 1,
                    };
                    inserts.push((idx, injected));
                }
                SiteAction::Auth { call_name } => {
                    // The runtime principal is the auth call's first argument. The
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

        inserts.sort_by(|a, b| b.0.cmp(&a.0));
        for (idx, text) in inserts {
            let idx = idx.min(lines.len());
            lines.insert(idx, text);
        }

        fs::write(path, lines.join("\n") + "\n")?;
    }

    // Make the afg_runtime macros available in every crate we rewrote. Fall back
    // to the project root for a single-crate app (no member crate was recorded).
    if runtime_manifests.is_empty() {
        ensure_runtime_dependency(&dst.join("Cargo.toml"), runtime_crate_path)?;
    } else {
        for manifest in &runtime_manifests {
            ensure_runtime_dependency(manifest, runtime_crate_path)?;
        }
    }

    // Propagate the principal across tokio::spawn. A spawned task runs on a fresh
    // task and does NOT inherit task-locals, so without this the principal is lost
    // in any work a request handler spawns. Wrap the future argument of every
    // tokio::spawn / tokio::task::spawn in the crates we instrumented (they now
    // depend on afg-runtime) with afg_runtime::with_current_context(..).
    let crate_roots: Vec<PathBuf> = if runtime_manifests.is_empty() {
        vec![dst.to_path_buf()]
    } else {
        runtime_manifests
            .iter()
            .filter_map(|m| m.parent().map(Path::to_path_buf))
            .collect()
    };
    let mut wrapped_total = 0usize;
    for root in &crate_roots {
        for entry in WalkDir::new(root).into_iter().flatten() {
            if entry.file_type().is_file()
                && entry.path().extension().and_then(|e| e.to_str()) == Some("rs")
            {
                let path = entry.path();
                let Ok(text) = fs::read_to_string(path) else {
                    continue;
                };
                let (rewritten, n) = wrap_spawns(&text);
                if n > 0 {
                    fs::write(path, rewritten)?;
                    wrapped_total += n;
                }
            }
        }
    }
    if wrapped_total > 0 {
        println!("[instrument] wrapped {wrapped_total} tokio::spawn site(s) with with_current_context");
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
