# Checkpoint — AI teacher built, deployed & live-tested; shared brain switched ON (2026-06-15, eve)

A very large session. The personalised AI teacher went **plan → built → deployed → tested
by the user**, and the **share-the-brain-across-repos** foundation was switched on and verified.

## The teacher — built, deployed, PRIVATE, working
- **Engine (file-native):** `skills/cogito-teacher/SKILL.md`, `learners/primary/profile.md`,
  `scripts/cogito-teach.sh`. Constrained tutor: hint-ladder, content-LOCK, mastery gate.
  Proven on **2 live lessons** (retrieval-practice recalled; adenosine derived).
- **Browser app:** `scripts/cogito-serve.sh` (local) + `teacher/index.html` (2D voice chat)
  + `teacher/avatar.html` (3D, CC0 "RobotExpressive" avatar via a drop-in glTF loader).
  Voice + mic, review **and** mastery write-back (server), per-learner (sibling scaffold
  ready), WebXR-wired.
- **DEPLOYED to Vercel** — project **cogito**, **private behind Vercel auth (user wants it
  private)**. Prod: `cogito-jfl-lol-projects.vercel.app` (`/` = 2D, `/avatar.html` = 3D).
  Brain = `api/chat.py` serverless fn (self-contained, free OpenRouter models, key =
  `OPENROUTER_API_KEY` env). **User confirmed: it speaks + the mic works.**
- **Feedback:** voice still robotic, teaching slightly better.
  - Warmer persona → **deployed (live)**.
  - **Neural voice** (Kokoro in-browser, falls back to browser TTS) → **committed on the
    branch, NOT deployed** (deploy interrupted + user paused). Picks up clean next time.
- Verifying the private deploy from here used the user's Vercel **Protection Bypass** secret
  (transient — never stored).

## The shared brain — foundation ON + verified
- **READ** (free, public, built + proven): `scripts/cogito-sync.sh` + a SessionStart hook
  loads the whole brain into any repo's session.
- **WRITE**: `COGITO_TOKEN` (fine-grained PAT, Contents:read+write, **cogito-only**) —
  user created + stored; **VERIFIED LIVE** this session (wrote a commit to a throwaway
  branch, then deleted it; main untouched). Write-back is ON.
- **Per-repo wiring still to do** (paint, the dashboard, future repos): install sync +
  capture **from each repo's own session** — cogito sessions are walled to cogito, can't
  reach other repos from here.
- **"Ultimate build dashboard"** = a future spoke: the control room over all projects,
  wired to the brain the same way.

## Decisions / corrections carried forward
- `main` pushes need **explicit per-time authorization** (classifier enforced; one "deploy
  it" is not standing permission). Brain-file FF to `main` via the converge hook is the
  authorized channel.
- Faceless is now set as **local git config** (Cogito) so merges don't slip to "Claude".
- Vercel deploy stays **private** until the user says publish.
- Token = **least privilege** (cogito-only, contents-only).

## Open / next
- Deploy the neural voice → user tests. If still robotic → a small **paid** model/voice is
  the real warmth lever (free models cap it).
- Wire **paint** + build the **dashboard**, each from its own session ("wire this to the brain").
- Grow neuroscience **lessons** (content) over time — the real "training".
- Lessons banked this session: council-consensus-is-an-echo, wait-for-dev-server-with-curl,
  install-eyes-when-no-reachable-URL, scan-LLM-verdicts-don't-first-token-parse,
  no-Box3-on-a-skinned-model-at-load, set-faceless-as-local-git-config, test-on-a-sandbox.
