# Project prompt — CMS layout reshape ("Obsidian & Ember")
_2026-06-13. A brief to drive the build. Hand this to the AI builder to execute._

## Mission
Completely reshape the layout and visual identity of the CMS — the dashboard where you build, host, manage, and monetize client websites — into a modern, futuristic interface dressed in an Elden Ring / Messmer dark-fantasy aesthetic, **without** sacrificing the speed, clarity, and usability of a tool you work in every day.

## Context (what we're reshaping)
- The CMS is your cockpit: one place to create client sites, manage content, see analytics and leads, handle domains and billing — without tab-switching.
- It is partially built. The current editor is a limited "click and change the words" tool, not a real editor. **This brief covers the CMS's layout, shell, and visual identity. The editor's deep functionality is a later phase that plugs into this new shell.**
- Bigger goal: this CMS becomes the cockpit of the "Mini-Squarespace" platform, and its themed component library + design tokens become reusable structure in Cogito.

## The ask (your words, made concrete)
- A **complete layout reshape** — rethink the structure, not just repaint it.
- **Modern / futuristic** feel.
- **Elden Ring / Messmer theme** — Messmer-led (fire, serpents, gold, crusader gravitas) with the broader Elden Ring dark-fantasy mood as the fallback register.

## Design language — "Obsidian & Ember"
The blend: **dark-fantasy atmosphere meets sci-fi precision.** Carved-stone gravitas, molten fire, frosted-glass futurism. Mood: sacred, ancient, ominous, premium — a war-room lit by flame. Cinematic, never cluttered.

**Palette (as tokens):**
- Base: obsidian with a warm undertone `#0C0A09`; charcoal panels `#16120E`; smoke borders `#2A2320`.
- Primary — Messmer's flame: ember `#E2562B` into gold `#E6B43C` (gradient on primary actions and key highlights).
- Erdtree gold `#C9A227` for accents, dividers, focus glow.
- Crimson `#9B1B1B` for destructive actions / alerts (the Impaler's blood).
- Cold counterpoint for futuristic info states: pale steel-blue `#7FA8C9`, used sparingly.
- Serpent green `#3A5A40` as a rare secondary accent.
- Text: warm bone-white `#EDE6DA` primary; muted ash `#9A9086` secondary.

**Typography:**
- Headings: a display serif with carved gravitas (e.g. Cinzel / a Trajan-like face) — legible, not blackletter.
- Body / UI: a clean modern sans (e.g. Inter) for speed and readability.
- The pairing *is* the "dark fantasy meets futuristic" tension.

**Motifs (subtle, never noisy):** gold filigree corners on key panels; serpentine line accents on dividers; ember rim-light / faint glow on hover and focus; fire-gradient primary buttons; a "kindled flame" loading state; frosted obsidian-glass panels with a thin gold edge; faint parchment/obsidian noise in backgrounds.

**Motion:** smooth, weighty, cinematic; subtle ember particles only on primary actions; respect reduced-motion settings.

**Guardrail (the Cogito red-team):** this is a daily workspace, not a game menu. Atmosphere serves the work. Non-negotiable: WCAG AA contrast, fast load, scannable density, legible type. Ship a **theme-intensity toggle (Full Flame / Low Ember)** so the drama can be dialed down for long sessions.

## Layout & screens
**App shell:** collapsible left sidebar (icon + label), top bar (global search / Cmd-K command palette, notifications, account), main content. Fully responsive.

**Screens:**
1. **Overview** — your sites at a glance; key stats (traffic, leads); quick action ("Forge new site").
2. **Sites** — grid/list of client websites; status (draft/live), last deploy. Open one →
3. **Site detail** — tabs: Editor (shell only for now), Content (pages, blog, products, services, portfolio), Media, Analytics, SEO, Domain, Publish/Deploy.
4. **Leads / CRM** — captured leads from site forms.
5. **Billing** — plans/tiers, usage.
6. **Domains** — buy / connect / DNS.
7. **Settings / Account.**

Futuristic touches: command palette (Cmd-K), keyboard shortcuts, fast inline actions, dark-first.

## Tech & structure
- React + Next.js; deploy to Netlify/Vercel.
- **Design tokens as the single source of truth** — the entire "Obsidian & Ember" theme lives in one tokens file (colors, type, spacing, radius, shadow, motion). Swappable, consistent. (Cogito: sources of truth first.)
- A reusable **themed component library** (Button, Card/Panel, Sidebar, Topbar, Table, Modal, Toast, Tabs, Form controls, Command palette). This library is the reusable "ultimate structure."
- Accessibility + performance budgets defined up front.

## Build method (Cogito phases)
1. **Assess current state** — get the existing CMS (repo / stack / screenshots); map keep vs. replace.
2. **Spec** — confirm screens, must-keep features, theme intensity, Messmer-vs-general.
3. **Tokens + shell first** — build the design-token file and the app shell before any screen.
4. **Build screen by screen, each on a live preview URL** — you react on your phone to the real thing.
5. **Verify** — screenshots → fix by cause; contrast/perf checks.
6. **Checkpoint** — state file (decisions, URLs, lessons) saved to the cogito repo.

## Answer these before building
- Where does the current CMS live (repo / stack), and can you share screenshots?
- Theme intensity to start: Full Flame or Low Ember?
- Messmer-led specifically, or general Elden Ring?
- Which existing features must stay exactly as they are?
- Editor's deep rebuild in scope now, or just its shell/placeholder?

## Definition of done
- New themed app shell + all listed screens reshaped; responsive; AA-accessible; fast.
- One design-tokens source of truth + a reusable themed component library.
- Deployed to a live preview; checkpoint saved.

## How it ladders to the bigger goal (Cogito)
- The tokens + component library become a reusable **themed-dashboard structure in the cogito repo** — the next build reuses it (compounding).
- A clean, well-structured shell is the home the real **editor** plugs into next.
- CMS cockpit + reusable structure + AI site-generation = the **Mini-Squarespace** platform. This reshape is the cockpit — step one.
