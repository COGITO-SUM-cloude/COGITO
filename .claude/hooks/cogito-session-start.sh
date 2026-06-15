#!/usr/bin/env bash
# Cogito SessionStart hook.
# Bootstraps the protocol skill from the repo (the durable source of truth),
# guarantees the lessons ledger exists and is writable, then injects the
# operating context into the session. Idempotent, non-interactive, fast.
# Runs in every session (remote or local) so Cogito is always live.
set -euo pipefail

REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILL_SRC="$REPO/skills/cogito-protocol"
SKILL_DST="$CLAUDE_HOME/skills/cogito-protocol"
LEDGER="$SKILL_DST/LESSONS.md"

mkdir -p "$SKILL_DST"

# Re-install the protocol from the repo every session: the container may revert
# skill edits, but the repo is durable, so this keeps the live skill in sync
# with the committed source of truth. The ledger is never clobbered.
if [ -f "$SKILL_SRC/SKILL.md" ] && [ "$SKILL_SRC" != "$SKILL_DST" ]; then
  cp -f "$SKILL_SRC/SKILL.md" "$SKILL_DST/SKILL.md"
fi
if [ ! -f "$LEDGER" ]; then
  if [ -f "$SKILL_SRC/LESSONS.md" ]; then
    cp "$SKILL_SRC/LESSONS.md" "$LEDGER"
  else
    printf '# Cogito — Lessons Ledger\n\nSYMPTOM -> ROOT CAUSE -> RULE\n\n## Lessons\n' > "$LEDGER"
  fi
fi

# Inject operating context (SessionStart stdout is added to the session).
cat <<'CTX'
Cogito protocol is active for this session.
Apply the cogito-protocol skill proportionally — near-silent on trivial tasks,
the full ritual on substantial or multi-session work. Run the session loop:
greet ("Cogito is live — what's our mission today?"), interview to a one-page
spec, red-team the goal, build in verifiable increments, capture lessons the
moment they happen (SYMPTOM -> ROOT CAUSE -> RULE), and close with a checkpoint
+ finish-line review, then ask whether the mission is accomplished.
Durable lessons ledger: ~/.claude/skills/cogito-protocol/LESSONS.md
CTX

# Surface the active mission, if one is set, for instant cross-session resume.
MISSION="$REPO/docs/ACTIVE-MISSION.md"
if [ -f "$MISSION" ]; then
  printf '\n----- ACTIVE MISSION (resume this) -----\n'
  cat "$MISSION"
  printf '\n----- end ACTIVE MISSION -----\n'
fi
