#!/usr/bin/env bash
# cogito-teach — open a teaching session board for a learner: the due retrieval rep,
# the next unlocked lesson, and the constrained-tutor rules. Composes the existing
# pieces (does NOT duplicate them): cogito-review.sh (scheduling) + the learner profile
# (mastery state) + the lesson objects (content). The engine spec is skills/cogito-teacher.
#
#   scripts/cogito-teach.sh [learner]      (default: primary)
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LEARNER="${1:-primary}"

exec python3 - "$ROOT" "$LEARNER" <<'PY'
import sys, os, re, subprocess
ROOT, LEARNER = sys.argv[1], sys.argv[2]
profile = os.path.join(ROOT, "learners", LEARNER, "profile.md")
if not os.path.isfile(profile):
    sys.stderr.write(f"cogito-teach: no profile at {profile}\n"); sys.exit(1)
text = open(profile).read()

# --- parse the skill-map table (the per-skill mastery model) ---
rows = []
for line in text.splitlines():
    if not line.strip().startswith("|"):
        continue
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) < 5:
        continue
    if cells[0] in ("skill", "") or set(cells[0]) <= set("-: "):   # header / separator
        continue
    skill, obj, prereq, state, last = cells[:5]
    pres = [] if prereq in ("—", "-", "") else [p.strip() for p in prereq.split(",") if p.strip()]
    rows.append(dict(skill=skill, obj=obj, prereqs=pres, state=state.lower(), last=last))

mastered = {r["skill"] for r in rows if r["state"] == "mastered"}
nxt = next((r for r in rows if r["state"] in ("next", "learning")
            and all(p in mastered for p in r["prereqs"])), None)

def field(body, label):
    m = re.search(r'-\s*\*\*' + label + r'[^:]*:\*\*\s*(.+?)(?=\n-\s*\*\*|\n##|\Z)', body, re.DOTALL)
    return re.sub(r'\s+', ' ', m.group(1)).strip() if m else None

print(f"=== Teaching session board — learner: {LEARNER} ===\n")

# 1) retrieval rep — reuse the review scheduler, don't reimplement it
print("1) OPEN WITH RETRIEVAL (ask this first, then grade it honestly):")
rv = os.path.join(ROOT, "scripts", "cogito-review.sh")
try:
    out = subprocess.run(["bash", rv, "due"], capture_output=True, text=True, cwd=ROOT)
    print("   " + (out.stdout or out.stderr or "(no review scheduler output)").rstrip("\n").replace("\n", "\n   "))
except Exception as e:
    print(f"   (could not run cogito-review.sh: {e})")

# 2) next unlocked lesson — first 'next'/'learning' skill whose prereqs are all mastered
print("\n2) NEXT NEW LESSON (prereqs mastered, not yet mastered):")
if not nxt:
    print("   None unlocked — review only, or add a lesson whose prereqs are mastered.")
else:
    print(f"   skill: {nxt['skill']}   (state: {nxt['state']}, prereqs: {', '.join(nxt['prereqs']) or 'none'})")
    objpath = nxt["obj"]
    full = None if objpath.startswith("(") else os.path.join(ROOT, objpath)
    if full and os.path.isfile(full):
        body = open(full).read()
        title = body.splitlines()[0].lstrip("# ").strip()
        concept, hint = field(body, "Concept"), field(body, "Hint")
        print(f"   lesson object: {objpath}")
        print(f"   title: {title}")
        if concept:
            print(f"   concept: {concept[:200]}{'…' if len(concept) > 200 else ''}")
        if hint:
            print(f"   open with the hint: {hint[:240]}{'…' if len(hint) > 240 else ''}")
    else:
        print(f"   (no lesson-object file yet: {objpath} — author one under docs/learning/lessons/)")

# 3) the constrained-tutor rules
print("\n3) RUN THE CONSTRAINED LOOP (engine: skills/cogito-teacher):")
print("   - Hint-ladder: pump → hint → worked example → reveal only after ~3 honest stalls.")
print("   - Content-LOCK: teach ONLY from the lesson object; outside it → 'let me find a")
print("     source', never invent. (The #1 guard for a child.)")
print("   - Mastery gate: advance only when explained unprompted, in their own words.")
print("   - Record: cogito-review.sh grade <N> pass|fail, then update the profile state.")
PY
