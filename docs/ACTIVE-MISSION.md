# ACTIVE MISSION — resume pointer
_Kept short on purpose: this file is `cat` into every session, so it costs tokens every turn._

When the user says "Cogito": greet in one line, confirm the mission, continue. Don't re-interview.

## Mission — multi-model deliberation ("the council"), 3 phases (the user's plan)
1. **NOW — free Claude-only council.** DONE: `skills/cogito-council/SKILL.md` + `.claude/agents/cogito-judge.md` (panel→judge→synthesize, Fusion-shaped). Verified live; used twice for real decisions.
2. **LATER — real OpenRouter Fusion** (cross-provider GPT/Gemini): gated on the user's budget/paid key. `openrouter.ai` reachable; `openrouter-mcp` exists; wire via repo `.mcp.json` reading `OPENROUTER_API_KEY` from env (key set by user, never committed).
3. **EVENTUALLY — local**, once the user has stronger hardware.

## Where we are
- Council shipped (phase 1). Then, to protect the user's metered plan, trimmed the per-session
  context tax: 5 must-know lessons tagged `#critical` (always load), ledger flipped to **index mode**
  (`COGITO_LOAD_THRESHOLD` default lowered to 20), mission file slimmed. Measure with `scripts/cogito-budget.sh`.
- **NEXT options:** phase 2 (needs the key); or keep using the council on real work.

## Prior mission — DONE
The 10-item Cogito upgrade roadmap (`docs/projects/06-cogito-upgrade-roadmap.md`), shipped + verified
2026-06-15. Checkpoint: `docs/checkpoints/2026-06-15-roadmap-complete.md`.

_(The hard-won guardrails now live as `#critical` lessons in the ledger — always loaded — so they're not repeated here.)_
