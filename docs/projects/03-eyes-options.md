# Eyes for Cogito — options (researched 2026-06-14)

**Goal:** let the AI see the rendered result of web work, instead of routing every visual check through the owner's screenshots.

**Constraint:** this container's egress is locked to the npm registry; live URLs return `403 host_not_allowed`. So the real question is which "eyes" route works *around* or *removes* that wall.

## The options

1. **Hosted browser MCP (Browserbase / Browserless / Hyperbrowser)** — a browser that runs in the cloud, added the same way our Vercel/Netlify MCP servers are. It loads the public site and returns screenshots *through the MCP channel*, bypassing this container's egress block entirely. **Easiest route that needs no environment change.** Needs: a (free-tier) account + the site publicly reachable.

2. **Open the environment network policy + Chrome DevTools MCP** — the standard "give your AI eyes" setup (official ChromeDevTools MCP; endorsed by Addy Osmani, who's in our own notes). Screenshots, DOM, console errors, network, performance — straight into chat. **Most powerful and reusable for every future task.** Needs: you open egress (one-time, applies on a new session).

3. **Playwright MCP (Microsoft)** — real browser control via MCP; token-efficient accessibility snapshots + screenshots. Same egress caveat as #2 if run locally in the container.

4. **Vercel MCP (already connected) — partial eyes, free, now** — `web_fetch` pulls a deployment's rendered HTML *through* Vercel (bypasses our egress), and `get_access` can mint a link that bypasses the login wall. Structure/text, not a real picture. Zero setup.

5. **User-side one-click capture (SightRelay / AppContext / ProofShot)** — a tool on the owner's own browser captures screenshot + DOM + console + errors in one click and feeds it to the AI. Leverages the browser that already works; richer than manual screenshots. Good complement.

## Recommendation
- **Today, free:** use #4 (Vercel MCP) for structure/text checks — already available.
- **Easiest real-picture eyes without touching the environment:** #1 (hosted browser MCP).
- **Most powerful long-term:** #2 (open egress + Chrome DevTools MCP) — full eyes + debugging, reusable everywhere.
- **Either way:** fix Vercel Deployment Protection so a non-owner can load the site. "Live" means a stranger can open it.

## Sources
- Chrome DevTools MCP (official): https://github.com/ChromeDevTools/chrome-devtools-mcp
- Addy Osmani, "Give your AI eyes: Chrome DevTools MCP": https://addyosmani.com/blog/devtools-mcp/
- Playwright MCP (Microsoft): https://github.com/microsoft/playwright-mcp
- Browserbase (hosted browser MCP): https://mcp.directory/blog/browserbase-vs-browserless-vs-hyperbrowser-vs-anchor-2026
- ProofShot (give coding agents eyes): https://github.com/AmElmo/proofshot
- Top 5 browser-automation MCP servers (2026): https://www.webfuse.com/blog/the-top-5-best-mcp-servers-for-ai-agent-browser-automation

## Decision + status (2026-06-14)
- **Chosen:** option 2 — open egress + Chrome DevTools MCP (most powerful; full screenshots + console + network).
- **Staged by Cogito:** `.mcp.json` at repo root defines the `chrome-devtools` server (`npx chrome-devtools-mcp@latest --headless --no-usage-statistics`). On the next session Claude Code should detect it and ask the owner to approve it.
- **Remaining owner action (exact):** click the cloud icon showing the current environment's name -> hover the environment -> click the settings/gear icon -> in the dialog set **Network access** from *Trusted* to **Full** (any domain), then start a NEW session (network changes apply on new sessions only). Levels: None / Trusted (default = npm + GitHub only) / Full (any) / Custom (own allowlist; would need `*.vercel.app`, `*.vercel-storage.com`, and the Chrome download host). Docs: code.claude.com/docs/en/claude-code-on-the-web#network-access.
- **Then, to verify eyes:** navigate + `take_screenshot` on any public page (proves the loop), and read the image back.
- **Separate fix to see the live site (not a login wall):** turn off Vercel Deployment Protection, or use the Vercel MCP access tool. "Live" = a stranger can load it.
- **Note:** Chrome is fetched on first use, which needs the open egress; npm itself is already allowed.

