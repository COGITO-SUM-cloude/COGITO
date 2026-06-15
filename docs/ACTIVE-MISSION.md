# ACTIVE MISSION — resume pointer
_Surfaced at session start so a new session resumes instantly. Delete/replace when the mission changes._

## When the user says "Cogito"
Do NOT re-interview from scratch — the mission is already specced. Greet in one line, confirm, then CONTINUE down the list.

## Mission
Implement the Cogito upgrade roadmap in `docs/projects/06-cogito-upgrade-roadmap.md`, going down the ROI-ranked list.

## Where we are (2026-06-15)
- **DONE (Tier 1):** #1 runnable verification gate (SKILL §5b); #2 lesson tags + importance `[I:1-10]` convention.
- **NEXT, in order:** #4 consolidation pass → #5 decay/archive → #6 CoALA taxonomy + skill-creation gate → #7 spaced-repetition for the learning log.
- **HOLD / extra care (blast radius — confirm + verify hard):** #3 index-then-load (touches the SessionStart load path), #8 guard/auto-capture hooks (tool boundary). A memory system that fails to load its lessons is the worst outcome — keep full-load as a safety net and prove the change before trusting it.
- **Tier 3 after:** #9 package as a plugin, #10 fresh-context reviewer subagent.

## Guardrails (hard-won this session)
- Sync ONLY `main` + the active working branch. NEVER push to old session branches — a stale push resurrects deleted ones.
- Verify every change by re-reading/running it (SKILL §5b). Never trust "probably / build passed / captured."
- Faceless: commit as `Cogito <cogito@users.noreply.github.com>`; nothing personal in artifacts.
- New lessons use the tagged format: `[#tag] [I:1-10] SYMPTOM -> ROOT CAUSE -> RULE`.

## Full context
Roadmap: `docs/projects/06-cogito-upgrade-roadmap.md` · Latest checkpoint: `docs/checkpoints/2026-06-15-upgrade-roadmap.md`
