#!/usr/bin/env bash
# Cogito "eyes" — screenshot a URL from the command line, with the exact flags this
# environment needs. A simple, dependency-free fallback for the chrome-devtools MCP.
#
# Usage:  scripts/see.sh <url> [out.png] [WIDTHxHEIGHT]
# Example: scripts/see.sh https://paint-jfl-lol-projects.vercel.app /tmp/home.png 1280x1000
#
# Notes:
#   - --ignore-certificate-errors: this env's egress intercepts TLS with an untrusted
#     proxy cert; without this flag Chrome shows "Your connection is not private".
#   - --no-sandbox: required because we run as root.
#   - --virtual-time-budget waits for content; JS count-up animations may render at
#     their start value. For pixel-perfect / network/console inspection use the MCP.
set -euo pipefail

URL="${1:?usage: scripts/see.sh <url> [out.png] [WxH]}"
OUT="${2:-/tmp/eyes.png}"
SIZE="${3:-1280x1000}"
W="${SIZE%x*}"; H="${SIZE#*x}"
CHROME="${COGITO_EYES_DIR:-${HOME}/.cache/cogito-eyes}/chrome"   # ${HOME}=/root in the web sandbox; matches .mcp.json there

if [ ! -x "$CHROME" ]; then
  echo "eyes: Chrome not installed yet — running scripts/ensure-eyes.sh first." >&2
  "$(dirname "$0")/ensure-eyes.sh"
fi

"$CHROME" --headless=new --no-sandbox --disable-gpu --hide-scrollbars \
  --ignore-certificate-errors --window-size="$W,$H" \
  --virtual-time-budget=12000 --run-all-compositor-stages-before-draw \
  --screenshot="$OUT" "$URL" 2>/dev/null

if [ -s "$OUT" ]; then echo "eyes: saved $OUT"; else echo "eyes: FAILED to capture $URL" >&2; exit 1; fi
