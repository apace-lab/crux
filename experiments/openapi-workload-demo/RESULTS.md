# OpenAPI-driven two-user workload (prototype for stage-5 / blind discovery)

This prototypes category 5 (the dynamic workload / blind discovery), driven by an app's OpenAPI
spec with no hand-coded scenario. It shows that a spec plus a tiny two-user seed is enough to
drive AFG's cross-user overlap automatically.

## Pieces

- `app/` : `notes_app`, a tiny multi-user notes service that ships an OpenAPI spec (via
  `utoipa`). Bearer token = username. It has a deliberate IDOR cross-user leak:
  `GET /notes/{id}` returns any note regardless of owner, while `GET /notes/{id}/owned`
  enforces ownership.
- `driver/` : `afg_workload`, the OpenAPI-driven two-user driver. It reads the spec, infers
  **producer** endpoints (a POST whose 200 response carries an `id`) and **consumer** endpoints
  (a GET with an `{id}` path parameter), synthesizes a request body from the schema, has user A
  create a resource and captures the id, then replays that id on every consumer **as user B**
  (the IDOR-style cross-user move).

## Result (spec-driven, no hand-coded scenario)

```
OpenAPI paths: ['/notes', '/notes/{id}', '/notes/{id}/owned']

[producer] alice POST /notes -> id=1
[LEAK] bob GET /notes/1 -> served alice's data (status 200); producer was POST /notes
[ok]   bob GET /notes/1/owned -> status 403, no cross-user data

afg_workload: 2 consumer endpoint(s) replayed cross-user, 1 leak(s) found
```

The driver discovered the producer/consumer relationship and the cross-user replay from the
spec, found the leak on the vulnerable endpoint, and did not false-flag the ownership-checked
one. The only per-app input is the base URL and how to authenticate the two users (here a
bearer-token-is-username seed).

## Oracle: both the response check AND the AFG-native verdict (wired)

The driver reports two verdicts. The response-based one (user B received user A's marker)
proves the driver finds the overlap. The **AFG-native** one is now wired: the instrumented app
emits a resource-linked trace (`AFG_TRACE_PATH`) and the driver calls `afg_observe::
analyze_traces`, which applies the resource-linked verdict (owner = first writer; a non-owner
read with rows > 0 = leak). End-to-end result:

```
afg_observe (AFG-native resource-linked verdict):
  LEAK: bob read note:1 (owned by alice), served 1 row(s)
```

The emitted trace:

```
{"event":"access","seq":1,"principal":"alice","kind":"Write","resource":"note:1","count":1,...}
{"event":"access","seq":2,"principal":"bob","kind":"Read","resource":"note:1","count":1,...}   # the IDOR
{"event":"access","seq":3,"principal":"bob","kind":"Read","resource":"note:1","count":0,...}   # safe endpoint, denied -> dominated
```

So the OpenAPI-driven two-user workload feeds AFG's native oracle: the vulnerable read (count 1,
non-owner) is the confirmed leak; the ownership-checked read (count 0) is dominated and not
flagged. In a tokio app, `afg_instrument` + `afg_runtime` inject these events automatically with
the task-local principal; this sync tiny_http server emits the same JSONL format directly (the
afg_runtime context is a tokio task-local, so it does not apply to a sync server). The
`afg_schedule_point!` gates let `afg_scheduler` then permute the two-user interleavings.

## Honest scope

- It needs a running app and either an OpenAPI spec (free for `utoipa`/`paperclip` apps) or a
  route list (derived from framework route macros) for apps that do not ship one (vaultwarden,
  atuin do not).
- It needs a tiny per-app auth seed (how two users log in). Not literally zero-input.
- Request-value synthesis is schema-based; deeper stateful chains (multi-step producer ->
  consumer across several resource types) are the RESTler-style extension.
- The AFG-native oracle integration (instrument `notes_app`, run under `afg_runtime`, read the
  trace with `afg_observe`) is the existing dynamic stage and is the next wiring step; this
  prototype validates the workload generator itself.

## Reproduce

```sh
cd app && cargo build
AFG_TRACE_PATH=/tmp/afg_notes.jsonl ADDR=127.0.0.1:8085 ./target/debug/notes_app &   # ships /api-docs/openapi.json
cd ../driver && cargo build
./target/debug/afg_workload http://127.0.0.1:8085 /tmp/afg_notes.jsonl
# prints the spec-driven response verdict AND the afg_observe native verdict; exits non-zero on a leak
```
