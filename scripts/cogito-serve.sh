#!/usr/bin/env bash
# cogito-serve — the browser bridge (Phase 2). A tiny localhost server that runs the
# file-native teacher OUTSIDE a Claude session: it reads the learner profile + due review
# + the lesson object, builds the constrained-tutor prompt, and calls the LLM via the
# existing scripts/cogito-openrouter.sh (so the API key stays in its one vetted path —
# server-side only, never the browser). Serves the chat UI in teacher/.
#
#   scripts/cogito-serve.sh [port]      (default 8133; binds 127.0.0.1 only)
#   then open http://127.0.0.1:8133
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PORT="${1:-8133}"

exec env COGITO_ROOT="$ROOT" COGITO_PORT="$PORT" python3 - <<'PY'
import os, sys, json, subprocess, http.server
ROOT = os.environ["COGITO_ROOT"]
PORT = int(os.environ.get("COGITO_PORT", "8133"))
TEACHER_DIR = os.path.join(ROOT, "teacher")
LESSON_PATH = "docs/learning/lessons/neuroscience/L-adenosine.md"

TUTOR_RULES = """You are the Cogito Teacher — a calm, plain-spoken tutor for ONE adult learner.
HARD RULES:
- Teach ONLY from the LESSON block below. If asked something outside it, say you'll find a
  real source — do NOT invent facts. If a question is close-but-not-covered, name that seam.
- Hint, don't lecture: ask a question that lets them predict or derive before you explain.
  Never hand over the answer you want them to reach until they have genuinely tried.
- Plain everyday words, short. Adult-to-adult. No jargon dumps, no emojis, no cheerleading.
- One small step per turn. Confirm what they got right, then nudge the next piece.
- If the session is just beginning, OPEN with the DUE REVIEW cue as a question (retrieval
  practice) and nothing else — do not start the new lesson yet."""

def read(rel):
    try:
        with open(os.path.join(ROOT, rel), encoding="utf-8") as f: return f.read()
    except Exception: return ""

def due_cue():
    try:
        out = subprocess.run(["bash", os.path.join(ROOT, "scripts/cogito-review.sh"), "due", "--quiet"],
                             capture_output=True, text=True, cwd=ROOT, timeout=15)
        return out.stdout.strip()
    except Exception: return ""

def build_prompt(messages):
    profile, lesson, cue = read("learners/primary/profile.md"), read(LESSON_PATH), due_cue()
    if any(m.get("role") == "user" for m in messages):
        convo = "\n".join("%s: %s" % (m.get("role","user").upper(), m.get("content","")) for m in messages)
    else:
        convo = "(the session is just beginning — produce the opener now)"
    return "\n\n".join([
        TUTOR_RULES,
        "=== LEARNER PROFILE ===\n" + profile,
        "=== DUE REVIEW CUE (open with this if the session is starting) ===\n" + (cue or "(nothing due)"),
        "=== LESSON (teach ONLY from this) ===\n" + lesson,
        "=== CONVERSATION SO FAR ===\n" + convo,
        "Reply as TEACHER for the next single turn (hint first, plain words, never invent):",
    ])

def call_llm(prompt):
    try:
        p = subprocess.run(["bash", os.path.join(ROOT, "scripts/cogito-openrouter.sh")],
                           input=prompt, capture_output=True, text=True, cwd=ROOT, timeout=120)
        if p.returncode == 0 and p.stdout.strip():
            return p.stdout.strip(), None
        tail = p.stderr.strip().splitlines()[-1] if p.stderr.strip() else "LLM call failed"
        return None, tail
    except Exception as e:
        return None, str(e)

class H(http.server.BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="application/json"):
        b = body if isinstance(body, bytes) else body.encode("utf-8")
        self.send_response(code); self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(b))); self.end_headers(); self.wfile.write(b)
    def log_message(self, *a): pass
    def do_GET(self):
        if self.path == "/api/health":
            return self._send(200, json.dumps({"ok": True}))
        path = "/index.html" if self.path in ("/", "") else self.path.split("?")[0]
        fp = os.path.normpath(os.path.join(TEACHER_DIR, path.lstrip("/")))
        if not fp.startswith(TEACHER_DIR) or not os.path.isfile(fp):
            return self._send(404, "not found", "text/plain")
        ctype = "text/html" if fp.endswith(".html") else "application/octet-stream"
        with open(fp, "rb") as f: return self._send(200, f.read(), ctype)
    def do_POST(self):
        if self.path != "/api/chat":
            return self._send(404, json.dumps({"error": "unknown endpoint"}))
        n = int(self.headers.get("Content-Length", 0))
        try: payload = json.loads(self.rfile.read(n) or b"{}")
        except Exception: payload = {}
        reply, err = call_llm(build_prompt(payload.get("messages", [])))
        return self._send(200, json.dumps({"reply": reply} if not err else {"error": err}))

httpd = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), H)
sys.stderr.write("cogito-teacher serving on http://127.0.0.1:%d  (Ctrl-C to stop)\n" % PORT)
httpd.serve_forever()
PY
