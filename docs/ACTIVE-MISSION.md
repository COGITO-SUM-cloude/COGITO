# ACTIVE MISSION — resume pointer
_Surfaced at session start so a new session resumes instantly. Delete/replace when the mission changes._

## When the user says "Cogito"
Do NOT re-interview from scratch — the mission is already specced. Greet in one line, confirm, then CONTINUE down the list.

## Mission
Implement the Cogito upgrade roadmap in `docs/projects/06-cogito-upgrade-roadmap.md`, going down the ROI-ranked list.

## Where we are (2026-06-15)
- **DONE (Tier 1):** #1 runnable verification gate (SKILL §5b); #2 lesson tags + importance `[I:1-10]` convention.
- **DONE (Tier 2):** #4 consolidation pass + #5 decay/archive policy — one ledger-maintenance skill (`cogito-consolidate`, `/consolidate`) + two helpers: `scripts/cogito-consolidate.sh` (`report` clusters by tag; `verify` = conservation gate, every removed lesson must reappear in the archive) and `scripts/cogito-decay.sh` (`report` cold+low-value candidates; `touch` = refresh-on-use stamps `[seen:DATE]`). Both write to `LESSONS-ARCHIVE.md`, which the loader never reads, so retiring a lesson drops it from context without losing it. Wired into SKILL §4b + install.sh. **Mechanism only** — ledger below the ~60 trigger; decay's safety floor retires only *explicitly* low-importance lessons (none exist yet), so nothing was retired. Every path tested live.
- **DONE (Tier 2 cont.):** #6 CoALA taxonomy + skill index + skill-creation gate — `skills/INDEX.md` (memory-type map: episodic=checkpoints, semantic=lessons, procedural=skills, working=context+ACTIVE-MISSION; + a description-keyed skill catalog) + `scripts/cogito-skill-check.sh` (runnable gate: frontmatter + listed-in-INDEX checks, states the Voyager/§5 "verified-in-a-real-session" rule) + protocol §4c. Audit passes all 4 skills; the bogus-name and unindexed-skill fail-paths verified.
- **DONE (#7):** spaced-repetition for the learning log — Leitner ladder (`box:N due:DATE`, 1/3/7/16/35/90d) on each log lesson; `scripts/cogito-review.sh` (`due`/`list`/`grade`); the SessionStart hook now surfaces the most-overdue recap cue (guarded, non-fatal — the lesson-load path is untouched). Verified live incl. the hook. **→ Tier 2 COMPLETE.**
- **DONE (#10):** fresh-context reviewer subagent (`.claude/agents/cogito-reviewer.md`) + protocol §5c grounded-signal rule + INDEX agents section. Proven live via a `general-purpose` proxy that independently re-verified this session's work against git + the scripts — and correctly **FAILED** an over-claim until the push landed (decorrelation working as designed). Invokable by `subagent_type` after the next session reload.
- **REMAINING:**
  - *Safe (Tier 3, low risk):* #9 package Cogito as a Claude Code plugin (one-command install across repos; bundles skills + agents + hooks).
  - *RISKY — confirm + verify hard before starting:* #3 index-then-load (touches the SessionStart **load path**); #8 guard/auto-capture hooks (PreToolUse/Stop — tool boundary). A memory system that fails to load its lessons is the worst outcome — keep full-load as the safety net and prove any change before trusting it.

## Guardrails (hard-won this session)
- Sync ONLY `main` + the active working branch. NEVER push to old session branches — a stale push resurrects deleted ones.
- Verify every change by re-reading/running it (SKILL §5b). Never trust "probably / build passed / captured."
- Faceless: commit as `Cogito <cogito@users.noreply.github.com>`; nothing personal in artifacts.
- New lessons use the tagged format: `[#tag] [I:1-10] SYMPTOM -> ROOT CAUSE -> RULE`.

## Full context
Roadmap: `docs/projects/06-cogito-upgrade-roadmap.md` · Latest checkpoint: `docs/checkpoints/2026-06-15-tier2-complete.md`
