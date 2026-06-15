# Checkpoint — Cogito upgrade #5: decay/archive policy (2026-06-15)

## Mission
Implement the Cogito upgrade roadmap (`docs/projects/06-cogito-upgrade-roadmap.md`)
down the ROI list. This session also did #4 (consolidation, separate checkpoint);
this file covers **#5 — decay/archive policy**.

## Decisions made (canonical, verified)
- **Decay reuses #4, it does not rebuild.** Decay is just another trigger for the
  same archive move and the same conservation gate (`cogito-consolidate.sh
  verify`). The only new thing is *which* lessons it picks.
- **The safety floor is the whole design.** 42 of 45 lessons are unscored. A naive
  "archive old low-value lessons" rule would read "unscored" as "low-value" and
  could gut the ledger. So the rule is inverted: a lesson decays **only if it is
  explicitly `[I:≤3]`** AND cold (>90d) AND off-probation AND not `#critical` /
  `[I:≥9]`. Unscored lessons are always kept. Decay is opt-in per lesson.
- **Recency without backfill.** A lesson's recency = the latest `[d:]`/`[seen:]`
  stamp in the line, else the line's git-blame commit date. No need to date the
  45 existing lessons. `[seen:DATE]` is the refresh-on-use signal (MemoryBank
  Ebbinghaus): applying a lesson keeps it warm.
- **Policy only, nothing retired.** The 3 scored lessons are all `[I:6]` (above
  the floor of 3), so there are zero decay candidates right now — correct. The
  mechanism waits for low-value lessons to exist and age.

## Current state — what exists, where
- `scripts/cogito-decay.sh` — `report` (list cold + low-value + off-probation
  candidates, with age and importance) and `touch "<text>"` (refresh-on-use:
  write/refresh `[seen:TODAY]` on the one matching lesson). Executable, tested.
- `skills/cogito-consolidate/SKILL.md` — now "ledger maintenance" = consolidate +
  decay: added the decay section (rule, refresh-on-use, procedure) and
  generalized the closing bias to "when in doubt, keep."
- `skills/cogito-protocol/SKILL.md` §4b — decay rule + the optional `[d:]`/`[seen:]`
  recency convention (git-blame fallback).
- Archive + conservation gate unchanged from #4 (shared).

## Verification (live)
- `report` on the real ledger → 0 candidates (only `[I:6]` lessons exist). ✓
- `touch` → stamped `[seen:2026-06-15]` on the exact target line, reverted. ✓
- Synthetic `[I:2] [d:2020-01-01]` lesson: invisible under default probation
  (it was most-recent), flagged as a candidate (2357d old) with `PROBATION=0`. ✓
- Synthetic *unscored* old lesson: never flagged, even with `PROBATION=0` — the
  safety floor holds. ✓

## Next actions (down the list)
#6 CoALA taxonomy + skill INDEX + skill-creation gate (episodic=checkpoints,
semantic=lessons, procedural=skills; commit a skill only after it is verified in a
real session) → #7 spaced-repetition for the learning log (Leitner ladder). Then
with extra care: #3 index-then-load, #8 hooks. Then Tier 3: #9 plugin, #10
reviewer subagent.

## Corrections / guardrails to remember
- Sync only `main` + the active working branch (`claude/confident-wright-mg519n`);
  never push old session branches.
- Verify by running, not reading. (#4 found two bugs only by running; #5 passed
  first try because the traps — unscored=low-value, synthetic-at-end hits
  probation — were engineered against up front.)
- Faceless commits as `Cogito <cogito@users.noreply.github.com>`.
- Pruning bias: only *explicitly* low-value lessons decay; when in doubt, keep.
