#!/usr/bin/env bash
# Cogito OpenRouter caller — adds ONE genuinely different (non-Claude) voice to the
# council, the cheapest cure for "one voice in triplicate" (decorrelated weights,
# not just a different lens). Uses a FREE model via OpenRouter's free tier ($0).
#
# SECURITY: the API key is read IN-PROCESS from $OPENROUTER_API_KEY and passed to
# Python via the environment only — it is NEVER placed in argv and NEVER written to
# a file (secrets stay off the command line; respects the standing security rules).
# Set the key as an environment secret in your Claude Code environment settings;
# do NOT paste it into chat or hard-code it.
#
# Degrades gracefully: no key / no network -> a one-line notice on stderr and a
# non-zero exit, so the council simply runs Claude-only. Reads the prompt from
# stdin; prints the model's answer to stdout.
#
#   echo "the question" | scripts/cogito-openrouter.sh [model]
#   default model: deepseek/deepseek-r1:free   (override with $COGITO_OR_MODEL or $1)
set -uo pipefail

MODEL="${1:-${COGITO_OR_MODEL:-deepseek/deepseek-r1:free}}"

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "cogito-openrouter: no OPENROUTER_API_KEY set — skipping the non-Claude voice (council runs Claude-only)." >&2
  exit 3
fi

prompt="$(cat)"
if [ -z "$prompt" ]; then
  echo "cogito-openrouter: empty prompt on stdin." >&2
  exit 2
fi

# key + prompt cross into Python via the environment (not argv, not a file)
OPENROUTER_API_KEY="$OPENROUTER_API_KEY" COGITO_MODEL="$MODEL" COGITO_PROMPT="$prompt" python3 - <<'PY'
import os, sys, json, urllib.request, urllib.error
key = os.environ["OPENROUTER_API_KEY"]
model = os.environ["COGITO_MODEL"]
prompt = os.environ["COGITO_PROMPT"]
body = json.dumps({"model": model, "messages": [{"role": "user", "content": prompt}]}).encode()
req = urllib.request.Request(
    "https://openrouter.ai/api/v1/chat/completions",
    data=body,
    headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
    method="POST",
)
try:
    with urllib.request.urlopen(req, timeout=60) as r:
        data = json.load(r)
    print(data["choices"][0]["message"]["content"])
except urllib.error.HTTPError as e:
    detail = e.read()[:300].decode("utf-8", "replace")
    sys.stderr.write("cogito-openrouter: HTTP %s — %s\n" % (e.code, detail))
    sys.exit(4)
except Exception as e:
    sys.stderr.write("cogito-openrouter: request failed — %s\n" % e)
    sys.exit(5)
PY
