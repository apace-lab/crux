// Analyze a MadSim trace with the dynamic stages (afg_observe + afg_cuie)
// to confirm cross-user overlap detection.
//   cargo run --example analyze_trace -- <trace.jsonl>
use afg_observe::analyze_traces;
use afg_cuie::generate_schedules;
use std::path::PathBuf;

fn main() {
    let path = std::env::args().nth(1).expect("usage: analyze_trace <trace.jsonl>");
    let obs = analyze_traces(&[PathBuf::from(path)]).expect("analyze_traces failed");
    println!("=== observation ===");
    println!("{}", serde_json::to_string_pretty(&obs).unwrap());
    let schedules = generate_schedules(&obs, 20);
    println!("=== schedules ({}) ===", schedules.len());
    println!("{}", serde_json::to_string_pretty(&schedules).unwrap());
}
