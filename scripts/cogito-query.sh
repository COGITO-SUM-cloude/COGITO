#!/usr/bin/env bash
# Cogito query — saved, structured views over the lessons ledger (the Obsidian
# "Bases" pattern: the data stays in LESSONS.md, a query is just a tiny config the
# script resolves). Complements cogito-recall (keyword match) with STRUCTURED
# retrieval by tag + importance. No embeddings — plain grep/awk over markdown.
#
#   cogito-query.sh tag <tag>      lessons carrying [#tag]
#   cogito-query.sh imp <N>        lessons with importance [I:>=N] (highest first)
#   cogito-query.sh critical       the always-load set (#critical or [I:>=9])
#   cogito-query.sh untagged       lessons with no [#tag] (maintenance: tag these)
#   cogito-query.sh saved <name>   run skills/cogito-protocol/queries/<name>.q
#   cogito-query.sh list           list saved queries
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LEDGER="$ROOT/skills/cogito-protocol/LESSONS.md"
QDIR="$ROOT/skills/cogito-protocol/queries"
[ -f "$LEDGER" ] || { echo "no ledger at $LEDGER" >&2; exit 1; }

lessons(){ grep '^- ' "$LEDGER"; }
# sort lesson lines by importance [I:N] desc; lines with no [I:] sink to the end
by_importance(){
  awk '{ imp=0; if (match($0,/\[I:[0-9]+\]/)) imp=substr($0,RSTART+3,RLENGTH-4)+0;
         printf "%02d\t%s\n", imp, $0 }' | sort -rn | cut -f2-
}

case "${1:-}" in
  tag)      lessons | grep -F "[#${2:?usage: tag <tag>}]" || true ;;
  imp)      lessons | awk -v n="${2:?usage: imp <N>}" 'match($0,/\[I:[0-9]+\]/){ if (substr($0,RSTART+3,RLENGTH-4)+0 >= n) print }' | by_importance ;;
  critical) lessons | grep -E '#critical|\[I:(9|10)\]' || true ;;
  untagged) lessons | grep -vE '\[#' || true ;;
  list)     { [ -d "$QDIR" ] && ls -1 "$QDIR" 2>/dev/null | sed 's/\.q$//'; } || echo "(no saved queries)" ;;
  saved)
    name="${2:?usage: saved <name>}"; qf="$QDIR/$name.q"
    [ -f "$qf" ] || { echo "no saved query: $qf (try: cogito-query.sh list)" >&2; exit 1; }
    # a .q file ANDs up to two filters:  tag: <t>   and/or   min-importance: <N>
    tag="$(sed -n 's/^tag:[[:space:]]*//p' "$qf" | head -1)"
    minI="$(sed -n 's/^min-importance:[[:space:]]*//p' "$qf" | head -1)"
    out="$(lessons)"
    [ -n "$tag" ]  && out="$(printf '%s\n' "$out" | grep -F "[#$tag]" || true)"
    [ -n "$minI" ] && out="$(printf '%s\n' "$out" | awk -v n="$minI" 'match($0,/\[I:[0-9]+\]/){ if (substr($0,RSTART+3,RLENGTH-4)+0 >= n) print }')"
    [ -n "$out" ] && printf '%s\n' "$out" | by_importance || echo "(no lessons match $name)"
    ;;
  *) echo "usage: cogito-query.sh {tag <t>|imp <N>|critical|untagged|saved <name>|list}" >&2; exit 2 ;;
esac
