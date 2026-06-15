---
name: cogito-council
description: Free, Claude-only multi-model deliberation — the "council". Fan a hard or high-stakes question out to several Claude panelists with deliberately DISTINCT lenses (answering independently, in parallel), then a judge compares them — consensus, contradictions, coverage gaps, unique insights, blind spots (the OpenRouter Fusion judge structure) — and you synthesize the final answer. Use when one pass isn't enough — research, expert critique, compare-and-contrast, design or architecture calls, anything where being wrong is costly. NOT for everyday questions (each run spends several agent calls). The free precursor to OpenRouter Fusion; same shape, so it upgrades cleanly to a real cross-provider panel later. Triggers — "/council", "convene the council", "get multiple opinions", "deliberate on this", "fusion this".
---

# Cogito Council (free, Claude-only multi-model deliberation)

OpenRouter's **Fusion** ensembles *different companies'* models (Claude + GPT +
Gemini) plus a judge. We can't do cross-provider for free — but the *structure*
(panel → judge → synthesize) carries most of the gain, and we can run it today
with Claude sub-agents at zero extra cost. This is the **free council**: the same
shape as Fusion, so when money or a stronger free model arrives, it swaps in
without changing how you work (§Upgrade path).

This is not new machinery — it is the pattern this repo already runs (parallel
research agents; the `cogito-reviewer` decorrelating a check), named and made
repeatable.

## When to convene it
- High-stakes or ambiguous questions where one answer isn't enough: research,
  expert critique, "compare and contrast", architecture/design calls — anything
  where the cost of being wrong outweighs a few extra agent calls.
- **Not** for everyday/tactical questions — a council spends several sub-agent
  calls. One good direct answer beats a needless council.

## The procedure
1. **Sharpen the question.** State it in one or two checkable sentences plus what
   a good answer must cover. A vague prompt produces a noisy panel.
2. **Convene the panel — independent + diverse.** Spawn 3–5 panelists **in a
   single message** so they run in parallel — each a `general-purpose` agent given
   a DISTINCT lens, told to answer **independently** and not assume other agents
   exist. All share one base model, so diversity comes from the lenses, not the
   weights:
   - rotate lenses like **pragmatist / skeptic / first-principles / domain-expert
     / contrarian**, or roles natural to the question;
   - vary **effort** (a couple deep, one fast) and framing;
   - require each to ground its claims (a check, a source, a real constraint) and
     to name its own confidence and blind spots.
3. **Judge — don't average.** Hand all panel answers to the **cogito-judge**
   subagent (or, until it has loaded, a `general-purpose` proxy carrying the judge
   role). It returns the Fusion-style comparison: **consensus** (treat as
   higher-confidence), **contradictions**, **coverage gaps**, **unique insights**,
   **blind spots none caught**, and a recommended synthesis.
4. **Synthesize + verify.** Write the final answer from the judge's analysis: lead
   with consensus, surface the live contradictions honestly, fold in the best
   unique insight, address the blind spots. Verify any grounded claim (§5b) before
   presenting it as fact.

## Distinctness is the whole game (the Claude-only caveat)
One model answering five times helps only if the five are genuinely independent
and differently aimed. Enforce it: don't let panelists see each other, give each a
real lens, ask each for its dissent and its uncertainty. A council that converges
because everyone framed the question the same way is theatre — the value is in the
disagreement the judge can then weigh.

**Decorrelate the judge too.** The judge shares the panel's base model, so it can
inherit the same blind spots. When you can, run the judge on a DIFFERENT model than
the panel — a different Claude model now (pass `model:` when spawning `cogito-judge`),
a non-Claude model once a key exists. A decorrelated judge is the cheapest way to
catch the "one voice in triplicate" the panel cannot see in itself.

## Upgrade path (→ real OpenRouter Fusion, later)
When a paid OpenRouter key — or a strong free non-Claude model — is available,
replace one or more panelists with a call to `openrouter/fusion` (or a specific
GPT/Gemini model); the judge and synthesis steps are unchanged.

**Now wired (free tier):** `scripts/cogito-openrouter.sh` calls a free non-Claude
model (default `deepseek/deepseek-r1:free`), reading the key from the
`$OPENROUTER_API_KEY` environment secret — never argv, never a file. Use it as ONE
panelist: pipe the sharpened question into it and hand its answer to `cogito-judge`
alongside the Claude panelists (this is the decorrelated voice that cures "one
voice in triplicate"). With no key set it exits cleanly and the council stays
Claude-only — so it is always safe to call. Phase 3 (run a
panel of local models on your own machine) needs stronger hardware but the
procedure is identical. The council is built so *how you use it* never changes as
the panel behind it gets stronger.
