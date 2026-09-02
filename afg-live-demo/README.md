# afg-live-demo

A runnable chat service, instrumented by the **real AFG pipeline** and run live.
Two users chat against one service whose answer cache is keyed by prompt only
(not by user), so one user can be served another's answer. AFG's static analysis
finds and instruments the shared access, and the live dynamic analysis catches
the cross-user overlap and the leak.

The auth check and the LLM call are instrumented **automatically by AFG's
pipeline**: this source uses catalog-matching stubs (`jsonwebtoken::decode`,
`async_openai::chat::Chat::create`) so the producer finds them, and the
instrumenter inserts `afg_auth!`/`afg_access!`/`afg_schedule_point!` with the real
PANode id from the PAG. The instrumented copy runs on real tokio, and `/afg` runs
the real `afg_observe::analyze_traces` + `afg_scheduler::generate_schedules` over
the live trace.

Two AFG pieces are added **by hand**: `with_afg_context` (per-request context,
which the instrumenter does not yet insert), and the accesses to the app's **own
shared cache** — a `Write` when an answer is cached, a `Read` when one is served
from cache. The cache is not a cataloged SDK call, so the pipeline can't find it;
marking your app's own shared resources is the developer's job. This is what makes
the leak show up as a real node overlap: alice **writes** the cache node, bob
**reads** it.

## Run it

```bash
cd afg_prototype/afg-live-demo
./run.sh
# then open http://127.0.0.1:8080
```

`run.sh`:
1. compiles the server to LLVM IR (with debug info),
2. runs `afg --instrument-only` (producer + instrumenter) to write an
   AFG-instrumented copy under `/tmp/afg_live_demo/instrumented/app`,
3. runs that instrumented copy live.

To see what AFG inserted (none of it is in this source):

```bash
grep -n 'afg_runtime::' /tmp/afg_live_demo/instrumented/app/src/main.rs
```

## Real LLM answers (optional)

By default the assistant returns a canned answer. To get real answers, copy
`.env.example` to `.env` and set **one** key (whichever is present is used; if
neither, it falls back to the canned answer):

```bash
cp .env.example .env
# then edit .env and set GEMINI_API_KEY=...  (or GROQ_API_KEY=...)
```

- **Gemini** — free key at https://aistudio.google.com/apikey (no card). Model
  defaults to `gemini-3.6-flash`, override with `GEMINI_MODEL`.
- **Groq** — free key at https://console.groq.com/keys. Model defaults to
  `llama-3.3-70b-versatile`, override with `GROQ_MODEL`.

The server prints the active backend on startup (`LLM backend: gemini|groq|stub`).
The real LLM call still goes through the same catalog-matched
`async_openai::chat::Chat::create`, so AFG's instrumentation is unaffected. `.env`
is gitignored; never commit real keys.

## Demo flow

Two chat users and a separate admin console (all hardcoded, shown on each
sign-in page):

- `http://127.0.0.1:8080/` — the chat app. Open it in **two browsers** (or two
  windows) and sign in as **alice@example.com / alicepass** and
  **bob@example.com / bobpass**.
- `http://127.0.0.1:8080/admin` — the AFG console. Sign in as
  **afg@example.com / afgpass**. `/afg` is admin-gated (403 without a token).

Script it live:
1. alice asks something, bob asks something **different** — in the console the
   trace fills, the per-principal scopes show each user reading the LLM node and
   writing the cache node, and the status flips to a cross-user overlap (alice ↔
   bob) on both nodes.
2. bob asks alice's earlier prompt — bob is served alice's cached answer (tagged
   as a leak in bob's chat and listed in the console). In the scopes, bob now
   **reads** the cache node that alice **wrote**: the leak as a write-then-read
   node overlap.

**Overlap vs leak:** an overlap means both users reached the same shared node
(the risk AFG flags — shown even with zero leaks). A leak is recorded only when a
user is actually served another user's cached answer, so "overlap detected, 0
leaks" is expected until someone reuses another user's exact prompt.

The console's **Reset scenario** clears the shared cache and recorded leaks so
the leak can be replayed; restart the server for a clean trace.

## Endpoints

| route | purpose |
|-------|---------|
| `GET /` | the chat page |
| `GET /admin` | the AFG console |
| `POST /login` | argon2 credential check for a chat user, returns a bearer token |
| `POST /admin/login` | argon2 admin sign-in, returns an admin token |
| `POST /chat` | authenticated request; the instrumented copy emits `afg_auth!`/`afg_access!` |
| `GET /afg?token=<admin>` | live events, per-principal scopes, `analyze_traces` overlaps, `generate_schedules` (admin-gated) |
| `POST /reset?token=<admin>` | clear the shared cache and recorded leaks (admin-gated) |

## Notes

- argon2 login is a credential check; AFG classifies it as *not* a principal
  source, so it correctly carries no `afg_auth!`.
- Deterministic schedule *replay* is a MadSim feature; this live server runs on
  real tokio and only does observation + detection (its cache leak is
  order-independent, so replay is not needed to reproduce it).
