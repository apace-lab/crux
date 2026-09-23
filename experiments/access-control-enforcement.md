# Access-control enforcement - plan + notes

Informal notes capturing the access-control-enforcement analysis, before we build it.

## The idea in one line

For **every data-access site** in an app (DB query + external API call), check whether
it is **dominated by an access-control check**. Report the ones that are not - that's
the list of places the developer forgot to protect.

In one line: *force the application to enforce security on all data access, and find
out where it does not have any security check (database and API calls only).*

## How it relates to what we already have

This is the **same dominance invariant** that underlies the whole tool, just used
differently:

- So far we've used the invariant to **confirm a specific leak** (tabby's unscoped
  query, AppFlowy's batch endpoint, zed's removal path) and to **confirm true
  negatives** - a targeted, per-scenario verdict.
- The **comprehensive / coverage** version: enumerate *all*
  data-access + API sites and flag *every* one lacking a dominating check. Output is a
  ranked list of unguarded accesses for manual triage, not a single yes/no.

Two complementary contributions, both in the paper:

| | schedule-driven testing | access-control enforcement |
|---|---|---|
| mode | dynamic (run under many schedules) | static (whole-program) + dynamic fallback |
| question | "is there a leak (incl. timing-dependent)?" | "where is a check missing, everywhere?" |
| output | a confirmed leak + witness schedule | a list of un-dominated data-access/API sites |
| strength | catches races a single run misses | systematic, whole-app coverage |

## What "dominated by an access-control check" means

For a data-access site D (a DB read/write or an outbound API call), on every path from
the request entry to D there must be an access-control check C (an auth/ownership/role
check for the *current principal*) that executes before D. If some path reaches D with
no such C, D is **un-dominated** → a candidate missing check.

This is a classic dominance computation on the call/control-flow graph, using the
points-to (PAG) info the producer already builds:
- **Data-access sites**: the producer already catalogs these (sqlx `execute`/`fetch_*`,
  dashmap/redis, outbound HTTP/LLM clients). tabby: 105 data-access + 4 LLM; AppFlowy:
  11 data-access.
- **Access-control points**: auth/ownership checks (jsonwebtoken decode, casbin
  `enforce`, an in-query ownership predicate, a membership check). This is the part
  that needs work - indirect calls (AppFlowy's casbin through `Arc<dyn ...>`) were not
  resolved statically and need devirtualization via the receiver's points-to set.
- **Dominance**: for each data-access site, does an AC point dominate it on all paths?

## The toolchain wrinkle for "do it on all 4 apps"

The *static* enumeration needs the LLVM-19 producer, which builds on:
- **tabby** (rustc 1.85) and **AppFlowy** (rustc 1.86) - static path works.
- **bionic-gpt** (rustc 1.97) and **zed** (rustc 1.98) - LLVM 20, static-blocked.

For bionic/zed we do the enumeration **dynamically** (from the trace: which data
accesses had a dominating auth event on their path) or by **manual code audit**. The
technique is uniform; the implementation path differs per app. We should say this
plainly in the paper.

## Plan (try on one app -> manual inspection)

1. **Pilot on tabby** (known-answer, static producer works). Enumerate its data-access
   + API sites, compute which are dominated by an auth check, and print the
   un-dominated ones. Success criterion: the unscoped `list_thread_messages` read
   shows up as un-dominated (that's the real bug), while writes/reads that sit behind
   the JWT/ownership checks do not. Manually inspect the full list for false
   positives/negatives.
2. **Extend to AppFlowy** (static, needs the casbin devirtualization to resolve AC
   points; the batch `collab_list` read should surface as un-dominated).
3. **bionic-gpt and zed**: dynamic/manual enumeration (LLVM-20, no static producer).
   bionic's reads should all be dominated (RLS + in-query predicate); zed's channel
   buffer broadcast should surface as un-dominated on the removal path.

## Status

- [x] tabby pilot DONE -> results/ENFORCEMENT_PILOT.md. Found a real, path-sensitive leak (convert_thread_to_page missing check_read_thread) AND corrected our earlier tabby framing (direct thread_messages IS resolver-guarded; persisted-thread sharing may be intended).
- [x] AppFlowy DONE -> appflowy-cloud-repro/results/ENFORCEMENT_PILOT.md. batch_get_collab (uid ignored, no enforce) UNSCOPED = leak; get_full_encode_collab enforces Action::Read = dominated. Same path-sensitive pattern; check lives in the STORAGE layer here (not the resolver).
- [x] bionic-gpt DONE -> bionic-gpt-repro/results/ENFORCEMENT_PILOT.md. TRUE NEGATIVE: ownership predicate (user_id=current_app_user()) EMBEDDED in every tenant read query + fail-closed GUC -> not omittable per-path.
- [x] zed DONE -> zed-repro/results/ENFORCEMENT_PILOT.md. Path/subsystem-sensitive: buffer join read dominated; buffer edit broadcast UN-dominated (removal/downgrade not evicted) = LEAK; project worktree broadcast dominated (collaborator lifecycle coupled). All 4 apps done.


## Enforcement-style taxonomy (all 4 apps done, 2026-09-23)

The pass distinguishes WHERE each app puts its check, which predicts the failure mode:

| app | check location | omittable per-path? | verdict |
|---|---|---|---|
| tabby | HTTP resolver (check_read_thread) | yes -> convert_thread_to_page omits it | LEAK |
| AppFlowy | storage method (get_full_encode_collab) | yes -> batch_get_collab omits it | LEAK |
| bionic | embedded in the query (user_id=current_app_user()), fail-closed | no | no leak |
| zed | membership check at join; live-session delivery recipients | yes (temporal: not revalidated after revocation) | LEAK |

Key insight for the paper: leaks arise wherever the check is a SEPARABLE step some
path/time can skip; bionic (check embedded in the query, principal mandatory) is the
only one where it cannot be skipped, and it is the only true negative. The
access-control-enforcement analysis = find data-access sites where the dominating check
is separable and some path/time omits it.
