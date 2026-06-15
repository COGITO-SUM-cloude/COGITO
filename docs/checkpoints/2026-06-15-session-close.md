# Checkpoint — Cogito upgrade session close (2026-06-15)

## Mission
Implement the Cogito upgrade roadmap (`docs/projects/06-cogito-upgrade-roadmap.md`)
down the ROI list. **This session shipped 6 of the 8 remaining items:** #4, #5, #6,
#7 (Tier 2) and #10, #9 (the two low-risk Tier-3 items). Only #3 and #8 — both
load-path/tool-boundary risky — are left, deliberately gated.

## What now exists (all committed + pushed, branch `claude/confident-wright-mg519n`)
- **#4 consolidate / #5 decay** — `cogito-consolidate` skill + `scripts/cogito-consolidate.sh`
  (report/verify conservation gate) + `scripts/cogito-decay.sh` (report/touch) +
  `LESSONS-ARCHIVE.md`. Lean-without-loss memory maintenance behind a runnable gate.
- **#6 library hygiene** — `skills/INDEX.md` (CoALA map + skill/agent catalog) +
  `scripts/cogito-skill-check.sh` + protocol §4c.
- **#7 spaced repetition** — Leitner `box:/due:` on the learning log +
  `scripts/cogito-review.sh` + a guarded SessionStart recap block.
- **#10 reviewer** — `.claude/agents/cogito-reviewer.md` + protocol §5c grounded-signal rule.
- **#9 plugin** — `.claude-plugin/plugin.json` + `marketplace.json` + `hooks/hooks.json`.
- Two new lessons captured (ledger 46): the grep `--` gate scar and the
  `git checkout` clobber scar.

## Finish-line review (§7) — whole session
**Progress.** Cogito went from "Tier 1 done" to a near-complete roadmap in one
session: memory now prunes itself without loss, the library is catalogued and
gated, the human's learning log schedules its own reviews, a fresh-context reviewer
decorrelates verification, and the whole system is installable as a plugin. ~10
new files, 12 commits, every one pushed.

**Critique.** Three "looks-right" scars, all caught by *running*, not reading:
(1) #4's gate false-failed its own pass path (grep parsed `-` as a flag);
(2) in #7 a `git checkout` wiped my own uncommitted feature edits;
(3) I called #10 "done + pushed" when it was only committed — the decorrelated
reviewer (#10 itself) caught it. The through-line is the knowing–doing gap
(learning-log Lesson 3): I *had* the rules loaded and still slipped until a check
fired at the moment of acting.

**Solutions (durable).** Both #1 and #2 are now tagged ledger lessons. #3 is the
mechanical case *for* #10, which already paid for itself by catching a real gap.
The standing fix is the same if-then the protocol preaches: the gate fires *before*
the done-claim; commit *before* the test.

**Recommendations.** Do **#3 (index-then-load)** and **#8 (hooks)** in a *fresh*
session, not at the tail of this one. Both touch the binding constraint — the
session boundary + the load path — where a quiet break means the system stops
loading its own lessons (the worst outcome). Approach: change behind a flag, keep
full-load as the fallback, and prove with `cogito-reviewer` + a real new-session
load before trusting. The plugin (#9) install+restart load is also worth a live
confirm next session.

## Next actions
- HOLD #3 + #8 for an explicit go-ahead; do them fresh, verify-hard.
- Optional: live-confirm the plugin installs (`/plugin marketplace add … ` →
  `/plugin install cogito@cogito`) in a real session.

## Corrections / guardrails
- Sync only `main` + the working branch; never old session branches.
- Verify by running; commit feature work before testing mutations on the same file.
- Faceless commits as `Cogito <cogito@users.noreply.github.com>`.
- Pruning bias: when in doubt, keep. Load-path changes: prove before trust.
