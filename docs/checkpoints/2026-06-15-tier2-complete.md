# Checkpoint — Cogito Tier 2 complete (#4–#7) + finish-line review (2026-06-15)

## Mission
Implement the Cogito upgrade roadmap (`docs/projects/06-cogito-upgrade-roadmap.md`)
down the ROI list. This session shipped **all of Tier 2: #4, #5, #6, #7** (Tier 1
was done in the prior session). Per-item detail for #4 and #5 lives in their own
checkpoints; this is the milestone record.

## What now exists (verified)
- **#4 Consolidation** — `cogito-consolidate` skill (`/consolidate`) +
  `scripts/cogito-consolidate.sh` (`report` clusters by tag; `verify` =
  conservation gate) + `LESSONS-ARCHIVE.md` (loader never reads it).
- **#5 Decay** — `scripts/cogito-decay.sh` (`report` cold+low-value candidates;
  `touch` = refresh-on-use). Safety floor: only *explicitly* low-importance
  lessons decay; unscored are kept. Reuses #4's archive + gate.
- **#6 Library hygiene** — `skills/INDEX.md` (CoALA memory-type map +
  description-keyed skill catalog) + `scripts/cogito-skill-check.sh` (frontmatter
  + index gate, states the Voyager "verified-in-a-real-session" rule) + protocol §4c.
- **#7 Spaced repetition** — `box:N due:DATE` Leitner ladder on each learning-log
  lesson + `scripts/cogito-review.sh` (`due`/`list`/`grade`) + a guarded,
  non-fatal SessionStart-hook block that surfaces the most-overdue recap cue.
- Protocol §4b/§4c carry the operative rules; `install.sh` seeds the archive.
- All on `claude/confident-wright-mg519n`, pushed (commits 8b5e7b8 → c6b7ea1).
- Lessons ledger: 46 (two scars captured this session — see Critique).

## Finish-line review (§7)
**Progress.** Tier 2 went from a ranked plan to four working, tested mechanisms in
one session. Memory can now stay lean without losing anything: merge duplicates
(#4), retire cold low-value lessons (#5) — both behind a runnable conservation
gate that refuses to drop a line; the library is catalogued and gated against
unverified skills (#6); and the human's learning log is now on a real
spaced-repetition schedule that surfaces itself at session start (#7). Six new
scripts/skills, all verified by running them, not by reading them.

**Critique (unflinching).** Two self-inflicted scars, both from trusting "looks
right" over running it: (1) #4's conservation gate *false-failed its own pass case*
because grep parsed `-`-prefixed lesson text as flags — a gate that always fails
would have blocked every real consolidation; caught only by exercising both paths.
(2) In #7 I ran `git checkout -- log.md` to undo a test grading and silently
discarded my uncommitted feature edits (the `box:`/`due:` fields) in the same file
— I'd verified #4 by committing first, then forgot my own discipline three items
later. Also: I lean on a static trigger (~60) and a 90-day cold window that are
guesses, not yet tuned to real data.

**Solutions (now durable).** Both scars are captured as tagged lessons:
`[#verify][#shell]` test a gate's pass AND fail paths; `[#git][#process]` commit
feature edits before testing mutations in the same file, never `git checkout` a
file holding uncommitted work. The "knowing ≠ doing" gap is the meta-pattern — the
fix is the same if-then binding the protocol already preaches (verify gate fires
*before* the done-claim; commit *before* the test).

**Recommendations.** The remaining items split by risk:
- *Safe (do next):* #10 fresh-context reviewer subagent (decorrelates verification
  — directly addresses the "looks right" scar above); #9 plugin packaging.
- *Risky (confirm + verify hard):* #3 index-then-load and #8 hooks both touch the
  load path / tool boundary. The binding constraint for the whole system is still
  the session boundary and the load path — so these are high-value but must keep
  full-load as a safety net and be proven before trust. Do them deliberately, ideally
  in a fresh session, not at the tail of a long one.

## Next actions
Proceed with the safe Tier-3 items (#10 then #9). Hold #3 and #8 for an explicit
go-ahead and extra verification (load-path blast radius).

## Corrections / guardrails
- Sync only `main` + the working branch; never old session branches.
- Verify by running; commit feature work before testing mutations on the same file.
- Faceless commits as `Cogito <cogito@users.noreply.github.com>`.
- Pruning bias (consolidate + decay): when in doubt, keep.
