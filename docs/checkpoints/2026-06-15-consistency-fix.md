# Checkpoint — Cross-session consistency fix (one brain, not five)
**Date:** 2026-06-15 · **Branch:** `claude/gallant-archimedes-fb0d4f` · **Author:** Cogito

## The mission
The user reported: "the sessions are different from each other… the live consistency feature is bugging." A newer session (`awesome-mayer`) re-did setup that an older session (`confident-wright`) had already finished.

## Root cause (one layer below the symptom)
Both SessionStart hooks loaded the brain (`LESSONS.md`, `ACTIVE-MISSION.md`, `SKILL.md`) from **the checked-out session branch's working tree**. With a fresh `claude/*` branch per web session and no convergence, the brains diverged. Recency ≠ canonicity: the newest session by clock had forked off a stale `main`, so the most-advanced state — stranded on `confident-wright` (+22 commits) — was invisible to it.

## Decisions made (verified)
1. **One canonical brain = `main`.** (User chose "main = brain, merge in".)
2. **Mission = Cogito tooling first**, then resume the AI teacher. (User chose.)
3. **Council + Hermes** = options brief owed; decide scope later. (User chose "explain first".)

## What now exists (this branch, pushed)
- **Merge commit `b3afe41`** — reconciled `confident-wright` into the main lineage. One brain now holds: the completed 10-item roadmap, the **council**, the AI-teacher start, all tooling (budget/decay/guard/review/skill-check, judge+reviewer agents, plugin packaging), and a unified **56-lesson** ledger (52 + 2 main-only re-added after a mechanical conservation check + 2 new). Conservation verified; zero conflict markers.
- **Fix commit `7521ce9`** — both hooks now read the brain from `origin/main` (override: `COGITO_BRAIN_REF`), with a working-tree fallback so a failed/offline read never blanks the brain.
- **Verified by running the hooks:** default loads canonical `origin/main` (45) while the working tree holds 56 — proof it ignores the branch; unreachable ref → falls back to local (56). Syntax clean.

## Open / next actions
1. **PENDING USER YES:** fast-forward `main` to this branch so `origin/main` becomes the 56-lesson brain + fixed hooks. Until then, new sessions still read the old 45-lesson `main`. `main` is protected — needs explicit approval.
2. **Trust-but-verify** confident-wright's "roadmap COMPLETE" claim — actually run each tool (#3,#5,#6,#7,#8,#9,#10).
3. **Council + Hermes** — user reviews the options brief, picks scope.
4. Resume the **AI teacher** once the base is trusted.

## Corrections captured this session (now durable lessons)
- I slipped into dense, technical, long replies — violated the standing "non-technical user, keep it plain" rule. → new `[#critical][#comms]` lesson.
- The consistency root cause itself → new `[#memory][#git][#critical] [I:9]` lesson.
- The safety classifier correctly blocked editing the startup hooks until the user gave explicit approval — honored, did not reroute (existing `[I:7]` lesson held).
