#!/usr/bin/env bash
# Cogito brain sync — make THIS session (in ANY repo) start knowing every lesson.
#
# Pulls the canonical protocol + lessons from the PUBLIC Cogito repo into
# ~/.claude/skills/cogito-protocol/. Read-only, anonymous, no token needed —
# this is what lets a session in the paint repo (or any other) avoid repeating
# a mistake recorded in a different repo's session.
#
# Drop-in for other repos: copy this file in and add a SessionStart hook that
# runs it (see docs/cogito-everywhere.md). Writing NEW lessons back to the
# central brain is a separate step (cogito-learn.sh / a one-time key).
set -euo pipefail

DST="$HOME/.claude/skills/cogito-protocol"
REPO="https://github.com/COGITO-SUM-cloude/COGITO.git"
mkdir -p "$DST"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if git clone --depth 1 --quiet "$REPO" "$tmp" 2>/dev/null && [ -f "$tmp/skills/cogito-protocol/LESSONS.md" ]; then
  cp -f "$tmp/skills/cogito-protocol/SKILL.md"   "$DST/SKILL.md"
  cp -f "$tmp/skills/cogito-protocol/LESSONS.md" "$DST/LESSONS.md"
  n="$(grep -c '^- ' "$DST/LESSONS.md" 2>/dev/null || echo '?')"
  echo "cogito: brain synced from the central repo — $n lessons loaded into this session"
else
  echo "cogito: WARNING could not reach the central brain; using whatever is already in $DST" >&2
fi
