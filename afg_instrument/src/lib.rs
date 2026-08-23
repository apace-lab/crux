use anyhow::Result;
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

pub fn instrument_project(src: &Path, dst: &Path, plan: &InstrumentationPlan) -> Result<()> {
    if dst.exists() {
        fs::remove_dir_all(dst)?;
    }
    copy_tree(src, dst)?;

    let mut by_file: HashMap<PathBuf, Vec<&InstrumentSite>> = HashMap::new();
    for site in &plan.sites {
        by_file.entry(site.file.clone()).or_default().push(site);
    }

    for (rel, mut sites) in by_file {
        sites.sort_by_key(|s| std::cmp::Reverse(s.line));
        let path = dst.join(&rel);
        if !path.exists() {
            eprintln!("[instrument] warning: missing {}", path.display());
            continue;
        }

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

            // TODO: we should instrument the macros separately instead of injecting them together here.
            let injected = format!(
                "afg_monitor!(function = {fn_id});\nafg_access!(node = {}, kind = AccessKind::{kind}, function = {fn_id});",
                site.panode
            );

            lines.insert(site.line - 1, injected);
        }

        fs::write(path, lines.join("\n") + "\n")?;
    }

    Ok(())
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
