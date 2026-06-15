# Cogito — Lessons Archive (consolidated / retired raw lessons)

This file holds raw lessons that a consolidation pass (skill: `cogito-consolidate`)
has **merged or superseded** into a higher-tier rule in the active ledger
(`LESSONS.md`). Nothing here is deleted — archiving keeps the specific, causal
detail while removing it from the always-loaded set, so the active ledger stays
small and the session-start load stays cheap. Git history is the deeper backstop.

The session loader reads only `LESSONS.md` (`grep '^- '`), so lines parked here no
longer load into context — that is the whole point of archiving.

## How an entry gets here
A consolidation pass cuts a raw `- ...` lesson line **verbatim** out of `LESSONS.md`
into the matching block below, under the higher-tier rule that now supersedes it.
The active rule cites these lines as provenance (e.g. "consolidates 3 process
scars"). The runnable gate `scripts/cogito-consolidate.sh verify` enforces the
invariant: every line removed from the active ledger must reappear here — no
lesson is ever lost, only relocated.

Format of each archived block (the raw `- ` lines stay at **column 0** — they are
moved *verbatim*, so `scripts/cogito-consolidate.sh verify` can match them against
the lines removed from the active ledger; only the `###` header and the `>` quote
are added around them):

    ### <YYYY-MM-DD> — <short cluster name>
    > superseded by: <the merged higher-tier rule, quoted>

    - <raw lesson line, verbatim>
    - <raw lesson line, verbatim>

---

## Archived lessons

_(none yet — the active ledger is still below the consolidation trigger. The
mechanism is in place; the first real pass runs when `LESSONS.md` passes ~60
lessons or a severe lesson lands. See skill: `cogito-consolidate`.)_
