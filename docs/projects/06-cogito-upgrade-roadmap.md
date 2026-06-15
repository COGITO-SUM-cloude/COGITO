# Cogito upgrade roadmap — research synthesis + ROI ranking
_2026-06-15. Distilled from a 3-lane parallel research sweep (Claude Code native features · external agent-memory frameworks · context-engineering + evals + learning science), each fanned out to deep primary-source sub-agents._

## Method
ROI = (impact on Cogito's core goal × fit with constraints) ÷ (effort + risk). Constraints, ranked against: **free, simple, private, faceless, file-portable, survives ephemeral containers, per-repo silos.** Anything needing paid plans, servers, embeddings, vector/graph DBs, or fine-tuning was excluded by constraint (see "Not portable").

## The headline finding (every lane converged here)
Cogito already *is* the architecture the field recommends: durable files as external memory, fresh sessions re-grounded from committed artifacts, sub-agents for context isolation, lessons-as-verbal-memory (textbook **Reflexion**), checkpoints (**CoALA episodic**), skills (**CoALA procedural**). So the upgrades are not new machinery — they close **three gaps Cogito's own ledger already documents as recurring scars**:
1. **It preloads everything** (the whole ledger prints every session) — collides with "context rot"; the field says **index + just-in-time retrieval**.
2. **"Verify outcomes not proxies" is prose, not a runnable artifact** — the field says **give the agent a check it can run** (a definition-of-done gate).
3. **The learning log has recap cues but no scheduler** — a file-based **spaced-repetition** ladder makes "due today" computed, not guessed.

## Ranked by ROI

| # | Upgrade | Tier | Effort | Risk | ROI |
|---|---------|------|--------|------|-----|
| 1 | **Runnable verification gate** (committed definition-of-done + "run the check, paste evidence, then claim done") | 1 | S | Low | ★★★★★ |
| 2 | **Lesson metadata: tags + importance `[I:1-10]` + date** (the embedding-free retrieval index + decay enabler) | 1 | S | Low | ★★★★★ |
| 3 | **Index-then-load / just-in-time retrieval** (grep relevant tags; always-load `#critical`; stop dumping the full ledger as it grows) | 1 | S–M | Med (load-path blast radius) | ★★★★★ |
| 4 | **Consolidation pass** (`/consolidate`: cluster→merge/supersede→archive raw w/ provenance; importance-triggered; probation buffer) | 2 | M | Med (over-merge → review git diff) | ★★★★ |
| 5 | **Decay/archive policy** (importance floor + recency + refresh-on-use; move cold low-value lessons to archive, never delete) | 2 | S–M | Low | ★★★★ |
| 6 | **CoALA taxonomy + skill INDEX + skill-creation gate** (episodic/semantic/procedural; commit a skill only after verified-in-a-real-session) | 2 | S | Low | ★★★★ |
| 7 | **Spaced-repetition for the learning log** (Leitner ladder: `due:`/`box:` frontmatter; recap the most-overdue at session start) | 2 | S | Low | ★★★★ |
| 8 | **Guard + auto-capture hooks** (PreToolUse guard for known-bad cmds e.g. self-matching pkill / branch-delete; Stop gate nags if verify not run) | 3 | M | Med-High (blast radius; verify schema vs live docs first) | ★★★ |
| 9 | **Package Cogito as a Claude Code plugin** (one-command install across repos; bundles skills+agents+hooks) | 3 | M | Low | ★★★ |
| 10 | **Fresh-context reviewer subagent + grounded-signal rule** (generalize design-qa to a done-check; CoVe questions; "self-critique only on verifiable/grounded claims") | 3 | S–M | Low | ★★★ |

## Per-item notes (what / why / source)
- **#1 Verification gate.** Anthropic Claude Code best-practices leads with "give Claude a check it can run… without it, 'looks done' is the only signal and you become the verification loop." Hamel's eval hierarchy: deterministic assertions first. Voyager adds a skill *only after* a critic verifies it. This converts our worst scars (favicon-404 miss, "captured ≠ rendered", SSO "looks live") into an enforced gate — and is the mechanical form of Lesson 3 ("knowing ≠ doing"). Sources: anthropic.com/engineering (best-practices, harnesses), hamel.dev/blog/posts/evals, Voyager (arXiv 2305.16291).
- **#2 + #3 Memory scaling.** Generative Agents retrieval = recency + importance + relevance; the relevance term is the *only* part needing embeddings, and an LLM judging relevance at read-time is **better** for a causal SYMPTOM→RULE ledger (mem0: "embeddings confuse similarity with causation"). Claude Code's own auto-memory is literally index + grep, "no embeddings." Anthropic: "context rot" + just-in-time retrieval + progressive disclosure. Tags are our index (lessons are already one-liners). Sources: Generative Agents (2304.03442), mem0.ai/blog, code.claude.com/docs/memory, anthropic.com/engineering/effective-context-engineering.
- **#4 + #5 Consolidation & decay.** Letta "sleep-time compute" (raw→learned context), Generative Agents reflection (importance-sum trigger ~150 → our ~30-50), mem0 ADD/UPDATE/DELETE/NOOP merge, ACT-R decay (recency×frequency), Soar chunking (compile recurring fixes into one rule), MemoryBank Ebbinghaus refresh-on-recall. Survey rule: **archive, don't delete; probation buffer; git diff is the validation layer.** Sources: letta.com/blog/sleep-time-compute, arXiv 2603.07670, 2305.10250.
- **#6 Library hygiene.** CoALA taxonomy (episodic=checkpoints, semantic=lessons, procedural=skills); Voyager's description-keyed index = Claude Code skill descriptions (progressive disclosure, native). Skill-creation gate = our "verify outcomes" applied to library growth. Sources: CoALA (2309.02427), Voyager.
- **#7 Spaced repetition.** Spacing effect + testing effect + expanding intervals (desirable difficulty). Leitner ladder (1→3→7→16→35→90d) is the right altitude; SM-2 later; full FSRS is over-engineering (needs a review-history dataset + floating-point math agents do unreliably). Sources: SM-2 (super-memory.com), FSRS repo, Cepeda spacing meta-analysis.
- **#8 Hooks.** Beyond SessionStart: PreToolUse can *block* a known-bad command at the boundary (the enforcer Lesson 3 wants); Stop can gate "did you verify?". Higher blast radius + some event/field names need verifying against live docs before building. Source: code.claude.com/docs/hooks.
- **#9 Plugin.** Solves per-repo silo: `claude plugin install` ships skills+agents+hooks in one step; fits the faceless/shareable ethos. Source: code.claude.com/docs/plugins.
- **#10 Verification design.** "LLMs cannot self-correct reasoning yet" (2310.01798) + the TACL survey (2406.01297): intrinsic reasoning self-correction *degrades*; channel critique to **grounded** signals (tests, user corrections, real outcomes), independent answering (CoVe 2309.11495), or critique-against-a-principles-file (Constitutional AI). A fresh-context reviewer (our design-qa, generalized) decorrelates the check from the author.

## Not portable (flagged — do NOT build)
Embeddings / vector DBs (mem0, Letta archival, A-MEM links), graph DBs (mem0g — *removed from mem0 itself in v3 anyway*; Zep/Graphiti needs Neo4j), running servers/daemons (Letta sleeptime daemon), routines / dynamic workflows / agent-teams (paid plans), full FSRS optimizer (needs review-history data + a Python package). For all of these, **the LLM-as-retriever over tagged plain files is the free substitute** — and for a causal ledger it's arguably better than vector similarity.

## Process caveat (a lesson from the research itself)
The 3 launched agents fanned out into ~30 sub-agents, several redundant (5+ on mem0/Letta) and some truncated by the session rate limit. Coverage was robust *because* of the redundancy, but it was wasteful. Captured as a ledger lesson: cap recursive fan-out; assign disjoint topics.

## Build order (risk-aware)
Tier 1 first, lowest-blast-radius first: **#1 verify gate → #2 metadata convention → #3 index-then-load (carefully, keep full-load as the safety net + verify the hook) → #4/#5 consolidation+decay → #6/#7 → then Tier 3.**
