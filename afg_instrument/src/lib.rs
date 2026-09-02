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

    // Make the afg runtime macros available in the instrumented app.
    ensure_runtime_dependency(dst, runtime_crate_path)?;

    let mut by_file: HashMap<PathBuf, Vec<&InstrumentSite>> = HashMap::new();
    for site in &plan.sites {
        by_file.entry(site.file.clone()).or_default().push(site);
    }

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
                    let injected = format!(
                        "{gate}afg_runtime::afg_monitor!(function = {fn_id});\nafg_runtime::afg_access!(node = {panode}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id});"
                    );
                    // Insert before the located call line (executed path, and
                    // syntactically safe even when the call is a tail expression),
                    // else at the site line.
                    let idx = match call_name {
                        Some(name) => {
                            find_call_line(&lines, site.line - 1, name).unwrap_or(site.line - 1)
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

    Ok(())
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

/// Append an `afg-runtime` path dependency to the instrumented app's Cargo.toml
/// (idempotent), so the injected macros resolve.
fn ensure_runtime_dependency(dst: &Path, runtime_crate_path: &Path) -> Result<()> {
    let manifest = dst.join("Cargo.toml");
    let mut text = fs::read_to_string(&manifest).with_context(|| {
        format!("instrumented app has no Cargo.toml at {}", manifest.display())
    })?;
    if text.contains("afg-runtime") {
        return Ok(());
    }
    let abs = fs::canonicalize(runtime_crate_path)
        .unwrap_or_else(|_| runtime_crate_path.to_path_buf());
    if !text.ends_with('\n') {
        text.push('\n');
    }
    text.push_str(&format!(
        "\n[dependencies.afg-runtime]\npath = {:?}\n",
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
