# Checkpoint — VR AI Teacher: Phases 1–5 built in a day (2026-06-15)

Branch `claude/focused-tesla-ipuuh9` (PR #1). Free, file-native, faceless throughout.
Plan: `docs/projects/07-vr-teacher-toolkit.md`. Engine: `skills/cogito-teacher/SKILL.md`.

## What's built + how it was verified
- **Phase 1 — brain/engine.** `skills/cogito-teacher` (constrained tutor: hint-ladder,
  content-LOCK, mastery gate, adult/child mode), `learners/primary/profile.md` (profile +
  per-skill mastery map), `scripts/cogito-teach.sh` (session board). **Proven on 2 live
  lessons**: retrieval-practice recalled (graded → box 2); adenosine derived by the user
  (mechanism + the caffeine-crash, unprompted).
- **Phase 2 — bridge.** `scripts/cogito-serve.sh` (localhost server, Python stdlib, no
  deps; key stays server-side via `cogito-openrouter.sh`; binds 127.0.0.1) + `teacher/
  index.html`. **Verified end-to-end** (health, retrieval opener, a teaching turn).
- **Phase 3 — voice.** Browser Web Speech TTS+STT + text fallback in `teacher/index.html`.
  **Verified** served + JS-valid; real audio runs in the user's browser.
- **Phase 4 — 3D body.** `teacher/avatar.html` — procedural Three.js head, mouth driven by
  the speaking state, same brain+voice backend. **Rendered + screenshot-verified** via the
  Chrome "eyes"; opened with the correct due-review question.
- **Phase 5 — VR-ready.** WebXR `immersive-vr` + Enter-VR button wired into `avatar.html`.
  Flat-screen **verified intact**; in-headset **UNVERIFIED** (no hardware).

## Key decisions (made autonomously under "make the best decision")
- Browser/WebXR/Three.js, not Unity (flat-screen-first, free, fastest to iterate).
- Reuse over rebuild (`cogito-review.sh`, `cogito-openrouter.sh`); **procedural placeholder
  avatar** (no missing-asset dead-end); a separate `teacher/` app so the public landing page
  (`web/`) is untouched.
- Council on CL4R1T4S → only one new pick survived the repo check: a **hard-capped working-
  rules stub** in `CLAUDE.md` (user opted in). Two of three picks were already built.
- Installed the Chrome "eyes" to screenshot — justified because the artifact lives on an
  unreachable container (no URL the user can open).

## Blockers (need the user or hardware)
1. **Phase 5 in-headset** — needs a Meta Quest to verify.
2. **The real face** — VRoid Studio is a GUI app; needs the user to make the avatar (or pick
   a free VRM/Ready-Player-Me URL) to drop into `avatar.html`'s slot.
3. **Phase 6 (the brother)** — needs his `docs/teaching/01-placement-check.md` results to
   build a child-scaffolded profile + Week-1 content.
4. **Real use off this container** — the brain server must run on the user's machine or a
   free serverless host, with `OPENROUTER_API_KEY` set there.

## Highest-value buildable-now next (no blocker)
- **Write-back**: server records pass/fail + mastery to the brain files automatically
  (completes the loop; currently read-only). Fully verifiable here.
- Neural voice + viseme lip-sync (HeadTTS/Kokoro) — upgrades Phases 3–4.
- More lesson objects (content) — partly the user's domain.

## Lessons banked today
Same-base-model council consensus is correlation not confirmation (the repo check
decorrelates); wait for a dev server with `curl --retry-connrefused`, not foreground sleep;
install the "eyes" + screenshot when the artifact is on an unreachable container.
