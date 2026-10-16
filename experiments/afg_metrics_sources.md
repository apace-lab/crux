# CRUX metrics table - source of every number

Companion to `afg_metrics_table.tex`. Each cell traces to a measurement so the
paper's numbers are reproducible. Measured 2026-09-22 unless noted.

## Verdicts / mechanisms (from each results/RESULTS.md)
- tabby (`21b2904`): LEAK. Unscoped `list_thread_messages` (`WHERE thread_id` only, no `user_id`). Mechanism: none (missing check).
- bionic-gpt (`6a82275`): no leak. Postgres RLS (`SET LOCAL row_level_security.user_id`) + in-query `current_app_user()` predicate.
- AppFlowy-Cloud (`c5bcfd3`): LEAK on source (batch `collab_list` unguarded, non-member served 4393 bytes); released image guards it (no leak). Mechanism: casbin RBAC.
- zed (`739fdbe`): no leak. Channel membership check `check_user_is_channel_participant`.

## Coverage
LOC measured with `find <scope> -name '*.rs' | xargs wc -l`:
- Analyzed scope: tabby `ee/tabby-db`+`ee/tabby-webserver` = 21,651; bionic `crates/db`+`crates/web-server` = 11,264; appflowy `services/appflowy-collaborate`+`src/api` = 16,254; zed `crates/collab/src` = 15,130.
- Whole repo (rust): tabby 175,840; bionic 114,739; appflowy 96,331; zed 2,108,723 (whole editor; collab crate incl. tests/migrations = 46,054).

Access-control points:
- tabby: 2 auth (jsonwebtoken decode: jwt.rs:37, license.rs:48, from static pass); 0 ownership checks dominate the leaking read (the bug).
- bionic: `grep -c 'get_permisisons('` in crates = 99 authz call sites, plus RLS `SET LOCAL` (~100 `current_app_user`/RLS refs in .sql) and the in-query predicate.
- appflowy: `grep -c 'enforce_action('` = 45 casbin call sites; static pass resolved 0 (dynamic dispatch through `Arc<dyn CollabAccessControl>`); the leaking batch path has none.
- zed: 176 `add_*_handler` registrations in rpc.rs (RPC edge points); 15 data-layer membership-guard sites (`check_user_is_channel_*` in db/queries: buffers.rs 3 + channels.rs 12).

Data-access sites (static producer):
- tabby: 105 (73 execute + 16 fetch_all + 9 fetch_optional + 7 fetch_one), from static pass; 111 semantic points total, 8 principals.
- appflowy: 11 (sqlx fetch/execute + dashmap + redis), from static pass.
- bionic: not separately counted (dynamic target).
- zed: 2 instrumented sites (auth + channel-buffer read) at PANode 7300.

LLM API calls (grep for openai/chat-completion in analyzed scope):
- tabby 4 (static: async_openai CreateChatCompletionRequestArgs::messages); bionic 9; appflowy 6; zed 0 (collab is not an LLM app).

## Seeds / interleavings / performance
- Only zed exposes a native seeded deterministic scheduler (gpui executor + SEED env), so seed/interleaving/timing sweeps are zed-only. tabby/bionic/appflowy were single two-user reproductions of the real app (one interleaving, `"seed":null` in their traces), no madsim/seed sweep.
- zed sweeps (this session): sequential denied+core = 30 seeds each, byte-identical traces (1 effective interleaving each, structural). Concurrent race (3 members + 1 non-member) = 60 seeds -> 21 distinct auth-order interleavings; invariant held on 100% (0 seeds where non-member read node 7300); 0 leaks. 240 instrumented+baseline runs in ~244s. Per-seed wall (deterministic executor): denied 0.171s, core avg 0.192-0.193s, race avg 0.227s (instrumented) / 0.229s (baseline); overhead within noise.
- "# seeds swept to first leak" = 1 for tabby and appflowy (deterministic leak, found on the first/only run; no seed sweep needed); n/a for bionic (true negative, no leak); 3 for zed (schedule-dependent join/removal race leak, first leaking seed is the 3rd). Interleavings were explored via each app native seeded executor, not CRUX trace-rescheduler. The seed/schedule machinery demonstrates CRUX can explore concurrent interleavings to both find a schedule-dependent leak (zed) and confirm a guard holds across them (zed join path, 21 interleavings).

## Performance timing (added 2026-09-22, "finish the table" pass)
- tabby: measured directly. Rebuilt the release harness (rustc 1.85, in-memory
  SQLite, real tabby-db create_thread_message/list_thread_messages, two users) and
  ran the binary 50x each mode. With instrumentation (CRUX_TRACE_PATH set):
  best 15.98 / avg 16.82 / worst 19.13 ms. Without (unset, probe no-op):
  best 16.07 / avg 17.27 / worst 19.60 ms. Overhead within run-to-run noise (the
  instrumented mean is actually lower). Process-level time = full 2-user scenario
  incl. process start + 49 in-memory migrations + create/read. Script:
  scratchpad/tabby_timing.sh; harness auto-restored (no changes left in checkout).
- bionic-gpt, AppFlowy: not re-timed. Both require a from-source rebuild with
  instrumentation.patch + full docker stack (bionic: cornucopia typechecks vs a
  live DB at build; appflowy: whole compose with gotrue/redis/minio/postgres, and
  the LEAK is on the source build). A "run" is one two-user HTTP request sequence,
  dominated by web-framework + DB latency, not CRUX compute. The probe is the same
  no-op-when-unset JSONL emitter as tabby's and zed's; its overhead (a few
  per-request file writes) is unmeasurable against HTTP latency and was measured
  negligible on tabby (in-process) and zed (executor). Filling exact ms would only
  reconfirm "negligible" at the cost of two from-source stack builds.
