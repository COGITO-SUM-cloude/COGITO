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

### 2026-06-15 — communication style for the user (3 raw -> 1 #critical rule)
> Early targeted pass (not the ~60 bulk trigger): the council's judge verified two of these lines CONTRADICTED each other and both loaded — the obsolete "baby steps" line was `#critical`/always-load while its correction was untagged/deferred. Merged into one current rule; raw lines kept here verbatim.
> superseded by: `[#critical][#comms] How to talk to THIS user -> talk adult-to-adult: plain everyday words, short replies, explain by analogy not jargon, do the tech myself; NO emojis, no cheerleading, no "baby steps"/"tiny concepts" framing — "simpler" means less jargon, not talking down; re-read when a task feels complex.`

- [#critical] Explained the work in dense jargon and long finish-line reviews -> the user is non-technical, has a limited vocabulary, and can't retain much, so technical replies don't help them and add friction -> ALWAYS use plain everyday words, short replies, and baby steps (one action at a time); do the tech myself; teach tiny concepts simply. This is a standing rule for this user.
- User said "treat me like I'm 20, tired of the emojis" -> after being asked to simplify, I over-corrected into an emoji-heavy, over-cheerful, hand-holding tone that read as patronizing -> talk adult-to-adult: plain, simple words but NO emojis, no cheerleading, no "baby steps" framing. "Simpler" means less jargon, not treating them like a child.
- [#critical][#comms] Slipped back into dense technical prose and a long diagnosis on a complex task, despite the standing non-technical-user rule -> under heavy cognitive load I defaulted to engineer-to-engineer register -> the user is non-technical: keep every reply short and plain, explain by analogy not jargon, no long reviews; re-read this rule the moment a task feels complex, because that is exactly when the slip happens.
