---
name: cogito-consolidate
description: Compact the Cogito lessons ledger when it grows large or noisy, by two mechanisms — CONSOLIDATE (cluster by tag; merge redundant/superseded lessons into fewer higher-tier rules) and DECAY (retire cold, low-value, or project-specific lessons that no longer earn a slot in the always-loaded ledger). Both MOVE raw lines to LESSONS-ARCHIVE.md with provenance — never delete. Use when the ledger passes ~60 lessons, right after a severe (#critical / I≥9) lesson lands, when project-specific trivia has accumulated, or on an explicit request to "consolidate"/"decay"/"prune"/"compact the ledger". Enforces a probation buffer (recent lessons settle first), archive-don't-delete, never decaying #critical/I≥9, refresh-on-use ([seen:DATE] resets the decay clock), and a runnable conservation check (no lesson lost) plus a git-diff review against over-compaction. Composes with cogito-protocol §4b.
---

# Cogito Consolidate (lessons-ledger compaction)

The ledger (`skills/cogito-protocol/LESSONS.md`) loads in **full** into every session,
in **every** repo, via the SessionStart hook. That is its strength — and its scaling limit:
past ~60 one-liners it starts paying the "context rot" tax the roadmap warns about. This
skill is the pressure valve, with **two mechanisms** that share one archive and one gate:

- **Consolidate** — turn many raw, redundant/superseded captures into fewer, denser,
  higher-tier rules (semantic compression: N lines -> 1 rule).
- **Decay** — retire lessons that are simply *cold and low-value* — not redundant, just no
  longer earning a slot in an always-loaded ledger (e.g. a lesson that only applies inside
  one inactive project). Decay has no replacement rule; the line just leaves the loaded set.

Both **move** (never delete) the raw lines to an archive that preserves provenance.
Procedural memory for the librarian job. Composes with `cogito-protocol` §4b.

> **The load-path contract — do not break it.** The hook counts and prints lessons with
> `grep '^- '` over `LESSONS.md` **only**. So: (a) every *live* lesson must start with
> `- `; (b) anything moved to `LESSONS-ARCHIVE.md` stops loading — that is the whole point;
> (c) section headers and `<!-- comments -->` are ignored by the grep, so they are safe to add.

## When to run (trigger)
- The ledger passes **~60** `- ` lines (`grep -c '^- ' LESSONS.md`), **or**
- right after a **severe** lesson lands (`#critical` or `[I:≥9]`) — a severe lesson often
  supersedes softer neighbours, **or**
- the ledger has accumulated **project-specific or one-off lessons** that are noise in every
  *other* repo (a decay smell — the global brain is carrying local lint/theme trivia), **or**
- an explicit request: "consolidate" / "decay" / "prune" / "compact the ledger".

Below ~60 with no severe trigger and no project-specific noise, **don't**. A healthy small
ledger needs no surgery; over-merging or over-decaying a thin one only loses detail.
(Exception: a single clearly-redundant pair, or a clearly project-specific cold line, may be
compacted as a worked example to keep the mechanism proven.)

## Probation buffer (what is NOT eligible)
New lessons are appended at the bottom, so **recency = position**. Treat the tail as
probationary: do **not** consolidate *or decay* a lesson added in the current or
immediately-prior session, nor (roughly) the most recent ~5 entries. A lesson must survive a
cycle before it has earned the right to be merged or retired — fresh nuance often *looks*
redundant or low-value before its distinct case recurs. When unsure whether a lesson has
settled, leave it.

## Mechanism A — consolidate (merge redundant / superseded)
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

## Mechanism B — decay (retire cold / low-value / project-specific)
Consolidation removes *redundancy*; decay removes lines that are individually fine but no longer
worth a slot in a ledger that loads into every repo. A lesson is **decay-eligible** only when ALL hold:
1. **Past probation** (settled — see above).
2. **Not safety-bearing:** never `#critical`, never `[I:≥9]`. A rare-but-catastrophic lesson (a
   destructive-command scar, a memory-integrity scar) is *cold by nature* and must stay — coldness is
   not low value for those. When unsure of the stakes, keep.
3. **Low standing value**, by at least one of:
   - **low importance** (roughly `[I:≤4]`), or
   - **low generality** — actionable only inside one *specific, currently-inactive* project (e.g. one
     repo's lint rule or theme detail); it is context-rot in every other repo, and its general kernel,
     if any, already lives in a skill. This is decay's highest-value target: project lessons that
     leaked into the global brain.
4. **Not recently used:** no `[seen:DATE]` within the recency window (see refresh-on-use).

For each eligible lesson: **move** the raw line verbatim into `LESSONS-ARCHIVE.md` under a dated
**decay** block that states *why* it was retired (cold / low-I / project-specific). There is **no**
replacement rule and **no** live back-pointer — the whole point is that the line leaves the loaded set.
(If a decayed project ever reactivates, its lessons are one `grep` away in the archive, or re-earned
on the spot.) Then log the pass in the archive's pass-log, same as consolidation.

**Refresh-on-use (the recency lease).** The moment a loaded lesson actually *fires* and saves you in a
session, append (or bump) a trailing `[seen:YYYY-MM-DD]` on it — that is the explicit decay clock, and a
`seen:` inside the recency window (~90 days / the last few active sessions) makes the lesson
**decay-immune** even if it is old and low-importance. Lessons with no `seen:` fall back to
position/inactivity as the recency proxy (we do not timestamp every line, so judgment fills the gap;
`seen:` always wins when present). Refresh-on-use is why frequency beats age: a lesson that keeps
mattering keeps its lease.

## The verification gate (run it; paste the evidence — do not assert)
Either mechanism edits the one file the whole system loads, so prove conservation before claiming done:
- `grep -c '^- ' LESSONS.md` and `grep -c '^- ' LESSONS-ARCHIVE.md`.
- **Conservation invariant:** `new_live == old_live − archived + new_rules`, where `archived` counts
  every raw line moved out (merged **or** decayed) and `new_rules` is the count of new consolidated
  rules written (**0 for a pure decay pass**). Every archived line's text must match an original
  **verbatim** (nothing silently reworded into oblivion); no raw lesson may end up in *neither* file,
  and the archive count must rise by exactly `archived`.
- **Over-compaction review:** read `git diff` — the human-reviewable validation layer. Over-merge = two
  merged lessons had *different* root causes (revert that merge). Over-decay = you archived a
  safety-bearing or still-general lesson (restore it). When in doubt, a slightly longer ledger beats a
  lossy one.
- Re-read `LESSONS.md`: every line still starts with `- `; any consolidated rule reads cleanly; the hook
  would still parse it (no welded lines — `grep -c '^- '` is the structural check, not just content).

This is `cogito-protocol` §5b applied to the librarian job: a compaction that has not been
conservation-checked is "looks done," not done.

## Anti-patterns
- Merging across root causes, or decaying for the sake of a smaller file. The goal is density without
  loss, not a shorter number.
- **Decaying a safety lesson because it is old.** Cold ≠ low-value for `#critical`/`[I:≥9]`/destructive-
  command/memory-integrity scars — those are rare *by design* and must always load.
- Deleting raw lines. Always **move** to the archive (git history is a backstop, not the interface).
- Compacting the probation tail. Let lessons settle before merging or decaying them.
- Touching the load path. Don't change how lessons are delimited; the `- ` prefix is a contract with the hook.
