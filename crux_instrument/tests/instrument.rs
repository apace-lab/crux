use crux_instrument::{
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
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../crux_runtime")
}

#[test]
fn adds_runtime_dep_and_qualified_macros() {
    let src = fresh("crux_instr_src");
    let dst = fresh("crux_instr_dst");
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
                schedule_site: None,
                resource: None,
                resource_arg: None,
                resource_prefix: None,
                resource_from_return: None,
                resource_expr: None,
            },
            reason: "test".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    // Gap 1: the instrumented app depends on crux_runtime.
    let manifest = fs::read_to_string(dst.join("Cargo.toml")).unwrap();
    assert!(manifest.contains("crux_runtime"), "runtime dep not added:\n{manifest}");

    // Gap 1: macros are inserted fully-qualified (no `use` needed).
    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        code.contains("crux_runtime::crux_monitor!(function = 210)"),
        "monitor macro missing:\n{code}"
    );
    assert!(
        code.contains(
            "crux_runtime::crux_access!(node = 1308, kind = crux_runtime::AccessKind::Read, function = 210)"
        ),
        "access macro missing:\n{code}"
    );
}

#[test]
fn basename_fallback_locates_file() {
    let src = fresh("crux_instr_src2");
    let dst = fresh("crux_instr_dst2");
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
                schedule_site: None,
                resource: None,
                resource_arg: None,
                resource_prefix: None,
                resource_from_return: None,
                resource_expr: None,
            },
            reason: "test".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(code.contains("crux_runtime::crux_access!(node = 7"), "basename fallback failed:\n{code}");
    assert!(code.contains("crux_runtime::AccessKind::Write"), "wrong access kind:\n{code}");
}

#[test]
fn inserts_schedule_point_before_gated_access() {
    let src = fresh("crux_instr_src5");
    let dst = fresh("crux_instr_dst5");
    // fixture with an async call site to gate for replay
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    fs::write(
        src.join("src/main.rs"),
        "async fn handle() {\n    let _ = create(\"hi\");\n}\n",
    )
    .unwrap();

    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 2,
            action: SiteAction::Access {
                panode: 911,
                function_id: Some(5),
                access: AccessKind::Read,
                call_name: Some("create".into()),
                schedule_site: Some(911),
                resource: None,
                resource_arg: None,
                resource_prefix: None,
                resource_from_return: None,
                resource_expr: None,
            },
            reason: "llm access".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    // the replay gate is inserted, awaited, and precedes the access record
    assert!(
        code.contains("crux_runtime::crux_schedule_point!(site = 911).await;"),
        "schedule point not inserted:\n{code}"
    );
    let gate = code.find("crux_schedule_point!").unwrap();
    let access = code.find("crux_access!").unwrap();
    assert!(gate < access, "schedule point must precede the access:\n{code}");
}

#[test]
fn inserts_crux_auth_at_auth_site() {
    let src = fresh("crux_instr_src3");
    let dst = fresh("crux_instr_dst3");
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
                principal_from_return: None,
                principal_expr: None,
            },
            reason: "auth point".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    // The principal is wrapped in crux_principal! so any type (incl. a Debug-only
    // newtype with no Into<String>) stringifies and compiles.
    assert!(
        code.contains("crux_runtime::crux_auth!(principal = crux_runtime::crux_principal!(user)"),
        "crux_auth! not inserted with crux_principal!-wrapped principal:\n{code}"
    );
}

// BUG B: an auth check in a match GUARD (`pat if check(..) => ..`) is an
// expression position with no statement slot. The instrumenter must SKIP it (and
// the output must still parse), not emit code that fails with "expected `=>`".
#[test]
fn skips_crux_auth_in_match_guard() {
    let src = fresh("crux_instr_guard_src");
    let dst = fresh("crux_instr_guard_dst");
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    fs::write(
        src.join("src/main.rs"),
        "fn h(x: Option<C>, u: U) {\n    let _r = match x {\n        Some(c) if c.check(u) => (),\n        _ => (),\n    };\n}\n",
    )
    .unwrap();

    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 3, // the match-guard line
            action: SiteAction::Auth {
                call_name: "check".into(),
                principal_from_return: None,
                principal_expr: None,
            },
            reason: "auth point".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        !code.contains("crux_auth!"),
        "crux_auth! must be skipped in a match-guard (expression) position:\n{code}"
    );
    assert!(
        syn::parse_file(&code).is_ok(),
        "skipped-site output must still parse as Rust:\n{code}"
    );
}

// BUG B: an auth check in a multi-line (block-less) `if` CONDITION. The probe
// must be placed BEFORE the whole `if` statement (a valid statement boundary),
// not spliced into the middle of the condition, and the result must parse.
#[test]
fn places_crux_auth_before_multiline_if() {
    let src = fresh("crux_instr_if_src");
    let dst = fresh("crux_instr_if_dst");
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    // The vaultwarden ciphers.rs shape: the auth call is the tail of a multi-line
    // `||` condition. The plan line points at the call line (3).
    fs::write(
        src.join("src/main.rs"),
        "fn h(u: U) {\n    if first()\n        || check(u)\n    {\n        work();\n    }\n}\n",
    )
    .unwrap();

    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 3, // the `|| check(u)` line
            action: SiteAction::Auth {
                call_name: "check".into(),
                principal_from_return: None,
                principal_expr: None,
            },
            reason: "auth point".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        code.contains("crux_runtime::crux_auth!(principal = crux_runtime::crux_principal!(u)"),
        "crux_auth! not inserted with wrapped principal:\n{code}"
    );
    // The probe must come BEFORE the `if`, not between condition lines.
    let auth = code.find("crux_auth!").unwrap();
    let iff = code.find("if first()").unwrap();
    assert!(auth < iff, "probe must precede the if statement:\n{code}");
    assert!(
        syn::parse_file(&code).is_ok(),
        "instrumented multi-line-if output must parse as Rust:\n{code}"
    );
}

#[test]
fn skips_crux_auth_for_byte_principal() {
    let src = fresh("crux_instr_src4");
    let dst = fresh("crux_instr_dst4");
    // fixture whose auth call takes password bytes first (argon2/bcrypt shape):
    // the principal is not a string, so no crux_auth! should be injected here.
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    fs::write(
        src.join("src/main.rs"),
        "fn main() {\n    let ok = verify_password(password.as_bytes(), &parsed);\n}\n",
    )
    .unwrap();

    let plan = InstrumentationPlan {
        sites: vec![InstrumentSite {
            file: "src/main.rs".into(),
            line: 2,
            action: SiteAction::Auth {
                call_name: "verify_password".into(),
                principal_from_return: None,
                principal_expr: None,
            },
            reason: "auth point".into(),
        }],
    };

    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        !code.contains("crux_auth!"),
        "crux_auth! should be skipped for a byte-slice (password) first argument:\n{code}"
    );
}

// Regression: a crate that receives ONLY a tokio::spawn wrap (no plan site) must
// still get the crux_runtime dependency. Previously the dep was added before the
// spawn-wrap pass, so a spawn-only crate was left without it and failed to compile.
#[test]
fn spawn_only_crate_still_gets_runtime_dep() {
    let src = fresh("crux_instr_spawn_src");
    let dst = fresh("crux_instr_spawn_dst");
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    // A tokio::spawn but NO plan site targeting this file.
    fs::write(
        src.join("src/main.rs"),
        "fn main() {\n    let h = tokio::spawn(async move { work().await; });\n}\n",
    )
    .unwrap();

    // Empty plan: the only injection is the spawn wrap.
    let plan = InstrumentationPlan { sites: vec![] };
    instrument_project(&src, &dst, &plan, &runtime_path(), &[], &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(
        code.contains("crux_runtime::with_current_context"),
        "spawn was not wrapped:\n{code}"
    );
    let manifest = fs::read_to_string(dst.join("Cargo.toml")).unwrap();
    assert!(
        manifest.contains("crux_runtime"),
        "spawn-only crate did not get the crux_runtime dep:\n{manifest}"
    );
}

// Source-DAO end to end through instrument_project: a rule captures the per-instance
// resource at a `let` binding, and the crate gets the crux_runtime dep.
#[test]
fn source_dao_rule_injects_and_adds_dep() {
    use crux_instrument::SourceDaoRule;
    let src = fresh("crux_instr_srcdao_src");
    let dst = fresh("crux_instr_srcdao_dst");
    fs::create_dir_all(src.join("src")).unwrap();
    fs::write(
        src.join("Cargo.toml"),
        "[package]\nname = \"fixture\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n",
    )
    .unwrap();
    fs::write(
        src.join("src/main.rs"),
        "async fn h(local_user_view: LocalUserView) {\n    let pm = Thing::read(&mut p, id).await.unwrap();\n}\n",
    )
    .unwrap();

    let rules = vec![SourceDaoRule {
        call: "Thing::read".into(),
        kind: "Read".into(),
        prefix: "thing".into(),
        id_expr: ".id".into(),
        resource_id_expr: None,
        count: 1,
        authorized_expr: None,
        principal_param: Some("local_user_view".into()),
        principal_expr: Some("local_user_view.person.id".into()),
    }];
    let plan = InstrumentationPlan { sites: vec![] };
    instrument_project(&src, &dst, &plan, &runtime_path(), &rules, &[], &Default::default()).unwrap();

    let code = fs::read_to_string(dst.join("src/main.rs")).unwrap();
    assert!(code.contains("resource = format!(\"thing:{:?}\", pm.id)"), "resource not captured:\n{code}");
    assert!(code.contains("principal = local_user_view.person.id"), "principal not captured on access:\n{code}");
    let manifest = fs::read_to_string(dst.join("Cargo.toml")).unwrap();
    assert!(manifest.contains("crux_runtime"), "source-DAO crate did not get the dep:\n{manifest}");
}
