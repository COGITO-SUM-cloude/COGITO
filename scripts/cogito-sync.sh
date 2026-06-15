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

LEDGER="$DST/LESSONS.md"
n="$(grep -c '^- ' "$LEDGER" 2>/dev/null || true)"; n="${n:-0}"

# Index-then-load (skill #3): full-load only while the ledger is genuinely small;
# past the threshold we switch to index + just-in-time retrieval. The default is
# deliberately LOW (20) because the full ledger rides EVERY turn — ~50 lessons is
# ~5k tokens/turn, which burns a metered plan's budget fast (measured via
# scripts/cogito-budget.sh). In index mode the always-load set (#critical / [I:9-10])
# still prints in full — so the must-know lessons are never deferred — and the rest
# are one `grep` away. Raise COGITO_LOAD_THRESHOLD to go back to full-load.
THRESHOLD="${COGITO_LOAD_THRESHOLD:-20}"
if [ "$n" -le "$THRESHOLD" ]; then
  # --- full-load (unchanged; the safety net) ---
  echo "cogito: brain loaded from $src — $n lessons now in context. Do NOT repeat these:"
  echo "----- COGITO LESSONS  (SYMPTOM -> ROOT CAUSE -> RULE) -----"
  grep '^- ' "$LEDGER"
  echo "----- end COGITO lessons -----"
else
  # --- index mode (just-in-time retrieval) ---
  echo "cogito: brain loaded from $src — $n lessons (index mode; grep for depth)."
  echo "----- ALWAYS-LOAD (critical / severe — these never defer) -----"
  grep -E '^- .*(\[I:(9|10)\]|#critical)' "$LEDGER" || echo "  (none flagged critical)"
  echo "----- COGITO LESSONS INDEX  (tag -> count; grep a tag in LESSONS.md for depth) -----"
  grep '^- ' "$LEDGER" | grep -oE '\[#[a-z][a-z-]*\]' | sort | uniq -c | sort -rn | sed 's/^/  /' \
    || echo "  (untagged — lessons exist but carry no tags yet)"
  echo "  $n lessons are not all printed (context-rot guard). To recall depth on a topic:"
  echo "    grep -i '<keyword>' ~/.claude/skills/cogito-protocol/LESSONS.md"
  echo "----- end COGITO INDEX -----"
fi
