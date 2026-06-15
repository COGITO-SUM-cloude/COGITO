#!/usr/bin/env bash
# Cogito guard — a PreToolUse hook that BLOCKS specific known-bad Bash commands at
# the moment they are about to run. It is the mechanical enforcer for "knowing !=
# doing": a loaded lesson does not fire by itself, but a hook at the tool boundary
# does (learning-log Lesson 3).
#
# FAIL-OPEN BY CONTRACT. It denies ONLY a command it positively recognises as
# known-bad; everything else (and any internal error) is allowed. A buggy guard must
# never brick a session. (Hence no `set -e`.)
#
# MENTION vs EXECUTION: a dangerous string INSIDE a quoted argument — a commit
# message, an `echo`, a captured lesson — is a mention, not a command. So we remove
# quoted SPANS first and inspect only the unquoted command skeleton, and we anchor
# detection to command position (start, or right after a shell operator ; && || | ( ).
# (Flattening quote *characters* was an earlier bug: it merged message text into the
# command and blocked a `git commit` whose message merely mentioned `pkill -f`.)
set -uo pipefail   # deliberately NOT -e: a stray non-zero must never become a block

# classify <command> -> echoes a human reason iff the command is known-bad (=> deny),
# else echoes nothing.
classify() {
  local cmd res
  cmd="$1"
  # Drop single- and double-quoted spans (chr(39)/chr(34) avoid quote-hell in -c).
  res="$(python3 -c 'import sys,re
s=sys.argv[1]; q=chr(39); d=chr(34)
s=re.sub(q+"[^"+q+"]*"+q,"",s)
s=re.sub(d+"[^"+d+"]*"+d,"",s)
print(s)' "$cmd" 2>/dev/null || true)"

  # 1. self-matching pkill -f / --full — matches the FULL command line incl. this
  #    shell; killed our own shell twice (exit 144).
  if printf '%s' "$res" | grep -qE '(^|[;&|(])[[:space:]]*pkill[[:space:]][^;&|]*(-[[:alnum:]]*f([[:space:]]|$)|--full)'; then
    echo "pkill -f/--full matches the FULL command line — including this shell (it has killed our own shell twice, exit 144). Kill by PID instead: pgrep -f '<pat>' then kill <pid>, or use a pattern that cannot match the kill command itself."
    return
  fi

  # 2. catastrophic root wipe — rm (any flags) with a root-ish target (/ /* ~ $HOME).
  if printf '%s' "$res" | grep -qE '(^|[;&|(])[[:space:]]*(sudo[[:space:]]+)?rm([[:space:]]+-[[:alnum:]]+)*[[:space:]]+(/|/\*|~|\$HOME)([[:space:]]|$)'; then
    echo "rm on a root path (/ ~ \$HOME /*) is catastrophic and unrecoverable. Target a specific subdirectory, never the root."
    return
  fi
}

# ---- selftest: the contract, as runnable assertions -------------------------------
selftest() {
  local fails=0
  check() { # check <expect deny|allow> <command>
    local want="$1" cmd="$2" reason; reason="$(classify "$cmd")"
    local got="allow"; [ -n "$reason" ] && got="deny"
    if [ "$got" = "$want" ]; then printf '  ok   [%s] %s\n' "$want" "$cmd"
    else printf '  FAIL want=%s got=%s : %s\n' "$want" "$got" "$cmd"; fails=$((fails+1)); fi
  }
  echo "cogito-guard selftest"
  # must DENY (real execution of a known-bad command)
  check deny  'pkill -f "next dev"'
  check deny  'pkill -f http.server'
  check deny  'pkill --full myproc'
  check deny  'pkill -9 -f pattern'
  check deny  'pkill -ef foo'
  check deny  'cd /tmp && pkill -f server'
  check deny  'rm -rf /'
  check deny  'rm -rf /*'
  check deny  'rm -rf ~'
  check deny  'rm -rf $HOME'
  check deny  'sudo rm -rf /'
  check deny  'rm -r -f /'
  check deny  'git commit -m "x"; rm -rf /'         # real rm after an operator
  # must ALLOW — safe commands, or merely MENTIONING a dangerous string
  check allow 'pkill -x exactname'
  check allow 'pkill chrome'
  check allow 'pgrep -f pattern'
  check allow 'echo "pkill -f x"'
  check allow 'echo pkill -f'                        # unquoted mention (not cmd pos)
  check allow './scripts/cogito-learn.sh "lesson: never pkill -f a self-matching pattern"'
  check allow 'git commit -m "fix: never pkill -f or rm -rf /"'   # THE regression
  check allow 'git commit -q -m "guard blocks pkill -f and rm -rf /"'
  check allow $'git commit -m "title\n\nnote: pkill -f and rm -rf / are banned"'  # multiline msg
  check allow 'grep "rm -rf" notes.md'
  check allow 'echo "rm -rf /"'
  check allow 'rm -rf ./build'
  check allow 'rm -rf /tmp/foo'
  check allow 'rm -rf node_modules'
  check allow 'git commit -m "m" && rm -rf ./dist'   # real rm of a specific dir
  check allow 'git status'
  echo
  [ "$fails" -eq 0 ] && echo "selftest: ALL PASS" || { echo "selftest: $fails FAILED"; return 1; }
}

# ---- hook mode: read PreToolUse JSON on stdin, decide ------------------------------
# Contract (verified vs code.claude.com/docs/en/hooks 2026-06-15): deny via exit 0 +
# {hookSpecificOutput.permissionDecision:"deny"} (preferred) or exit 2 + stderr. ANY
# other exit code (incl. crash/timeout) is non-blocking -> the tool proceeds. So every
# path here except a positive match returns 0 = allow. That is the fail-open guarantee.
hook_mode() {
  local input cmd reason
  input="$(cat 2>/dev/null || true)"
  cmd="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    if d.get("tool_name")=="Bash": print(d.get("tool_input",{}).get("command",""))
except Exception: pass' 2>/dev/null || true)"
  [ -n "$cmd" ] || exit 0                 # non-Bash / no command / parse failed -> allow
  reason="$(classify "$cmd")"
  [ -n "$reason" ] || exit 0              # not known-bad -> allow
  if printf '%s' "$reason" | python3 -c 'import sys,json
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"cogito-guard blocked this — "+sys.stdin.read()}}))' 2>/dev/null; then
    exit 0
  fi
  echo "cogito-guard blocked this — $reason" >&2
  exit 2
}

case "${1:-}" in
  --selftest) selftest ;;
  *) hook_mode ;;
esac
