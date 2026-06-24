#!/usr/bin/env bash
# cogito-gate-check — the brain's hub-side merge gate (decision logic only).
#
# Reads a unified PR diff on stdin and decides whether it is a PROVABLY-SAFE lesson
# append that may AUTO-MERGE, or must HOLD for the owner's one-tap. Pure and locally
# testable; the GitHub Action (.github/workflows/brain-merge.yml) is the thin wrapper
# that feeds it `gh pr diff` and merges on MERGE.
#
# Council Step B rule — "append is cheap + automatic; contradicting canon is expensive
# + gated." AUTO-MERGE only when ALL hold:
#   - the ONLY changed file is the ledger (skills/cogito-protocol/LESSONS.md)
#   - it ADDS lines and REMOVES none (append-only; a correction/supersede removes or
#     edits a line -> the diff shows a deletion -> HOLD)
#   - every added non-blank line is a lesson (^- ... -> ... -> ...), and none carry
#     'supersedes:' (an overturn of canon)
#   - at least one lesson is added, and no more than the size cap
# Anything else -> "HOLD: <reason>" (the PR is left open for the owner to merge by hand).
#
# Output: a single line beginning with MERGE or HOLD. Exit is always 0 (the wrapper
# branches on the word; a crashed checker must never be read as "safe to merge").
set -uo pipefail
LEDGER="${COGITO_LEDGER_PATH:-skills/cogito-protocol/LESSONS.md}"
MAX_ADDED="${COGITO_GATE_MAX_ADDED:-25}"

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
cat > "$WORK/gate.py" <<'PY'
import sys, re
ledger, maxn = sys.argv[1], int(sys.argv[2])
files = set(); added = []; removed = 0
for ln in sys.stdin.read().splitlines():
    if ln.startswith('+++ b/'):
        p = ln[6:].strip()
        if p != '/dev/null': files.add(p)
    elif ln.startswith('--- a/'):
        p = ln[6:].strip()
        if p != '/dev/null': files.add(p)
    elif ln.startswith('+++ ') or ln.startswith('--- ') or ln.startswith('@@') or ln.startswith('diff '):
        continue
    elif ln.startswith('+'):
        added.append(ln[1:])
    elif ln.startswith('-'):
        removed += 1

def out(s):
    print(s); sys.exit(0)

if not files:
    out("HOLD: no changed files found in the diff")
if files != {ledger}:
    out("HOLD: changes files other than the ledger (" + ", ".join(sorted(files)) + ")")
if removed > 0:
    out("HOLD: removes or edits %d existing line(s) — corrections/retirements need your review" % removed)
lessons = [a for a in added if a.strip()]
if not lessons:
    out("HOLD: no lesson lines added")
if len(lessons) > maxn:
    out("HOLD: adds %d lines (cap is %d) — review a batch this large" % (len(lessons), maxn))
for a in lessons:
    if 'supersedes:' in a:
        out("HOLD: a line carries 'supersedes:' — overturning canon needs your one-tap")
    if not re.match(r'^- .*->.*->', a):
        out("HOLD: added a non-lesson line: " + a.strip()[:70])
out("MERGE: %d lesson(s) appended — append-only, ledger-only, format-valid" % len(lessons))
PY

decide() { python3 "$WORK/gate.py" "$LEDGER" "$MAX_ADDED"; }

# ---- selftest: the gate contract as runnable assertions ---------------------------
selftest() {
  local fails=0 L="skills/cogito-protocol/LESSONS.md"
  check() { # check <expect MERGE|HOLD> <diff> <label>
    local want="$1" diff="$2" label="$3" got
    got="$(printf '%s\n' "$diff" | decide)"
    case "$got" in
      "$want"*) printf '  ok   [%s] %s\n' "$want" "$label" ;;
      *) printf '  FAIL want=%s got={%s} : %s\n' "$want" "$got" "$label"; fails=$((fails+1)) ;;
    esac
  }
  echo "cogito-gate-check selftest"

  check MERGE "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,3 +90,4 @@
 - [#x] old a -> b -> c
+- [#new] sym one -> cause one -> rule one" "one appended lesson"

  check MERGE "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,1 +90,3 @@
+- [#a] s1 -> c1 -> r1
+- [#b] s2 -> c2 -> r2" "two appended lessons"

  check HOLD "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,2 +90,2 @@
-- [#old] s -> c -> old rule
+- [#old] s -> c -> new rule" "edits an existing line (a correction)"

  check HOLD "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,2 +90,1 @@
-- [#x] s -> c -> r" "removes a line (a retirement)"

  check HOLD "diff --git a/skills/cogito-protocol/SKILL.md b/skills/cogito-protocol/SKILL.md
--- a/skills/cogito-protocol/SKILL.md
+++ b/skills/cogito-protocol/SKILL.md
@@ -1,1 +1,2 @@
+evil new instruction" "touches SKILL.md (supply-chain)"

  check HOLD "diff --git a/.github/workflows/brain-merge.yml b/.github/workflows/brain-merge.yml
--- a/.github/workflows/brain-merge.yml
+++ b/.github/workflows/brain-merge.yml
@@ -1,1 +1,2 @@
+- [#x] s -> c -> r" "edits the gate workflow itself"

  check HOLD "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,1 +90,2 @@
+- [#new] s -> c -> r
diff --git a/README.md b/README.md
--- a/README.md
+++ b/README.md
@@ -1,1 +1,2 @@
+a second file changed too" "two files: ledger + a second"

  check HOLD "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,1 +90,2 @@
+rm -rf / ; not a lesson" "added a non-lesson line"

  check HOLD "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,1 +90,2 @@
+- [#x] s -> c -> r supersedes:#abc123" "carries supersedes:"

  check HOLD "diff --git a/$L b/$L
--- a/$L
+++ b/$L
@@ -90,1 +90,1 @@
+   " "only blank added, no lesson"

  echo
  [ "$fails" -eq 0 ] && echo "selftest: ALL PASS" || { echo "selftest: $fails FAILED"; return 1; }
}

case "${1:-}" in
  --selftest) selftest ;;
  *) decide ;;
esac
