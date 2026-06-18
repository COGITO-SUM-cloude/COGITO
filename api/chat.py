from http.server import BaseHTTPRequestHandler
import json, os, urllib.request

# Self-contained Cogito-teacher brain for a Vercel serverless deploy. The canonical,
# file-native teacher lives in scripts/cogito-serve.sh + the repo's brain files; this is a
# trimmed, read-only copy (no write-back) so the user can TEST the voice + teaching in a
# browser. The API key is read from the OPENROUTER_API_KEY env var ONLY (set it in the
# Vercel project settings — never in the repo).

TUTOR = (
    "You are Cogito — a warm, encouraging tutor who talks like a favorite teacher: patient, "
    "curious, a little playful, and genuinely interested in the learner. Sound like a real "
    "person in conversation, NOT a textbook and NOT a list.\n"
    "How you teach:\n"
    "- Hint, don't lecture: ask a question that lets them figure it out; give the answer only "
    "after they've really tried, and warmly acknowledge it when they get there.\n"
    "- Teach ONLY from the LESSON below. If they ask something it doesn't cover, say warmly "
    "that you'll find them a good source — never make a fact up.\n"
    "- Plain, everyday words. Short, natural sentences — one small step at a time. No jargon, "
    "no bullet-point lectures, no emojis.\n"
    "- If the chat is just starting, open with ONE friendly line, then the REVIEW question — "
    "nothing else."
)
REVIEW = ('Open by asking, as a question: "Trail in the grass — what makes the path deeper, '
          'looking at it or walking it?" (this checks the testing effect / retrieval practice).')
LESSON = (
    "LESSON — Adenosine, the brain's tiredness chemical (teach ONLY from this):\n"
    "- Concept: Tiredness isn't running out of fuel — it's a chemical, adenosine, piling up "
    "the longer you're awake; the more it builds, the foggier you feel. Sleep clears it. "
    "Caffeine doesn't add energy — it blocks adenosine's parking spots so the tiredness "
    "signal can't land; the adenosine keeps building, so when caffeine wears off it floods "
    "in at once (the crash).\n"
    "- Hint (don't reveal): \"Caffeine makes you feel less tired — is it adding energy, or "
    "blocking the feeling? And if tiredness is a signal, what's building up to send it?\"\n"
    "- Mastery: they can explain, in their own words, that (a) tiredness = adenosine building "
    "up, (b) sleep clears it, (c) caffeine blocks the signal rather than adds energy; bonus: "
    "the crash = the adenosine was there all along.\n"
    "- Misconceptions to fix: 'caffeine gives energy' (no — it blocks the signal); 'tired = "
    "low sugar' (it's mostly adenosine load)."
)
MODELS = [
    # openrouter/free is OpenRouter's auto-router over whatever free models are live
    # right now — tried FIRST so a single deprecated/rate-limited slug can't blank the
    # teacher (the "free model is busy" failure). The explicit slugs below remain a
    # belt-and-suspenders fallback if the router itself is unavailable.
    "openrouter/free",
    "nvidia/nemotron-3-nano-30b-a3b:free",
    "google/gemma-4-31b-it:free",
    "meta-llama/llama-3.3-70b-instruct:free",
    "qwen/qwen3-next-80b-a3b-instruct:free",
    "nousresearch/hermes-3-llama-3.1-405b:free",
]


def call_llm(prompt):
    key = os.environ.get("OPENROUTER_API_KEY")
    if not key:
        return None, "no_key"
    for m in MODELS:
        body = json.dumps({"model": m, "messages": [{"role": "user", "content": prompt}]}).encode()
        req = urllib.request.Request(
            "https://openrouter.ai/api/v1/chat/completions", data=body,
            headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"}, method="POST")
        try:
            # Per-model timeout kept well under the Vercel function budget (maxDuration
            # 60s in vercel.json): one slow/hung free model must not eat the whole budget
            # and starve the fallbacks. 5 models x 10s = 50s < 60s.
            with urllib.request.urlopen(req, timeout=10) as r:
                return json.load(r)["choices"][0]["message"]["content"], None
        except Exception:
            continue
    return None, "all_models_failed"


class handler(BaseHTTPRequestHandler):
    def _send(self, code, obj):
        b = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(b)))
        self.end_headers()
        self.wfile.write(b)

    def do_POST(self):
        try:
            # Cap the read: a chat turn is tiny, so refuse to pull an arbitrarily large
            # body into memory on an untrusted public endpoint (a declared Content-Length
            # of gigabytes would otherwise be read whole). 64 KB is generous for messages.
            n = int(self.headers.get("Content-Length", 0))
            if n < 0 or n > 65536:
                return self._send(413, {"reply": "That message is too large — keep it short and send again."})
            messages = json.loads(self.rfile.read(n) or b"{}").get("messages", [])
        except Exception:
            messages = []
        if any(m.get("role") == "user" for m in messages):
            convo = "\n".join("%s: %s" % (m.get("role", "").upper(), m.get("content", "")) for m in messages)
        else:
            convo = "(the session is just beginning — produce the opener now)"
        prompt = "\n\n".join([TUTOR, REVIEW, LESSON,
                              "=== CONVERSATION SO FAR ===\n" + convo,
                              "Reply as TEACHER for the next single turn (hint first, plain words, never invent):"])
        reply, err = call_llm(prompt)
        if err == "no_key":
            return self._send(200, {"reply": "Hi — I'm your teacher, and you can hear my voice. "
                                              "My thinking isn't switched on yet: add OPENROUTER_API_KEY in the "
                                              "Vercel project settings, then reload this page and we'll begin."})
        if err:
            return self._send(200, {"reply": "The free model is busy this second — give it a moment and send again."})
        return self._send(200, {"reply": reply})

    def do_GET(self):
        return self._send(200, {"ok": True})
