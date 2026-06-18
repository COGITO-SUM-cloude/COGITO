# ACTIVE MISSION — resume pointer
_Short on purpose: read into every session, costs tokens each turn. Talk adult-to-adult: plain, short, no jargon, no "baby steps" (the user is non-technical but NOT a child)._

When the user says "Cogito": greet in one line, confirm, continue. Don't re-interview.

## Mission — the AI teacher is BUILT + DEPLOYED; now make it good + give the brain to every project
The personalised AI teacher exists and is live (private). Two active threads:
1. **Polish the teacher** (warmth: voice + model).
2. **Share the brain across all repos** (the "Cogito everywhere" hub-and-spoke) + build the **dashboard** (the control room over all projects).
Everything stays $0 + file-native where possible; a small paid model is the one open cost question.

## Where things stand (2026-06-17) — detail: `docs/checkpoints/2026-06-17-dashboard-mock-and-cms-deploy.md` (earlier: `2026-06-15-teacher-deployed-brain-shared.md`)
- **Teacher: built, deployed, PRIVATE, works.** Engine = `skills/cogito-teacher` + `learners/primary/profile.md` + `scripts/cogito-teach.sh`; app = `scripts/cogito-serve.sh` + `teacher/` (2D `index.html`, 3D `avatar.html` + CC0 robot). Review + mastery write-back. Live on Vercel project **cogito** (private behind Vercel auth) — `cogito-jfl-lol-projects.vercel.app` (`/`, `/avatar.html`); brain = `api/chat.py` serverless fn (free OpenRouter models, `OPENROUTER_API_KEY` env). User confirmed it speaks + mic works.
- **Voice:** still robotic. Warmer persona = deployed. **Neural voice (Kokoro) = committed on branch, NOT deployed** (paused). Next: deploy it → user tests → if still flat, a small **paid** model/voice is the real lever.
- **Shared brain: ON.** `COGITO_TOKEN` (fine-grained, contents:rw, cogito-only) set + **verified live** (write-back works). READ half = `scripts/cogito-sync.sh` + SessionStart hook. **To work across repos: start the web session with BOTH repos via the "+" selector at launch** (a session reaches any repo the GitHub account can see; can't add one mid-session). This supersedes the old "a cogito session is walled to cogito" — that's only true if you didn't add the other repo at start.
- **Dashboard: first screen mocked.** A self-contained "control room" for Cogito — Map (how it works) + Live status + an Accept/Reject **Inbox** for brain edits — at `prototypes/cogito-screen.html` (branch `claude/brave-carson-8sa2lm`; sent to user). Sample data; live-dots illustrative; Accept not yet wired. Becomes real by porting into the CMS (idk-whatimdoing).

## Resume here (next)
- **Brain write-back** (council + live test 2026-06-16; design → `docs/checkpoints/2026-06-16-brain-writeback-council.md`): **SETTLED**. A satellite has NO safe write path to the hub (verified from paint: anon read works, but no gh, MCP is paint-scoped, and the only credential is COGITO_TOKEN which an agent must not wield). So: a satellite writes lessons to its OWN repo (`cogito-outbox.md`, standard lesson format) and a trusted NON-agent actor merges them into the brain. **Working today = human relay** (paste the outbox into a cogito session; zero infra, proven). **Deferred = an automated CI courier** (holds a scoped token, runs OUTSIDE agent sessions) — build only if the relay becomes a chore. The hub-write key never lives in an agent session.
- **Teacher polish**: deploy the neural voice; decide the paid-model question; grow neuroscience lessons (content = the real "training").
- **CMS (`idk-whatimdoing`) — DEPLOY DONE; real blocker is AI credit.** ~~deploy fix~~ The "Obsidian & Ember" redesign is merged to `main` AND live in production (verified 2026-06-17 via Vercel: prod deploy = `main` HEAD `74200a7`, READY; the live login is the new themed one). The actual open issue: **the AI assistant produces no output** — the Anthropic account has no credit and the OpenRouter free model is rate-limited (429). **#1 next action is owner-side: fund one provider** (a few $ on Anthropic, or a paid OpenRouter model). The editor/CMS/board (P0–P3) are live and working.
- **Dashboard:** first screen mocked (above). Next: iterate with user → port into the CMS → wire real logged-out live-checks + the Accept→brain path (safe key, non-agent relay).
- **Status note:** step-A cleanup, hardened converge hook, TLS fix are all **on `main`** now (the earlier "step-A PENDING push to main" was stale). Only the dashboard mock + a paint-prompt doc sit on branch `claude/brave-carson-8sa2lm`, not main — non-critical.

## Guardrails (always on)
- One brain = `main`. The converge Stop hook pushes **brain files ONLY** to `main` (synthetic commit on `origin/main`; hardened 06-15 so a withheld branch commit can't ride along). **A direct/manual `main` push needs an EXPLICIT per-time yes — a generic "go"/"continue" is NOT main consent** (classifier enforces this; one "deploy it" is not standing permission).
- Faceless: now set as LOCAL git config (`Cogito <cogito@users.noreply.github.com>`) so merges don't slip to "Claude". Nothing personal in artifacts.
- The Vercel deploy stays **private** until the user says publish. Keys = least privilege, read in-process never argv.
- Verify by running/re-reading — never "probably / passed". Talk plain + short (the #critical comms lesson).
