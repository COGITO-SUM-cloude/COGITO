#!/usr/bin/env bash
# Cogito Stop hook — save the brain durably at the end of a turn.
#
# Why: a session's NEW lessons / mission edits can sit uncommitted and be lost
# when the ephemeral container is reclaimed (the highest-frequency recorded pain:
# forked ledgers/branches, stale resume). This captures them the moment a turn
# ends so they survive — committed and pushed to the CURRENT BRANCH.
#
# Auto-pushes the brain to main (FF-only) at session end — the user EXPLICITLY
# enabled this on 2026-06-15 ("turn auto push on"). It performs a clean
# fast-forward only: never force, never clobber; a diverged/raced main is left
# untouched and reported. Revert to branch-only with COGITO_CONVERGE_TO_MAIN=0,
# or turn the hook off entirely with COGITO_AUTO_CONVERGE=0.
#
# Deliberately narrow and safe:
#   - BRAIN FILES ONLY (never sweeps code or other working changes)
#   - commits + pushes to the current branch (durable); main is opt-in + FF-only
#   - faceless identity; non-fatal (a Stop hook must never break the session)
#   - kill switch:  export COGITO_AUTO_CONVERGE=0
#   - branch-only:  export COGITO_CONVERGE_TO_MAIN=0   (main auto-push is ON by default; FF-only)
#   - safe testing: export COGITO_CONVERGE_DRYRUN=1    (report only; no commit/push)
set -uo pipefail   # NOT -e: never hard-fail the session

[ "${COGITO_AUTO_CONVERGE:-1}" = "0" ] && exit 0

REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$REPO" 2>/dev/null || exit 0
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

MAIN_BRANCH="${COGITO_MAIN_BRANCH:-main}"
DRYRUN="${COGITO_CONVERGE_DRYRUN:-0}"
TO_MAIN="${COGITO_CONVERGE_TO_MAIN:-1}"   # ON: user opted in 2026-06-15 ("turn auto push on"); FF-only. =0 -> branch-only.
BRAIN_PATHS=(
  "skills/cogito-protocol/LESSONS.md"
  "skills/cogito-protocol/LESSONS-ARCHIVE.md"
  "docs/ACTIVE-MISSION.md"
)

# what changed? (modified / staged / untracked — porcelain catches all states)
changed=()
for p in "${BRAIN_PATHS[@]}"; do
  [ -e "$p" ] || continue
  [ -n "$(git status --porcelain -- "$p" 2>/dev/null)" ] && changed+=("$p")
done
[ "${#changed[@]}" -eq 0 ] && exit 0   # nothing to save — silent

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"

# Is a fast-forward of main even possible (only consulted if opted in)?
ff_ok="no"
if [ "$TO_MAIN" = "1" ]; then
  git fetch -q origin "$MAIN_BRANCH" 2>/dev/null || true
  git merge-base --is-ancestor "origin/$MAIN_BRANCH" HEAD 2>/dev/null && ff_ok="yes"
fi

if [ "$DRYRUN" = "1" ]; then
  printf 'cogito[dryrun]: would commit %d brain file(s) on %s: %s\n' \
    "${#changed[@]}" "$branch" "$(printf '%s ' "${changed[@]}")"
  printf 'cogito[dryrun]: push to main -> enabled=%s, fast-forward-possible=%s\n' "$TO_MAIN" "$ff_ok"
  exit 0
fi

# commit ONLY the brain paths (faceless) — never other work in the tree
GIT_AUTHOR_NAME="Cogito"    GIT_AUTHOR_EMAIL="cogito@users.noreply.github.com" \
GIT_COMMITTER_NAME="Cogito" GIT_COMMITTER_EMAIL="cogito@users.noreply.github.com" \
  git commit -q --no-verify --only -m "cogito: auto-save brain [stop-hook]" -- "${changed[@]}" 2>/dev/null \
  || exit 0   # nothing actually committed -> bail quietly

git push -q origin "HEAD:$branch" 2>/dev/null || true   # durable on the branch

synced="branch '$branch' (durable; say \"update main\" to make it canonical)"
if [ "$TO_MAIN" = "1" ] && [ "$ff_ok" = "yes" ]; then
  git push -q origin "HEAD:$MAIN_BRANCH" 2>/dev/null && synced="$MAIN_BRANCH (fast-forward, opt-in)"
fi

printf 'cogito: brain saved -> %s (%d file[s])\n' "$synced" "${#changed[@]}"
exit 0
