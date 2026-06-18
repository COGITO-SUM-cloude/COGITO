# How to use your AI base

Plain-English guide to everything Cogito gives you, and the exact words to say to use
it. **None of this needs a Max plan** — it's all files in this repo, so it keeps working
on any plan, in any Claude Code session that has this repo open.

> One rule to remember: you talk to it in **plain English**. You don't run commands —
> you say what you want ("review this", "is it live", "write me a prompt for X") and the
> right tool fires.

---

## 1. The session loop (how every session should start)

Say **"Cogito"** at the start. It greets you, loads your memory (lessons + the active
mission), and runs the disciplined loop: take the mission → make the goal concrete →
red-team it → build in small verified steps → capture a lesson the moment something goes
wrong → checkpoint at the end. Say **"checkpoint"** anytime to save a state file.

The point: each session wakes up already knowing your projects, and every mistake
becomes a saved lesson so it never happens twice.

---

## 2. The agents — specialists you summon ("use the X agent…")

Each runs in its own fresh context and reports back. Just name it in plain English.

| Say this… | …and this agent runs | What you get |
|---|---|---|
| "review this before we ship" / "is this really done?" | **cogito-reviewer** | a fresh-eyes PASS/FAIL check against real signals (build, test, HTTP), not vibes |
| "check how the site looks" / "QA the homepage on mobile" | **design-qa** | renders the page desktop+mobile, reads the pixels, lists what's visually wrong |
| "is it actually live?" / "did it deploy?" | **deploy-verifier** | confirms the live site = the intended commit (real SHA + logged-out check) |
| "is this site ready for the client?" | **site-handoff-checker** | finds placeholder/unfinished content ("photo coming soon", lorem, fake numbers) |
| "will this rank on Google?" / "SEO audit" | **seo-auditor** | ranks title/meta/H1/alt/schema/sitemap issues by impact |
| "what projects did I start?" / "go through my old chats" | **project-archaeologist** | triages chat exports + repos into active / stalled / dead, with next moves |
| "did I leak a key?" / "scan for secrets" | **secrets-scanner** | scans files + full git history for committed credentials; tells you to rotate |
| (inside a council) "judge these answers" | **cogito-judge** | weighs several answers, returns the consensus / contradictions / blind spots |

---

## 3. The skills — know-how that fires automatically by topic

You usually don't call these by name; they activate when the work matches. The ones to
invoke on purpose:

| Say this… | …and this skill applies |
|---|---|
| (always on) | **cogito-protocol** — the disciplined session loop above |
| "write me a master prompt for X" / "optimize this prompt" | **prompt-architect** — turns a job into an optimized prompt (+ a saved library, below) |
| "convene the council" / "get multiple opinions on this" | **cogito-council** — several AI panelists with different lenses + a judge, for hard calls |
| "teach me about X" / (at session end) | **adaptive-learning** — grows *you* with small plain explanations, tracked in `docs/learning/` |
| "run a teaching session" | **cogito-teacher** — a structured tutor with mastery tracking |
| "/consolidate" (when lessons pass ~60) | **cogito-consolidate** — tidies the memory without losing anything |
| building/QA-ing a website | **web-build-loop** — prove a web change by real pixels + HTTP, never a green build |

### The saved-prompt library
Ready-to-paste master prompts for jobs that recur, in
[`skills/prompt-architect/library/`](../skills/prompt-architect/library/): the CMS
"improve text" assistant, local-service website copy, SEO metadata, and lead replies.
Open one, fill the `{placeholders}`, paste it where the AI runs. It grows over time —
when a new prompt works well, it gets saved back.

---

## 4. The hooks — what runs on its own (no action needed)

| When | What happens |
|---|---|
| session start | loads your lessons + active mission into context |
| every prompt you send | surfaces the 1-3 past lessons relevant to it |
| before a risky Bash command | the safety guard blocks `rm -rf /` and self-killing `pkill -f` |
| session end | auto-saves your brain (lessons + mission) to `main` |

---

## 5. Your memory (the part that compounds)

- **Lessons ledger** — `skills/cogito-protocol/LESSONS.md`: earned rules in the shape
  `SYMPTOM → ROOT CAUSE → RULE`. Loaded every session so a scar never repeats.
- **Archive** — `LESSONS-ARCHIVE.md`: older raw lessons, merged into sharper rules but
  never deleted.
- **Active mission** — `docs/ACTIVE-MISSION.md`: what you're working on right now, so any
  session resumes instantly.
- **Learning log** — `docs/learning/`: what *you* are learning, on a spaced-repetition
  schedule (FSRS) so it sticks.

---

## 6. A typical day

1. Open a session with the repos you need (use the **"+"** selector at launch — a session
   can only reach repos you add at the start).
2. Say **"Cogito"** → it resumes your mission.
3. Do the work in plain English; summon agents to verify ("is it live?", "QA it",
   "review this").
4. Say **"checkpoint"** before you stop. The brain auto-saves.

That's it. The system gets a little smarter every session — and all of it is yours,
in files, on any plan.
