# AppFlowy-Cloud: does it leak documents across users?

On the current released build, no. A user who is not a member of another user's
workspace cannot read that workspace's documents. AppFlowy-Cloud is our third
real target, and its access control is casbin (role-based policy checks), which is
a different mechanism from bionic-gpt (Postgres row-level security) and from tabby
(no check at all).

Run date: 2026-09-16, against the prebuilt appflowyinc images.

## What we found

alice has a workspace with documents (collabs). bob, who is not a member of that
workspace, asks for one of alice's documents. He is refused, on both the single
document endpoint and the batch endpoint. alice reading her own document works, so
the refusal is real access control, not a broken endpoint.

## How it happens

Every read under `/api/workspace/{workspace_id}/...` goes through a casbin check,
`enforce_action(uid, workspace_id, Read)` (for example src/api/workspace.rs and
src/api/search.rs). casbin looks up whether that user has a role that grants Read
on that workspace. bob has no role in alice's workspace, so the check returns
false and the handler refuses before serving anything. The shared document read
is dominated by an ownership check bound to the requesting user.

## How we tested it

The real deployment: AppFlowy-Cloud's docker-compose with deploy.env, nine
services (nginx, gotrue for auth, postgres, redis, minio, appflowy_cloud, ai,
worker, search), casbin turned on (APPFLOWY_ACCESS_CONTROL=true). The API is
reached through nginx on localhost (/gotrue for auth, /api for the app).

Two points worth recording for anyone repeating this:

- minio/minio no longer has a pullable tag on Docker Hub, so we pointed the minio
  service at quay.io/minio/minio with a small compose override.
- The prebuilt image enforces a one-user seat license at signup (a gotrue hook
  refuses the second user with "Seat limit reached ... Upgrade your license").
  That is a billing gate, not the access-control code we care about. To exercise
  casbin with a real second user we seeded bob directly: a row in auth.users, a
  row in af_user, and a JWT signed with the dev secret (GOTRUE_JWT_SECRET). bob
  is a genuine outsider, no workspace, no membership. This bypasses licensing
  only, not access control.

Results, with alice's workspace/folder collab WS:

| who   | request                                     | result                                    |
| ----- | ------------------------------------------- | ----------------------------------------- |
| alice | batch-get her own collab (collab_list)      | 200, document returned                    |
| bob   | single-get alice's collab (collab/{id})     | 1012, "user is not a member of workspace" |
| bob   | batch-get alice's collab (collab_list)      | 1012, "Not enough permissions ... Read"   |

## How to reproduce

```sh
# bring up the stack (minio override points at quay)
docker compose --env-file deploy.env -f docker-compose.yml -f <minio-quay-override> up -d

# sign up + verify alice through gotrue, then GET /api/workspace to get her workspace id
# seed bob (auth.users + af_user + a JWT signed with GOTRUE_JWT_SECRET)

# with each user's Bearer token, run the three requests above:
#   GET /api/workspace/{WS}/collab/{WS}       (single)
#   GET /api/workspace/{WS}/collab_list       (batch, body: [{object_id, collab_type}])
```

## The interesting part is in the source, not the image

The running image blocks bob on both paths. But the source checkout we have
(commit c5bcfd3) is older, and in it the batch path does not enforce anything. We
follow that up in the dynamic run (dynamic.md), where we build that source,
instrument it, and watch AFG catch the leak the batch path actually has.
