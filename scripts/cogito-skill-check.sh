#!/usr/bin/env bash
# Cogito skill-creation gate — §5 "verify outcomes" applied to the skill library
# (Voyager: add a skill only once it is verified). It checks the MECHANICAL
# preconditions a real skill must meet, and then states the judgment the author
# must satisfy before committing: that the skill actually worked in a real session.
#
#   cogito-skill-check.sh            audit every skill under skills/
#   cogito-skill-check.sh <name>     check one skill (skills/<name>/SKILL.md)
#
# Mechanical checks (runnable): frontmatter starts the file; name == directory;
# description is present and substantial (it is the just-in-time retrieval key);
# the skill is listed in skills/INDEX.md. Exits non-zero if any fail.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
INDEX="$ROOT/skills/INDEX.md"
MIN_DESC="${COGITO_SKILL_MIN_DESC:-40}"   # description must say WHEN to use it

fail=0
note(){ printf '  %s\n' "$*"; }

check_one(){
  local skill="$1" md="$ROOT/skills/$1/SKILL.md" name desc dlen
  echo "skill: $skill"
  if [ ! -f "$md" ]; then note "FAIL: no SKILL.md at $md"; fail=1; return; fi
  if [ "$(head -1 "$md")" != "---" ]; then
    note "FAIL: SKILL.md must open with a '---' frontmatter block"; fail=1; return
  fi
  name="$(sed -n 's/^name:[[:space:]]*//p' "$md" | head -1)"
  desc="$(sed -n 's/^description:[[:space:]]*//p' "$md" | head -1)"
  dlen=${#desc}
  if [ "$name" != "$skill" ]; then note "FAIL: frontmatter name ('$name') != directory ('$skill')"; fail=1; fi
  if [ "$dlen" -lt "$MIN_DESC" ]; then
    note "FAIL: description is thin ($dlen chars) — it is the retrieval key; say WHEN to use it"; fail=1
  fi
  if [ ! -f "$INDEX" ] || ! grep -qF "$skill" "$INDEX"; then
    note "FAIL: not listed in skills/INDEX.md — add it to the index table"; fail=1
  fi
  [ "$fail" -eq 0 ] && note "ok: frontmatter + index checks pass" || true
}

if [ -n "${1:-}" ]; then
  check_one "$1"
else
  for d in "$ROOT"/skills/*/; do
    [ -f "$d/SKILL.md" ] || continue
    check_one "$(basename "$d")"
  done
fi

echo
echo "GATE (Voyager / §5 verify-outcomes): mechanical checks are necessary, not"
echo "sufficient. A skill is procedural memory only after it WORKED in a real"
echo "session. Before committing, name the real task it ran on and the observed"
echo "outcome that proved it. A skill added on spec is a hypothesis — keep it on a"
echo "branch until a session proves it."

exit "$fail"
