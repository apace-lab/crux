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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InstrumentSite {
    pub file: PathBuf,
    pub line: usize,
    pub panode: u64,
    pub function_id: Option<u64>,
    pub site_id: u64,
    pub access: AccessKind,
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

    for (rel, mut sites) in by_file {
        // Insert from the bottom up so earlier insertions don't shift later lines.
        sites.sort_by_key(|s| std::cmp::Reverse(s.line));
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

        for site in sites {
            if site.line == 0 || site.line > lines.len() + 1 {
                continue;
            }
            let fn_id = site.function_id.unwrap_or(0);
            let kind = match site.access {
                AccessKind::Read => "Read",
                AccessKind::Write => "Write",
            };

            // Fully-qualified paths so the instrumented file needs no `use`
            // imports for the macros or AccessKind.
            let injected = format!(
                "afg_runtime::afg_monitor!(function = {fn_id});\nafg_runtime::afg_access!(node = {}, kind = afg_runtime::AccessKind::{kind}, function = {fn_id});",
                site.panode
            );

            lines.insert(site.line - 1, injected);
        }

        fs::write(path, lines.join("\n") + "\n")?;
    }

    Ok(())
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
