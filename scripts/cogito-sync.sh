#!/usr/bin/env bash
# Cogito brain sync — make THIS session (in ANY repo) start KNOWING every lesson.
#
# Run as a SessionStart hook: it loads the protocol + lessons into ~/.claude AND
# prints the lessons to stdout. A SessionStart hook's stdout is injected into the
# session's context, so the session literally starts with the lessons in mind and
# can't repeat a past mistake — syncing to disk alone is not enough.
#
#   - Inside the central Cogito repo: uses the local, authoritative ledger
#     (which may hold lessons not yet pushed).
#   - In any other repo: clones the PUBLIC Cogito repo (anonymous, no token).
set -euo pipefail

DST="$HOME/.claude/skills/cogito-protocol"
REPO_URL="https://github.com/COGITO-SUM-cloude/COGITO.git"
SUB="skills/cogito-protocol"
mkdir -p "$DST"

src=""
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
root="$(git -C "$proj" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$root" ] && [ -f "$root/$SUB/LESSONS.md" ] \
   && git -C "$root" remote -v 2>/dev/null | grep -qiE 'COGITO-SUM-cloude/COGITO(\.git)?'; then
  cp -f "$root/$SUB/SKILL.md"   "$DST/SKILL.md"   2>/dev/null || true
  cp -f "$root/$SUB/LESSONS.md" "$DST/LESSONS.md"
  src="local central repo"
else
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  if git clone --depth 1 --quiet "$REPO_URL" "$tmp" 2>/dev/null && [ -f "$tmp/$SUB/LESSONS.md" ]; then
    cp -f "$tmp/$SUB/SKILL.md"   "$DST/SKILL.md"
    cp -f "$tmp/$SUB/LESSONS.md" "$DST/LESSONS.md"
    src="public central repo"
  fi
fi

if [ ! -f "$DST/LESSONS.md" ]; then
  echo "cogito: WARNING could not load the brain (offline?); no lessons available this session" >&2
  exit 0
fi

n="$(grep -c '^- ' "$DST/LESSONS.md" 2>/dev/null || echo '?')"
echo "cogito: brain loaded from $src — $n lessons now in context. Do NOT repeat these:"
echo "----- COGITO LESSONS  (SYMPTOM -> ROOT CAUSE -> RULE) -----"
grep '^- ' "$DST/LESSONS.md"
echo "----- end COGITO lessons -----"
