# ACTIVE MISSION — resume pointer
_Short on purpose: this is read into every session, so it costs tokens each turn. Plain language only — the user is non-technical._

When the user says "Cogito": greet in one line, confirm, continue. Don't re-interview.

## Mission — Cogito tooling first, then resume the AI teacher
Make the memory trustworthy and consistent across sessions BEFORE building more on top of it.

## The fix (2026-06-15): one brain, not five
Symptom: each session read its memory from its OWN branch, so sessions drifted apart and a new one re-did finished work ("the live consistency feature is bugging").
Fix:
1. `main` is the ONE canonical brain. All stranded session work was reconciled into it — the completed 10-item roadmap, the council, the AI-teacher start, and the full lessons ledger (now 56).
2. The SessionStart hooks load the brain from `origin/main` (a fixed point), NOT the local branch, with the local copy as an offline fallback. Sessions can't drift apart again.
3. Write-back: at checkpoint, converge this session's new lessons + this file back to `main`. `main` is protected — ASK the user for a clear yes before updating it; never auto-push.

## Next, in order
1. Trust-but-VERIFY confident-wright's "roadmap COMPLETE" claim — actually RUN each tool (#3 index-load, #5 decay, #6 skill-gate, #7 spaced-rep, #8 guard, #9 plugin, #10 reviewer) and confirm it works before trusting "done".
2. Council + Hermes direction — user asked for an options brief first; don't build until chosen.
3. Resume the AI teacher (`docs/checkpoints/2026-06-15-ai-teacher-pivot.md`) once the base is trusted.

## Guardrails (always on)
- One brain = `main`. Sync only `main` + the active branch. NEVER push to old session branches (a stale push resurrects deleted ones).
- `main` is protected: update it only with the user's explicit yes to that exact action.
- Faceless: commit as `Cogito <cogito@users.noreply.github.com>`; nothing personal in artifacts.
- Verify by running/re-reading — never "probably / build passed / captured."
- Plain language, short replies — the user is non-technical.

## Full context
Roadmap: `docs/projects/06-cogito-upgrade-roadmap.md` · Teacher: `docs/checkpoints/2026-06-15-ai-teacher-pivot.md` · This fix: `docs/checkpoints/2026-06-15-consistency-fix.md`
