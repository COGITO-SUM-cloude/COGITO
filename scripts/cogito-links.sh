#!/usr/bin/env bash
# Cogito link-graph helper — the brain is a GRAPH; [[wikilinks]] are its edges.
# Plain markdown + grep: no app, no database (Obsidian's value is the link FORMAT,
# not the GUI). This is the prerequisite-graph substrate a future VR/3D teacher
# walks: link related notes with [[note-name]] and the graph grows on its own.
#
#   cogito-links.sh backlinks <name>   what links TO [[name]]  (incoming edges)
#   cogito-links.sh out <file>         what <file> links out to (outgoing edges)
#   cogito-links.sh all                every [[edge]] in the brain (file:line -> target)
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$ROOT" || exit 1
SCOPE=(docs skills)

case "${1:-}" in
  backlinks)
    n="${2:?usage: backlinks <name>}"; n="$(basename "${n%.md}")"
    echo "Notes linking to [[$n]]:"
    if grep -rln -- "\[\[$n\]\]" "${SCOPE[@]}" 2>/dev/null | grep -q .; then
      grep -rln -- "\[\[$n\]\]" "${SCOPE[@]}" 2>/dev/null | sed 's/^/  /'
    else
      echo "  (none yet)"
    fi
    ;;
  out)
    f="${2:?usage: out <file>}"
    echo "[[links]] out of $f:"
    grep -oE '\[\[[^]]+\]\]' "$f" 2>/dev/null | sort -u | sed 's/^/  /' || echo "  (none)"
    ;;
  all)
    echo "Brain link graph (file:line -> [[target]]):"
    grep -rEno '\[\[[^]]+\]\]' "${SCOPE[@]}" 2>/dev/null | sed 's/^/  /' || echo "  (no links yet)"
    ;;
  *) echo "usage: cogito-links.sh {backlinks <name>|out <file>|all}" >&2; exit 2 ;;
esac
