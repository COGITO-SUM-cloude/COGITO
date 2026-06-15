# ACTIVE MISSION — resume pointer
_Short on purpose: read into every session, costs tokens each turn. Talk adult-to-adult: plain, short, no jargon, no "baby steps" (the user is non-technical but NOT a child)._

When the user says "Cogito": greet in one line, confirm, continue. Don't re-interview.

## Mission — make the brain as POWERFUL as possible, then the VR teacher is easy
Harden + upgrade Cogito's memory (file-based, no vector DB, low context-tax) so a future VR/3D AI teacher is easy to build. Execute the council's ROI-ranked list, best payoff first. Every pick is $0 + file-native.

## Foundation already in place (2026-06-15)
- ONE canonical brain on `main`; the SessionStart hooks load from `origin/main`, not the session branch (cross-session consistency — fixed + verified).
- Brain AUTO-SAVES at turn end (Stop hook `scripts/cogito-converge.sh`): brain files only, commits + pushes to the BRANCH so lessons survive. It does NOT auto-push to main (main needs an explicit "update main"). Opt-in hands-off main: `COGITO_CONVERGE_TO_MAIN=1` (FF-only). Kill switch: `COGITO_AUTO_CONVERGE=0`.

## Council-ranked roadmap — go down the list
1. DONE — supersession: a corrected lesson consolidates/archives the old one so only the current rule loads (fixed a verified contradiction; conservation gate passed).
2. DONE — Stop-hook auto-save (above).
3. NEXT — `UserPromptSubmit` hook: auto-pull only the 1-3 lessons matching the prompt's keywords (biggest context-tax win). [edits a startup file -> needs an explicit yes]
4. Verify-before-store gate: a lesson always-loads only after it recurs/confirms.
5. Sharpen + rotate the council JUDGE (use a non-Claude model for it once a key exists).
6. Wikilink + grep-backlink format — the prerequisite-graph the VR teacher walks.
7. One FREE OpenRouter non-Claude voice in the council (needs a key; still $0).
8. Obsidian "Bases"-style saved-query views.
DEFER (panel agreed): paid Fusion, local Hermes (big GPU), MCP "expose the brain" server (for the VR client later), local embedding index, the Obsidian app.

## For later (the real long-pole)
The VR teacher's hard part is the STUDENT MODEL — tracking what a learner knows over time (same temporal-validity idea as #1, but for the learner). Convene a dedicated council on it when we shift from "harden the brain" to "build the teacher".

## Guardrails (always on)
- One brain = `main`. Sync only `main` + the active branch. NEVER push to old session branches.
- `main` is protected: any update to it needs the user's explicit yes to that exact action. The auto-save hook respects this (branch only by default).
- Faceless: commit as `Cogito <cogito@users.noreply.github.com>`; nothing personal in artifacts.
- Verify by running/re-reading — never "probably / passed / captured."
- Talk adult-to-adult: plain, short, no jargon, no "baby steps" framing (the #critical comms lesson).

## Full context
This session's council + judge produced the roadmap above. Teacher: `docs/checkpoints/2026-06-15-ai-teacher-pivot.md`. Fixes: `docs/checkpoints/2026-06-15-consistency-fix.md`.
