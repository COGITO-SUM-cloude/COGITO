# Checkpoint — Cogito upgrade #4: consolidation pass (2026-06-15)

## Mission
Implement the Cogito upgrade roadmap (`docs/projects/06-cogito-upgrade-roadmap.md`)
down the ROI list. This session: roadmap item **#4 — consolidation pass**.

## Decisions made (canonical, verified)
- **#4 is a mechanism, not a merge.** The ledger is at 45 lessons; the
  consolidation trigger is ~60. Forcing a merge on a small ledger is exactly the
  "over-merge" risk the roadmap flags, so this session *built and proved* the
  mechanism and ran **no** real merge.
- **Archive = a separate file the loader never reads.** The session loader
  (`scripts/cogito-sync.sh`) greps `^- ` from `LESSONS.md` only. So moving a raw
  lesson into `LESSONS-ARCHIVE.md` removes it from context automatically — this is
  the mechanism #4 needs and that #5 (decay) will reuse. Nothing is deleted; git
  keeps the deeper history.
- **The gate is the safety layer.** `cogito-consolidate.sh verify` enforces one
  invariant: every `- ` line removed from the active ledger must reappear verbatim
  in the archive (exit non-zero otherwise). This is §5b's runnable gate applied to
  memory surgery. Tested live on PASS, FAIL, and no-op paths.

## Current state — what exists, where
- `skills/cogito-consolidate/SKILL.md` — the `/consolidate` procedure (mem0
  ADD/UPDATE/MERGE/NOOP + Soar chunking; probation buffer = most-recent ~5 exempt;
  archive-with-provenance; bias = when in doubt, NOOP).
- `scripts/cogito-consolidate.sh` — `report` (cluster by tag, trigger check) and
  `verify` (conservation gate). Executable; both paths verified.
- `skills/cogito-protocol/LESSONS-ARCHIVE.md` — seeded, empty of lessons; format
  documented (raw `- ` lines stay at column 0 so the gate matches them verbatim).
- `skills/cogito-protocol/SKILL.md` §4b — now points at the runnable mechanism
  (skill + helper + archive + verify + probation), not just prose.
- `install.sh` — seeds/preserves `LESSONS-ARCHIVE.md` like the ledger.
- `skills/cogito-protocol/LESSONS.md` — 45 lessons (added the grep `--` scar).
- Commits on `claude/confident-wright-mg519n` (and to be pushed there).

## Compact finish-line review (#4)
- **Progress:** went from "consolidation described in §4b prose" to a runnable,
  tested mechanism: a `/consolidate` skill, a deterministic conservation gate
  (3 paths verified), an archive wired into the loader's blind spot, protocol +
  installer updated. Ledger never at risk (no merge run).
- **Critique:** two self-inflicted bugs caught only by *running* the gate — (1)
  `report` counted a `[#tag]` token from documentation prose, not a real lesson;
  (2) the gate false-FAILED its own PASS case because `grep` parsed `-`-prefixed
  lesson text as options. Either could have shipped if I'd trusted "looks right."
- **Solutions → captured:** scan only `^- ` lines when extracting tags; end grep
  option parsing with `--` for data that may start with `-`; **always test a
  gate's pass AND fail paths.** Last point is now a ledger lesson `[#verify][#shell]`.
- **Recommendation:** #5 (decay) is the natural next step — it reuses this exact
  archive + gate. Keep the same discipline: build the mechanism, prove it, don't
  let it touch live lessons until a trigger fires.

## Next actions (down the list)
#5 decay/archive policy (importance floor + recency + refresh-on-use; move cold
low-value lessons to `LESSONS-ARCHIVE.md`) → #6 CoALA taxonomy + skill-creation
gate → #7 spaced-repetition for the learning log. Then with extra care: #3
index-then-load, #8 hooks. Then Tier 3: #9 plugin, #10 reviewer subagent.

## Corrections / guardrails to remember
- Sync only `main` + the active working branch (`claude/confident-wright-mg519n`);
  never push old session branches (a stale sync once resurrected a deleted one).
- Verify by running, not by reading — this session proved it twice over.
- Faceless commits as `Cogito <cogito@users.noreply.github.com>`.
- Over-merge, not under-merge, is the consolidation failure mode: when in doubt, NOOP.
