---
name: cogito-consolidate
description: Consolidate the Cogito lessons ledger when it grows large — cluster lessons by tag, merge redundant or superseded ones into fewer higher-tier rules, and MOVE the raw lines to LESSONS-ARCHIVE.md with provenance (never delete). Use when the ledger passes ~60 lessons, right after a severe (#critical / I≥9) lesson lands, or on an explicit request to "consolidate the ledger" / "/consolidate". Enforces a probation buffer (recent lessons settle before merging), archive-don't-delete, keeping #critical/I≥9 rules always-loaded, and a runnable conservation check (no lesson lost) plus a git-diff review against over-merge. Composes with cogito-protocol §4b.
---

# Cogito Consolidate (lessons-ledger compaction)

The ledger (`skills/cogito-protocol/LESSONS.md`) loads in **full** into every session
via the SessionStart hook. That is its strength — and its scaling limit: past ~60
one-liners it starts paying the "context rot" tax the roadmap warns about. Consolidation
is the pressure valve — turn many raw, redundant captures into fewer, denser, higher-tier
rules, and **move** (never delete) the raw lines to an archive that preserves provenance.
Procedural memory for the librarian job. Composes with `cogito-protocol` §4b.

> **The load-path contract — do not break it.** The hook counts and prints lessons with
> `grep '^- '` over `LESSONS.md` **only**. So: (a) every *live* lesson must start with
> `- `; (b) anything moved to `LESSONS-ARCHIVE.md` stops loading — that is the whole point;
> (c) section headers and `<!-- comments -->` are ignored by the grep, so they are safe to add.

## When to run (trigger)
- The ledger passes **~60** `- ` lines (`grep -c '^- ' LESSONS.md`), **or**
- right after a **severe** lesson lands (`#critical` or `[I:≥9]`) — a severe lesson often
  supersedes softer neighbours, **or**
- an explicit request: "consolidate the ledger" / "/consolidate".

Below ~60 with no severe trigger, **don't**. A healthy small ledger needs no surgery;
over-merging a thin one only loses detail. (Exception: a single, clearly-redundant pair may
be merged as a worked example to keep the mechanism proven.)

## Probation buffer (what is NOT eligible)
New lessons are appended at the bottom, so **recency = position**. Treat the tail as
probationary: do **not** consolidate a lesson added in the current or immediately-prior
session, nor (roughly) the most recent ~5 entries. A lesson must survive a cycle before it
has earned the right to be merged — fresh nuance often *looks* redundant before its distinct
case recurs. When unsure whether a lesson has settled, leave it.

## The procedure
1. **Cluster.** Group eligible lessons by tag/theme (`grep` a tag, or read and bucket). Name each cluster.
2. **Classify** each lesson in a cluster: *duplicate* (same symptom+root+rule, captured twice),
   *superseded* (a later lesson corrects/extends an earlier one — name the contradiction explicitly),
   or *distinct* (different root cause — **keep**, even under the same tag).
3. **Merge** only duplicates and supersededs into **one** higher-tier rule that:
   - preserves every distinct concrete case (cite them briefly so the rule stays falsifiable),
   - keeps the root cause and the rule intact,
   - is tagged + scored: `[#tag] [I:n] SYMPTOM -> ROOT CAUSE -> RULE (consolidates N -> LESSONS-ARCHIVE.md <date>)`.
4. **Archive the raw lines.** *Move* (cut, don't copy) each merged raw line into
   `skills/cogito-protocol/LESSONS-ARCHIVE.md` under a dated block naming the consolidated rule it
   now lives inside. Provenance is bidirectional: the live rule points at the archive date; the
   archive points back at the rule.
5. **Always-load rule.** A consolidated rule that is `#critical` or `[I:≥9]` **stays** in the live
   ledger — that is the policy; it must always load. Only the verbose raw captures get archived.
   Never archive a critical rule itself.
6. **Log the pass.** Add a one-line dated entry to the archive's pass-log (what merged into what).
   Keep `LESSONS.md` clean — just the swapped lines.

## The verification gate (run it; paste the evidence — do not assert)
Consolidation edits the one file the whole system loads, so prove conservation before claiming done:
- `grep -c '^- ' LESSONS.md` and `grep -c '^- ' LESSONS-ARCHIVE.md`.
- **Conservation invariant:** `new_live == old_live − archived + new_consolidated_rules`, and every
  archived line's text matches an original **verbatim** (nothing silently reworded into oblivion).
  No raw lesson may end up in *neither* file.
- **Over-merge review:** read `git diff` — the human-reviewable validation layer. If two merged
  lessons had *different* root causes, you over-merged: revert that merge. When in doubt, a slightly
  longer ledger beats a lossy one.
- Re-read `LESSONS.md`: every line still starts with `- `; the consolidated rule reads cleanly; the
  hook would still parse it.

This is `cogito-protocol` §5b applied to the librarian job: a consolidation that has not been
conservation-checked is "looks done," not done.

## Anti-patterns
- Merging across root causes to hit a number. The goal is density without loss, not a shorter file.
- Deleting raw lines. Always **move** to the archive (git history is a backstop, not the interface).
- Consolidating the probation tail. Let lessons settle.
- Touching the load path. Don't change how lessons are delimited; the `- ` prefix is a contract with the hook.
