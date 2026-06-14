# Checkpoint — web-build-loop skill (2026-06-14)

## Mission (this session)
Encode the web build-and-verify loop as a reusable, auto-triggering **skill** — chosen
(via spec sign-off) over fixing the paint photo bug, which is out of scope here (the paint
site is a separate repo this session cannot reach). The point: make spec-first (#3) and
verify-by-pixels (#2) into durable structure, not good intentions.

## Decisions made (canonical, verified)
- **New skill `skills/web-build-loop/SKILL.md`** — the web-specific specialization of the
  cogito loop (orient → spec → small increments → verify with the eyes → checkpoint).
  Composes with cogito-protocol. *Verified*: re-read from
  `~/.claude/skills/web-build-loop/SKILL.md` after install, and it appears in this
  session's available-skills list (it triggers).
- **`install.sh` now installs every companion skill** under `skills/` (block "1b"), so new
  skills auto-load globally like the protocol — not just cogito-protocol.
- **Verify gate hardened** after the dogfood: added "console is clean (no 404s/errors;
  favicon present)" to the skill's definition-of-done.
- **Dogfooded on `web/index.html`**: added a real "View on GitHub" link (header CTA +
  footer). *Verified* by rendered pixels at desktop (1280) + mobile (390), from a
  logged-out local server; page returns HTTP 200, link present in served bytes, CTA wraps
  cleanly on mobile.

## Current state — what exists, where
- `skills/web-build-loop/SKILL.md` — the loop (installed + committed).
- `install.sh` — companion-skill install block.
- `docs/projects/05-web-build-loop.md` — spec + build log + findings.
- `web/index.html` — GitHub links (header + footer).
- `skills/cogito-protocol/LESSONS.md` — +2 lessons (favicon gate; pkill recall).
- All on branch `claude/peaceful-allen-tykil7`, pushed.

## Open questions / next actions
- **Highest-value pending real-world win:** open a *paint-pointed* session and run the new
  web-build-loop on the diagnosed photo bug (`next.config` `images.remotePatterns` for the
  blob host). That is the real test of this skill and the unshipped Priority-1 fix.
- Favicon 404 on the live Cogito site is unfixed (owner's call; cheap = inline SVG favicon).
- Consider merging this branch into the repo default so future sessions inherit the skill
  (per the forked-branch ledger lesson).

## Corrections to remember
- "my website project" = the **paint site** (separate repo), not the Cogito public site.
- Repeated the `pkill -f` self-kill scar despite it being loaded at session start — recall
  is not application; stop processes by PID or port check, never a self-matching pattern.

## Addendum — unpublish + roadmap 2/3/4 (same session)
- **Unpublish:** the Cogito site is already private. Not on Netlify. On Vercel it is
  project `skills` (static), SSO-walled (public gets 401); the clean alias 404s; no public
  production deploy. The public `idk-whatimdoing` is BIHO CMS, not Cogito. The Vercel MCP
  here is read/deploy-only — toggling protection or deleting is dashboard-only. Decision:
  keep it private as Cogito's hub until the owner says publish.
- **#2 favicon:** added `web/favicon.svg` + `<link rel=icon>`; the page console is now
  clean (verified with the eyes). Committed + pushed.
- **#3 parallel agents:** wired the `design-qa` subagent into the web-build-loop as the
  preferred parallel verification path; made context-packing an explicit Orient step.
- **#4 branches:** there is no `main`; the default was the session branch
  `claude/gallant-babbage-ig5y05`. Creating a real `main` from this branch AND
  fast-forwarding the current default to it. Owner to flip the GitHub default to `main`
  (dashboard — I cannot change that setting from here).
