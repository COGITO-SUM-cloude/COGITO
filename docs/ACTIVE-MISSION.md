# ACTIVE MISSION — resume pointer
_Short on purpose: read into every session, costs tokens each turn. Talk adult-to-adult: plain, short, no jargon, no "baby steps" (the user is non-technical but NOT a child)._

When the user says "Cogito": greet in one line, confirm, continue. Don't re-interview.

## Mission — the AI teacher is BUILT + DEPLOYED; now make it good + give the brain to every project
The personalised AI teacher exists and is live (private). Two active threads:
1. **Polish the teacher** (warmth: voice + model).
2. **Share the brain across all repos** (the "Cogito everywhere" hub-and-spoke) + build the **dashboard** (the control room over all projects).
Everything stays $0 + file-native where possible; a small paid model is the one open cost question.

## Where things stand (2026-06-15 eve) — full detail: `docs/checkpoints/2026-06-15-teacher-deployed-brain-shared.md`
- **Teacher: built, deployed, PRIVATE, works.** Engine = `skills/cogito-teacher` + `learners/primary/profile.md` + `scripts/cogito-teach.sh`; app = `scripts/cogito-serve.sh` + `teacher/` (2D `index.html`, 3D `avatar.html` + CC0 robot). Review + mastery write-back. Live on Vercel project **cogito** (private behind Vercel auth) — `cogito-jfl-lol-projects.vercel.app` (`/`, `/avatar.html`); brain = `api/chat.py` serverless fn (free OpenRouter models, `OPENROUTER_API_KEY` env). User confirmed it speaks + mic works.
- **Voice:** still robotic. Warmer persona = deployed. **Neural voice (Kokoro) = committed on branch, NOT deployed** (paused). Next: deploy it → user tests → if still flat, a small **paid** model/voice is the real lever.
- **Shared brain: ON.** `COGITO_TOKEN` (fine-grained, contents:rw, cogito-only) set + **verified live** (write-back works). READ half = `scripts/cogito-sync.sh` + SessionStart hook. **To wire another repo (paint, dashboard): do it FROM that repo's own session** — cogito sessions are walled to cogito.

## Resume here (next)
- When in **another repo's session**: "wire this to the brain" → drop in `cogito-sync.sh` + hook + capture, then watch a real lesson land in the brain.
- **Teacher polish**: deploy the neural voice; decide the paid-model question; grow neuroscience lessons (content = the real "training").
- **Build the dashboard** (its own repo, wired to the brain).
- **Done (this session):** council auto-uses a non-Claude voice + names which model actually answered; converge hook hardened (brain-only to `main`; converges edits + appends) and bug-fixed — **all on `main`**. Optional, not yet done: silence the git-check nag (Stop-hook ordering); fix the hook's by-hand `../..` repo-path fallback.

## Guardrails (always on)
- One brain = `main`. The converge Stop hook pushes **brain files ONLY** to `main` (synthetic commit on `origin/main`; hardened 06-15 so a withheld branch commit can't ride along). **A direct/manual `main` push needs an EXPLICIT per-time yes — a generic "go"/"continue" is NOT main consent** (classifier enforces this; one "deploy it" is not standing permission).
- Faceless: now set as LOCAL git config (`Cogito <cogito@users.noreply.github.com>`) so merges don't slip to "Claude". Nothing personal in artifacts.
- The Vercel deploy stays **private** until the user says publish. Keys = least privilege, read in-process never argv.
- Verify by running/re-reading — never "probably / passed". Talk plain + short (the #critical comms lesson).
