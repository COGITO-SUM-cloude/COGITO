# AI "brain" — what it is, and the tools worth adding to Cogito
_Research 2026-06-14. Plain language. For a solo, cost-sensitive, faceless builder using Claude Code._

## What "AI brain" means
An AI's "brain" is **memory that survives between chats** — so the assistant starts each
session already knowing your project instead of from zero. Modern "brain" tools do three jobs:
- **Remember** facts and preferences across sessions.
- **Organize** them — a flat list, or a *knowledge graph* that links related facts and tracks
  how they change over time.
- **Retrieve** only the relevant ones for the task at hand, so it still works at thousands of notes.

## The good news: you already built one
Cogito **is** an AI brain — a hand-built, file-based one:
- Auto-loads every session (the SessionStart hook) → persistent memory.
- `LESSONS.md` → earned long-term rules (the "what we learned" memory).
- Checkpoints → session snapshots (episodic memory).
- The skill → how it operates.

Most people never get this far. The paid tools below mostly *productize* what you already do by hand.

## The named tools (and whether they fit you)
| Tool | What it's for | Fit for you |
|---|---|---|
| **Mem0** | Remembers user preferences / personalization | Cloud + API key + cost. Overkill at 29 notes. |
| **Zep** | Temporal knowledge graph (tracks how facts change) | Powerful, but a production dev tool. Later. |
| **Letta** (ex-MemGPT) | The agent edits its own tiered memory | Closest to Cogito's idea, but heavier. Later. |
| **Anthropic's built-in Memory tool** | Native cross-session memory for agents (with "context editing", ~84% token savings on long tasks) | The platform is moving your way; it's aimed at API builders. Worth watching. |
| **Obsidian + MCP** | Your notes become the AI's brain, staying on your machine | Only if you actually use the Obsidian *app*. (Your dashboard name "Obsidian & Ember" reads Elden-Ring-themed, so probably unrelated — don't assume.) |

**Takeaway:** don't bolt on a heavy cloud memory system. It fights your values (free, private,
simple) and you don't need it yet. Add the pieces that fit.

## The tools that actually fit — Claude Code's own "brain" layers
Claude Code extends with five pieces. You use three; the two unused ones are your biggest upgrades:
- CLAUDE.md (rules) — ✓ have it
- A skill (how-to) — ✓ have it (cogito-protocol)
- A hook (auto-runs) — ✓ have it (session start)
- **Subagents** — specialist helpers, each with its own context (e.g. a design-QA helper that
  uses the new eyes). — ✗ unused, high value.
- **More skills** — e.g. turn the painting site into a reusable "build-a-site" recipe so site #2
  is fast. — ✗ already called for in the painting-site plan.

Plus the #1 power-user practice — **verification** — which we just enabled today (the eyes).

## Roadmap (smallest-first)
1. **Done:** eyes — the AI can see and check its own visual work.
2. **Next (pick one):**
   - **Design-QA helper** (subagent) — auto-checks how pages look, using the eyes.
   - **Smarter memory** — index/tag the lessons so the right ones surface per task and it scales.
   - **Reusable build-a-site recipe** (skill) — the biggest long-term multiplier; best once the
     painting site is a bit further along.
3. **Later, only if needed:** real retrieval (a memory MCP server, or Obsidian-MCP if you adopt
   Obsidian). Don't build it before the memory is actually big.

## Sources
- [The 6 Best AI Agent Memory Frameworks (2026) — MachineLearningMastery](https://machinelearningmastery.com/the-6-best-ai-agent-memory-frameworks-you-should-try-in-2026/)
- [Best AI Agent Memory Frameworks 2026 — Atlan](https://atlan.com/know/best-ai-agent-memory-frameworks-2026/)
- [AI Agent Memory Systems 2026: Mem0, Zep, Letta — Dev Genius](https://blog.devgenius.io/ai-agent-memory-systems-in-2026-mem0-zep-hindsight-memvid-and-everything-in-between-compared-96e35b818da8)
- [Claude Memory Tool — Anthropic API guide](https://claudeapi.com/en/blog/dev-guides/claude-memory-tool-guide/)
- [Effective harnesses for long-running agents — Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [My Claude Code Setup: MCP, Hooks, Skills, Agents (2026)](https://okhlopkov.com/claude-code-setup-mcp-hooks-skills-2026/)
- [Choosing between skills, subagents, and MCP servers in Claude Code](https://smithhorngroup.substack.com/p/choosing-between-skills-subagents)
- [Obsidian + Claude Second Brain Setup 2026 — innobu](https://www.innobu.com/en/articles/obsidian-claude-second-brain-knowledge-management.html)
