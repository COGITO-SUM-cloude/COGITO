#!/usr/bin/env bash
# Cogito OpenRouter caller — adds ONE genuinely different (non-Claude) voice to the
# council, the cheapest cure for "one voice in triplicate" (decorrelated weights).
# Uses FREE models via OpenRouter ($0).
#
# FALLBACK CHAIN: free tiers rotate out / rate-limit, so a single slug is brittle.
# It tries models in order and the first that answers wins. The default prefers
# Hermes (the user's pick), then falls back to other free models.
#
# SECURITY: the API key is read IN-PROCESS from $OPENROUTER_API_KEY and crosses into
# Python via the environment only — NEVER in argv, NEVER written to a file (secrets
# stay off the command line). Set it as an environment secret; never paste it in chat.
#
# Degrades gracefully: no key / all models down -> one-line notice on stderr and a
# non-zero exit, so the council simply runs Claude-only. Prompt on stdin; answer on
# stdout; which model answered is reported on stderr.
#
#   echo "the question" | scripts/cogito-openrouter.sh ["model1,model2,..."]
#   default chain via $COGITO_OR_MODELS, else: hermes-405b -> llama-3.3-70b -> qwen3-next-80b (all :free)
set -uo pipefail

# openrouter/free leads the chain: it auto-routes over whatever free models are live,
# so a deprecated/rate-limited slug can't silence the non-Claude voice. Explicit free
# slugs stay as fallback. (NB: openrouter/fusion is a separate, PAID product — kept out
# of this $0 chain on purpose.)
DEFAULT_CHAIN="openrouter/free,nousresearch/hermes-3-llama-3.1-405b:free,nvidia/nemotron-3-nano-30b-a3b:free,google/gemma-4-31b-it:free,meta-llama/llama-3.3-70b-instruct:free,qwen/qwen3-next-80b-a3b-instruct:free"
MODELS="${1:-${COGITO_OR_MODELS:-$DEFAULT_CHAIN}}"

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "cogito-openrouter: no OPENROUTER_API_KEY set — skipping the non-Claude voice (council runs Claude-only)." >&2
  exit 3
fi
prompt="$(cat)"
if [ -z "$prompt" ]; then
  echo "cogito-openrouter: empty prompt on stdin." >&2
  exit 2
fi

OPENROUTER_API_KEY="$OPENROUTER_API_KEY" COGITO_MODELS="$MODELS" COGITO_PROMPT="$prompt" python3 - <<'PY'
import os, sys, json, urllib.request, urllib.error
key = os.environ["OPENROUTER_API_KEY"]
models = [m.strip() for m in os.environ["COGITO_MODELS"].split(",") if m.strip()]
prompt = os.environ["COGITO_PROMPT"]
last = "no models tried"
for model in models:
    body = json.dumps({"model": model, "messages": [{"role": "user", "content": prompt}]}).encode()
    req = urllib.request.Request(
        "https://openrouter.ai/api/v1/chat/completions",
        data=body,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
        method="POST")
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            data = json.load(r)
        msg = data["choices"][0]["message"]["content"]
        sys.stderr.write("cogito-openrouter: answered by %s\n" % model)
        print(msg)
        sys.exit(0)
    except urllib.error.HTTPError as e:
        last = "HTTP %s on %s — %s" % (e.code, model, e.read()[:160].decode("utf-8", "replace"))
    except Exception as e:
        last = "%s on %s" % (e, model)
    sys.stderr.write("cogito-openrouter: %s; trying next...\n" % last)
sys.stderr.write("cogito-openrouter: all models failed (last: %s). Council stays Claude-only.\n" % last)
sys.exit(4)
PY
