#!/usr/bin/env bash
# Cogito installer — makes the protocol "online": durable + live + auto-loading.
#
#   ./install.sh                 install the skill + verify the ledger is writable
#   ./install.sh --global-hook   also auto-load Cogito in EVERY session, every repo
#
# Idempotent and safe to re-run. Never clobbers an accumulated LESSONS.md.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILL_SRC="$REPO_DIR/skills/cogito-protocol"
SKILL_DST="$CLAUDE_HOME/skills/cogito-protocol"
LEDGER="$SKILL_DST/LESSONS.md"
ARCHIVE_SRC="$SKILL_SRC/LESSONS-ARCHIVE.md"
ARCHIVE_DST="$SKILL_DST/LESSONS-ARCHIVE.md"

say() { printf '  %s\n' "$*"; }

echo "Cogito installer"
say "repo:        $REPO_DIR"
say "claude home: $CLAUDE_HOME"

# --- 1. Install the skill (protocol), preserving any accumulated ledger -------
mkdir -p "$SKILL_DST"
cp -f "$SKILL_SRC/SKILL.md" "$SKILL_DST/SKILL.md"
cp -f "$REPO_DIR/.claude/hooks/cogito-session-start.sh" "$SKILL_DST/session-start.sh"
chmod +x "$SKILL_DST/session-start.sh"
say "installed SKILL.md + session-start.sh"

if [ ! -f "$LEDGER" ]; then
  cp "$SKILL_SRC/LESSONS.md" "$LEDGER"
  say "seeded LESSONS.md"
else
  say "kept existing LESSONS.md (preserving accumulated lessons)"
fi

# Seed the consolidation archive too (raw lessons retired by /consolidate land
# here; the loader never reads it, so archiving removes a lesson from context
# without losing it). Preserve any accumulated archive, like the ledger.
if [ -f "$ARCHIVE_SRC" ]; then
  if [ ! -f "$ARCHIVE_DST" ]; then
    cp "$ARCHIVE_SRC" "$ARCHIVE_DST"; say "seeded LESSONS-ARCHIVE.md"
  else
    say "kept existing LESSONS-ARCHIVE.md"
  fi
fi

# --- 1b. Install companion skills (every other skill under skills/) -----------
for src in "$REPO_DIR"/skills/*/; do
  name="$(basename "$src")"
  [ "$name" = "cogito-protocol" ] && continue
  [ -f "$src/SKILL.md" ] || continue
  dst="$CLAUDE_HOME/skills/$name"
  mkdir -p "$dst"
  cp -f "$src"/*.md "$dst"/
  say "installed companion skill: $name"
done

# --- 2. Verify the ledger is writable AND survives a write (protocol §4b) -----
probe="<!-- install-probe $(date -u +%Y-%m-%dT%H:%M:%SZ) $$ -->"
printf '%s\n' "$probe" >> "$LEDGER"
if grep -qF "$probe" "$LEDGER"; then
  grep -vF "$probe" "$LEDGER" > "$LEDGER.tmp" && mv "$LEDGER.tmp" "$LEDGER"
  say "ledger is writable and persists ✓"
else
  echo "  WARNING: ledger write did not persist — the capture path is broken." >&2
  exit 1
fi

# --- 3. Optional: wire a GLOBAL SessionStart hook (every repo) ----------------
if [ "${1:-}" = "--global-hook" ]; then
  settings="$CLAUDE_HOME/settings.json"
  cmd="$SKILL_DST/session-start.sh"
  python3 - "$settings" "$cmd" <<'PY'
import json, os, sys
settings, cmd = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(settings):
    with open(settings) as f:
        try: data = json.load(f) or {}
        except json.JSONDecodeError: data = {}
hooks = data.setdefault("hooks", {})
starts = hooks.setdefault("SessionStart", [])
flat = [h.get("command") for grp in starts for h in grp.get("hooks", [])]
if cmd not in flat:
    starts.append({"hooks": [{"type": "command", "command": cmd}]})
os.makedirs(os.path.dirname(settings), exist_ok=True)
with open(settings, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("  wired global SessionStart hook -> " + cmd)
PY
else
  say "skipped global hook (run with --global-hook to auto-load in every repo)"
  say "this repo already auto-loads via .claude/settings.json"
fi

echo "Done. Cogito is live. Skill: $SKILL_DST"
