#!/usr/bin/env bash
# Cogito decay — the "archive cold, low-value lessons" half of ledger maintenance
# (the sibling of consolidation; see skill: cogito-consolidate). It does NOT move
# anything — it identifies which lessons have DECAYED by an ACT-R-style rule
# (low importance AND cold AND not refreshed). The move + the conservation gate
# are shared with consolidation: scripts/cogito-consolidate.sh verify.
#
#   cogito-decay.sh report          list decay candidates (and why). Changes nothing.
#   cogito-decay.sh touch "<text>"  refresh-on-use: stamp the one matching lesson
#                                   with [seen:YYYY-MM-DD] so it is no longer cold.
#
# SAFETY: only a lesson with an explicit low importance ([I:N], N <= FLOOR) can
# decay. Unscored lessons are KEPT — we never assume a lesson is low-value.
# #critical and [I:>=9] never decay. The most-recent PROBATION lessons are exempt.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LEDGER="$ROOT/skills/cogito-protocol/LESSONS.md"
FLOOR="${COGITO_DECAY_FLOOR:-3}"            # importance <= FLOOR may decay
COLD_DAYS="${COGITO_DECAY_COLD_DAYS:-90}"   # older than this (days) = cold
PROBATION="${COGITO_DECAY_PROBATION:-5}"    # most-recent N lessons exempt
TODAY="$(date -u +%Y-%m-%d)"

die(){ echo "cogito-decay: $*" >&2; exit 1; }

# Recency of a lesson: the latest [seen:DATE]/[d:DATE] stamp in the line, else the
# line's last git-commit date (blame fallback). Unknown -> today (treated warm).
line_recency(){
  local line="$1" stamp d
  stamp="$(printf '%s\n' "$line" \
    | grep -oE '\[(seen|d):[0-9]{4}-[0-9]{2}-[0-9]{2}\]' \
    | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1 || true)"
  if [ -n "$stamp" ]; then printf '%s\n' "$stamp"; return; fi
  d="$(git -C "$ROOT" log -1 --format=%cs -S"$line" -- "$LEDGER" 2>/dev/null || true)"
  printf '%s\n' "${d:-$TODAY}"
}

age_days(){
  local then now
  then="$(date -u -d "$1" +%s 2>/dev/null)" || { echo 0; return; }
  now="$(date -u -d "$TODAY" +%s)"
  echo $(( (now - then) / 86400 ))
}

report(){
  [ -f "$LEDGER" ] || die "no ledger at $LEDGER"
  mapfile -t L < <(grep '^- ' "$LEDGER")
  local total=${#L[@]} cutoff=$(( ${#L[@]} - PROBATION ))
  echo "Cogito decay — report"
  echo "  ledger    : $LEDGER  ($total active lessons)"
  echo "  rule      : decay if [I:<=$FLOOR] AND older than ${COLD_DAYS}d AND off-probation,"
  echo "              never #critical / [I:>=9] / unscored"
  echo "  probation : most-recent $PROBATION lessons exempt"
  echo
  local found=0 i line imp rec age
  for i in "${!L[@]}"; do
    line="${L[$i]}"
    imp="$(printf '%s' "$line" | grep -oE '\[I:[0-9]+\]' | grep -oE '[0-9]+' | head -1 || true)"
    [ -n "$imp" ] || continue                          # unscored -> keep
    printf '%s' "$line" | grep -qiE '#critical' && continue
    [ "$imp" -ge 9 ] && continue                        # severe -> never decay
    [ "$imp" -gt "$FLOOR" ] && continue                 # not low-value -> keep
    [ "$i" -ge "$cutoff" ] && continue                  # probation -> keep
    rec="$(line_recency "$line")"
    age="$(age_days "$rec")"
    if [ "$age" -gt "$COLD_DAYS" ]; then
      found=$((found+1))
      echo "  CANDIDATE  I:$imp  ${age}d old (recency $rec)"
      echo "    ${line:0:110}"
    fi
  done
  echo
  if [ "$found" -eq 0 ]; then
    echo "No decay candidates — low-value lessons are still warm/refreshed, or none are scored low."
  else
    echo "$found candidate(s). To retire each: MOVE it (verbatim) to LESSONS-ARCHIVE.md under a"
    echo "'decayed: cold + low-value' block, then run  scripts/cogito-consolidate.sh verify  before committing."
  fi
}

touch_lesson(){
  local pat="${1:-}"; [ -n "$pat" ] || die 'usage: cogito-decay.sh touch "<substring of the lesson>"'
  python3 - "$LEDGER" "$pat" "$TODAY" <<'PY'
import sys, re
led, pat, today = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(led).read().split('\n')
idx = [i for i, l in enumerate(lines) if l.startswith('- ') and pat in l]
if len(idx) != 1:
    sys.stderr.write(f"cogito-decay: need exactly one matching lesson, got {len(idx)}\n"); sys.exit(1)
i = idx[0]
l = re.sub(r'\s*\[seen:\d{4}-\d{2}-\d{2}\]', '', lines[i]).rstrip() + f' [seen:{today}]'
lines[i] = l
open(led, 'w').write('\n'.join(lines))
print(f"refreshed (line {i+1}) -> ...{l[-72:]}")
PY
}

case "${1:-}" in
  report) report ;;
  touch)  shift; touch_lesson "${1:-}" ;;
  *) echo 'usage: cogito-decay.sh {report | touch "<substring>"}' >&2; exit 2 ;;
esac
