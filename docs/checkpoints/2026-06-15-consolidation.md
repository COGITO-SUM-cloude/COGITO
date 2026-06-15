# Checkpoint — Cogito upgrade #4: consolidation pass (2026-06-15)

## Mission
Implement the upgrade roadmap (`docs/projects/06-cogito-upgrade-roadmap.md`) down the ROI list.
This session: roadmap item **#4 — the consolidation pass** (mechanism + first verified run).

## Decisions made (canonical, verified)
- **Consolidation is a standalone skill, not prose in the protocol.** New skill
  `skills/cogito-consolidate/SKILL.md` holds the full procedure (trigger → cluster →
  classify duplicate/superseded/distinct → merge into one higher-tier tagged rule →
  MOVE raw lines to archive with provenance → conservation check). Keeps the always-loaded
  protocol lean; matches the CoALA-procedural direction of #6; progressive disclosure.
- **Archive lives at `skills/cogito-protocol/LESSONS-ARCHIVE.md`** — co-located with the
  ledger but NEVER loaded: the hook/sync copy and grep only `LESSONS.md`, so archived
  lines stop entering context (the goal) while staying as auditable provenance.
- **Probation buffer = position.** Lessons are appended at the bottom; don't consolidate
  the most-recent ~5 / current+prior session's lessons — they must settle first.
- **`#critical` / `[I:≥9]` consolidated rules stay LIVE** (always-load); only the verbose
  raw captures get archived.
- **The conservation check is the gate** (our #1, applied to the librarian job):
  `new_live == old_live − archived + new_consolidated`, raw lines verbatim in archive,
  `git diff` reviewed for over-merge. Not optional.

## Current state — what exists, where
- `skills/cogito-consolidate/SKILL.md` — the consolidation procedure (NEW).
- `skills/cogito-protocol/LESSONS-ARCHIVE.md` — archive + pass-log (NEW); holds the 2 raw
  security-classifier lines moved out by the first pass.
- `skills/cogito-protocol/LESSONS.md` — first pass applied: the 2 security captures merged
  into one `[#security][#boundary] [I:9]` rule; +1 new lesson on the edit-newline scar.
  **Loads cleanly at 44 `- ` lines** (43 after the merge, +1 captured this session).
- `skills/cogito-protocol/SKILL.md` §4b — now points at the `cogito-consolidate` skill +
  the archive file + the probation/conservation guards.
- `docs/ACTIVE-MISSION.md` — #4 marked DONE; NEXT = #5 decay/archive.
- On `main` (the #4 commit was fast-forwarded from the session branch onto main mid-session, at the user's request; the session branch is now redundant).

## Verification (evidence, not assertion — §5b)
- `grep -c '^- '` → 43 live + 2 archived right after the merge; conservation `43 = 44 − 2 + 1` held.
- Ran the real `scripts/cogito-sync.sh`: "brain loaded — 43 lessons now in context"; the
  consolidated rule was among the printed lessons. Load path intact.
- The gate **caught a real bug**: a line-delete welded two neighbouring lessons into one
  physical line (count read 42, not 43). Fixed by restoring the newline; re-verified.

## Next actions (go down the list)
#5 decay/archive policy (importance floor + recency + refresh-on-use; move cold low-value
lessons to the same archive) → #6 CoALA taxonomy + skill INDEX + skill-creation gate →
#7 spaced-repetition for the learning log. Then with extra care: #3 index-then-load, #8 hooks.
Then Tier 3: #9 plugin, #10 reviewer subagent.

## Corrections / guardrails to remember
- To delete a whole line with Edit, match the **trailing** newline (`text\n`→``), never a
  leading one — a leading-`\n` match welds the neighbours. Re-grep the count after any
  structural ledger edit; content greps alone miss line-structure corruption.
- Sync only `main` + the working branch; never push old session branches.
- Faceless commits as `Cogito <cogito@users.noreply.github.com>` (live git config reverts to
  `Claude` each container — reset it before committing).
- New lessons use the tagged `[#tag] [I:n]` format; consolidation never deletes, only moves.
