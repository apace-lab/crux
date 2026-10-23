# AppFlowy-Cloud: released-image run

The prebuilt AppFlowy-Cloud stack, driven with two users. Target: appflowyinc
released images (the build newer than source commit `c5bcfd3`). Run date
2026-09-16. Access control here is casbin, a role-based policy check, which is a
different mechanism from bionic-gpt (Postgres row-level security) and tabby (no
check).

## What we found

On the released build a non-member cannot read another user's document. alice
owns a workspace with documents; bob is not a member. bob is refused on both the
single-document endpoint and the batch endpoint. alice reading her own document
works, so the refusal is real access control, not a broken endpoint.

```
alice  GET /api/workspace/{WS}/collab_list   200 Success (her own document)
bob    GET /api/workspace/{WS}/collab/{WS}   1012 "user is not a member of workspace"
bob    GET /api/workspace/{WS}/collab_list   1012 "Not enough permissions ... Read"
```

What it means: every read under `/api/workspace/{workspace_id}/...` goes through
casbin `enforce_action(uid, workspace_id, Read)` (for example in
`src/api/workspace.rs` and `src/api/search.rs`). bob has no role in alice's
workspace, so the check returns false and the handler refuses before serving
anything. This is the guarded case: the shared read is dominated by an ownership
check for the requesting user. The batch path is guarded too in this build, which
is the difference from source commit `c5bcfd3`, where it is not (see dynamic.md).

## How to reproduce

```sh
# bring the stack up (minio: override to quay.io/minio/minio)
docker compose --env-file deploy.env -f docker-compose.yml -f <minio-quay-override> up -d

# sign up + verify alice through gotrue, GET /api/workspace to read her workspace id.
# the prebuilt image caps at one licensed user, so seed bob directly to test casbin
# with a second principal (this bypasses the billing seat gate, not access control):
#   - insert a row in auth.users and af_user for bob
#   - mint bob a JWT signed with GOTRUE_JWT_SECRET

# then, with each user's Bearer token, run the three requests above:
GET /api/workspace/{WS}/collab/{WS}      # single
GET /api/workspace/{WS}/collab_list      # batch, body: [{object_id, collab_type}]
```

Expected: alice reads her own document; bob is refused on both paths.

## Note

The interesting case is in the source, not this image. Source commit `c5bcfd3` is
older and its batch path does not enforce anything. dynamic.md builds that source,
instruments it, and shows CRUX catch the leak the batch path actually has.
