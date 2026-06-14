---
name: web-build-loop
description: The web-specific build-and-verify loop. Use whenever building, iterating on, fixing, deploying, or QA-ing a website or web app — landing pages, multi-page sites, Next/Vite/Astro/static sites — and the change must be proven by what a real visitor actually sees. Enforces orienting before coding (read the build contract + confirm the framework API against the installed node_modules), specifying the one outcome before writing code, no hardcoded strings or hex (everything from sources of truth), building in small increments each on a preview URL, and the non-negotiable gate — verify by rendered pixels from a logged-out context plus the asset's own HTTP status, never a green build. Composes with cogito-protocol. Triggers on "build the site", "fix the page", "why does it look broken", "ship the web change", "deploy the site", "screenshot and check it".
---

# Web Build Loop

The web-specific specialization of the Cogito loop. `cogito-protocol` governs the
reasoning and memory around the work; this skill governs how a **web artifact** is
built and *proven*. They compose — load both for any web project.

## The one rule everything else serves

**A green build is not a working page.** The truth of a web change is the
**rendered pixels a logged-out visitor sees**, plus the **asset's own HTTP status** —
never the build log, never "deployed", never "screenshot captured". Web work gets its
own loop precisely because the proxy signals (build passed, push succeeded, file
written) lie often enough to burn a whole session. Verify the outcome, not the proxy
(cogito §5).

## The loop

### 0. Orient — read before you touch
- Read the `README`, the build contract (`BUILD_CONTRACT.md` or equivalent), the
  framework config (`next.config.*` / `vite.config.*` / `astro.config.*` / deploy
  config), and the **content + brand source-of-truth files**.
- **Confirm framework/API details against the _installed_ version in `node_modules`.**
  "This is not the Next.js you know" has cost us real time — do not code from memory of
  the framework's docs; verify the API the project actually has.
- Identify the sources of truth. Every change flows from them.
- **Pack the context before building.** Pull the relevant code, the contract, the
  brand/content tokens, and the known pitfalls (the failure modes below) into view
  first. One change made with the right context in hand beats three made blind.

### 1. Spec + plan (no code yet)
- State the **single outcome that defines done**, in one sentence.
- Plan the increments; use plan mode for anything non-trivial.
- **No hardcoded strings, no raw hex.** Copy, colors, fonts, photos all read from the
  sources of truth — change once, propagate everywhere.

### 2. Build in small, verifiable increments
- One coherent change at a time, each pushed to a **preview URL** (PRs get preview
  deploys; the production branch auto-deploys). Keep each diff small enough that **one
  screenshot can confirm or refute it.**

### 3. Verify with the eyes — the gate (do NOT skip)
For every visual change:
- **Screenshot the rendered result and read it back.** Do not infer success from a
  green build or a byte count.
- **Verify from a logged-out context.** An owner's Vercel/SSO login has masked a wall
  that every real visitor hit — the truth is what a stranger sees.
- **For assets/images:** check the asset's *own* request and status (e.g. the page's
  actual `/_next/image?...` URL → expect `200` + correct `content-type`), not just that
  the page "loaded".
- **Check desktop _and_ mobile widths.**

How to verify — prefer delegating to a parallel agent:
- **Best — hand off to the `design-qa` subagent.** It loads the page, captures it at
  desktop + mobile, reads the pixels + console + network, and returns a short
  prioritized report (Blocker / Major / Minor + likely fix layer). Launch it as a
  separate agent so verification runs **in parallel** while you keep building — and
  because it is read-only, it can only diagnose, never "fix" a problem by hiding it.
  Reach for it whenever a visual change needs checking ("QA the deploy", "does this
  render", "check it on mobile").
- **Direct (small checks):** the `chrome-devtools` MCP — `navigate_page`,
  `take_screenshot`, `list_console_messages`, `list_network_requests`.
- **In the Cogito repo:** `scripts/ensure-eyes.sh` (once), then `scripts/see.sh <url>`.
- **Anywhere (fallback):** `npx @puppeteer/browsers install chrome@stable` once, then
  headless Chrome with `--no-sandbox` (root) + `--ignore-certificate-errors` (egress
  intercepts TLS). Screenshot a desktop and a mobile width.

### 4. Checkpoint
Record decisions, the live/preview URL, and any lesson (`SYMPTOM -> ROOT CAUSE -> RULE`)
per cogito-protocol §4 / §4b.

## Definition of done (copy-paste gate)

```
[ ] Outcome stated in one sentence — and met.
[ ] No hardcoded strings/hex; values come from the sources of truth.
[ ] Change is on a preview/live URL.
[ ] Rendered result read back at desktop AND mobile, from a LOGGED-OUT context.
[ ] Asset changes: the asset's own URL returns 200 + correct content-type.
[ ] Browser console is clean — no 404s/errors (a missing favicon counts).
[ ] Checkpoint written; any lesson captured.
```

## Standing rules
- **Faceless identity.** Commit as **Cogito** with a non-personal noreply email. Never
  put a personal handle/email in code, commits, README, or any public artifact.
  (Business contact info shown *on the site* is intentionally public — that's fine.)
- **Sources of truth.** Content + brand live in dedicated files; change once, propagate
  everywhere. Extract reusable structure toward the eventual **build-a-site** capability
  — site #2 should be faster than site #1. That compounding is the point.

## Failure modes seen before (don't relearn these)
- Deploy 404'd with no logs -> framework/publish field unset -> set deploy config
  (framework, output dir, publish) **explicitly on day one**.
- Page "live" for the owner, blank/walled for visitors -> owner's login masked an
  SSO/preview-protection wall -> **always verify from a logged-out context**.
- Images blank for every visitor while the raw asset is fine -> image host not
  allowlisted for the framework's optimizer (e.g. `next.config` `images.remotePatterns`)
  -> allowlist the host and confirm the optimizer URL returns `200`.
- "Screenshot captured" but it's blank or stale -> trusted the tool's success message,
  not the pixels -> **read the image back**; treat byte count and "captured" as proxies.
- Coded against the framework "you know" -> the installed version differed -> confirm the
  API against `node_modules` first.

## Relationship to other skills
- **cogito-protocol** governs the reasoning + memory loop around the work; this skill
  governs the web artifact's build + proof. Load both.
- Apply the systems-thinking lens (sources of truth, downstream consumers) to the
  content + brand files.
