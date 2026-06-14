# Paste this into a paint-repo Claude Code session

You're in the **paint** repo (`COGITO-SUM-cloude/paint`). Do these in order.

## 0. Load the Cogito brain NOW — before touching anything
```bash
git clone --depth 1 https://github.com/COGITO-SUM-cloude/COGITO /tmp/cogito 2>/dev/null \
  && bash /tmp/cogito/scripts/cogito-sync.sh
```
This prints every Cogito lesson. Read them. Do not repeat any of them.

## 1. Wire this repo to the brain (so future paint sessions auto-load lessons)
```bash
mkdir -p scripts && cp /tmp/cogito/scripts/cogito-sync.sh scripts/ && chmod +x scripts/cogito-sync.sh
```
Then add a SessionStart hook to `.claude/settings.json` (create the file, or merge into the
existing `hooks.SessionStart`):
```json
{ "hooks": { "SessionStart": [ { "hooks": [
  { "type": "command", "command": "$CLAUDE_PROJECT_DIR/scripts/cogito-sync.sh" }
] } ] } }
```
Add one line to this repo's `CLAUDE.md`: *"Apply the cogito-protocol; say 'Cogito' to run the
loop. Lessons load via scripts/cogito-sync.sh from the central Cogito brain."*
Commit + push, author **Cogito `<cogito@users.noreply.github.com>`** (faceless — never the
owner's personal handle/email).

## 2. Fix the hero headline contrast (verified by QA on the live site)
The hero `<h1>` renders its non-gold lines in a dark slate on the dark navy hero — legible but
weak. Lighten the light/white portion of the heading toward cream/near-white so every line
reads clearly; keep the gold accent line ("Columbia, SC"). Verify before AND after with a
screenshot at desktop (1280) and mobile (390) — read the pixels, don't assume.
(Eyes setup, if needed: `npx @puppeteer/browsers install chrome@stable`, then screenshot with
`--no-sandbox --ignore-certificate-errors`; or use the chrome-devtools MCP.)

## 3. Send back what you learn (close the loop)
Whenever you hit a correction, a layered bug, or repeated friction, record it:
```bash
bash /tmp/cogito/scripts/cogito-learn.sh "SYMPTOM -> ROOT CAUSE -> RULE"
```
- If `COGITO_TOKEN` is set in this environment, it pushes straight to the central brain.
- If not, it queues the lesson locally and tells you — then paste those lines into a Cogito
  session so they reach the brain. Either way the lesson is never lost.

Standing rules: verify outcomes (pixels + the asset's own URL), not proxies; faceless commits.
