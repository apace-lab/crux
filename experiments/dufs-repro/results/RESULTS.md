# dufs: captured results

Target: `sigoden/dufs` tag `v0.43.0`, a single-binary HTTP/WebDAV file server (tokio +
hyper). Many users are served by one process; per-user access is defined by `--auth`
rules mapping accounts to path permissions. Toolchain rustc 1.99 (LLVM 20), so this is a
dynamic-plus-code target, like bionic-gpt, zed, spiceai, and vaultwarden. This is a
non-LLM target: dufs makes no LLM API calls. Run date 2026-10-02.

## Verdict: TRUE NEGATIVE (no cross-user leak), confirmed by CRUX's own probe

Every file-serving and directory-enumeration operation is scoped to the authenticated
user's permitted paths, so one user is never served another user's files. The code audit
and the dynamic CRUX-native run agree.

## The mechanism (verified in code)

- Principal: the authenticated user from `AccessControl::guard`
  (`src/auth.rs`), which authenticates the request and returns
  `(Option<user>, Option<AccessPaths>)`: the user and the sub-tree of paths they may
  access for the requested path, or `None` if the path is denied.
- Access-control check: `AccessPaths::find(path, writable)` decides whether this user may
  access this path; enumeration (`list_dir`, `handle_search_dir`, `zip_dir`,
  `handle_propfind_dir`) re-scopes to the user by iterating `access_paths.child_paths` /
  `child_names` rather than the raw directory. `list_dir`'s raw `read_dir` runs only in the
  branch where the user holds a full (non-index-only) grant on that directory.
- Shared resource: the served filesystem paths.

In the request dispatch (`src/server.rs`), `guard` runs once at the top; an authenticated
user denied the requested path gets a 403 before any serve handler runs, and an authorized
user proceeds with the scoped `access_paths`. So every data-access site is dominated by the
guard. The enforcement shape is distinct from the other targets: the check is *separable*
(the scope is produced once and threaded as a parameter into every handler) yet
*consistently applied everywhere*. Contrast bionic and spiceai (the check is not
separable) and tabby and AppFlowy (the check is separable and omitted on one path, which
leaks).

## CRUX instrumentation and dynamic verdict

We instrumented dufs at the access-control choke point with an CRUX probe behind an
off-by-default `crux-probe` cargo feature (not part of a normal build), using `serde_json`:

- A probe module `src/crux_probe.rs`.
- One probe site on PANode 9500 in the `guard` match in `src/server.rs`
  (`function_id` 950001): an authorized access is recorded as
  `Read(user, file:<path>, count=1)` (served); an authenticated user whose path is denied
  is recorded as `Read(user, file:<path>, count=0)` (the read was dominated by the access
  check, so no data flowed). The resource is the requested path, so two users requesting
  the same path share one resource string.

Scenario: run dufs with two users, `alice:...@/alice:rw` and `bob:...@/bob:rw`, over a
serve tree with `/alice/secret.txt` and `/bob/secret.txt`. alice reads her own file; bob
attempts alice's file; bob reads his own file.

The probe produced a 3-event trace (`results/afg_trace.jsonl`):

```
seq1 Read alice file:alice/secret.txt count=1  950001  (alice authorized -> served; owner)
seq2 Read bob   file:alice/secret.txt count=0  950001  (bob DENIED -> dominated; same resource, no rows)
seq3 Read bob   file:bob/secret.txt   count=1  950001  (bob authorized to his own)
```

`crux_observe` (`results/afg_observe_verdict.txt`) reports:

```
coarse PANode overlaps (static-style signal): 1   (alice and bob both reach node 9500)
resource-linked leak verdict: 0 confirmed leaks
```

This is the positive-control shape (the same as bionic-gpt): both principals reach the
same resource `file:alice/secret.txt`, but bob's read returns 0 rows because the access
check dominated it, so there is no leak. A dufs whose `guard`/`find` failed to scope a path
would let bob's read reach the serve with `count=1` on alice's file, which `crux_observe`
would report as a confirmed cross-user leak, so the probe has real discriminating power.

## Behavioral confirmation

At the HTTP level in the same run: alice reading her own file returns 200; bob reading
alice's file, directory listing, and zip all return 403; a root listing shows bob only
`/bob/`; and bob reading his own file returns 200 (so it is a real check, not a blanket
deny).

## How to reproduce

```sh
cd dufs
cargo build --release --features crux-probe
mkdir -p /tmp/dufs_demo/alice /tmp/dufs_demo/bob
echo ALICE-SECRET > /tmp/dufs_demo/alice/secret.txt
echo BOB-SECRET   > /tmp/dufs_demo/bob/secret.txt
CRUX_TRACE_PATH=/tmp/dufs_afg.jsonl ./target/release/dufs /tmp/dufs_demo -p 5080 \
  -a "alice:alicepass@/alice:rw" -a "bob:bobpass@/bob:rw" &
curl --anyauth -u alice:alicepass http://127.0.0.1:5080/alice/secret.txt   # 200
curl --anyauth -u bob:bobpass     http://127.0.0.1:5080/alice/secret.txt   # 403
curl --anyauth -u bob:bobpass     http://127.0.0.1:5080/bob/secret.txt     # 200
cd ../AFG/crux
cargo run --example analyze_trace -- /tmp/dufs_afg.jsonl
```

Expect: alice reads her own file, bob is denied alice's file and reads his own, and
`crux_observe` reports 1 coarse overlap and 0 confirmed leaks (true negative).
