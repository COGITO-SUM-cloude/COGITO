# Cogito — Learning Log

The durable record of what the user is learning, so progress is never lost to a
forgotten session. Each entry: the idea in plain words, its real name, one way to
use it, and a recap cue for next time. We revisit these on purpose — that is how
we beat forgetting.

We also **schedule** the reviews (spaced repetition, Leitner ladder): each lesson
carries `box:N due:YYYY-MM-DD`. A correct recall promotes it to a longer interval
(boxes 1→2→3→4→5→6 = 1, 3, 7, 16, 35, 90 days); a miss resets it to box 1. At
session start the most-overdue lesson's recap cue is surfaced automatically.
`scripts/cogito-review.sh due` lists what's due; `… grade N pass|fail` records a
review. (`box:0` = seeded, not yet in rotation.)

**Field in focus:** Neuroscience (started 2026-06-13) — current focus: **nootropics & brain chemistry** (proven vs. hyped).
**How the user learns best:** by *deriving it with hints* — give a nudge + a question, let him reason it out (don't hand over the answer). Record **observations, not labels**.
**Lesson definitions** (the reusable "meaning" objects, learner-agnostic) live in `docs/learning/lessons/`; this log is the per-learner **progress** record.

---

## Lesson 1 — You remember what you work for
- **Plain version:** Struggling to recall or figure something out is what makes a
  memory stick. Being told something once, passively, barely leaves a mark.
- **Picture:** A memory is a trail through tall grass. *Re-reading* = looking at
  the trail. *Recalling it yourself* = walking it — and only walking deepens the
  path. The struggle is what carves the memory in.
- **Real name:** the **testing effect** / **retrieval practice** (part of a bigger
  idea called *desirable difficulty*).
- **Use it:** To learn anything, don't just re-read it — **close it and try to
  recall it.** The effort is the point. (This is why Cogito hints instead of
  telling: your effort is the chisel.)
- **Recap cue (ask next time):** "Trail in the grass — what makes the path deeper,
  looking at it or walking it?"
- **Status:** ✓ Derived by the user (2026-06-13) — chose "B, the struggle one" and
  reasoned it out. Earned, not just told.
- **Review:** box:1 due:2026-06-14

---

## Lesson 2 — Why a tired brain can't learn *(seeded, for when fresh)*
- **Where it came from:** the user's own observation — *"I was extremely tired and
  my brain was slowing down."* A real insight, spotted in themselves.
- **Question to explore next:** if struggle carves memory, why does a *tired* brain
  carve so poorly — and what is sleep actually *for*?
- **Where we're headed (don't reveal — let them derive):** a tired brain encodes
  weakly, and sleep is when the day's faint trails get reinforced. So rest isn't
  lazy — it's literally part of learning.
- **Review:** box:0 (seeded — enters rotation once taught/derived)

---

## Lesson 3 — Knowing a rule isn't the same as following it
- **Where it came from:** today, real and unflattering. I had the exact rule loaded
  ("don't use a self-matching `pkill`") and broke it anyway — then applied it correctly
  the second time, once it was cued right at the moment of acting.
- **Plain version:** a stored rule is just an *input* to the decision, not an enforcer —
  nothing makes it fire. In the moment, the *output* (the decision) can skip it: either it
  never surfaced, or something else looked better. First time here, it never surfaced;
  the second time, the failure forced a review that pulled the rule back up.
- **The upgrade (so a failure isn't required first):** pre-bind the rule to its trigger —
  "WHEN I'm about to stop a server → THEN kill by PID." A cue glued to the moment fires
  *before* the slip instead of waiting for trial-and-error to surface it.
- **Real names:** availability vs. accessibility (Bjork) — stored ≠ reachable when needed;
  the knowing–doing gap; implementation intentions (if–then planning).
- **Use it:** for any rule you keep breaking, write it as "when X → I do Y," tied to the
  visible trigger, not as a fact filed away.
- **Recap cue (ask next time):** "Fire extinguisher in the basement vs. bolted by the
  stove — what makes a known rule actually fire when it's needed?"
- **Status:** ✓ Derived by the user (2026-06-14). Their words: a rule "is just an input …
  the true decision is in its output," with "no actual enforcer"; the second time worked
  because the failure made it "review its knowledge and [find] there was a rule for it."
  Reached the availability/accessibility idea on their own.
- **Review:** box:1 due:2026-06-15
