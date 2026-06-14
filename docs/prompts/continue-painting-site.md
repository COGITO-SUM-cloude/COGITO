# Prompt — continue building the painting site (J.L. Painting SC)

Paste this into a Claude Code session pointed at the **paint** repo
(`COGITO-SUM-cloude/paint`). It carries the context so the session starts informed
("context packing"). Cogito is always-on; this just aims it.

---

## Mission
Continue improving **J.L. Painting SC** — a real, already-live painting-business site
for Columbia, SC. This is iterative improvement of a deployed product, **not** a fresh
build. Live URL: `https://paint-jfl-lol-projects.vercel.app` (Vercel project `paint`,
auto-deploys on push to `main`; PRs get preview URLs).

What it already is: a multi-page Next.js site (App Router, turbopack) — Home, About,
Services (+ service detail pages), "See the Future" paint **visualizer** (upload a room
photo, tap a wall, preview real Sherwin-Williams colors, capture a lead), and Contact.
Warm-editorial design (Fraunces serif; ink-navy + ochre). Content is **CMS-driven** via a
build contract (see `BUILD_CONTRACT.md`, ~v2.1): pages/sections/copy/photos come from
content files, not hardcoded.

## How to work (the loop — do not skip)
1. **Orient first.** Read `README.md`, `BUILD_CONTRACT.md`, `next.config.*`, and the
   content/source-of-truth files before changing anything. Confirm framework/API details
   against the installed version in `node_modules` (this repo has bitten us by not being
   "the Next.js you know").
2. **Spec + plan before code.** State the one outcome that defines done; use plan mode.
   No hardcoded strings, no raw hex — everything reads from the sources of truth.
3. **Build in small, verifiable increments**, each pushed to a preview URL.
4. **Verify with your eyes, every visual change.** Screenshot the preview and read it
   back; don't infer success from a green build. From this environment:
   `npx @puppeteer/browsers install chrome@stable` once, then screenshot with
   `--no-sandbox --ignore-certificate-errors` (the egress intercepts TLS), or use the
   chrome-devtools MCP if configured. Confirm "live" from a **logged-out** context — the
   owner's Vercel login has masked an SSO wall before.
5. **Checkpoint at the end** (decisions, live URL, lessons) per the cogito protocol.

## Priority 1 — fix the broken production photos (verified live, 2026-06-14)
The hero photo and all service-card photos are **blank for every visitor**. Diagnosis is
done; you just need to fix + verify:
- The page's own optimized image URL returns **400**:
  `GET /_next/image?url=<blob>&w=3840&q=75` → `400 INVALID_IMAGE_OPTIMIZE_REQUEST`
  (both large and small widths). The **raw** blob image is fine (200, valid webp).
- **Root cause:** the Vercel Blob host is not allowlisted for Next image optimization.
  `next.config` is missing `images.remotePatterns` for `*.public.blob.vercel-storage.com`.
  (Note: Vercel does **not** auto-allow blob storage here, contrary to an older note.)
- **Fix:** add it to `next.config`, e.g.
  ```js
  images: { remotePatterns: [
    { protocol: 'https', hostname: '**.public.blob.vercel-storage.com' },
  ] },
  ```
  (Match the exact host pattern Next requires for your version; verify against the
  installed Next docs in `node_modules`.)
- **Verify (don't trust the build):**
  1. `curl -s -o /dev/null -w "%{http_code}\n" "https://<preview>/_next/image?url=<the
     page's exact encoded blob url>&w=3840&q=75"` → expect **200**, `content-type:
     image/webp`.
  2. Screenshot the homepage from a logged-out context → hero + 3 service photos render.

## Priority 2 — real photos (content, owner-side)
The hero currently points at a placeholder (`...-try.webp`). Once Priority 1 is fixed,
the owner should replace the hero + service photos with **real job photos** via the CMS
(Obsidian & Ember). Don't fabricate images; surface this as an owner action with exact
steps when the CMS path is ready.

## Then — pick the next increment with the owner
Likely candidates (confirm priority before building): polish per-page content/copy,
strengthen the quote-form/lead flow, tune the visualizer, mobile QA, performance/SEO.

## Standing rules for this repo
- **Faceless identity:** commit as **Cogito** with a non-personal noreply email. Never
  put the owner's personal handle/email in code, commits, README, or any public artifact.
  (The business phone/email shown on the site are intentionally public — those are fine.)
- **Sources of truth:** content + brand live in dedicated files; change once, propagate
  everywhere. Extract any reusable structure toward the eventual "build-a-site" skill.
- **Verify outcomes, not proxies:** the rendered pixels and the asset's own URL are the
  truth, never "build passed" or "captured."
