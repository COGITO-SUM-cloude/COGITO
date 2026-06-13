# Cogito — Lessons Ledger

The durable memory of the system. Each line is one earned lesson in the form:

    SYMPTOM -> ROOT CAUSE -> RULE

An entry is warranted whenever (skill §4b): the user corrects Claude; a bug's
root cause sits at a different layer than its symptom; a help request reveals a
missing tool/permission/context; or the same friction happens twice. Capture
prospectively — the moment it happens, not at the end. This file is the
write-path that makes the protocol compound; an empty ledger means the system
is relearning its scars every session.

> Verify on every session start that this file is reachable and survives a
> write (ephemeral containers silently revert). If it does not, say so
> immediately rather than shipping a ledger that looks alive but isn't.

---

## Lessons

- Protocol described always-on behaviors (silent lessons capture, "load every session, every repo") but nothing executed them -> CLAUDE.md memory *describes* automated behaviors while only a SessionStart hook + an installed skill can *run* them -> wire the hook and install the skill globally on day one; never assume prose in CLAUDE.md self-executes.
- "get cogito online" with an empty repo read as ambiguous (web-deploy vs. persist vs. activate) -> "online" for a memory system means durable + auto-loading, not "has a URL"; the binding constraint is the session boundary, not the absence of a web page -> for persistence-shaped goals, make the memory durable and the loading automatic first; treat any web presence as showcase, not substance.
- Skill referenced ~/.claude/skills/cogito-protocol/LESSONS.md but that path did not exist at runtime -> the canonical protocol lived only as uploaded session files, never installed -> the durable copy is the one committed to a repo the user owns; commit first, then install, then verify the ledger is writable by re-reading after a test write.
- git push rejected, and I retried it 4× as if it were transient -> GH007: the commit author was the user's private email, which GitHub's email-privacy setting blocks — a deterministic policy rejection, not a network error -> set the commit email to {id}+{login}@users.noreply.github.com before the first commit; and never retry a remote *rejection* (retry only true network failures — check transport vs. logic, skill §2).
