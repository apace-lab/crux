use serde::{Deserialize, Serialize};
use std::{
    cell::RefCell,
    env,
    fs::{File, OpenOptions},
    future::Future,
    io::Write,
    path::PathBuf,
    sync::{Mutex, OnceLock},
};

pub type PANodeId = u64;
pub type FunctionId = u64;
pub type PACallSiteID = u64;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AccessKind {
    Read,
    Write,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthInfo {
    pub method: String,
    pub permissions: Vec<String>,
    pub duration_ms: Option<u64>,
}

#[derive(Debug, Clone, Default)]
pub struct AfgContext {
    pub principal: Option<String>,
    pub auth: Option<AuthInfo>,
}

tokio::task_local! {
    static AFG_CONTEXT: RefCell<AfgContext>;
}

pub async fn with_afg_context<F, T>(ctx: AfgContext, future: F) -> T
where
    F: Future<Output = T>,
{
    AFG_CONTEXT.scope(RefCell::new(ctx), future).await
}

pub fn current_context() -> AfgContext {
    AFG_CONTEXT
        .try_with(|ctx| ctx.borrow().clone())
        .unwrap_or_default()
}

/// Run `future` under the CURRENT task's AFG context.
///
/// tokio (and other executors) run `spawn`ed work on a FRESH task, and task-locals
/// are NOT inherited, so a spawned task loses the request's principal. Wrap the
/// spawned future with this to carry the principal across the spawn boundary:
///
/// ```ignore
/// tokio::spawn(afg_runtime::with_current_context(async move { /* ... */ }));
/// ```
///
/// The context is captured eagerly (in the calling task, where the principal is
/// set) and re-established when the returned future runs. This is the piece the
/// instrumenter wraps around a spawn argument; it adds no executor dependency, so
/// it works with whatever tokio the application itself uses.
pub fn with_current_context<F, T>(future: F) -> impl Future<Output = T>
where
    F: Future<Output = T>,
{
    with_afg_context(current_context(), future)
}

/// Convenience: `tokio::spawn` a future that carries the current AFG context.
///
/// When instrumenting a real application, prefer wrapping the app's own
/// `tokio::spawn` argument with [`with_current_context`] (so the app's own tokio
/// version and `JoinHandle` type are used). This helper is for AFG's own
/// demos/harnesses, where afg-runtime's tokio is the one in use.
pub fn afg_spawn<F>(future: F) -> tokio::task::JoinHandle<F::Output>
where
    F: Future + Send + 'static,
    F::Output: Send + 'static,
{
    tokio::spawn(with_current_context(future))
}

/// Context-carrying counterpart to `tokio::spawn!`-style use. `afg_spawn!(fut)`
/// spawns `fut` so it keeps the current principal (see [`afg_spawn`]).
#[macro_export]
macro_rules! afg_spawn {
    ($future:expr $(,)?) => {{
        $crate::afg_spawn($future)
    }};
}

pub fn set_auth(
    principal: impl Into<String>,
    method: impl Into<String>,
    permissions: Vec<String>,
    duration_ms: Option<u64>,
) {
    let principal = principal.into();
    let method = method.into();
    let auth = AuthInfo {
        method: method.clone(),
        permissions: permissions.clone(),
        duration_ms,
    };

    let _ = AFG_CONTEXT.try_with(|ctx| {
        let mut ctx = ctx.borrow_mut();
        ctx.principal = Some(principal.clone());
        ctx.auth = Some(auth.clone());
    });

    record(Event::Auth {
        principal,
        method,
        permissions,
        duration_ms,
    });
}

#[derive(Debug, Serialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum Event {
    Auth {
        principal: String,
        method: String,
        permissions: Vec<String>,
        duration_ms: Option<u64>,
    },
    Monitor {
        principal: Option<String>,
        function_id: FunctionId,
        module: &'static str,
        file: &'static str,
        line: u32,
    },
    Access {
        principal: Option<String>,
        node: PANodeId,
        kind: AccessKind,
        function_id: Option<FunctionId>,
        // Resource INSTANCE key (e.g. "conversation:1"), when the site can name the
        // specific row/object it touches. This is what lets afg_observe link a write
        // and a read on the SAME resource and decide a leak per instance, instead of
        // flagging every principal that reaches the resource's PANode.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        resource: Option<String>,
        // Rows/items the access actually yielded. A read that returns 0 was dominated
        // by an ownership check (no data flowed); a read that returns > 0 did serve
        // the instance's data.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        count: Option<u64>,
        file: &'static str,
        line: u32,
    },
    SchedulePoint {
        principal: Option<String>,
        site: PACallSiteID,
        file: &'static str,
        line: u32,
    },
    /// Optional, app-reported domain-level leak (the current principal was served
    /// `owner`'s data). Not derivable from the trace itself, so an app records it
    /// explicitly via `afg_leak!`; the dashboard shows it when present.
    Leak {
        principal: Option<String>,
        owner: String,
        detail: String,
    },
}

#[derive(Debug, Serialize)]
struct EventEnvelope {
    seq: u64,
    seed: Option<String>,
    #[serde(flatten)]
    event: Event,
}

struct TraceWriter {
    file: Mutex<File>,
    seq: Mutex<u64>,
}

static TRACE: OnceLock<TraceWriter> = OnceLock::new();

fn trace_writer() -> &'static TraceWriter {
    TRACE.get_or_init(|| {
        let path = env::var_os("AFG_TRACE_PATH")
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from("afg-events.jsonl"));

        let file = OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(path)
            .expect("failed to open AFG trace file");

        TraceWriter {
            file: Mutex::new(file),
            seq: Mutex::new(0),
        }
    })
}

pub fn record(event: Event) {
    let writer = trace_writer();
    let mut seq = writer.seq.lock().expect("AFG seq lock poisoned");
    *seq += 1;

    let envelope = EventEnvelope {
        seq: *seq,
        seed: env::var("MADSIM_TEST_SEED").ok(),
        event,
    };

    let mut file = writer.file.lock().expect("AFG trace lock poisoned");
    serde_json::to_writer(&mut *file, &envelope).expect("failed to serialize AFG event");
    file.write_all(b"\n").expect("failed to write AFG trace");
}

pub fn monitor(function_id: FunctionId, module: &'static str, file: &'static str, line: u32) {
    let ctx = current_context();
    record(Event::Monitor {
        principal: ctx.principal,
        function_id,
        module,
        file,
        line,
    });
}

pub fn access(
    node: PANodeId,
    kind: AccessKind,
    function_id: Option<FunctionId>,
    file: &'static str,
    line: u32,
) {
    access_resource(node, kind, function_id, None, None, file, line);
}

/// Like [`access`] but also records the resource INSTANCE the site touched and how
/// many rows/items it yielded. afg_observe uses these to decide a cross-user leak
/// per instance: a read of a resource by a principal that does not own it, that
/// returns rows, is a leak; a read that returns none was dominated by an ownership
/// check and is not.
pub fn access_resource(
    node: PANodeId,
    kind: AccessKind,
    function_id: Option<FunctionId>,
    resource: Option<String>,
    count: Option<u64>,
    file: &'static str,
    line: u32,
) {
    let ctx = current_context();
    record(Event::Access {
        principal: ctx.principal,
        node,
        kind,
        function_id,
        resource,
        count,
        file,
        line,
    });
}

/// Record an optional, app-reported domain-level leak: the current principal was
/// served `owner`'s data. Purely additive -- apps that don't call this simply
/// produce no Leak events, and the dashboard falls back to AFG-derived findings.
pub fn leak(owner: impl Into<String>, detail: impl Into<String>) {
    let ctx = current_context();
    record(Event::Leak {
        principal: ctx.principal,
        owner: owner.into(),
        detail: detail.into(),
    });
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ScheduleStep {
    pub principal: String,
    pub site: PACallSiteID,
}

#[derive(Default)]
struct ScheduleState {
    steps: Vec<ScheduleStep>,
    current: usize,
}

static SCHEDULE: OnceLock<Mutex<ScheduleState>> = OnceLock::new();

fn schedule_state() -> &'static Mutex<ScheduleState> {
    SCHEDULE.get_or_init(|| {
        let steps = env::var_os("AFG_SCHEDULE_PATH")
            .and_then(|path| std::fs::read_to_string(path).ok())
            .and_then(|s| serde_json::from_str::<Vec<ScheduleStep>>(&s).ok())
            .unwrap_or_default();

        Mutex::new(ScheduleState { steps, current: 0 })
    })
}

/// Name of the artificial second user the scheduler synthesizes for single-user
/// apps. Must match `afg_scheduler::SYNTHETIC_PRINCIPAL`.
pub const SYNTHETIC_PRINCIPAL: &str = "afg-synthetic";

/// Whether the loaded replay schedule includes `principal` as a step. An app can
/// use this to inject a synthetic second user ONLY during a synthetic replay:
/// the schedule is empty during observation (so this is false then), and carries
/// the synthesized `afg-synthetic` steps during the replay that tests the leak.
pub fn schedule_contains_principal(principal: &str) -> bool {
    schedule_state()
        .lock()
        .expect("AFG schedule lock poisoned")
        .steps
        .iter()
        .any(|s| s.principal == principal)
}

/// Pure gate decision for one `schedule_point` hit.
/// `Some(true)`  = it's this step's turn (caller should advance `current`);
/// `Some(false)` = proceed without gating (schedule exhausted, unauthenticated,
///                 or this `(principal, site)` isn't part of the schedule);
/// `None`        = must wait (it's in the schedule but not yet this turn).
fn gate_check(
    steps: &[ScheduleStep],
    current: usize,
    principal: Option<&str>,
    site: PACallSiteID,
) -> Option<bool> {
    if current >= steps.len() {
        return Some(false);
    }
    let Some(p) = principal else {
        // Unauthenticated/background work is not gated.
        return Some(false);
    };
    // If this schedule never mentions this (principal, site), don't gate it,
    // otherwise a schedule for one node would block on another node's gates.
    let in_schedule = steps.iter().any(|s| s.principal == p && s.site == site);
    if !in_schedule {
        return Some(false);
    }
    let expected = &steps[current];
    if expected.principal == p && expected.site == site {
        Some(true)
    } else {
        None
    }
}

pub async fn schedule_point(site: PACallSiteID, file: &'static str, line: u32) {
    let ctx = current_context();
    let principal = ctx.principal.clone();

    record(Event::SchedulePoint {
        principal: principal.clone(),
        site,
        file,
        line,
    });

    // No configured schedule: observation-only mode.
    if schedule_state()
        .lock()
        .expect("AFG schedule lock poisoned")
        .steps
        .is_empty()
    {
        return;
    }

    // Bounded cooperative gate: if it isn't this step's turn we yield and retry,
    // but only up to a cap, so a divergent replay (a scheduled step that never
    // arrives) can't hang the run forever.
    let max_spins: u64 = env::var("AFG_SCHEDULE_MAX_SPINS")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(10_000);
    let mut spins = 0u64;
    loop {
        let allowed = {
            let mut state = schedule_state().lock().expect("AFG schedule lock poisoned");
            match gate_check(&state.steps, state.current, principal.as_deref(), site) {
                Some(true) => {
                    state.current += 1;
                    true
                }
                Some(false) => true,
                None => false,
            }
        };
        if allowed {
            return;
        }
        spins += 1;
        if spins >= max_spins {
            eprintln!(
                "[afg_runtime] schedule gate gave up at site {site} for {principal:?} after {spins} spins (divergent replay path); proceeding ungated"
            );
            return;
        }
        // Cooperative gate: MadSim remains the actual executor/scheduler.
        tokio::task::yield_now().await;
    }
}

#[macro_export]
macro_rules! afg_auth {
    (
        principal = $principal:expr,
        method = $method:expr,
        permissions = $permissions:expr,
        duration_ms = $duration:expr $(,)?
    ) => {{
        $crate::set_auth(
            $principal,
            $method,
            ($permissions).into_iter().map(|x| x.to_string()).collect(),
            $duration,
        );
    }};
}

#[macro_export]
macro_rules! afg_monitor {
    (function = $function_id:expr $(,)?) => {{
        $crate::monitor($function_id, module_path!(), file!(), line!());
    }};
}

#[macro_export]
macro_rules! afg_access {
    (node = $node:expr, kind = $kind:expr $(,)?) => {{
        $crate::access($node, $kind, None, file!(), line!());
    }};
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr $(,)?) => {{
        $crate::access($node, $kind, Some($function_id), file!(), line!());
    }};
    // Resource-linked variants: name the instance touched and the rows it yielded.
    (node = $node:expr, kind = $kind:expr, resource = $resource:expr, count = $count:expr $(,)?) => {{
        $crate::access_resource(
            $node,
            $kind,
            None,
            Some(($resource).to_string()),
            Some($count as u64),
            file!(),
            line!(),
        );
    }};
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr, resource = $resource:expr, count = $count:expr $(,)?) => {{
        $crate::access_resource(
            $node,
            $kind,
            Some($function_id),
            Some(($resource).to_string()),
            Some($count as u64),
            file!(),
            line!(),
        );
    }};
}

#[macro_export]
macro_rules! afg_schedule_point {
    (site = $site:expr $(,)?) => {{
        $crate::schedule_point($site, file!(), line!())
    }};
}

/// Optional: record an app-reported domain leak into the trace so the dashboard
/// can show it. Apps that don't use it lose nothing (AFG-derived findings apply).
#[macro_export]
macro_rules! afg_leak {
    (owner = $owner:expr, detail = $detail:expr $(,)?) => {{
        $crate::leak($owner, $detail);
    }};
}

#[cfg(test)]
mod tests {
    use super::{gate_check, ScheduleStep};

    // A bare tokio::spawn drops the task-local principal; with_current_context
    // carries it across the spawn boundary. This is the tokio issue that heavy-
    // spawn apps hit during dynamic instrumentation.
    #[test]
    fn spawn_context_propagation() {
        use super::{current_context, with_afg_context, with_current_context, AfgContext};
        let rt = tokio::runtime::Builder::new_current_thread()
            .build()
            .expect("current-thread runtime");
        rt.block_on(async {
            let ctx = AfgContext { principal: Some("alice".into()), auth: None };
            with_afg_context(ctx, async {
                // In the request task, the principal is visible.
                assert_eq!(current_context().principal.as_deref(), Some("alice"));

                // A bare spawn runs on a fresh task and does NOT inherit it.
                let bare = tokio::spawn(async { current_context().principal });
                assert_eq!(bare.await.unwrap(), None);

                // with_current_context captures it and re-establishes it.
                let wrapped =
                    tokio::spawn(with_current_context(async { current_context().principal }));
                assert_eq!(wrapped.await.unwrap(), Some("alice".to_string()));
            })
            .await;
        });
    }

    fn steps() -> Vec<ScheduleStep> {
        vec![
            ScheduleStep { principal: "alice".into(), site: 1 },
            ScheduleStep { principal: "bob".into(), site: 1 },
        ]
    }

    #[test]
    fn our_turn_advances() {
        assert_eq!(gate_check(&steps(), 0, Some("alice"), 1), Some(true));
        assert_eq!(gate_check(&steps(), 1, Some("bob"), 1), Some(true));
    }

    #[test]
    fn wrong_turn_but_in_schedule_waits() {
        // bob is in the schedule (step 1) but it's alice's turn (step 0) -> wait
        assert_eq!(gate_check(&steps(), 0, Some("bob"), 1), None);
    }

    #[test]
    fn exhausted_schedule_proceeds() {
        assert_eq!(gate_check(&steps(), 2, Some("alice"), 1), Some(false));
    }

    #[test]
    fn unauthenticated_is_not_gated() {
        assert_eq!(gate_check(&steps(), 0, None, 1), Some(false));
    }

    #[test]
    fn site_or_principal_not_in_schedule_proceeds() {
        // a gated site this schedule doesn't own (deadlock-robustness): proceed
        assert_eq!(gate_check(&steps(), 0, Some("alice"), 99), Some(false));
        assert_eq!(gate_check(&steps(), 0, Some("carol"), 1), Some(false));
    }
}
