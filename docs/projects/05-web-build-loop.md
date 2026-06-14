# Project plan — encode the web-build loop as a reusable skill
_Spec + build log. 2026-06-14. Branch `claude/peaceful-allen-tykil7`._

## Mission (one outcome = done)
A reusable, auto-triggering skill that makes *any* web change go spec-first → build in
small increments → **verify by real rendered pixels** → checkpoint — so the next paint
session runs this discipline automatically instead of from a hand-pasted prompt.

## Why now
The loop already existed, but only as a one-off prompt
(`docs/prompts/continue-painting-site.md`) bolted to the paint repo: it couldn't
trigger, couldn't be reused, wouldn't compound. Encoding it as a skill is the "build
reusable structure" move — and the prerequisite that turns #2 (verify) and #3
(spec-first) into habits rather than good intentions.

## Deliverable
1. `skills/web-build-loop/SKILL.md` — the skill. Composes with cogito-protocol (which
   governs reasoning/memory); this governs the web artifact's build + proof.
2. `install.sh` extended to install every companion skill under `skills/` into
   `~/.claude/skills/`, so it auto-loads everywhere like the protocol.
3. This spec, persisted.

## Acceptance criteria (each independently verifiable)
- **Structural:** skill in `git ls-files`; `./install.sh` runs clean; the skill is then
  present + re-readable in `~/.claude/skills/web-build-loop/` (re-read-after-write proof).
- **Functional:** run the new loop once, for real, on `web/index.html` — one small genuine
  improvement (a real "View on GitHub →" link the page currently lacks) — then verify it
  with the eyes at desktop + mobile, reading the pixels back. Proves the loop triggers and
  the verify-gate works, and ships a real change (defeats diagnosis-without-shipping).
  Rides the feature branch, not prod — the live site is untouched until merge.

## Out of scope
The paint repo (separate, unreachable from this session), the CMS editor, the visualizer,
a from-scratch site generator.

## Decisions
- Name: `web-build-loop` (a composable sibling to `cogito-protocol`, not a rewrite).
- Auto-load globally via `install.sh`: yes.
- Live functional demo on the Cogito site: yes (it's how we prove verification works).

## Build log
- [x] (1) Persist this spec.
- [x] (2) Write `skills/web-build-loop/SKILL.md`.
- [x] (3) Wire `install.sh` to install companion skills.
- [x] (4) Run install + structural proof — re-read from `~/.claude/skills/web-build-loop/`; the skill also appears in the session's available-skills list.
- [x] (5) Functional demo — added a "View on GitHub" link to `web/index.html`, verified by pixels at desktop + mobile from a logged-out local server (HTTP 200).
- [x] (6) Checkpoint + finish-line review.

## Findings (from the dogfood)
- The eyes caught a pre-existing `/favicon.ico` 404 on every page load → folded "console clean (no 404s; favicon present)" into the skill's definition-of-done. The site favicon itself is left unfixed (owner's call; cheapest fix = an inline SVG data-URI `<link rel="icon">`).
- Repeated the documented `pkill -f` self-kill scar despite it being loaded at session start → captured as a lesson (recall ≠ application; stop processes by PID/port).

## How this reaches the bigger goal
The reusable loop is the seed of the "build-a-site" skill: each site teaches the
structure, the skill carries it forward, and eventually the AI builds a whole verified
site from one prompt. This skill is step one of that compounding — not a side quest.
