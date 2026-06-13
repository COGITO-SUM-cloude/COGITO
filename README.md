# Cogito

**A metacognitive operating protocol for AI-assisted work — durable memory for a system that otherwise forgets.**

Cogito treats the user, the AI, and the tools as one coupled cognitive system (an *extended mind*). It does not try to make the model smarter. It makes the **system** smarter by turning the right strategies — explicit assumptions, honest capability boundaries, externalized memory, harsh retrospectives — from incidental into deliberate.

> Cogito is the **memory** (it persists as files and loads into every session). The assistant is the **worker** (it runs only while a session is open). Nothing runs between sessions — but because the memory is always present, each session wakes already knowing the project.

---

## The session loop

Saying **"Cogito"** (or simply starting a session) runs the loop:

1. **Greet + take the mission** — *"Cogito is live — what's our mission today?"*
2. **Interview to a spec** — keep asking until the goal is concrete and the assumption-check clears ~80%.
3. **Red-team the mission** — critique the *goal* before serving it; a goal shipped un-critiqued is the most expensive error there is.
4. **Build in verifiable increments** — verify each step by its real outcome, never a proxy.
5. **Self-update on every stumble** — capture the one-line lesson the instant it happens.
6. **Checkpoint + confirm** — produce a state file and ask plainly, *"Is the mission accomplished?"*
7. **Finish-line review** — Progress → Critique → Solutions → Recommendations, and fold each fix back into durable memory.
8. **The dividend** — a mistake turned into a *persisted* lesson does not recur, so each loop runs leaner than the last.

The full machinery lives in [`skills/cogito-protocol/SKILL.md`](skills/cogito-protocol/SKILL.md).

---

## Quick start

```bash
git clone https://github.com/eduardocastanon27-tech/COGITO.git
cd COGITO
./install.sh            # installs the skill into ~/.claude/skills/ and verifies the ledger
./install.sh --global-hook   # also auto-load the protocol in EVERY session, every repo
```

`install.sh` copies the protocol to `~/.claude/skills/cogito-protocol/`, never clobbers an
accumulated `LESSONS.md`, and proves the ledger is writable by re-reading a test write
(protocol §4b) — so "installed" means *verified live*, not *probably done*.

---

## What's in here

| Path | Role |
|------|------|
| `skills/cogito-protocol/SKILL.md` | The protocol itself — the machinery the loop invokes. |
| `skills/cogito-protocol/LESSONS.md` | The durable lessons ledger (`SYMPTOM -> ROOT CAUSE -> RULE`). |
| `CLAUDE.md` | Project-level operating instructions: apply the protocol, capture lessons, checkpoint on command. |
| `install.sh` | One-shot installer + ledger verification. |
| `.claude/` | SessionStart hook that auto-loads the protocol and guarantees the ledger exists. |
| `web/` | The public face of Cogito — a static page, no build step. |
| `docs/` | Room to grow. |

---

## How the pieces fit

- **The skill** is the *what* — the reasoning discipline, loaded on demand.
- **CLAUDE.md** is the *when/always* — the standing instructions for sessions in this repo.
- **The hook** is the *automatic* — `CLAUDE.md` can *describe* always-on behavior, but only a hook can *execute* it at session start. (That distinction is itself lesson #1 in the ledger.)
- **LESSONS.md** is the *memory that compounds* — the single durable write-path. The user owns it; the assistant only compiles into it.

---

## Ethos

This protocol is **meant to be shared** — anyone, human or AI, is free to learn from it and build on it. Point it at work that is honest and humane, that helps more than it harms. Prefer the efficient path to the wasteful one, the smallest sufficient compute, the change that lasts over the one rebuilt twice.

**Know when to set it down.** Cogito serves the work and the people, never itself. If applying it ever does more harm than good, scale it back or retire it gracefully. A good tool carries the wisdom of its own off-switch.

## License

[MIT](LICENSE). Free to learn from, adapt, and build on.
