#!/usr/bin/env bash
# Cogito budget — approximate the per-session token cost of everything the
# SessionStart chain injects into context. "Measure before you trim": run it,
# don't install it (no hook loads this script, so it costs nothing per session).
# Tokens are rough (~chars/4); good enough to rank the levers.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LEDGER="$ROOT/skills/cogito-protocol/LESSONS.md"
MISSION="$ROOT/docs/ACTIVE-MISSION.md"
THRESHOLD="${COGITO_LOAD_THRESHOLD:-20}"
PREAMBLE_TOK=260   # the fixed protocol text the two hooks always print (approx)

tok() { local c; c=$(printf '%s' "${1:-}" | wc -m | tr -d ' '); echo $(( c / 4 )); }

n=$(grep -c '^- ' "$LEDGER" 2>/dev/null || echo 0)
if [ "${n:-0}" -le "$THRESHOLD" ]; then
  ledger_txt="$(grep '^- ' "$LEDGER" 2>/dev/null || true)"
  ledger_mode="FULL — all $n lessons loaded every session (<= $THRESHOLD threshold)"
else
  crit="$(grep -E '^- .*(\[I:(9|10)\]|#critical)' "$LEDGER" 2>/dev/null || true)"
  idx="$(grep '^- ' "$LEDGER" 2>/dev/null | grep -oE '\[#[a-z-]+\]' | sort | uniq -c || true)"
  ledger_txt="$crit"$'\n'"$idx"
  cn=$(printf '%s' "$crit" | grep -c '^- ' || true)
  ledger_mode="index — $cn #critical always-load, other $((n-cn)) deferred to grep (> $THRESHOLD)"
fi
mission_txt="$(cat "$MISSION" 2>/dev/null || true)"
recap_txt="$("$ROOT/scripts/cogito-review.sh" due --quiet 2>/dev/null || true)"

lt=$(tok "$ledger_txt"); mt=$(tok "$mission_txt"); rt=$(tok "$recap_txt")
total=$(( lt + mt + rt + PREAMBLE_TOK ))

echo "Cogito — approx tokens injected into EVERY session (chars/4):"
printf '  %-26s ~%5s tok   %s\n' "lessons ledger"          "$lt"           "$ledger_mode"
printf '  %-26s ~%5s tok   %s\n' "ACTIVE-MISSION.md"       "$mt"           "(cat in full, no size cap)"
printf '  %-26s ~%5s tok   %s\n' "learning recap"          "$rt"           "(most-overdue cue)"
printf '  %-26s ~%5s tok   %s\n' "fixed protocol preamble" "$PREAMBLE_TOK" "(the two hooks boilerplate)"
echo   "  --------------------------------------------------------------"
printf '  %-26s ~%5s tok   <- rides every turn, every session\n' "TOTAL" "$total"
echo
echo "Levers, biggest first: ledger mode (lower COGITO_LOAD_THRESHOLD, or run"
echo "cogito-consolidate to merge duplicates); cap ACTIVE-MISSION.md; demote the recap."
