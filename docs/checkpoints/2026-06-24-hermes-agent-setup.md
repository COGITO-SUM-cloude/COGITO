# Checkpoint — 2026-06-24 — Hermes Agent setup (owner's personal assistant: WhatsApp + free brain + Claude Code/Max delegation)

## Mission
Side-quest, not the teacher/dashboard mission. Owner asked "help me set up my Hermes
agent" — the Nous **Hermes Agent** app on his own Linux machine (`/home/mesmer`, not this
repo). It was crashing before it could answer (HTTP 400: pointed at GitHub Copilot with a
classic PAT, which Copilot rejects). Real goals that emerged: (1) get it running, (2) **text
it via WhatsApp**, (3) use his **Claude Max** subscription for heavy work, (4) buying advice
for a local-AI laptop, (5) example uses.

## Decisions (the brain path took three tries)
- **Brain = free Google Gemini `gemini-3.5-flash`** via a Google AI Studio key. Reached only
  after two dead ends: Claude-as-direct-brain needs Max **+ purchased extra credits** (he has
  none → blocked), and **GLM-4.7 via Z.AI was NOT free** (direct API 429'd "insufficient
  balance"; the free GLM only lives on Puter, which Hermes can't use). Pick "best free brain
  that sets up easily" → Gemini Flash.
- **WhatsApp = Baileys self-chat (QR)**, no second number — he texts his own "Message
  Yourself" chat. Chosen over the official Business API (simpler, personal).
- **Number fix:** the QR first linked his **old** number (7802) because that phone's WhatsApp
  was still on it; he **changed his WhatsApp number to 2635** in-app, then re-linked.
- **Persistence:** `hermes gateway install` as a **systemd user service**, auto-start on
  login/boot.
- **Claude Max usage = Claude Code CLI delegation**, NOT Claude-as-brain. Installed
  `@anthropic-ai/claude-code`, logged into Max (OAuth), Hermes delegates via the bundled
  `claude-code` skill ("use claude code to …"). Uses the subscription's *included* allowance,
  no extra credits.

## Current state (all on the owner's machine — only this repo's checkpoint + lessons changed)
- Hermes Agent **v0.17.0**, brain = **gemini-3.5-flash (free)** — running, answers in-terminal.
- **WhatsApp self-chat WORKS** (received + replied; home channel set via `/sethome`). Gateway
  installed as a systemd service (survives terminal close; auto-starts on boot).
- **Claude Code installed + logged into Max**; Hermes delegates to it — **verified** (it wrote
  `hello.txt`, a poem, via Opus 4.8 on Max, handed off by Hermes-on-Gemini). Full chain proven.

## Open questions / loose ends
- **Free Gemini quota exhausted** at session end ("exceeded your current quota") on a heavy
  clone-and-analyze task. The **Cogito-ideas demo** (Claude Code reads the cogito repo →
  suggest 3 build ideas) was interrupted by the quota **and** a duplicate-gateway shutdown —
  **not completed**. Resume: run it **directly in the Claude Code tab (Max)**, bypassing Gemini;
  to revive Hermes, wait for the Gemini reset or switch its brain to his OpenRouter key.
- **24/7 reachability:** Hermes only answers while the computer is **on + awake** (local agent).
  For always-on, run Hermes on a mini-PC / Pi / cloud box. Not set up.
- **Laptop:** he wants local-first AI (occasional cloud). Recommended **System76 Oryx Pro 16"
  (~$2,720, RTX 5070 ≈16GB VRAM)** for the $3k budget; confirm exact VRAM at config.

## Corrections / what I got wrong
- Told him **GLM-4.7 was "free"** → it wasn't; sent him through a Z.AI signup that dead-ended
  on a paywall. (→ lesson captured.)
- Minor: "press Enter" was taken literally (he typed the word "enter"). Say "tap the Enter key".

## Next step
Finish the Cogito-ideas demo via Claude Code (Max) directly; revive the Hermes brain (Gemini
reset or OpenRouter); then decide on a paid Gemini key / an always-on box / the laptop.

## Guardrails reaffirmed
Faceless (commit as Cogito); checkpoint doc stays on the feature branch — only brain blobs
converge to `main` via the hook; verify by running, not "probably"; plain + short with this
non-technical owner.
