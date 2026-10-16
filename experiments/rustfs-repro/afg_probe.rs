// CRUX dynamic probe (validation harness, CVE-2026-39360 / GHSA-mx42-j6wv-px98).
//
// Emits the crux_observe JSONL access schema, one line per access event, to the
// file named by the CRUX_TRACE_PATH environment variable. It is a no-op unless
// that variable is set, so an un-instrumented run has no behavioral change.
//
// Plain semantics: `kind` is the actual operation (the owner's PutObject is a
// Write, the source-object read on the multipart-copy path is a Read), the
// principal is the real requesting access key, and the resource is the real
// object instance id. The authorization verdict is NOT encoded here; the
// crux_observe oracle decides owner-vs-reader itself.
use std::fs::OpenOptions;
use std::io::Write;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Mutex, OnceLock};

static SEQ: AtomicU64 = AtomicU64::new(0);
static PATH: OnceLock<Option<String>> = OnceLock::new();
static LOCK: Mutex<()> = Mutex::new(());

fn trace_path() -> Option<&'static str> {
    PATH.get_or_init(|| std::env::var("CRUX_TRACE_PATH").ok()).as_deref()
}

pub(crate) fn emit(principal: &str, kind: &str, resource: &str, count: u64) {
    let Some(path) = trace_path() else { return };
    let seq = SEQ.fetch_add(1, Ordering::SeqCst) + 1;
    let line = format!(
        "{{\"event\":\"access\",\"seq\":{seq},\"principal\":{},\"node\":9801,\"kind\":{},\"resource\":{},\"count\":{count}}}\n",
        json_str(principal),
        json_str(kind),
        json_str(resource),
    );
    let _g = LOCK.lock().unwrap_or_else(|e| e.into_inner());
    if let Ok(mut f) = OpenOptions::new().create(true).append(true).open(path) {
        let _ = f.write_all(line.as_bytes());
    }
}

fn json_str(s: &str) -> String {
    let mut o = String::with_capacity(s.len() + 2);
    o.push('"');
    for c in s.chars() {
        match c {
            '"' => o.push_str("\\\""),
            '\\' => o.push_str("\\\\"),
            '\n' => o.push_str("\\n"),
            '\r' => o.push_str("\\r"),
            '\t' => o.push_str("\\t"),
            c if (c as u32) < 0x20 => o.push_str(&format!("\\u{:04x}", c as u32)),
            c => o.push(c),
        }
    }
    o.push('"');
    o
}
