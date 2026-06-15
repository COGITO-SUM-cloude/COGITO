# ACTIVE MISSION — resume pointer
_Surfaced at session start so a new session resumes instantly. Delete/replace when the mission changes._

## When the user says "Cogito"
The upgrade-roadmap mission is **COMPLETE** (all 10 items). Do NOT resume it. Greet
in one line, note the roadmap is done, and interview for the **next** mission — or
pick up an optional follow-up below.

## Last mission (DONE)
Implement the Cogito upgrade roadmap in `docs/projects/06-cogito-upgrade-roadmap.md`,
ROI-ranked. **All 10 items shipped and verified** (#1–#2 a prior session; #3–#10 on
2026-06-15), every change proven by running it, several by a decorrelated reviewer.

- **#1 verification gate** (SKILL §5b) · **#2 lesson tags + importance** (§4b).
- **#3 index-then-load** — `cogito-sync.sh` full-loads below ~80 lessons (safety net,
  byte-identical today: 47→47 empty diff) then switches to index + always-load
  `#critical`/`[I:≥9]` + grep-hint. `COGITO_LOAD_THRESHOLD` tunes it.
- **#4 consolidate / #5 decay** — `cogito-consolidate` skill + `scripts/cogito-consolidate.sh`
  (report/verify conservation gate) + `scripts/cogito-decay.sh` (report/touch) +
  `LESSONS-ARCHIVE.md`. Mechanism only (ledger < trigger); nothing retired.
- **#6 library hygiene** — `skills/INDEX.md` (CoALA map + skill/agent/hook catalog)
  + `scripts/cogito-skill-check.sh` + §4c.
- **#7 spaced repetition** — Leitner `box:/due:` on the learning log + `scripts/cogito-review.sh`
  + a guarded SessionStart recap.
- **#8 guard** — `scripts/cogito-guard.sh` blocks self-matching `pkill -f` and `rm -rf`
  root at the tool boundary (fail-open, mention-immune); wired in settings.json +
  plugin. Blocking Stop-gate deliberately deferred (§5d).
- **#9 plugin** — `.claude-plugin/plugin.json` + `marketplace.json` + `hooks/hooks.json`
  (`claude plugin validate .` clean). **#10 reviewer** — `.claude/agents/cogito-reviewer.md`
  + §5c grounded-signal rule.

## Optional follow-ups (not blocking)
- Live-confirm the plugin actually installs + loads in a FRESH session:
  `/plugin marketplace add COGITO-SUM-cloude/COGITO` → `/plugin install cogito@cogito`
  → `/plugin details cogito@cogito` (restart to apply).
- If ever wanted: a NON-blocking Stop reminder (the blocking form was rejected).
- Consolidation/decay are mechanisms awaiting their triggers (ledger ~47 < 60/80).

## Guardrails (hard-won)
- Sync ONLY `main` + the active working branch; never old session branches.
- Verify by running, not reading. **Commit feature edits BEFORE testing mutations on
  the same file** (a `git checkout` ate uncommitted work this session).
- **Test a gate/guard on BOTH pass and fail paths**, and against inputs that merely
  *mention* what it blocks (the guard blocked its own commit until fixed).
- Faceless commits as `Cogito <cogito@users.noreply.github.com>`.
- Load-path / tool-boundary changes: keep the safe fallback, prove before trust.

## Full context
Roadmap: `docs/projects/06-cogito-upgrade-roadmap.md` · Final checkpoint:
`docs/checkpoints/2026-06-15-roadmap-complete.md`
