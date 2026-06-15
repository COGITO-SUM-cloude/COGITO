# Checkpoint — Cogito upgrades: research + Tier-1 start (2026-06-15)

## Mission
Research extensively, rank by ROI, and implement upgrades to Cogito. This session: the research + ranking + the first two Tier-1 items. Continues next session down the list.

## Decisions made (canonical, verified)
- **Ranked roadmap committed:** `docs/projects/06-cogito-upgrade-roadmap.md` (3-lane parallel research; ROI table; per-item notes; not-portable flags; sources).
- **Core finding:** Cogito already *is* the architecture the field recommends. Heavy frameworks (Letta, mem0, Zep, graph/vector DBs, embeddings, routines/workflows/agent-teams) are not portable to a free/file system and not needed — an LLM reading tagged plain files replaces them, and is better for a causal SYMPTOM→RULE ledger.
- **Implemented + verified:** Tier-1 #1 (runnable verification gate, SKILL §5b) and #2 (lesson tag + importance `[I:1-10]` convention; header + §4b).
- **Cross-session resume made automatic:** `docs/ACTIVE-MISSION.md`, surfaced by the SessionStart hook, so a new session wakes already knowing the mission and position.

## Current state — what exists, where
- `docs/projects/06-cogito-upgrade-roadmap.md` — the ranked plan.
- `skills/cogito-protocol/SKILL.md` — §5b verification gate; §4b lesson-format/scale note.
- `skills/cogito-protocol/LESSONS.md` — header format note + new tagged lessons.
- `docs/ACTIVE-MISSION.md` — the resume pointer.
- `.claude/hooks/cogito-session-start.sh` — now prints the active mission at session start.
- All on `main` (the default) and `claude/peaceful-allen-tykil7`, synced.

## Next actions (go down the list)
#4 consolidation → #5 decay/archive → #6 CoALA taxonomy + skill-creation gate → #7 spaced-repetition log. Then with extra care: #3 index-then-load, #8 hooks. Then Tier 3: #9 plugin, #10 reviewer subagent.

## Corrections / guardrails to remember
- Sync only `main` + working branch; never push old session branches (a stale sync resurrected `gallant-babbage` after it was deleted).
- Do not break the SessionStart load path; verify hard.
- Faceless commits as Cogito; tagged-format lessons.
- "my website project" = the paint site (separate repo); the Cogito web/ site is a private hub, not a public showcase.
