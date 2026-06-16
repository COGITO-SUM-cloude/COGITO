# Checkpoint — 2026-06-16 — Brain write-back: council + cleanup (step A done)

## Mission
Make the shared brain a **living, self-correcting notebook** that satellite repos can
write to **autonomously** (no human relay), including **correcting** outdated lessons —
the user's flat-earth→round analogy — WITHOUT (a) tripping the harness safety classifier,
(b) a supply-chain backdoor, (c) one bad edit poisoning every reader.

## Decisions (council verdict — 5 decorrelated voices + judge, verified vs the repo)
- **Satellites PROPOSE, never push.** No satellite holds a canonical-write token (that is
  the exact exfil shape the classifier blocked 4×). The hub does the writing.
- **Append is cheap + automatic; contradicting/retiring canon is expensive + gated.** New
  lessons can auto-merge; overturning an existing "truth" keeps a one-tap human (or a 2nd
  independent corroboration) circuit-breaker. This is the correct reading of the vision:
  the notebook is rewritable, but not *unreviewed*.
- **Correction = supersede-by-archival, never hard delete** (already the brain's grain;
  cogito-consolidate.sh `verify` + cogito-decay.sh do the evolve/retire work).
- **Sync LESSONS only; never auto-overwrite SKILL.md from the remote** (supply-chain).

## Current state
- **Step A (cleanup) — DONE on branch `claude/brave-carson-8sa2lm` (commit 947fb8c), PENDING main push:**
  - `cogito-learn.sh`: Mode 2 (token → direct API write to main) REMOVED. Satellites queue locally + relay/propose.
  - `cogito-sync.sh`: LESSONS-only; no remote SKILL.md auto-overwrite.
  - `.gitattributes`: `LESSONS*.md merge=union` (conflict-free concurrent appends).
  - Verified: syntax OK; no `api.github.com` / no token use in learn; sync still loads 84 lessons.
- **Already on main:** TLS hardening of cogito-learn (11a602a, now moot since Mode 2 is gone); hardened converge hook; council skill auto-uses a non-Claude voice. Brain = 84 lessons.

## Step B design (build AFTER the blocker below is settled)
- **Hub-side gate = a GitHub Action on the public repo** (greenfield — no `.github/workflows` exists yet).
  Auto-merge a PR only if: touches LESSONS.md only, **removes no active line** (stricter than
  consolidate `verify`, which allows archived removals), every new line matches `^- .*->.*->.*`,
  size cap. Anything that edits/deletes a line, carries `supersedes:`, or touches SKILL.md →
  stays open for the owner's **one-tap** merge. Pin action to a SHA; guard against a PR editing the workflow itself.
- **Provenance/supersession trailer:** `... RULE {by:repo/role, d:date, conf:N, status:active|proposed|superseded}`.
  A correction appends a new line + `supersedes:#<hash-of-old>` that **must match a current active line** (signing-free
  anti-clobber, from the non-Claude voice). Old line → `status:superseded` / moved to ARCHIVE (history kept).
- **Quarantine:** satellites append to a `## Proposed` zone, loaded as "unverified"; promoted to active by a 2nd
  independent corroboration or consolidation. Append safe; contradiction gated.

## Open questions / THE BLOCKER (gates the rest of B)
- **Can a PRIVATE satellite (paint) get a proposal to the hub autonomously?** UNVERIFIED — judge says settle
  with a LIVE TEST from a satellite session, not more deliberation. Reads are free (anon clone). But a PR needs a
  credential to push a branch/fork (the blocked shape), and the hub can't pull a PRIVATE repo without a ONE-TIME
  owner grant (a GitHub App / read-grant). **Do NOT build the hub Action until this is tested.**
- **Sybil/identity** (one actor, N repos, self-corroborates) is unsolved under faceless+$0 — mitigated only by the
  one-tap on contradictions. **"The first true lesson looks like a vandal"** → lone-genius corrections wait in
  quarantine; the human tap is the resolution. Fully-autonomous *correction of canon* is not safe for a solo owner.

## Next step
Run the live test from a **paint** session: can it open a PR / deposit a proposal the hub can read? That answer
(PR-push vs hub-pull vs one-time-grant) decides the hub gate's shape. THEN build the Action.

## Guardrails reaffirmed this session
Faceless (commit as Cogito); a main push needs an explicit per-time "push to main" (a generic go/continue is not);
never scatter a write-secret; never fetch-and-run secret-touching code; verify by running, not "probably."
