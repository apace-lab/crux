// Analyze one or more AFG JSONL traces and print the scope overlaps plus the
// resource-linked leak verdict. Unlike the full `afg` pipeline this does not run
// the app; it just analyzes traces already produced by an instrumented run.
//
//   cargo run --example analyze -- trace1.jsonl [trace2.jsonl ...]
use std::path::PathBuf;

fn main() -> anyhow::Result<()> {
    let paths: Vec<PathBuf> = std::env::args().skip(1).map(PathBuf::from).collect();
    if paths.is_empty() {
        eprintln!("usage: analyze <trace.jsonl> [more.jsonl ...]");
        std::process::exit(2);
    }

    let result = afg_observe::analyze_traces(&paths)?;

    println!("principals: {}", result.principals.len());
    for (name, scope) in &result.principals {
        println!(
            "  {name}: read_nodes={:?} write_nodes={:?}",
            scope.read_nodes, scope.write_nodes
        );
    }

    println!("\ncoarse PANode overlaps (static-style signal): {}", result.overlaps.len());
    for o in &result.overlaps {
        println!("  {} <-> {} on nodes {:?}", o.left, o.right, o.shared_nodes);
    }

    println!(
        "\nresource-linked leak verdict: {} confirmed leak(s)",
        result.resource_leaks.len()
    );
    for l in &result.resource_leaks {
        println!(
            "  LEAK: {} read {}'s {} (node {}) and was served {} row(s)",
            l.reader, l.owner, l.resource, l.panode, l.rows
        );
    }
    if result.resource_leaks.is_empty() {
        println!("  none: every cross-principal read of a shared instance returned no rows (dominated by an ownership check)");
    }

    // Access-then-access: the full three-pattern view (write-then-read =
    // confidentiality, write-then-write + read-then-write = integrity).
    let integrity: Vec<_> = result
        .access_findings
        .iter()
        .filter(|f| f.pattern != afg_observe::AccessPattern::WriteThenRead)
        .collect();
    println!(
        "\naccess-then-access findings: {} total ({} confidentiality / write-then-read, {} integrity)",
        result.access_findings.len(),
        result.resource_leaks.len(),
        integrity.len()
    );
    for f in &result.access_findings {
        println!(
            "  {} [{}]: {} -> {} on {} (node {}){}",
            f.pattern.label(),
            match f.class {
                afg_observe::FindingClass::Confidentiality => "confidentiality",
                afg_observe::FindingClass::Integrity => "integrity",
            },
            f.actor,
            f.victim,
            f.resource,
            f.panode,
            if f.rows > 0 { format!(", served {} row(s)", f.rows) } else { String::new() },
        );
    }
    if integrity.is_empty() {
        println!("  no integrity (write-then-write / read-then-write) hazards in this trace");
    }

    Ok(())
}
