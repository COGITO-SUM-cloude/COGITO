#!/usr/bin/env bash
# cogito-control — the control room, for real (Idea #2). A tiny localhost server that
# turns prototypes/cogito-screen.html from a mock into a working review surface:
#
#   • Inbox  = the live drain queue (docs/inbox/queue.json). Accept / Reject call the
#              SAME authority the CLI uses — scripts/cogito-drain.sh accept|reject <id> —
#              so a click appends to LESSONS.md (or archives), exactly like the drain.
#   • Where it's live = real LOGGED-OUT HTTP checks (curl, no cookies) of the projects in
#              scripts/cogito-projects.txt — the honest "is it up" test.
#
# Binds to 127.0.0.1 ONLY. It can mutate the ledger, so it must never be exposed; the
# brain's write happens via the already-trusted converge hook, never a network key here.
#
#   scripts/cogito-control.sh [port]        (default 8787)  → open http://127.0.0.1:8787
set -euo pipefail
# Resolve ROOT in two unambiguous steps. (A one-liner `git ... || cd ... && pwd` parses as
# `(git || cd) && pwd` and, on git success, appends pwd's output too — a two-line ROOT that
# breaks every derived path.)
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${1:-8787}"

exec env COGITO_ROOT="$ROOT" COGITO_PORT="$PORT" python3 - <<'PY'
import os, json, re, subprocess, urllib.parse, http.server, socketserver, concurrent.futures

ROOT = os.environ["COGITO_ROOT"]
PORT = int(os.environ.get("COGITO_PORT", "8787"))
DRAIN = os.path.join(ROOT, "scripts", "cogito-drain.sh")
DASH  = os.path.join(ROOT, "prototypes", "cogito-screen.html")
# Paths honor the same COGITO_* overrides as cogito-drain.sh (which the subprocess
# inherits) — handy for a sandboxed test that never touches the real brain.
QUEUE = os.environ.get("COGITO_QUEUE",  os.path.join(ROOT, "docs", "inbox", "queue.json"))
LEDGER= os.environ.get("COGITO_LEDGER", os.path.join(ROOT, "skills", "cogito-protocol", "LESSONS.md"))
PROJECTS = os.environ.get("COGITO_PROJECTS", os.path.join(ROOT, "scripts", "cogito-projects.txt"))
CA = next((c for c in (os.environ.get("CURL_CA_BUNDLE"), "/root/.ccr/ca-bundle.crt")
           if c and os.path.exists(c)), None)
ID_RE = re.compile(r'^[0-9a-f]{6,12}$')

def read(path, default=""):
    try:
        with open(path, encoding="utf-8") as f: return f.read()
    except FileNotFoundError: return default

def load_queue():
    try:
        return json.loads(read(QUEUE, "") or "{}") or {"entries": []}
    except ValueError:
        return {"entries": []}

def ledger_lessons():
    return sum(1 for ln in read(LEDGER).splitlines() if re.match(r'^\s*-\s+.*->.*->', ln))

def drain(op, qid):
    if not ID_RE.match(qid or ""):
        return False, {"error": "bad id"}
    try:
        p = subprocess.run(["bash", DRAIN, op, qid], capture_output=True, text=True,
                           cwd=ROOT, timeout=30)
    except Exception as ex:
        return False, {"error": "could not run the drain: %s" % ex}
    try:    out = json.loads(p.stdout.strip() or "{}")
    except ValueError: out = {"stdout": p.stdout.strip()}
    if p.returncode != 0:
        out["error"] = (p.stderr.strip() or "drain failed")
    return p.returncode == 0, out

def projects():
    rows = []
    for ln in read(PROJECTS).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith("#"): continue
        parts = [x.strip() for x in ln.split("|")]
        if len(parts) >= 2:
            rows.append({"name": parts[0], "url": parts[1],
                         "hint": (parts[2] if len(parts) > 2 else "")})
    return rows

def probe(p):
    # ONE logged-out HTTP check. code 000 = unreachable (down); any real code = up.
    cmd = ["curl", "-sS", "-o", "/dev/null", "-w", "%{http_code}", "--max-time", "8"]
    if CA: cmd += ["--cacert", CA]
    cmd += [p["url"]]
    code = "000"
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=12)
        code = (r.stdout.strip() or "000")[:3]
    except Exception:
        code = "000"
    up = code != "000"
    private = p.get("hint") == "private" or code in ("401", "403") or code.startswith("30")
    if not up:        state, meta = "off",  "unreachable"
    elif private:     state, meta = "warn", "live · private (login wall)"
    else:             state, meta = "good", "live · public"
    return {"name": p["name"], "url": p["url"], "code": code, "up": up, "state": state, "meta": meta}

def status():
    ps = projects()
    with concurrent.futures.ThreadPoolExecutor(max_workers=min(8, max(1, len(ps)))) as ex:
        items = list(ex.map(probe, ps)) if ps else []
    return {"projects": items, "lessons": ledger_lessons()}

class H(http.server.BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="application/json"):
        b = body.encode("utf-8") if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(b)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(b)

    def _json(self, code, obj): self._send(code, json.dumps(obj), "application/json")

    def do_GET(self):
        path = urllib.parse.urlparse(self.path).path
        if path in ("/", "/index.html"):
            html = read(DASH)
            return self._send(200 if html else 404, html or "dashboard not found", "text/html; charset=utf-8")
        if path == "/api/queue":  return self._json(200, load_queue())
        if path == "/api/status": return self._json(200, status())
        return self._send(404, "not found", "text/plain")

    def do_POST(self):
        u = urllib.parse.urlparse(self.path)
        qs = urllib.parse.parse_qs(u.query)
        qid = (qs.get("id", [""])[0])
        if u.path == "/api/accept":
            ok, out = drain("accept", qid); return self._json(200 if ok else 400, out)
        if u.path == "/api/reject":
            ok, out = drain("reject", qid); return self._json(200 if ok else 400, out)
        return self._send(404, "not found", "text/plain")

    def log_message(self, *a): pass  # quiet

class Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True

print("cogito control room → http://127.0.0.1:%d   (Ctrl-C to stop)" % PORT, flush=True)
print("  inbox = %s" % QUEUE, flush=True)
try:
    Server(("127.0.0.1", PORT), H).serve_forever()
except KeyboardInterrupt:
    pass
PY
