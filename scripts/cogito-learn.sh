#!/usr/bin/env bash
# cogito-learn — record a lesson into the central Cogito brain so EVERY future
# session (any repo) inherits it. Usage:
#   scripts/cogito-learn.sh "SYMPTOM -> ROOT CAUSE -> RULE"
#
#   - In the central Cogito repo  -> append to the local ledger (then commit & push).
#   - Elsewhere with $COGITO_TOKEN -> append to the central repo via the GitHub API.
#   - Elsewhere with no token      -> queue locally + warn LOUDLY (never silently lose one).
#
# NOTE: the token (API) path is built but must be verified live the first time a
# token exists — we do not trust unverified lesson-capture.
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

# Mode 2 — elsewhere with a token: push via the GitHub API (token read from env, never argv).
if [ -n "${COGITO_TOKEN:-}" ]; then
  if python3 - "$OWNER" "$REPO" "$LP" "$LESSON" <<'PY'
import os,sys,json,base64,ssl,urllib.request
owner,repo,path,lesson=sys.argv[1:5]; tok=os.environ["COGITO_TOKEN"]
api=f"https://api.github.com/repos/{owner}/{repo}/contents/{path}"
def call(url,method="GET",data=None,ctx=None):
    r=urllib.request.Request(url,method=method,data=(json.dumps(data).encode() if data else None))
    r.add_header("Authorization",f"Bearer {tok}"); r.add_header("Accept","application/vnd.github+json")
    return json.load(urllib.request.urlopen(r,context=ctx))
def run(ctx):
    cur=call(api,ctx=ctx); body=base64.b64decode(cur["content"]).decode()
    body=(body if body.endswith("\n") else body+"\n")+f"- {lesson}\n"
    call(api,"PUT",{"message":"cogito: capture lesson from a satellite session",
                    "content":base64.b64encode(body.encode()).decode(),"sha":cur["sha"]},ctx=ctx)
try: run(None)
except ssl.SSLError: run(ssl._create_unverified_context())  # egress may intercept TLS
print("ok")
PY
  then echo "cogito-learn: pushed the lesson to the central brain via API."; exit 0
  else echo "cogito-learn: API push FAILED — queueing locally instead (lesson NOT lost)." >&2; fi
fi

# Mode 3 — fallback: queue locally, warn loudly.
mkdir -p "$(dirname "$QUEUE")"; printf -- '- %s\n' "$LESSON" >> "$QUEUE"
echo "cogito-learn: queued to $QUEUE (lesson saved locally)." >&2
echo "  Set COGITO_TOKEN (docs/cogito-everywhere.md) for auto-sync, or paste these into a Cogito session." >&2
exit 0
