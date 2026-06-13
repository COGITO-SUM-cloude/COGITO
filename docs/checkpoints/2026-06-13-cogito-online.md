# COGITO — Checkpoint · 2026-06-13 · "Get Cogito online"

Paste/upload this at the start of the next Cogito session on this project.

## Decisions (canonical, verified)
- **Mission:** "get cogito online" = make the protocol **durable + live + auto-loading + publicly visible** — not a web-app deploy (the protocol has no app). Binding constraint = the session boundary + activation.
- **Repo shape:** room-to-grow skill repo.
- **Skill home:** installed globally at `~/.claude/skills/cogito-protocol/`.
- **Activation:** SessionStart hook re-bootstraps the skill from the repo each session (defeats ephemeral reverts) and guarantees the ledger.
- **Commit identity:** `eduardocastanon27-tech <291881939+eduardocastanon27-tech@users.noreply.github.com>` (noreply, to satisfy GH email privacy).
- **License:** MIT. **Web host:** Netlify site `cogito-protocol` → `cogito-protocol.netlify.app` (siteId `b3f59a56-7289-4fb0-890f-dab23804f0be`).

## Current state — what exists, where
- **Branch** `claude/gallant-babbage-ig5y05`, pushed to origin. Tree: `README.md`, `LICENSE`, `CLAUDE.md`, `install.sh`, `vercel.json`, `netlify.toml`, `.gitignore`, `.claude/{settings.json,hooks/cogito-session-start.sh}`, `skills/cogito-protocol/{SKILL.md,LESSONS.md}`, `web/index.html`, `docs/`.
- ✅ **Skill LIVE** — verified on disk at `~/.claude/skills/cogito-protocol/` and present in the runtime skills list.
- ✅ **Ledger LIVE** — 5 lessons; verified writable (probe write re-read).
- ✅ **Auto-load hook** — runs, bootstraps skill + ledger; syntax/JSON/execution verified.
- ⏳ **Web page** — built + committed; Netlify site created; **deploy pending** (user runs the provided `npx @netlify/mcp` command; verify 200 after).

## Open questions / next actions
1. Run the Netlify deploy command → verify `cogito-protocol.netlify.app` serves 200 + content.
2. Add the live URL to `README.md` and `web/index.html` footer once confirmed.
3. Optional: `./install.sh --global-hook` for auto-load in **every** repo.
4. Consider a `main` branch + Netlify continuous deploy so "online" stays online without per-deploy secrets.
5. **Propose skill update:** 5 lessons have accumulated (§4b threshold) — fold the durable rules into `SKILL.md` and commit (user is the write-path).

## Corrections / guardrails hit (highest-value memory)
- Push failed with GH007 (private email) → switched to noreply email; stop retrying deterministic rejections.
- Netlify deploy command blocked by the security classifier (live JWT in argv) → user runs it / use git CD. Correctly *not* worked around.

## Lessons (full ledger: `skills/cogito-protocol/LESSONS.md`)
1. CLAUDE.md describes always-on behavior but only a hook executes it → wire the hook + install the skill day one.
2. "online" for a memory system = durable + auto-loading, not "has a URL" → make memory durable & loading automatic first.
3. The durable copy is the one committed to a repo the user owns → commit, then install, then verify the ledger by re-reading a test write.
4. Push rejected = GH007 private email (deterministic, not network) → use noreply commit email; don't retry policy rejections.
5. MCP "deploy" tools return a CLI command (Netlify embeds a JWT) → verify deploy mechanism/auth/CLI up front; prefer git CD.
