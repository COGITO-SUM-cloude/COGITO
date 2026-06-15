# Project 07 — VR AI Teacher: the complete toolkit + build plan

_Output of a 5-researcher Cogito council (2026-06-15), cross-checked against the
project's hard constraints and the standing decision in
`docs/checkpoints/2026-06-15-ai-teacher-pivot.md`. This is the reference artifact:
every tool we will need, the backup for each, the joints between them, and the order
to build. Written so a later session can start here and not re-research._

---

## 0. The strategic principle (read first)

The user's ask was "get as many tools as possible so we never stall mid-build."
The corrected form — and what this plan delivers — is the opposite of a big catalog:

> **The smallest kit that covers every variable.** For each NEED: ONE primary tool
> + ONE fallback, each chosen so it can't dead-end us. Pre-stage them so a problem
> we already foresaw never costs us a build-day. Free-first; a paid lever only where
> it's clearly decisive, and flagged as optional.

Why not "max tools": every extra tool is maintenance + a way to break + context-tax.
This project has already been bitten by bloat (see the #memory lessons). Minimal-and-
complete beats maximal-and-tangled.

---

## 1. How this sits on what's already decided

The pivot checkpoint already locked the shape: a **presentation-agnostic, learner-
agnostic "golden structure"** — build the teaching engine first, prove it on the USER
in plain text (no headset, no fast hardware), then add VR as a *skin* and swap the
learner for the brother. This plan does NOT relitigate that. It fills in the toolkit
for each layer and pre-stages the VR skin so it's ready when the engine is proven.

So the work runs on **two tracks**:

- **TRACK A — the brain (BUILD NOW):** golden-structure layers 1–4 (Learner Profile,
  Adaptive Loop, Progress Memory, Content Engine). Pure files + prompts, tested on the
  user's subject (neuroscience). No VR. This is the long-pole and the priority.
- **TRACK B — the VR skin (PRE-STAGE NOW, build later):** the 3D world, the body/face,
  the voice. Researched now so when Track A's loop works, we bolt the skin on without
  stalling. Built flat-screen-first, headset last.

---

## 2. The merged toolkit — every layer, primary + fallback

Risk = chance the pick dead-ends us. Cost is monthly unless noted.

### Layer 0 — The 3D world (Track B)

| Need | Primary | Fallback | Cost | Pre-empts | Dead-end risk |
|---|---|---|---|---|---|
| 3D / WebXR engine | **Three.js** (matches the lip-sync linchpin — see §3) | Babylon.js | $0 | Rebuilding lip-sync ourselves | Low |
| Flat-screen → VR | Three.js `WebXRManager` + an "Enter VR" button; `OrbitControls` on desktop | — | $0 | Rewriting the scene for VR | Low |
| Hosting (front-end) | **Netlify** — free, HTTPS by default, git-push deploy, per-branch preview URLs | GitHub Pages | $0 | WebXR/mic both REQUIRE HTTPS | Low |
| Headset debugging | **Meta Immersive Web Emulator** (Chrome ext — fakes a Quest on desktop) | `adb reverse` + `chrome://inspect` over USB | $0 | Slow blind test cycles on the headset | Low |
| Assets / environment | Poly Pizza + Kenney.nl (CC0 low-poly), glTF/GLB only | Sketchfab CC0 filter | $0 | Needing a 3D artist; over-budget scenes on Quest | Low |

### Layer 1 — The body + face (Track B)

| Need | Primary | Fallback | Cost | Pre-empts | Dead-end risk |
|---|---|---|---|---|---|
| Avatar source | **VRoid Studio → VRM → GLB** (add ARKit blendshapes via HANA_Tool) | Avaturn (free tier, GLB w/ ARKit shapes) | $0 | RPM shutdown + non-commercial license blocking us | Low |
| Avatar+lipsync engine | **TalkingHead.js** (MIT, Three.js) — loads the GLB, plays Mixamo clips, drives lip-sync from visemes, does blinks/expressions — **THE LINCHPIN** | three-vrm + custom blendshape driver | $0 | The hardest joint (mouth ↔ voice) — solved end-to-end | Med* |
| Body animation | **Mixamo** (idle, talk, point, nod, think; retarget in Blender, bake to GLB) | Mesh2Motion (open-source, browser) | $0 | Needing an animator | Low |
| Expression + gaze | ARKit-52 blendshapes + VRM `LookAt` + procedural blink | Hardcoded happy/neutral/thinking keyframes | $0 | A dead-eyed, lifeless teacher | Low |

\*Med only because it depends on the voice layer emitting viseme timing — which our
primary voice pick does natively (§3, §4).

### Layer 2 — The voice: mouth + ears (Track B)

| Need | Primary | Fallback | Cost | Pre-empts | Dead-end risk |
|---|---|---|---|---|---|
| Teacher's voice (TTS) | **HeadTTS + Kokoro** (browser, neural, FREE) — and it emits Oculus visemes natively, feeding TalkingHead.js directly | ElevenLabs Flash v2.5 (paid, only if a kid tunes out) | $0 / ~$22 opt. | Robotic voice killing engagement; silent mouth (no visemes) | Low |
| Hearing the student (STT) | **Browser Web Speech now** (adult tester) → **local whisper.cpp** when the child uses it (audio never leaves device) | Deepgram Nova-3 (cloud, only if accuracy forces it; $200 free credit) | $0 | Child-voice errors + COPPA biometric-data exposure (§3) | Med |
| Turn-taking / barge-in | **@ricky0123/vad-web** (Silero VAD, browser WASM) | WebRTC silence detection | $0 | App can't tell when the kid stopped / interrupted | Low |
| Conversation loop | **Modular** STT → LLM → TTS (stream each stage) | OpenAI Realtime API (only if latency forces it) | $0 + tokens | A black-box API that locks out our brain + lip-sync hooks | Low |

### Layer 3 — The teaching brain + student model (Track A — BUILD FIRST)

| Need | Primary | Fallback | Cost | Pre-empts | Dead-end risk |
|---|---|---|---|---|---|
| Student model | **Extended FSRS** — per skill: `stability`, `difficulty`, `last_review` (3 numbers) in JSON; upgrades the existing Leitner reviewer in place | BKT-lite (4 floats/skill) | $0 | DKT's training-pipeline hell; pure forgetting blindness | Low |
| Mastery gate | `retrievability ≥ 0.85 AND difficulty < 7 AND reps ≥ 3 → advance`, computed at session start | BKT `P(mastery) ≥ 0.9` | $0 | Advancing a child before they're ready | Low |
| Pedagogy loop | **Constrained hint-ladder prompt**: open Socratic question → targeted hint → worked example → reveal only if stuck after 3 | Fixed Socratic template | tokens | LLM giving the answer (kills the testing effect) | Low |
| Content retrieval | **BM25 over the lesson `.md` files** (no vector DB) | Tag-based YAML frontmatter index | $0 | A paid vector DB fighting our file-native rule | Low |
| Skill graph | `prereqs:` in each lesson's YAML frontmatter; gate-unlock on prereq mastery | Flat `curriculum.json` sequence | $0 | Teaching a skill whose prereqs aren't mastered | Low |
| Anti-hallucination | **Content-locked prompt**: "teach ONLY from the lesson below; if it's not there, say 'let me find a source' and defer" | Second self-check pass | $0 | A child learning confident wrong facts — the worst failure | High without it |
| Engagement | streak + stars + free-text notes in the profile file | Verbal encouragement from profile context | $0 | Kid not coming back | Low |

### Layer 4 — The glue + the repair tools (spans both tracks)

| Need | Primary | Fallback | Cost | Pre-empts | Dead-end risk |
|---|---|---|---|---|---|
| Brain ↔ browser bridge | **One small local HTTP/JSON server** (Node or Python) that holds the API key, sets CORS, routes LLM calls, reads/writes the brain files | MCP server (only if Claude Code must call the brain as a tool too) | $0 | Keys leaking into the browser; CORS blocking the first call | Low |
| State persistence | Plain git-tracked files (the existing pattern) | SQLite (one file) only if concurrent writes appear | $0 | Losing progress between sessions | Low |
| LLM routing | **OpenRouter `models` fallback chain**: Hermes-3 → mistral-small → Claude Haiku, `allow_fallbacks:true` | Direct Claude key as last resort | usage | Rate limits stalling the tutor | Med |
| Observability (fix-fast) | **Arize Phoenix** local (`pip install`, zero cloud, no Docker) — traces every prompt/response | Langfuse self-hosted (needs Docker) | $0 | Hallucinations + bad turns invisible when debugging | Low |
| Automated tutor testing | **pytest** with scripted-student fixtures ("confused kid", "fast learner") + assertions on the tutor's move | Langfuse datasets | $0 | Teaching-loop regressions slipping through | Low |
| Coding agent | **Claude Code** (this) + **Hermes-3 the MODEL** via OpenRouter for the tutor | — | usage | — | — |

**Agent-framework verdicts (the ones topping OpenRouter that the user flagged):**
- **Hermes Agent (Nous)** — use the *model* (Hermes-3) as a cheap tutor/council voice; **skip the agent wrapper** (heavyweight, solves a different job).
- **Kilo Code** — **skip.** It's an IDE plugin; our engineering is Claude Code in the terminal.
- **OpenClaw** — **skip.** Messaging-platform automation, unrelated to tutoring or VR.

---

## 3. The council's cross-checks (where comparing the panel beat any single answer)

This is the part a single researcher would have gotten wrong.

1. **Engine choice was driven by the wrong layer.** The runtime researcher logically
   picked Babylon.js for a generic scene. But the embodiment AND voice researchers —
   independently — both built on `TalkingHead.js` + `HeadTTS` (same author,
   met4citizen), which solve avatar + animation + lip-sync + viseme-timed neural TTS
   together, for free, in **Three.js**. Choosing Babylon would force us to rebuild that
   linchpin by hand. **Resolution: Three.js**, because the hardest joint is already
   solved there. (Babylon's reasoning was sound in isolation — this is exactly the blind
   spot a decorrelated panel exists to catch.)

2. **Avatar contradiction, made moot.** One researcher recommended Ready Player Me;
   another reported RPM shut down (2026-01-31) *and* that its license is non-commercial
   — which would block a real kid-facing app regardless. **Resolution: VRoid Studio**
   (free, commercial-OK, kid-appropriate). The shutdown claim is unverified but doesn't
   matter; the licensing point decides it either way.

3. **Free + child-privacy vs. the best STT.** Deepgram is the most accurate, but it's
   paid and it ships a *child's* audio to a third party — and as of COPPA 2.0
   (in force 2026-04-22) a minor's voice recording is biometric data needing verifiable
   parental consent. **Resolution: sequence it** — free browser STT now (adult tester) →
   **local whisper.cpp** when the brother is the user (audio never leaves the device) →
   Deepgram only if accuracy genuinely forces it, with a consent flow.

4. **Remote use needs a host the front-end host can't provide.** Netlify serves the
   static front-end, but the brain server holds the API key and must run code — fine on
   `localhost` for the user-as-tester, but the brother using it from home will need the
   brain server hosted (a free serverless tier). **Resolution: defer** — localhost is
   correct until the loop is proven; flagged here so it doesn't surprise us later.

---

## 4. The integration seams (the joints that bite if unplanned)

The tools are fine alone; failures live in the gaps between them.

- **Lip-sync timing seam (the big one):** the mouth needs `{time, viseme}` events synced
  to the audio. HeadTTS emits Oculus visemes with ms timestamps → TalkingHead.js consumes
  them natively. If we ever swap to a TTS without timing (e.g. a local voice), the fallback
  is `rhubarb-lip-sync-wasm` (feed it the WAV, get viseme timings back, +~200ms).
- **Audio + VR unlock seam:** browsers block audio and WebXR until a user gesture. The
  *same* "Start Lesson / Enter VR" click must unlock `AudioContext` AND start the XR
  session AND request the mic. One button, three unlocks.
- **Keys-stay-server-side seam:** the API key lives in the brain server's `.env` only —
  never the browser, never argv, never a log (a #critical project lesson). The browser
  calls `localhost:PORT/api/...`; the server holds the secret.
- **HTTPS everywhere seam:** WebXR and `getUserMedia` both need a secure context.
  `localhost` is exempt for dev; any other test URL must be HTTPS (Netlify gives it free;
  for wireless Quest testing use a Cloudflare tunnel, not a self-signed cert).
- **CORS seam:** front-end (`:5173`) and brain (`:3001`) are different origins in dev —
  one `cors({origin})` line on the server, or it's the first-hour blocker. Disappears in
  same-origin production.
- **Quest debug seam:** developer mode must be enabled in the Horizon app and USB
  debugging accepted *in the headset* before `adb`/`chrome://inspect` see anything.
- **glTF-only seam:** the browser speaks glTF/GLB. Mixamo (FBX) and VRoid (VRM) both pass
  through a one-time Blender/HANA_Tool bake to GLB — script it once, don't redo per asset.
- **Context-tax seam (our standing rule):** the student model must inject only the
  **active skill set** (5–10 skills in rotation), not all skills; archive mastered ones.

---

## 5. Pre-stage NOW vs. build LATER

**Pre-stage NOW (cheap, unblocks everything, mostly one sitting):**
- Track A: lock the `skills.json` schema (§6 of the brain research) and the FSRS
  retrievability function; extend the SessionStart hook to load the active skill set;
  add the anti-hallucination "teach only from context" line to the tutor prompt.
- Track B: create the teacher avatar in VRoid → HANA_Tool → GLB; pull the core Mixamo
  clips and bake them in; this single GLB is what everything else hangs on.
- Glue: `.env` + `.gitignore` for the key; the OpenRouter fallback chain; `pip install
  arize-phoenix` and one trace decorator; a Netlify account linked to the repo.

**Build LATER (only when its predecessor is proven):**
- Hand-tracking UI, Quest passthrough/AR, LOD swaps, KTX2 compression pass — all need a
  real headset; flat-screen first.
- ElevenLabs upgrade — only if free voice bores the kid.
- whisper.cpp local STT swap — when the brother (child) onboards.
- Brain-server hosting — when use moves off the user's machine.
- MCP "expose the brain" server, the self-check anti-hallucination pass, cross-session
  analytics — refinements after the loop works.

---

## 6. Build order (de-risked, structure-first, no headset needed until Phase 5)

- **Phase 0 — Pre-stage** (above): accounts, the avatar GLB, the `.env`, Phoenix.
- **Phase 1 — The brain, text only, on the user.** Extend the learning log into the FSRS
  `skills.json`; wire the constrained hint-ladder tutor prompt + BM25 over the lesson
  files. Prove the adaptive loop in plain text on neuroscience. (Golden-structure 1–4.)
- **Phase 2 — The bridge.** **(DONE 2026-06-15 — `scripts/cogito-serve.sh` + `teacher/`.)**
  Small local HTTP server exposes the brain; a plain browser
  page runs the same loop (still 2D). Keys server-side, CORS set.
- **Phase 3 — Voice.** **(DONE 2026-06-15 — browser Web Speech TTS+STT in `teacher/`, text
  fallback; verified served + JS-valid, audio needs the user's browser. HeadTTS/Kokoro
  visemes deferred to Phase 4, where lip-sync needs them.)** Add HeadTTS/Kokoro (TTS) +
  browser STT + Silero VAD. The teacher talks and listens, still 2D.
- **Phase 4 — The body, flat screen.** **(DONE 2026-06-15 v0 — `teacher/avatar.html`: a
  procedural Three.js head whose mouth is driven by the speaking state, same brain+voice
  backend; rendered + screenshot-verified headless. Real VRoid avatar + TalkingHead.js
  viseme lip-sync drop into this same slot next.)** Three.js scene + VRoid avatar +
  TalkingHead.js lip-sync wired to the voice. The avatar teaches on a normal monitor.
  *Structure proven, skin added — no headset yet.*
- **Phase 5 — VR.** **(CODE-READY 2026-06-15 — WebXR `immersive-vr` + an Enter-VR button
  wired into `teacher/avatar.html` via `renderer.xr`; flat-screen render verified intact,
  in-headset behavior UNVERIFIED — needs a Quest. Perf pass + KTX2 on real hardware.)**
  Flip on the WebXR session; perf pass (draw calls, KTX2, one light); test on a Quest.
- **Phase 6 — The brother.** Swap to the child-scaffolded profile + his placement results;
  switch STT to local whisper.cpp for privacy; turn on the engagement layer.

---

## 7. Cost ledger (honest)

**$0 to start and through Phase 5.** Free picks cover the whole stack: Three.js,
TalkingHead.js, HeadTTS/Kokoro, VRoid, Mixamo, Silero VAD, Netlify, Phoenix, BM25, FSRS,
browser STT. Plus the existing Claude Pro window + OpenRouter free tier.

**Optional paid levers, each only if proven necessary, each flagged:**
- ElevenLabs Flash ~$22/mo — only if a kid disengages from the free voice.
- Deepgram — only if free/local STT can't understand the child (has $200 free credit).
- ~$5 OpenRouter credit — for heavy testing days beyond the free tier.

---

## 8. Open decisions for the user (recommended default in bold; none block the plan)

1. **First subject for your own teacher loop: neuroscience/cognition** (your learning log
   already points there) — or name another.
2. **Stay free on voice until a kid actually tunes out** (then consider the $22 ElevenLabs
   lever) — or commit to it now.
3. **Defer remote hosting; run on localhost while you're the tester** — or set up the
   free serverless brain-host early.

---

## 9. Provenance

Five parallel `general-purpose` researchers (Sonnet), one slice each — runtime,
embodiment, voice, brain/student-model, glue/infra — web-researched (2026-06) and
returned primary+fallback decision tables with sources. Synthesized + cross-checked
(Opus) against the project's hard constraints and the pivot decision. Full raw reports
are in this session's transcript; the four cross-checks in §3 are where the synthesis
overrode an individual panelist.
