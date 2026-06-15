# Cogito Skills — Index (procedural memory)

Cogito's memory follows the **CoALA** taxonomy (Cognitive Architectures for
Language Agents, arXiv 2309.02427). Each memory type has one durable home, so
nothing load-bearing lives only in a volatile context window:

| Memory type | What it holds | Where it lives |
|---|---|---|
| **Episodic** | what happened in a session | `docs/checkpoints/`, `docs/learning/log.md` |
| **Semantic** | earned general rules | `skills/cogito-protocol/LESSONS.md` (+ `LESSONS-ARCHIVE.md`) |
| **Procedural** | how to act (skills) | `skills/*/SKILL.md` — indexed below |
| **Working** | the current turn | the context window + `docs/ACTIVE-MISSION.md` |

Each skill is loaded **just-in-time by its description** (progressive disclosure:
Claude Code reads the frontmatter `description`, then expands the body only when a
task matches — Voyager's description-keyed skill library, native to the harness).

## Skills (procedural memory)

| Skill | Use it when | Status |
|---|---|---|
| **cogito-protocol** | any substantial or multi-session work — the metacognitive OS: assumptions, three-layer analysis, state files, verify-outcomes gate, lessons ledger, finish-line review. Always-on by default. | battle-tested |
| **cogito-consolidate** | the lessons ledger passes ~60, a severe lesson lands, or you say `/consolidate` — ledger maintenance: merge redundant lessons + decay cold low-value ones into the archive (never delete). | helpers verified live; the merge/decay *procedure* awaits its first real trigger (ledger < 60) |
| **adaptive-learning** | a concept surfaces in the work, the user asks how/why, or at session close — grow the user with small, plain-language teaching. Record: `docs/learning/log.md`. | in use |
| **web-build-loop** | building, fixing, deploying, or QA-ing a website — prove the change by rendered pixels from a logged-out context + the asset's own HTTP status, never a green build. | battle-tested |

## Adding a skill — the creation gate
A skill is procedural memory **only after it has worked in a real session**
(Voyager adds a skill only once a critic verifies it; this is §5 "verify outcomes"
applied to library growth). Before committing a new skill:

1. Run `scripts/cogito-skill-check.sh <name>` — frontmatter + index checks pass.
2. Be able to name the **real task it ran on** and the **observed outcome** that
   proved it (not "it should work").
3. Add it to the table above.

A skill added on spec is a hypothesis, not memory — keep it on a branch until a
session proves it. (Rationale: docs/projects/06-cogito-upgrade-roadmap.md, #6.)
