# Checkpoint — 2026-06-24 — Brain write-back pipeline (Drain → Dashboard → Guards)

Status: COMPLETE on branch `claude/optimistic-clarke-ptim35`. All three ideas built + verified.

## Mission
Build the three "resume here" items as one pipeline:
1. **Drain** — `scripts/cogito-drain.sh` pulls lessons from public satellite outboxes,
   dedupes vs the master ledger, stages them for review (ends the manual copy-paste relay).
2. **Dashboard** — bring `prototypes/cogito-screen.html` to life: Inbox reviews the drained
   queue (Accept→append, Reject→archive); live-dots driven by real logged-out HTTP checks.
3. **Guards** — convert high-severity ledger scars into PreToolUse guards in `cogito-guard.sh`
   (block direct `main` push + TLS-disable-while-tokens-live, unless explicitly approved).

## Locked decisions (from the opening interview)
- Dashboard backing = **local review tool** ($0, in-session): a tiny local server with
  /accept /reject endpoints; NOT a CMS port (that's blocked on AI-credit), NOT patch-only.
- Outbox source = **satellite-agnostic + synthetic test**: drain reads a configurable list of
  sources (raw https URL OR local path); proven with a synthetic fixture; real satellites
  (HaloXBrainrot etc.) pointed at afterward. Anon read only works for PUBLIC satellites.
- Pacing = **all three now, in order 1→2→3**, checkpoint at the end.
- Develop on branch `claude/optimistic-clarke-ptim35` (both repos). No PR unless asked.

## Architecture (why it's safe)
```
PUBLIC satellite repo → cogito-outbox.md   (lessons, standard format)
        │  anon raw read — NO credential (the verified-safe path; council 06-16)
        ▼
cogito-drain.sh   fetch → dedupe vs ledger → stage to docs/inbox/queue.json
        │  the drain holds NO write-secret; it only reads public files + edits a LOCAL file
        ▼
dashboard Inbox (local server) → accept = cogito-drain.sh accept <id> → append LESSONS.md
                                 reject = cogito-drain.sh reject <id> → archive
        ▼
converge Stop hook (already trusted) → brain-only FF push to main → human reviews git diff
```
- Ledger-mutation is centralized in `cogito-drain.sh` (single authority); the server shells out.
- The guard is PreToolUse-on-Bash → it blocks the AGENT's ad-hoc `git push … main`, but the
  converge Stop hook runs in its own process and is unaffected (sanctioned path stays open).

## Ground-truth facts confirmed
- Master ledger to append to = the **repo** copy `skills/cogito-protocol/LESSONS.md` (42.6KB,
  versioned → main). The **installed** copy `~/.claude/skills/cogito-protocol/LESSONS.md`
  (46.3KB) has drifted ahead (install.sh never clobbers it). Drain dedupes vs the UNION of
  both + LESSONS-ARCHIVE + the queue. Drift reconciliation is converge's job — NOT touched here.
- Ledger line format: `- [#tag] [I:1-10] SYMPTOM -> ROOT CAUSE -> RULE`. High-severity = `#critical` or I≥9.
- Dashboard prototype lives on `origin/claude/brave-carson-8sa2lm:prototypes/cogito-screen.html`
  (213 lines; Map + Live + Accept/Reject Inbox; sample data; decide() only changes the screen).

## What shipped (all on the feature branch)
- `scripts/cogito-drain.sh` (+ `cogito-satellites.txt`) — fetch (URL or local path, anon) →
  dedupe vs ledger∪archive∪installed∪queue → stage to `docs/inbox/queue.json`; subcommands
  `drain | list | accept <id> | reject <id> | accept-all | --selftest`. Verified: 9/9 selftest.
- `scripts/cogito-control.sh` (+ `cogito-projects.txt`) — localhost-only server: serves the
  dashboard, `/api/queue`, `/api/accept|reject` (shell out to the drain), `/api/status` (real
  logged-out curl checks). Verified: 11/11 endpoint tests; real probes (Teacher 401, Paint 200,
  brain repo 200) through the proxy CA.
- `prototypes/cogito-screen.html` — ported off `claude/brave-carson-8sa2lm` and rewired to the
  live queue + status; Accept/Reject hit the server; graceful "server off" banner for file://.
- `scripts/cogito-guard.sh` — +2 classify rules: gated `main` push (escape hatch
  `COGITO_ALLOW_MAIN_PUSH=1`) and TLS-disable block. Verified: 62/62 selftest + 5 hook-mode tests.

## Verification (grounded, not inferred)
- Drain selftest, control endpoint suite, guard selftest + hook JSON all PASS (pasted in session).
- Guard ⟂ converge confirmed: the Stop hook pushes in its own process, never through PreToolUse,
  so gating agent `main` pushes does NOT break the sanctioned brain→main path.

## Open questions / next actions
- Point the drain at the REAL HaloXBrainrot outbox (need the public repo URL, or clone it locally
  and add the path to `scripts/cogito-satellites.txt`) to drain the 7 real scars.
- Add the CMS production URL to `scripts/cogito-projects.txt` so its live-dot is real.
- Optional: update `docs/ACTIVE-MISSION.md` "Resume here" to mark Drain/Dashboard as DONE
  (left untouched this session to keep `main` changes to the captured lesson only).
- TLS-disable rule is unconditional (not token-gated) — simpler + matches the standing "never
  disable TLS" rule; say so if you'd prefer it to fire only when a secret is in the env.

## LESSONS captured this session
- ROOT two-line bug (`$(git || cd && pwd)` precedence) → appended to the ledger; symptom was at
  the HTTP layer, cause was shell operator precedence. The smooth rest of the build produced no
  other scar.
