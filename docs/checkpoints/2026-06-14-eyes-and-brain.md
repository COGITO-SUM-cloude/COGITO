# Checkpoint — Eyes + AI-brain session (2026-06-14)

## Mission (this session)
Finish the "eyes" setup → write a prompt to continue the painting site → research
"AI brain" + tools and set up the first one.

## Decisions made (canonical, verified)
- **Eyes = headless Chrome via Chrome-for-Testing.** Network access is now **Full**, so
  Chrome installs from the registry/Google host. Install + stable symlink handled by
  `scripts/ensure-eyes.sh`; flags needed: `--no-sandbox` (root) and
  `--ignore-certificate-errors` (egress intercepts TLS). Proven end-to-end (read real
  screenshots back). `.mcp.json` now points the chrome-devtools MCP at this Chrome
  (owner-authorized); `scripts/see.sh` is the always-works fallback.
- **Correction:** *Obsidian & Ember* is the owner's **control panel for managing all his
  sites**, NOT a public website.
- **Painting site** is already built + live: **J.L. Painting SC** (Columbia, SC), Vercel
  project `paint`, prod `https://paint-jfl-lol-projects.vercel.app`. "Continue building"
  = iterate on a real deployed site. Brief: `docs/prompts/continue-painting-site.md`.
- **AI brain:** Cogito already is one (files + hook + ledger + checkpoints). Skip heavy
  cloud memory (Mem0/Zep/Letta) — it fights free/private/simple. Add Claude Code's own
  layers (subagents, skills) + verification (eyes). **First upgrade chosen + built: the
  design-QA subagent.**

## Current state — what exists, where
- `scripts/ensure-eyes.sh`, `scripts/see.sh` — install + screenshot.
- `.mcp.json` — chrome-devtools MCP wired to the installed Chrome (live next session).
- `.claude/agents/design-qa.md` — visual-QA specialist (live next session).
- `docs/projects/03-eyes-options.md` — marked DONE, working recipe + gotchas.
- `docs/prompts/continue-painting-site.md` — paste-ready build brief.
- `docs/projects/04-ai-brain.md` — research + smallest-first roadmap.
- `skills/cogito-protocol/LESSONS.md` — +6 lessons this session (29 → 35).
- All pushed to branch `claude/awesome-ramanujan-52rr08`.

## Bug found (by the eyes, first real use)
Paint site hero + service photos are blank for every visitor. The page's own
`/_next/image?...&w=3840&q=75` returns **400 INVALID_IMAGE_OPTIMIZE_REQUEST** (raw blob
image is 200). Cause: blob host not in `next.config` `images.remotePatterns`. Fix lives
in the **paint** repo — captured as priority 1 in the build prompt.

## Open questions / next actions
- Fix the paint image bug (owner chose: do it in the build session via the prompt).
- Replace placeholder `try.webp` hero with real job photos (owner, via the CMS).
- Next session: `scripts/ensure-eyes.sh`, then try the design-QA subagent on the paint site.
- Later brain upgrades: smarter/indexed memory; the reusable build-a-site skill (once the
  painting site is further along).

## Corrections to remember
- Obsidian & Ember = control panel, not a site (above).
- Don't trust "captured"/byte count — read the pixels and the asset's own URL.
