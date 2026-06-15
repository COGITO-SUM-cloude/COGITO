# Checkpoint — pivot to building the personalised AI Teacher (2026-06-15)

## The decision (canonical)
Start building the **personalised AI teacher NOW** — this session's earlier council said
"defer the VR tutor," and the user supplied decisive new factors that correctly reverse it:
- The brother **already gets help at school**, so the home teacher is a long-term
  **supplement**, not his only lifeline — it doesn't have to work this month.
- The user **accepts a multi-year timeline** and judges starting ASAP the best ROI.
- **Structure-first, tailored to the USER first** (the available, motivated tester): build
  and prove the "golden structure" on himself — *this needs no VR headset and no fast
  hardware* — then reuse that structure for the brother (swap the learner + add child
  scaffolding) and for anyone. Even if it never reaches the brother, it's useful to the user.
- **30-day Claude Pro window** — build aggressively; do NOT optimize tokens until the user
  says they're token-limited.

## The user (context that matters)
Only English speaker in the family, only one to finish middle + high school, off to college
in the fall. Carrying a lot; highly capable, self-taught, motivated. Non-technical for code —
keep replies plain and short; do the tech for him (a #critical ledger lesson).

## Proposed "golden structure" for the AI teacher (to council-test, then build next session)
Presentation-agnostic (text now, VR later) and learner-agnostic (user now, brother later):
1. **Learner Profile** — one file: current level per skill, goals, interests, what
   works/doesn't, pace, accommodations. (User's first; brother's later, same shape.)
2. **Adaptive Lesson Loop** (the engine, text/dialogue now): assess the next step → teach ONE
   small piece at their level → check understanding (retrieval) → adjust (reteach differently
   if missed, advance if got it) → log it.
3. **Progress Memory** — what's taught / what stuck / what's due for review (spaced repetition).
4. **Content Engine** — generate the lesson material at the right level (Claude + Cogito).
5. **Presentation Layer (LATER)** — text now; VR/3D visuals + "read the room" is a *skin* on
   top of the same 1–4; swapping it must not change the structure.

**Key insight:** Cogito ALREADY seeds this for the user — the `adaptive-learning` skill is the
Loop, and `docs/learning/log.md` is the Progress Memory + spaced repetition. So the teacher is
an *extension/formalization* of what Cogito already does for the user, not a build from zero.
The brother's version reuses 1–4 with a child-scaffolded, decoding-first profile (NOT the adult
skill — see ledger lesson) + the placement results.

## Current state — what exists, where
- **Council** (decision tool, built + proven this session): `skills/cogito-council/SKILL.md` +
  `.claude/agents/cogito-judge.md` (now a live subagent). Phase 2 = real OpenRouter Fusion when
  the user has a paid key.
- **Lean loading** done: ledger in index mode, ~1.4k tok/turn (was ~6.2k). `scripts/cogito-budget.sh`.
- **Brother placement check** built + delivered: `docs/teaching/01-placement-check.md` — awaiting
  the user running it with him → results → build his Week 1.
- **Data export** (job 1): ChatGPT export started (free, ~7-day delay, link expires 24h);
  DeepSeek via browser extension or `service@deepseek.com`. Still to verify + clean into Cogito.
- Branch `claude/confident-wright-mg519n`, all pushed.

## Next session — START HERE
1. Convene the council (fresh full window) on the **AI-teacher architecture** above:
   pressure-test the golden structure, the build order, and the "prove on user → adapt to
   brother / add VR" sequence.
2. Then build **v0 of the file-based teacher tailored to the user** (pick the user's subject —
   his learning log points at neuroscience / cognition), reusing `adaptive-learning` + the
   learning log as the seed. Make it a real, runnable loop, not a doc about one.
3. Keep the 3 Pro-window jobs alive in parallel: finish the data export+clean; the one capped
   cognition-research file; the brother's Week 1 when his placement results arrive.

## Corrections / guardrails carried forward
- A council's verdict is only as good as the factors it's given; the user can override it with
  new information (this pivot is the example). Get full goals+constraints before convening.
- 30-day Pro: build big, don't token-optimize until told.
- Structure-first; presentation (VR) and the specific learner are swappable layers, not the core.
- Plain words for the user; faceless commits; #critical guardrails always loaded.
