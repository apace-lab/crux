use afg_instrument::{
    instrument_project, AccessKind, InstrumentSite, InstrumentationPlan, SiteAction,
};
use std::{fs, path::PathBuf};

fn fresh(name: &str) -> PathBuf {
    let p = std::env::temp_dir().join(name);
    let _ = fs::remove_dir_all(&p);
    p
}

fn write_fixture(dir: &PathBuf) {
    fs::create_dir_all(dir.join("src")).unwrap();
    fs::write(
        dir.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    fs::write(dir.join("src/main.rs"), "fn main() {\n    let _x = 1;\n}\n").unwrap();
}

fn runtime_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../afg-runtime")
}

#[test]
fn adds_runtime_dep_and_qualified_macros() {
    let src = fresh("afg_instr_src");
    let dst = fresh("afg_instr_dst");
    write_fixture(&src);

    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 2,
            action: SiteAction::Access {
                panode: 1308,
                function_id: Some(210),
                access: AccessKind::Read,
                call_name: None,
            },
            reason: "test".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path()).unwrap();

    // Gap 1: the instrumented app depends on afg-runtime.
    let manifest = fs::read_to_string(dst.join("Cargo.toml")).unwrap();
    assert!(manifest.contains("afg-runtime"), "runtime dep not added:\n{manifest}");

    // Gap 1: macros are inserted fully-qualified (no `use` needed).
    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        code.contains("afg_runtime::afg_monitor!(function = 210)"),
        "monitor macro missing:\n{code}"
    );
    assert!(
        code.contains(
            "afg_runtime::afg_access!(node = 1308, kind = afg_runtime::AccessKind::Read, function = 210)"
        ),
        "access macro missing:\n{code}"
    );
}

#[test]
fn basename_fallback_locates_file() {
    let src = fresh("afg_instr_src2");
    let dst = fresh("afg_instr_dst2");
    write_fixture(&src);

    // Gap 2: file path doesn't match the layout, but the basename is unique.
    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "some/wrong/dir/main.rs".into(),
            line: 2,
            action: SiteAction::Access {
                panode: 7,
                function_id: None,
                access: AccessKind::Write,
                call_name: None,
            },
            reason: "test".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(code.contains("afg_runtime::afg_access!(node = 7"), "basename fallback failed:\n{code}");
    assert!(code.contains("afg_runtime::AccessKind::Write"), "wrong access kind:\n{code}");
}

#[test]
fn inserts_afg_auth_at_auth_site() {
    let src = fresh("afg_instr_src3");
    let dst = fresh("afg_instr_dst3");
    // fixture with an auth call whose first argument is the principal
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    fs::write(
        src.join("src/main.rs"),
        "fn main() {\n    let ok = decode(user);\n}\n",
    )
    .unwrap();

    // An Auth site: the instrumenter extracts decode's first arg (`user`).
    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 2,
            action: SiteAction::Auth {
                call_name: "decode".into(),
            },
            reason: "auth point".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        code.contains("afg_runtime::afg_auth!(principal = user"),
        "afg_auth! not inserted with extracted principal:\n{code}"
    );
}
