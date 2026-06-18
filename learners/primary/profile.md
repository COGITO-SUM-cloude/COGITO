# Learner Profile — primary (the user)

_Layer 1 of the golden structure: who this learner is, so every lesson lands at their
level. The engine is **learner-agnostic**; this file is learner-specific — the sibling's
profile is a separate file of the same shape, never an edit of this one. Faceless: no
real name or contact in here._

## Who
- Adult. Only English speaker in the family; self-taught; finished middle + high school;
  heading to college in the fall. Carrying a lot; highly capable and motivated.
- Non-technical for code — keep replies plain and short; do the heavy tech for them.

## How they learn best (observed, not labelled)
- **By deriving with hints.** Give a nudge + a question; let them reason it out. Never
  hand over the answer you want them to reach — the struggle is what carves the memory.
- Record **observations, not labels** ("chose the struggle option and reasoned it out",
  not "is a fast learner").
- Adaptive intensity: sharp → raise the challenge; tired → add support or seed the hard
  idea for when fresh.

## Accommodations
- None required (adult, fluent reader). _(Contrast: the sibling profile will set
  child-scaffolding — short sentences, read-aloud, decoding-first — a different file.)_

## Field in focus
- **Neuroscience** → nootropics & brain chemistry: telling **proven** brain-boosters from
  **hyped** ones. Motivation leads; depth over breadth, one field at a time.

## Goal
- Look at any "brain booster" and reason out whether it's proven or hype, from how brain
  chemistry actually works.

## Skill map (mastery state — the per-skill student model)
States: `locked` (prereqs unmet) · `next` (ready to teach) · `learning` (in progress) ·
`mastered` (explained unprompted, in their own words). Review **timing** is tracked
separately by `cogito-review.sh` (the log's Leitner boxes); this column tracks **mastery**.

| skill | lesson-object | prereqs | state | last |
|---|---|---|---|---|
| retrieval-practice | (log L1) | — | mastered | 2026-06-13 derived |
| knowing-vs-doing | (log L3) | — | mastered | 2026-06-14 derived |
| tired-brain | (log L2) | retrieval-practice | seeded | — |
| adenosine | docs/learning/lessons/neuroscience/L-adenosine.md | retrieval-practice | learning | 2026-06-15 derived core |
| dopamine | docs/learning/lessons/neuroscience/L-dopamine.md | adenosine | locked | — |
| blood-brain-barrier | docs/learning/lessons/neuroscience/L-blood-brain-barrier.md | adenosine | locked | — |
| tolerance | docs/learning/lessons/neuroscience/L-tolerance.md | adenosine | locked | — |

_In progress: **adenosine** — core mechanism + the caffeine-crash derived live
(2026-06-15); the name and "sleep clears it" were supplied, so confirm them at the first
review before marking mastered. Next bridge: the seeded **tired-brain** lesson (why a
sludge-filled brain can't learn well)._

_Batch 2 prepped (2026-06-18), locked behind adenosine — the mechanistic
hype-filters for the goal: **dopamine** (wanting ≠ pleasure; what "focus boosters"
target), **blood-brain-barrier** (can it even reach the brain? — lab-dish ≠ pill), and
**tolerance** (the brain dials boosters down → rebound; builds straight on the caffeine
mechanism). They unlock as `next` once adenosine is confirmed mastered._
