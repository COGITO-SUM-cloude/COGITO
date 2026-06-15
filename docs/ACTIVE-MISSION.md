# ACTIVE MISSION — resume pointer
_Surfaced at session start so a new session resumes instantly. Delete/replace when the mission changes._

## When the user says "Cogito"
Greet in one line, confirm the mission below, and continue. Do NOT re-interview from scratch.

## Mission — multi-model deliberation ("the council"), in 3 phases
The user wants a "panel of AIs answer → a judge compares → synthesize one better answer"
capability (OpenRouter's **Fusion** is the paid product). Plan, in their words:
1. **NOW — free Claude-only council.** Build it with Claude sub-agents (zero extra cost).
2. **LATER — real OpenRouter Fusion.** Swap in cross-provider models (GPT/Gemini) when
   there's budget *or* a strong free non-Claude model worth adding. Needs the user's paid
   OpenRouter API key (set as an env secret like `COGITO_TOKEN`; never committed).
3. **EVENTUALLY — local.** Run a panel of local models on the user's own machine, once
   they have stronger hardware (their current laptop — ChromeOS, i3, 4GB RAM — can't run
   local LLMs, but the cloud council doesn't need it).
The capability is built so **how you use it never changes** across phases — only the
line-up of models behind the panel gets stronger.

## Where we are
- **Phase 1 — DONE (this session):** `skills/cogito-council/SKILL.md` (the panel→judge→
  synthesize procedure, Fusion-shaped, with the upgrade path) + `.claude/agents/cogito-judge.md`
  (the judge: consensus / contradictions / coverage / unique insights / blind spots +
  synthesis). Registered in `skills/INDEX.md`. The panel→judge pattern is already proven
  live in this repo (the 3-lane research fan-out; the cogito-reviewer audits).
- **NEXT:** phase 2 (real Fusion) is gated on the user's budget/key — do not start until
  they say go. `openrouter.ai` is reachable from this env; the `openrouter-mcp` npm package
  exists; `claude mcp add` works here — but the durable, faceless wiring is a repo `.mcp.json`
  entry reading `OPENROUTER_API_KEY` from env (key set by the user, never committed).

## Prior mission — DONE
The Cogito upgrade roadmap (all 10 items, `docs/projects/06-cogito-upgrade-roadmap.md`)
shipped + verified on 2026-06-15. Final checkpoint: `docs/checkpoints/2026-06-15-roadmap-complete.md`.

## Guardrails (hard-won)
- Sync ONLY `main` + the active working branch; never old session branches.
- Verify by running, not reading. Commit feature edits BEFORE testing mutations on the same file.
- Test a gate/guard on BOTH pass and fail paths, and against inputs that merely *mention* what it blocks.
- A new skill/agent is memory only after it works in a real session (`scripts/cogito-skill-check.sh`).
- Faceless commits as `Cogito <cogito@users.noreply.github.com>`; nothing personal in artifacts.
- Plain words for this user — short, adult-to-adult, no jargon, do the tech yourself.
- Never put a secret (API key) in a command or a commit; read it from env, set by the user.

## Full context
Roadmap: `docs/projects/06-cogito-upgrade-roadmap.md` · Council: `skills/cogito-council/SKILL.md`
