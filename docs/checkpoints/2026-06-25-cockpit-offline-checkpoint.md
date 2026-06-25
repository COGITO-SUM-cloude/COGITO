# Checkpoint — 2026-06-25 — Cogito brain pipeline + BIHO desktop cockpit

Paste/upload this at the start of the next session. Resume pointer: `docs/ACTIVE-MISSION.md`.
Next work is in the **terminal** (idkwhatimdoing) — use the Hermes/Claude-Code handoff prompt.

## Decisions (canonical, verified)
- **Brain write-back loop** = drain → review → Accept opens an **append-only PR** (separate
  least-privilege `COGITO_BRAIN_TOKEN`, never pushes main) → **hub gate auto-merges** safe
  lesson PRs and holds edits/removals/`supersedes:`/SKILL.md/multi-file for the owner's one-tap.
- **Cockpit = a private LOCAL app on the Linux laptop** (clickable `.desktop` → chromeless
  window). Confirmed opening.
- **Offline** = switchable Mongoose↔NeDB (`COGITO_LOCAL_DB=1`), one-file local store,
  auto-backups, cloud→local migration. Proven offline under true network isolation.
- **Guards on**: no `git push … main` without an explicit per-time "merge to main"
  (`cogito-guard.sh`; sentinel `COGITO_ALLOW_MAIN_PUSH=1`); no TLS-disable. Faceless commits.
- **$0**; Linux just runs it (no signing/Gatekeeper/Apple anything).

## Current state — what exists, where
- **COGITO `main` @ 19ee9f7**: `scripts/cogito-{drain,control,guard,gate-check}.sh`,
  `.github/workflows/brain-merge.yml`, `prototypes/cogito-screen.html`, the ledger (~94 lessons).
- **idkwhatimdoing `main` @ 1f94481**: `src/lib/{db,backup,brain}.ts`, the 5 models refactored
  to the switchable layer, `src/app/api/brain/*`, `dashboard/brain/page.tsx` (live), `linux-app/`
  (launcher + install), `scripts/migrate-to-local.mjs`, dep `@seald-io/nedb`.
- **Owner's laptop** (Debian 12 / ChromeOS Crostini): app installed on **port 3100** (Hermes
  holds 3000); `~/.config/biho-cms.env` = `COGITO_LOCAL_DB=1` + `BIHO_PORT=3100`; local DB at
  `~/.local/share/biho-cms/db` with migrated data (users 1, sites 1=paint, projects 2,
  formsubmissions 6) + backups. Both branches merged to `main`.

## Open questions / next actions
- **Delete the CMS's Vercel deploy** (owner, via the Vercel dashboard) to run laptop-only.
  Caveat: removes clients' *online edit link* (NOT their live sites); **keep Atlas** as the
  safety net + for any future online client surface.
- **Brain loop full-on**: set `COGITO_BRAIN_TOKEN` + `COGITO_SATELLITE_OUTBOXES` in the CMS env.
- **NEXT (terminal, local Claude Code)**: add a **Hermes panel** (WhatsApp gateway, local
  `:3000`) + a **Claude Code panel** to the cockpit. Discover their APIs locally; spec before building.
- Deferred: a slim *online* client-edit surface; optional offline "queue publish, deploy when online".

## Corrections this session (highest-value memory)
- **Owner is on LINUX, not Mac** — I assumed Mac (built a Mac `.app` + ran a Mac-framed
  council). Rebuilt for Linux. → confirm OS before OS-specific work.
- **"checkpoint" / "continue" / "you have my word" ≠ main consent.** Only an explicit
  "merge to main" authorizes a main push. (Honored throughout.)
- **The offline adapter compiled but was missing `.exists()`** — the cast to Mongoose's type
  hid the gap; the *live* offline test caught it. → live-test shimmed APIs; inventory exhaustively.
- **The council's four voices were all one base model** → discount same-model "consensus",
  weight the grounded dissent.

## Lessons ledger
Appended live to `skills/cogito-protocol/LESSONS.md` (repo + installed). New this session:
shell `&&`/`||` precedence (the ROOT bug), serverless→DB-not-files, council decorrelation,
OS-assumption, shim-cast-hides-missing-methods.
