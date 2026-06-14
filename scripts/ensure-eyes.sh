#!/usr/bin/env bash
# Cogito "eyes" — guarantee a headless Chrome exists so the AI can SEE web work
# (screenshots, DOM, console, network) via the chrome-devtools MCP or scripts/see.sh.
#
# Why this script exists:
#   - The container is ephemeral: anything in ~/.cache is wiped on a new session,
#     so Chrome must be (re)installed the first time eyes are used each session.
#   - Egress is the env's network policy. With Network access = Full, Chrome for
#     Testing installs straight from the registry/Google host. (storage.googleapis
#     .com returns 403 only on *bucket listings* — the real binary host is open.)
#   - We run as root with no system Chrome, so the MCP/CLI must be pointed at a
#     downloaded binary (--executablePath) and launched --no-sandbox.
#
# Idempotent: if Chrome is already present and runnable, it exits fast (no download).
# Run it once per session before using the eyes; it costs a ~170MB download only on
# the first run in a fresh container, nothing after.
set -euo pipefail

STABLE_DIR="/root/.cache/cogito-eyes"
STABLE="$STABLE_DIR/chrome"          # stable path that .mcp.json + see.sh point at
mkdir -p "$STABLE_DIR"

if [ -x "$STABLE" ] && "$STABLE" --version >/dev/null 2>&1; then
  echo "eyes: ready -> $("$STABLE" --version 2>/dev/null)"
  exit 0
fi

echo "eyes: installing Chrome for Testing (one-time for this container)..."
OUT="$(npx -y @puppeteer/browsers install chrome@stable --path /root/.cache/puppeteer 2>&1 | tail -1)"
echo "  $OUT"
BIN="$(printf '%s\n' "$OUT" | grep -oE '/[^ ]*/chrome-linux64/chrome' | tail -1)"

if [ -z "${BIN:-}" ] || [ ! -x "$BIN" ]; then
  echo "eyes: ERROR — could not locate the installed Chrome binary." >&2
  echo "      Is Network access set to Full for this environment?" >&2
  exit 1
fi

ln -sfn "$BIN" "$STABLE"
if "$STABLE" --version >/dev/null 2>&1; then
  echo "eyes: ready -> $STABLE"
else
  echo "eyes: ERROR — installed Chrome will not launch." >&2
  exit 1
fi
