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
        file: &'static str,
        line: u32,
    },
    SchedulePoint {
        principal: Option<String>,
        site: PACallSiteID,
        file: &'static str,
        line: u32,
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
    let ctx = current_context();
    record(Event::Access {
        principal: ctx.principal,
        node,
        kind,
        function_id,
        file,
        line,
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

    loop {
        let allowed = {
            let mut state = schedule_state().lock().expect("AFG schedule lock poisoned");

            if state.current >= state.steps.len() {
                true
            } else if let Some(ref p) = principal {
                let expected = &state.steps[state.current];
                if expected.principal == *p && expected.site == site {
                    state.current += 1;
                    true
                } else {
                    false
                }
            } else {
                // Unauthenticated/background work is not gated by principal schedules.
                true
            }
        };

        if allowed {
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
}

#[macro_export]
macro_rules! afg_schedule_point {
    (site = $site:expr $(,)?) => {{
        $crate::schedule_point($site, file!(), line!())
    }};
}
