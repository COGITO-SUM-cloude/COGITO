#!/usr/bin/env bash
# Cogito SessionStart hook.
# Bootstraps the protocol skill from the CANONICAL ref (origin/main — the durable
# source of truth, NOT the checked-out session branch), guarantees the lessons
# ledger exists, then injects the operating context. Idempotent, fast, non-interactive.
# Runs in every session (remote or local) so Cogito is always live.
set -euo pipefail

REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILL_DST="$CLAUDE_HOME/skills/cogito-protocol"
LEDGER="$SKILL_DST/LESSONS.md"
BRAIN_REF="${COGITO_BRAIN_REF:-origin/main}"   # the ONE canonical brain — NEVER the checked-out branch

mkdir -p "$SKILL_DST"

# Load the brain from a single fixed point (origin/main), not the branch this
# container happened to check out — otherwise each session reads a different
# branch's memory and they silently diverge (the cross-session consistency bug).
# Fetch is best-effort; canon_read falls back to the working tree offline so a
# fetch failure never blanks the brain (the safety net). Always returns 0.
git -C "$REPO" fetch --quiet origin main 2>/dev/null || true
canon_read() { git -C "$REPO" show "$BRAIN_REF:$1" 2>/dev/null || cat "$REPO/$1" 2>/dev/null || true; }

# Re-install the protocol every session from the canonical ref (the container may
# revert skill edits, but origin/main is durable). The ledger is never clobbered.
skill_md="$(canon_read skills/cogito-protocol/SKILL.md)"
if [ -n "$skill_md" ]; then printf '%s\n' "$skill_md" > "$SKILL_DST/SKILL.md"; fi
if [ ! -f "$LEDGER" ]; then
  lessons_md="$(canon_read skills/cogito-protocol/LESSONS.md)"
  if [ -n "$lessons_md" ]; then
    printf '%s\n' "$lessons_md" > "$LEDGER"
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

# Surface the active mission from the canonical ref for instant cross-session
# resume — the SAME mission for every session, not whatever this branch holds.
mission="$(canon_read docs/ACTIVE-MISSION.md)"
if [ -n "$mission" ]; then
  printf '\n----- ACTIVE MISSION (resume this) -----\n'
  printf '%s\n' "$mission"
  printf '\n----- end ACTIVE MISSION -----\n'
fi

# Surface the most-overdue learning recap (spaced repetition — skill #7). NEVER
# fatal: the learning log is the human-growth twin of the lessons ledger, but a
# missing/malformed log or script must never disturb the lesson-load path. The
# command substitution swallows errors and the if-guard keeps set -e happy.
REVIEW="$REPO/scripts/cogito-review.sh"
if [ -x "$REVIEW" ]; then
  recap="$("$REVIEW" due --quiet 2>/dev/null || true)"
  if [ -n "$recap" ]; then
    printf '\n----- LEARNING RECAP (spaced repetition — most overdue) -----\n'
    printf '%s\n' "$recap"
    printf 'Open with this recap cue; after they answer: scripts/cogito-review.sh grade <N> pass|fail\n'
    printf -- '----- end LEARNING RECAP -----\n'
  fi
fi
