#!/usr/bin/env bash
# cogito-serve — the browser bridge (Phase 2). A tiny localhost server that runs the
# file-native teacher OUTSIDE a Claude session: it reads the learner profile + due review
# + the lesson object, builds the constrained-tutor prompt, and calls the LLM via the
# existing scripts/cogito-openrouter.sh (so the API key stays in its one vetted path —
# server-side only, never the browser). Serves the chat UI in teacher/.
#
#   scripts/cogito-serve.sh [port] [learner]      (default port 8133, learner 'primary')
#   then open http://127.0.0.1:8133
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PORT="${1:-8133}"
LEARNER="${2:-${COGITO_LEARNER:-primary}}"

exec env COGITO_ROOT="$ROOT" COGITO_PORT="$PORT" COGITO_LEARNER="$LEARNER" python3 - <<'PY'
import os, sys, json, re, subprocess, http.server
ROOT = os.environ["COGITO_ROOT"]
PORT = int(os.environ.get("COGITO_PORT", "8133"))
LEARNER = os.environ.get("COGITO_LEARNER", "primary")
PROFILE_REL = "learners/%s/profile.md" % LEARNER
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

def due_review():
    # (lesson_number, recap_cue) for the most-overdue item, via the existing scheduler.
    try:
        lines = subprocess.run(["bash", os.path.join(ROOT, "scripts/cogito-review.sh"), "due", "--quiet"],
                               capture_output=True, text=True, cwd=ROOT, timeout=15).stdout.strip().splitlines()
    except Exception:
        return (None, "")
    if not lines:
        return (None, "")
    m = re.match(r'Lesson (\d+)', lines[0])
    return (int(m.group(1)) if m else None, lines[1] if len(lines) > 1 else "")

def grade_review(num, result):
    # write-back: record the spaced-repetition result via the existing scheduler.
    try:
        subprocess.run(["bash", os.path.join(ROOT, "scripts/cogito-review.sh"), "grade", str(num), result],
                       capture_output=True, text=True, cwd=ROOT, timeout=15)
    except Exception:
        pass

def assess_recall(cue, answer):
    # one narrow PASS/FAIL/SKIP judgment — binary tasks are reliable even on free models.
    prompt = ('A learner was asked this review question:\n"%s"\nThey answered:\n"%s"\n'
              'Did they recall it correctly? Reply with ONE word only: PASS, FAIL, or SKIP '
              '(SKIP if they did not actually attempt it).' % (cue, answer))
    reply, err = call_llm(prompt)
    if err or not reply.strip():
        return None
    up = reply.strip().upper()
    if "SKIP" in up: return "SKIP"
    if "FAIL" in up: return "FAIL"
    if "PASS" in up: return "PASS"
    return None

def lesson_field(label):
    m = re.search(r'\*\*' + label + r'[^:]*:\*\*\s*(.+?)(?=\n-\s*\*\*|\n##|\Z)', read(LESSON_PATH), re.S)
    return re.sub(r'\s+', ' ', m.group(1)).strip() if m else ""

def current_learning_skill():
    # the skill the learner is mid-way through (first profile row in state 'learning')
    for line in read(PROFILE_REL).splitlines():
        if line.strip().startswith("|"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) >= 5 and cells[3].lower() == "learning":
                return cells[0]
    return None

def assess_mastery(transcript):
    crit = lesson_field("Mastery")
    if not crit:
        return None
    prompt = ("A lesson's mastery test is:\n%s\n\nThe learner said, across the session:\n%s\n\n"
              "Has the learner MET that test — explained it correctly in their OWN words, unprompted? "
              "Reply ONE word only: MASTERED or NOTYET." % (crit, transcript))
    reply, err = call_llm(prompt)
    if err or not reply.strip():
        return None
    up = reply.strip().upper().replace(" ", "")
    if "NOTYET" in up: return "NOTYET"
    if "MASTERED" in up: return "MASTERED"
    return None

def advance_skill(skill):
    # profile write-back: flip the skill's state cell learning -> mastered.
    import datetime
    path = os.path.join(ROOT, PROFILE_REL)
    try:
        prof = open(path, encoding="utf-8").read()
    except Exception:
        return
    today, out = datetime.date.today().isoformat(), []
    for line in prof.splitlines():
        s = line.strip()
        if s.startswith("|") and s.strip("|").split("|")[0].strip() == skill:
            cells = [c.strip() for c in s.strip("|").split("|")]
            if len(cells) >= 5:
                cells[3], cells[4] = "mastered", "%s mastered (auto)" % today
                line = "| " + " | ".join(cells) + " |"
        out.append(line)
    open(path, "w", encoding="utf-8").write("\n".join(out) + ("\n" if prof.endswith("\n") else ""))

def build_prompt(messages):
    profile, lesson, cue = read(PROFILE_REL), read(LESSON_PATH), due_review()[1]
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
        messages = payload.get("messages", [])
        # write-back: on the learner's FIRST answer (the review opener), grade the recall
        # and record it through the scheduler — once per session, not every turn.
        graded = None
        user_msgs = [m for m in messages if m.get("role") == "user"]
        if len(user_msgs) == 1:
            num, cue = due_review()
            if num is not None:
                verdict = assess_recall(cue, user_msgs[0].get("content", ""))
                if verdict in ("PASS", "FAIL"):
                    grade_review(num, "pass" if verdict == "PASS" else "fail")
                    graded = verdict
        reply, err = call_llm(build_prompt(messages))
        out = {"reply": reply} if not err else {"error": err}
        if graded: out["graded"] = graded
        # write-back #2: advance the current skill to 'mastered' once the learner meets its
        # observable mastery test in their own words. Self-limiting — once advanced, there is
        # no 'learning' skill left to assess.
        if len([m for m in messages if m.get("role") == "user"]) >= 2:
            skill = current_learning_skill()
            if skill:
                transcript = "\n".join("%s: %s" % (m.get("role", ""), m.get("content", "")) for m in messages)
                if assess_mastery(transcript) == "MASTERED":
                    advance_skill(skill)
                    out["mastered"] = skill
        return self._send(200, json.dumps(out))

httpd = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), H)
sys.stderr.write("cogito-teacher serving on http://127.0.0.1:%d  (Ctrl-C to stop)\n" % PORT)
httpd.serve_forever()
PY
