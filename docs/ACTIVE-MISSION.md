# ACTIVE MISSION — resume pointer
_Short on purpose: read into every session, costs tokens each turn. Talk adult-to-adult: plain, short, no jargon, no "baby steps" (the user is non-technical but NOT a child)._

When the user says "Cogito": greet in one line, confirm, continue. Don't re-interview.

## Mission — make the brain as POWERFUL as possible, then the VR teacher is easy
Harden + upgrade Cogito's memory (file-based, no vector DB, low context-tax) so a future VR/3D AI teacher is easy to build. Execute the council's ROI-ranked list, best payoff first. Every pick is $0 + file-native.

## Foundation already in place (2026-06-15)
- ONE canonical brain on `main`; the SessionStart hooks load from `origin/main`, not the session branch (cross-session consistency — fixed + verified).
- Brain AUTO-SAVES at turn end (Stop hook `scripts/cogito-converge.sh`): brain files only, commits + pushes to the branch, AND fast-forwards `main` — the user turned auto-push ON (2026-06-15); FF-only, never clobber. Branch-only: `COGITO_CONVERGE_TO_MAIN=0`; fully off: `COGITO_AUTO_CONVERGE=0`.

## Council-ranked roadmap — go down the list
1. DONE — supersession: a corrected lesson consolidates/archives the old one so only the current rule loads (fixed a verified contradiction; conservation gate passed).
2. DONE — Stop-hook auto-save (above).
3. DONE — `UserPromptSubmit` hook (`scripts/cogito-recall.sh`): auto-pulls the 1-3 lessons matching the prompt's keywords; verified live. Kill switch: `COGITO_RECALL=0`.
4. DONE — Verify-before-store gate: the skill-check gate (`cogito-skill-check.sh`) + the documented rule + the lesson-probation buffer already existed (prior merge); ran the gate, all 5 skills pass. Confirmed working, not rebuilt.
5. DONE — Sharpened the JUDGE: explicit same-base-model decorrelation check ("one voice in triplicate") + judge-model-rotation guidance in cogito-council. Rotating onto a non-Claude judge waits on a key (#7).
6. NEXT — Wikilink + grep-backlink format — the prerequisite-graph the VR teacher walks.
7. One FREE OpenRouter non-Claude voice in the council (needs a key; still $0).
8. Obsidian "Bases"-style saved-query views.
DEFER (panel agreed): paid Fusion, local Hermes (big GPU), MCP "expose the brain" server (for the VR client later), local embedding index, the Obsidian app.

## For later (the real long-pole)
The VR teacher's hard part is the STUDENT MODEL — tracking what a learner knows over time (same temporal-validity idea as #1, but for the learner). Convene a dedicated council on it when we shift from "harden the brain" to "build the teacher".

## Guardrails (always on)
- One brain = `main`. Sync only `main` + the active branch. NEVER push to old session branches.
- `main` updates: the auto-save hook now FF-pushes to `main` (user opted in 2026-06-15; FF-only, never clobber). A human-initiated force/non-FF update to `main` still needs an explicit yes.
- Faceless: commit as `Cogito <cogito@users.noreply.github.com>`; nothing personal in artifacts.
- Verify by running/re-reading — never "probably / passed / captured."
- Talk adult-to-adult: plain, short, no jargon, no "baby steps" framing (the #critical comms lesson).

## Full context
This session's council + judge produced the roadmap above. Teacher: `docs/checkpoints/2026-06-15-ai-teacher-pivot.md`. Fixes: `docs/checkpoints/2026-06-15-consistency-fix.md`.
