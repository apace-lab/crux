use serde::{Deserialize, Serialize};
use std::{
    cell::RefCell,
    env,
    fs::{File, OpenOptions},
    future::Future,
    io::{BufWriter, Write},
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
pub struct CruxContext {
    pub principal: Option<String>,
    pub auth: Option<AuthInfo>,
}

tokio::task_local! {
    static CRUX_CONTEXT: RefCell<CruxContext>;
}

// Fallback principal store for tasks that are NOT running inside an CRUX_CONTEXT
// scope. The common real-world case: a web framework (hyper, actix) spawns the
// per-request task itself, outside our instrumentation, so the task-local is never
// established and `set_auth`'s `try_with` silently fails. Keyed by the tokio task
// id, so `set_auth` at the auth point and the later data accesses in the SAME
// request task share the principal with no scope required. Bounded-run prototype:
// entries are not reclaimed (task ids are not reused within a run).
static TASK_CTX: OnceLock<Mutex<std::collections::HashMap<String, CruxContext>>> = OnceLock::new();

fn task_ctx_map() -> &'static Mutex<std::collections::HashMap<String, CruxContext>> {
    TASK_CTX.get_or_init(|| Mutex::new(std::collections::HashMap::new()))
}

/// Stable key for the current tokio task, or None outside a task context.
fn current_task_key() -> Option<String> {
    // The per-task principal map keys on the tokio task id. `tokio::task::try_id`
    // (via real tokio) is stable only in tokio >= 1.44; on older pins (e.g. lemmy's
    // 1.35) it is gated behind `--cfg tokio_unstable`. So the map's key is available
    // only when that cfg is set (and not under the madsim shim). When it is not
    // available this returns None and the map stays inert -- apps whose principal is
    // captured at the access site (the source-DAO `principal =` path) do not need it,
    // and the upstream-auth flow (crux_auth then a later access) enables the map by
    // building with `--cfg tokio_unstable`.
    #[cfg(all(not(madsim), tokio_unstable))]
    {
        tokio_real::task::try_id().map(|id| id.to_string())
    }
    #[cfg(not(all(not(madsim), tokio_unstable)))]
    {
        None
    }
}

pub async fn with_crux_context<F, T>(ctx: CruxContext, future: F) -> T
where
    F: Future<Output = T>,
{
    CRUX_CONTEXT.scope(RefCell::new(ctx), future).await
}

pub fn current_context() -> CruxContext {
    // Prefer a scoped task-local that carries a principal.
    if let Ok(c) = CRUX_CONTEXT.try_with(|ctx| ctx.borrow().clone()) {
        if c.principal.is_some() {
            return c;
        }
    }
    // Fallback: the per-task store populated by set_auth when no scope was active.
    if let Some(key) = current_task_key() {
        if let Some(c) = task_ctx_map().lock().unwrap().get(&key).cloned() {
            return c;
        }
    }
    CRUX_CONTEXT
        .try_with(|ctx| ctx.borrow().clone())
        .unwrap_or_default()
}

/// Run `future` under the CURRENT task's CRUX context.
///
/// tokio (and other executors) run `spawn`ed work on a FRESH task, and task-locals
/// are NOT inherited, so a spawned task loses the request's principal. Wrap the
/// spawned future with this to carry the principal across the spawn boundary:
///
/// ```ignore
/// tokio::spawn(crux_runtime::with_current_context(async move { /* ... */ }));
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
    with_crux_context(current_context(), future)
}

/// Convenience: `tokio::spawn` a future that carries the current CRUX context.
///
/// When instrumenting a real application, prefer wrapping the app's own
/// `tokio::spawn` argument with [`with_current_context`] (so the app's own tokio
/// version and `JoinHandle` type are used). This helper is for CRUX's own
/// demos/harnesses, where crux_runtime's tokio is the one in use.
pub fn crux_spawn<F>(future: F) -> tokio::task::JoinHandle<F::Output>
where
    F: Future + Send + 'static,
    F::Output: Send + 'static,
{
    tokio::spawn(with_current_context(future))
}

/// Context-carrying counterpart to `tokio::spawn!`-style use. `crux_spawn!(fut)`
/// spawns `fut` so it keeps the current principal (see [`crux_spawn`]).
#[macro_export]
macro_rules! crux_spawn {
    ($future:expr $(,)?) => {{
        $crate::crux_spawn($future)
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

    let scoped = CRUX_CONTEXT
        .try_with(|ctx| {
            let mut ctx = ctx.borrow_mut();
            ctx.principal = Some(principal.clone());
            ctx.auth = Some(auth.clone());
        })
        .is_ok();
    // No active scope (framework-spawned request task): record into the per-task
    // fallback store so the same task's later accesses see this principal.
    if !scoped {
        if let Some(key) = current_task_key() {
            task_ctx_map().lock().unwrap().insert(
                key,
                CruxContext {
                    principal: Some(principal.clone()),
                    auth: Some(auth.clone()),
                },
            );
        }
    }

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
        // specific row/object it touches. This is what lets crux_observe link a write
        // and a read on the SAME resource and decide a leak per instance, instead of
        // flagging every principal that reaches the resource's PANode.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        resource: Option<String>,
        // Rows/items the access actually yielded. A read that returns 0 was dominated
        // by an ownership check (no data flowed); a read that returns > 0 did serve
        // the instance's data.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        count: Option<u64>,
        // Principals authorized for this resource beyond the writer (a private
        // message's recipient, a document's collaborators), declared at write time
        // from the resource's own data model so crux_observe does not flag a
        // legitimate second party as a leak.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        authorized: Option<Vec<String>>,
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
    /// explicitly via `crux_leak!`; the dashboard shows it when present.
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
    // BufWriter coalesces serde_json's many small writes per event into one
    // buffered region; record() flushes once per event so no events are lost
    // if the host process is killed (SIGKILL does not run Drop).
    file: Mutex<BufWriter<File>>,
    seq: Mutex<u64>,
}

static TRACE: OnceLock<TraceWriter> = OnceLock::new();

fn trace_writer() -> &'static TraceWriter {
    TRACE.get_or_init(|| {
        let path = env::var_os("CRUX_TRACE_PATH")
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from("crux-events.jsonl"));

        let file = OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(path)
            .expect("failed to open CRUX trace file");

        TraceWriter {
            file: Mutex::new(BufWriter::new(file)),
            seq: Mutex::new(0),
        }
    })
}

pub fn record(event: Event) {
    let writer = trace_writer();
    let mut seq = writer.seq.lock().expect("CRUX seq lock poisoned");
    *seq += 1;

    let envelope = EventEnvelope {
        seq: *seq,
        seed: env::var("MADSIM_TEST_SEED").ok(),
        event,
    };

    let mut file = writer.file.lock().expect("CRUX trace lock poisoned");
    serde_json::to_writer(&mut *file, &envelope).expect("failed to serialize CRUX event");
    file.write_all(b"\n").expect("failed to write CRUX trace");
    // Flush per event so the trace is complete even if the host process is
    // SIGKILLed by a test harness; the BufWriter still coalesces serde_json's
    // many small writes into a single syscall per event.
    file.flush().expect("failed to flush CRUX trace");
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
    access_resource(node, kind, function_id, None, None, None, None, file, line);
}

/// Like [`access`] but also records the resource INSTANCE the site touched and how
/// many rows/items it yielded. crux_observe uses these to decide a cross-user leak
/// per instance: a read of a resource by a principal that does not own it, that
/// returns rows, is a leak; a read that returns none was dominated by an ownership
/// check and is not.
///
/// `principal_override`: when the instrumenter can name the principal directly at
/// the access (it is in scope, e.g. a handler's `local_user_view`), it passes it
/// here. This is more robust than the task-local/task-id-map propagation (no
/// cross-task/await concerns, no tokio task-id dependency) and is what the
/// source-DAO pass uses. When None, the principal falls back to the current task
/// context (set upstream by `crux_auth`).
#[allow(clippy::too_many_arguments)]
pub fn access_resource(
    node: PANodeId,
    kind: AccessKind,
    function_id: Option<FunctionId>,
    resource: Option<String>,
    count: Option<u64>,
    authorized: Option<Vec<String>>,
    principal_override: Option<String>,
    file: &'static str,
    line: u32,
) {
    let principal = principal_override.or_else(|| current_context().principal);
    record(Event::Access {
        principal,
        node,
        kind,
        function_id,
        resource,
        count,
        authorized,
        file,
        line,
    });
}

/// Record an optional, app-reported domain-level leak: the current principal was
/// served `owner`'s data. Purely additive -- apps that don't call this simply
/// produce no Leak events, and the dashboard falls back to CRUX-derived findings.
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
        let steps = env::var_os("CRUX_SCHEDULE_PATH")
            .and_then(|path| std::fs::read_to_string(path).ok())
            .and_then(|s| serde_json::from_str::<Vec<ScheduleStep>>(&s).ok())
            .unwrap_or_default();

        Mutex::new(ScheduleState { steps, current: 0 })
    })
}

/// Name of the artificial second user the scheduler synthesizes for single-user
/// apps. Must match `crux_scheduler::SYNTHETIC_PRINCIPAL`.
pub const SYNTHETIC_PRINCIPAL: &str = "crux-synthetic";

/// Whether the loaded replay schedule includes `principal` as a step. An app can
/// use this to inject a synthetic second user ONLY during a synthetic replay:
/// the schedule is empty during observation (so this is false then), and carries
/// the synthesized `crux-synthetic` steps during the replay that tests the leak.
pub fn schedule_contains_principal(principal: &str) -> bool {
    schedule_state()
        .lock()
        .expect("CRUX schedule lock poisoned")
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
        .expect("CRUX schedule lock poisoned")
        .steps
        .is_empty()
    {
        return;
    }

    // Bounded cooperative gate: if it isn't this step's turn we yield and retry,
    // but only up to a cap, so a divergent replay (a scheduled step that never
    // arrives) can't hang the run forever.
    let max_spins: u64 = env::var("CRUX_SCHEDULE_MAX_SPINS")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(10_000);
    let mut spins = 0u64;
    loop {
        let allowed = {
            let mut state = schedule_state().lock().expect("CRUX schedule lock poisoned");
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
                "[crux_runtime] schedule gate gave up at site {site} for {principal:?} after {spins} spins (divergent replay path); proceeding ungated"
            );
            return;
        }
        // Cooperative gate: MadSim remains the actual executor/scheduler.
        tokio::task::yield_now().await;
    }
}

/// Compile-time principal stringification for instrumenter-injected auth sites.
///
/// The auto-instrumenter takes an auth check's first argument as the principal
/// (a convention), but that argument's concrete TYPE is not known when the probe
/// is written: vaultwarden's ownership checks take a `&UserId` newtype (which
/// derives `Debug` but NOT `Into<String>`, the ~36 E0277 errors), while
/// `is_valid_request`'s first argument is a resource struct that derives neither.
/// `set_auth` wants a `String`, so neither type is accepted directly.
///
/// This module resolves it with autoref specialization (stable since 1.0, so it
/// works on the pinned 1.84.1): calling `crux_to_principal` on `&CruxPrincipal(&x)`
/// picks the `Debug` impl (on `CruxPrincipal<T>`) with no autoref when `T: Debug`,
/// and otherwise autorefs once to the blanket fallback impl (on
/// `&CruxPrincipal<T>`). So the injected auth site ALWAYS compiles whatever the
/// principal expression's type is: a `Debug` principal stringifies through `{:?}`,
/// and a non-Debug one records a fixed label.
pub mod principal {
    pub struct CruxPrincipal<T>(pub T);

    pub trait ViaDebug {
        fn crux_to_principal(&self) -> String;
    }
    impl<T: std::fmt::Debug> ViaDebug for CruxPrincipal<T> {
        fn crux_to_principal(&self) -> String {
            format!("{:?}", self.0)
        }
    }

    pub trait ViaFallback {
        fn crux_to_principal(&self) -> String;
    }
    impl<T> ViaFallback for &CruxPrincipal<T> {
        fn crux_to_principal(&self) -> String {
            String::from("crux-principal")
        }
    }
}

/// Stringify any principal expression to a `String` (see [`principal`]). Used by
/// the instrumenter so an `crux_auth!` principal of any type compiles.
#[macro_export]
macro_rules! crux_principal {
    ($e:expr) => {{
        #[allow(unused_imports)]
        use $crate::principal::{ViaDebug as _, ViaFallback as _};
        (&$crate::principal::CruxPrincipal(&$e)).crux_to_principal()
    }};
}

#[macro_export]
macro_rules! crux_auth {
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
macro_rules! crux_monitor {
    (function = $function_id:expr $(,)?) => {{
        $crate::monitor($function_id, module_path!(), file!(), line!());
    }};
}

#[macro_export]
macro_rules! crux_access {
    (node = $node:expr, kind = $kind:expr $(,)?) => {{
        $crate::access($node, $kind, None, file!(), line!());
    }};
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr $(,)?) => {{
        $crate::access($node, $kind, Some($function_id), file!(), line!());
    }};
    // Resource-linked variant without a runtime count: the instrumenter knows the
    // static store the access touches (the points-to resource) but not the rows it
    // yields, so count is left unset. This is enough to link a write and a read on
    // the same store across different call sites.
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr, resource = $resource:expr $(,)?) => {{
        $crate::access_resource($node, $kind, Some($function_id), Some(($resource).to_string()), None, None, None, file!(), line!());
    }};
    // Resource-linked variants: name the instance touched and the rows it yielded.
    (node = $node:expr, kind = $kind:expr, resource = $resource:expr, count = $count:expr $(,)?) => {{
        $crate::access_resource($node, $kind, None, Some(($resource).to_string()), Some($count as u64), None, None, file!(), line!());
    }};
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr, resource = $resource:expr, count = $count:expr $(,)?) => {{
        $crate::access_resource($node, $kind, Some($function_id), Some(($resource).to_string()), Some($count as u64), None, None, file!(), line!());
    }};
    // Resource-linked write that also declares the resource's additional authorized
    // principals (a PM's recipient, a document's collaborators), so crux_observe does
    // not flag a legitimate second party as a leak.
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr, resource = $resource:expr, count = $count:expr, authorized = $authorized:expr $(,)?) => {{
        $crate::access_resource($node, $kind, Some($function_id), Some(($resource).to_string()), Some($count as u64), Some(($authorized).into_iter().map(|x| x.to_string()).collect()), None, file!(), line!());
    }};
    // Principal captured DIRECTLY at the access (it is in scope), the robust path
    // the source-DAO pass uses: no task-local / task-id-map propagation, no tokio
    // task-id dependency, no cross-await concern.
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr, resource = $resource:expr, count = $count:expr, principal = $principal:expr $(,)?) => {{
        $crate::access_resource($node, $kind, Some($function_id), Some(($resource).to_string()), Some($count as u64), None, Some(format!("{:?}", $principal)), file!(), line!());
    }};
    (node = $node:expr, kind = $kind:expr, function = $function_id:expr, resource = $resource:expr, count = $count:expr, authorized = $authorized:expr, principal = $principal:expr $(,)?) => {{
        $crate::access_resource($node, $kind, Some($function_id), Some(($resource).to_string()), Some($count as u64), Some(($authorized).into_iter().map(|x| x.to_string()).collect()), Some(format!("{:?}", $principal)), file!(), line!());
    }};
}

#[macro_export]
macro_rules! crux_schedule_point {
    (site = $site:expr $(,)?) => {{
        $crate::schedule_point($site, file!(), line!())
    }};
}

/// Optional: record an app-reported domain leak into the trace so the dashboard
/// can show it. Apps that don't use it lose nothing (CRUX-derived findings apply).
#[macro_export]
macro_rules! crux_leak {
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
        use super::{current_context, with_crux_context, with_current_context, CruxContext};
        let rt = tokio::runtime::Builder::new_current_thread()
            .build()
            .expect("current-thread runtime");
        rt.block_on(async {
            let ctx = CruxContext { principal: Some("alice".into()), auth: None };
            with_crux_context(ctx, async {
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

    // Regression (vaultwarden): the instrumenter takes an auth check's first arg
    // as the principal. vaultwarden's checks pass a `&UserId` newtype that derives
    // Debug but NOT Into<String> (the E0277 failure), and some checks pass a struct
    // that derives neither. `crux_principal!` must stringify a Debug principal via
    // {:?} and fall back for a non-Debug one, so the injected site always compiles.
    #[test]
    fn crux_principal_debug_and_fallback() {
        #[derive(Debug)]
        struct UserId(String); // Debug, but no Into<String> (like vaultwarden's)
        struct Opaque; // derives nothing (like EmergencyAccess at is_valid_request)

        let uid = UserId("abc".into());
        assert_eq!(crate::crux_principal!(&uid), format!("{:?}", &uid));
        assert_eq!(crate::crux_principal!(uid), "UserId(\"abc\")");

        let o = Opaque;
        assert_eq!(crate::crux_principal!(&o), "crux-principal");
    }

    // The exact instrumenter-generated `crux_auth!` form must COMPILE with a
    // Debug-only newtype principal (the bug was `principal = user_uuid` where
    // `&UserId: !Into<String>`). Guarded by `if false` so the test does not write
    // a trace file; the body is still type-checked.
    #[test]
    fn crux_auth_compiles_with_debug_only_newtype() {
        #[derive(Debug)]
        struct UserId(String);
        let uid = UserId("u1".into());
        let principal = crate::crux_principal!(&uid);
        assert_eq!(principal, "UserId(\"u1\")");
        if false {
            crate::crux_auth!(
                principal = crate::crux_principal!(&uid),
                method = "crux-static",
                permissions = ["*".to_string()],
                duration_ms = None
            );
        }
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
