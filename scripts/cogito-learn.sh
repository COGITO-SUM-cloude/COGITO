#!/usr/bin/env bash
# cogito-learn — record a lesson into the central Cogito brain so EVERY future
# session (any repo) inherits it. Usage:
#   scripts/cogito-learn.sh "SYMPTOM -> ROOT CAUSE -> RULE"
#
#   - In the central Cogito repo -> append to the local ledger (then commit & push).
#   - Elsewhere (a satellite repo) -> queue locally + warn LOUDLY (never silently lose one);
#     lessons reach the brain by being PROPOSED to the hub (gated) or relayed by a human.
#
# SECURITY (council 2026-06-16): the old token -> direct-API-write path is REMOVED (see the
# Mode 2 note below). No satellite holds a canonical-write token — that is the blocked exfil shape.
set -euo pipefail

LESSON="$*"
[ -n "${LESSON// /}" ] || { echo 'usage: cogito-learn.sh "SYMPTOM -> ROOT CAUSE -> RULE"' >&2; exit 2; }
OWNER=COGITO-SUM-cloude; REPO=COGITO; LP="skills/cogito-protocol/LESSONS.md"
QUEUE="$HOME/.claude/cogito-pending-lessons.md"

# Mode 1 — inside the central repo: append to the local ledger.
root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$root" ] && [ -f "$root/$LP" ] && git -C "$root" remote -v 2>/dev/null | grep -qiE "$OWNER/$REPO(\.git)?"; then
  printf -- '- %s\n' "$LESSON" >> "$root/$LP"
  echo "cogito-learn: appended to $root/$LP — commit & push to publish."
  exit 0
fi

# Mode 2 (a stored COGITO_TOKEN -> direct GitHub-API write to the brain's default branch)
# was REMOVED for security (council ruling 2026-06-16): a scattered write-token is the exact
# exfil shape the harness safety classifier blocks, and a direct write to canon lets one
# session poison every reader. Satellites must PROPOSE (a PR the hub gates + auto-merges for
# append-only), never hold a canonical-write token. Until that propose path is wired and
# live-tested, satellite lessons fall through to the local queue below and a human relays them.

# Mode 3 — fallback: queue locally, warn loudly.
mkdir -p "$(dirname "$QUEUE")"; printf -- '- %s\n' "$LESSON" >> "$QUEUE"
echo "cogito-learn: queued to $QUEUE (lesson saved locally)." >&2
echo "  Relay these to a Cogito session (or the hub propose-and-gate path) — write-back by stored token was removed for security." >&2
exit 0
