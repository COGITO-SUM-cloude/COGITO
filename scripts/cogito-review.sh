#!/usr/bin/env bash
# Cogito spaced-repetition review for the LEARNING LOG (docs/learning/log.md) — the
# human-growth twin of the lessons ledger. Schedules WHEN to revisit each lesson so the
# spacing + testing effects fire, instead of hoping we remember to recap.
#
# Scheduler: FSRS-5 (Free Spaced Repetition Scheduler) — the modern open standard
# (Anki's default; ~20-30% fewer reviews than Leitner/SM-2 for the same retention). Each
# lesson carries its own memory state: S=<stability,days> D=<difficulty,1-10> plus
# due:/rev: dates. A review updates S and D from the grade and how overdue it was, then
# schedules the next visit at the requested retention (default 0.90, $COGITO_FSRS_RETENTION).
#
# Backward compatible: legacy `box:N` lines (the old Leitner ladder) are read and seeded
# into FSRS automatically — lazily migrated to S=/D= the next time that lesson is graded,
# so the file converts itself with no bulk rewrite and no data loss. `box:0` = seeded
# (not yet in rotation); first grade initialises its FSRS state.
#
#   cogito-review.sh due [--quiet]      the most-overdue lesson's recap cue (--quiet
#                                       prints just the cue, for the SessionStart hook)
#   cogito-review.sh list               every lesson with state / due / overdue
#   cogito-review.sh grade N <result>   record a recall. result = pass|fail (kept for the
#                                       hook) OR the finer FSRS scale again|hard|good|easy
#                                       (pass=good, fail=again).
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG="$ROOT/docs/learning/log.md"
[ -f "$LOG" ] || { echo "cogito-review: no learning log at $LOG" >&2; exit 1; }

exec python3 - "$LOG" "$@" <<'PY'
import sys, re, math, os, datetime
LOG = sys.argv[1]
args = sys.argv[2:]
cmd = args[0] if args else 'due'
today = datetime.date.today()

# --- FSRS-5 (default parameters) ----------------------------------------------------
W = [0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575,
     0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, 0.6621]
DECAY  = -0.5
FACTOR = 0.9 ** (1.0 / DECAY) - 1.0           # ~0.2345 (so the interval at R=0.9 equals S)
R_TARGET = float(os.environ.get("COGITO_FSRS_RETENTION", "0.9"))
BOX_INTERVAL = {1: 1, 2: 3, 3: 7, 4: 16, 5: 35, 6: 90}   # legacy Leitner -> seed stability
GRADE = {'fail': 1, 'again': 1, 'hard': 2, 'pass': 3, 'good': 3, 'easy': 4}

def clamp(x, lo, hi): return max(lo, min(hi, x))
def init_stability(g):  return max(W[g - 1], 0.1)
def init_difficulty(g): return clamp(W[4] - math.exp(W[5] * (g - 1)) + 1.0, 1.0, 10.0)
def retrievability(t, S): return (1.0 + FACTOR * max(t, 0) / S) ** DECAY
def next_interval(S):
    iv = (S / FACTOR) * (R_TARGET ** (1.0 / DECAY) - 1.0)
    return max(1, int(round(iv)))
def next_difficulty(D, g):
    Dp = D - W[6] * (g - 3)                                    # harder grade -> lower D
    return clamp(W[7] * init_difficulty(4) + (1.0 - W[7]) * Dp, 1.0, 10.0)  # mean-revert
def stab_recall(D, S, R, g):
    hard = W[15] if g == 2 else 1.0
    easy = W[16] if g == 4 else 1.0
    return S * (1.0 + math.exp(W[8]) * (11.0 - D) * (S ** -W[9])
                * (math.exp(W[10] * (1.0 - R)) - 1.0) * hard * easy)
def stab_forget(D, S, R):
    return W[11] * (D ** -W[12]) * (((S + 1.0) ** W[13]) - 1.0) * math.exp(W[14] * (1.0 - R))

def parse(text):
    lines = text.split('\n')
    heads = [i for i, l in enumerate(lines) if re.match(r'## Lesson \d+', l)]
    out = []
    for k, start in enumerate(heads):
        end = heads[k + 1] if k + 1 < len(heads) else len(lines)
        block = '\n'.join(lines[start:end])
        m = re.match(r'## Lesson (\d+) — (.*)', lines[start])
        sm  = re.search(r'\bS=([\d.]+)', block)
        dm  = re.search(r'\bD=([\d.]+)', block)
        bm  = re.search(r'box:(\d+)', block)
        duem = re.search(r'due:(\d{4}-\d{2}-\d{2})', block)
        revm = re.search(r'rev:(\d{4}-\d{2}-\d{2})', block)
        cm = re.search(r'\*\*Recap cue[^:]*:\*\*\s*(.+?)(?=\n\s*- \*\*|\n## |\Z)', block, re.DOTALL)
        cue = re.sub(r'\s+', ' ', cm.group(1)).strip() if cm else '(no recap cue)'
        S   = float(sm.group(1)) if sm else None
        D   = float(dm.group(1)) if dm else None
        box = int(bm.group(1)) if bm else None
        due = duem.group(1) if duem else None
        rev = revm.group(1) if revm else None
        in_rot = (S is not None) or (box is not None and box >= 1)
        # lazy migration (in memory): a legacy box:N seeds an FSRS state for scheduling
        if S is None and box is not None and box >= 1:
            S = float(BOX_INTERVAL.get(box, 1))
            D = init_difficulty(3)
            if rev is None and due:
                try:
                    rev = (datetime.date.fromisoformat(due)
                           - datetime.timedelta(days=int(round(S)))).isoformat()
                except ValueError:
                    rev = None
        out.append(dict(num=int(m.group(1)), title=m.group(2).strip(), S=S, D=D, box=box,
                        due=due, rev=rev, in_rot=in_rot, cue=cue, start=start, end=end))
    return lines, out

lines, lessons = parse(open(LOG).read())

def overdue(l):
    if not l['in_rot'] or not l['due']:
        return None
    return (today - datetime.date.fromisoformat(l['due'])).days

if cmd == 'due':
    quiet = '--quiet' in args
    due_items = sorted(((overdue(l), l) for l in lessons
                        if overdue(l) is not None and overdue(l) >= 0), key=lambda x: -x[0])
    if not due_items:
        if not quiet: print("Nothing due for review.")
        sys.exit(0)
    od, l = due_items[0]
    if quiet:
        print(f"Lesson {l['num']} — {l['title']}")
        print(l['cue'])
    else:
        print(f"Most overdue: Lesson {l['num']} — {l['title']}  (due {l['due']}, {od}d overdue)")
        print(f"  Recap cue: {l['cue']}")
        print(f"  After recapping, record it:  scripts/cogito-review.sh grade {l['num']} pass|fail")
        if len(due_items) > 1:
            print(f"  (+{len(due_items)-1} more due)")
    sys.exit(0)

if cmd == 'list':
    for l in lessons:
        od = overdue(l)
        if not l['in_rot']:  st = 'seeded'
        elif od is None:     st = 'no due'
        elif od >= 0:        st = f'{od}d overdue'
        else:                st = f'in {-od}d'
        state = f"S={l['S']:.1f} D={l['D']:.1f}" if l['S'] is not None else f"box:{l['box'] or 0}"
        due = ('due:' + l['due']) if l['due'] else 'due:—'
        print(f"  L{l['num']}  {state:<14}{due:<16}[{st}]  {l['title']}")
    sys.exit(0)

if cmd == 'grade':
    if len(args) < 3:
        sys.stderr.write('usage: cogito-review.sh grade <lesson-number> <pass|fail|again|hard|good|easy>\n'); sys.exit(2)
    try:
        num = int(args[1])
    except ValueError:
        sys.stderr.write('lesson number must be an integer\n'); sys.exit(2)
    result = args[2].lower()
    if result not in GRADE:
        sys.stderr.write("result must be pass|fail (or again|hard|good|easy)\n"); sys.exit(2)
    g = GRADE[result]
    t = next((l for l in lessons if l['num'] == num), None)
    if not t:
        sys.stderr.write(f"no Lesson {num} in the log\n"); sys.exit(1)
    oldS = t['S']
    if t['S'] is None:                                   # seeded / first ever review
        S2 = init_stability(g); D2 = init_difficulty(g)
    else:
        t_days = (today - datetime.date.fromisoformat(t['rev'])).days if t['rev'] else 0
        R = retrievability(t_days, t['S'])
        D2 = next_difficulty(t['D'], g)
        S2 = stab_forget(t['D'], t['S'], R) if g == 1 else stab_recall(t['D'], t['S'], R, g)
        S2 = max(0.1, S2)
    iv = next_interval(S2)
    newdue = today + datetime.timedelta(days=iv)
    newline = f"- **Review:** S={S2:.2f} D={D2:.2f} due:{newdue.isoformat()} rev:{today.isoformat()}"
    rev_i = next((i for i in range(t['start'], t['end'])
                  if re.match(r'\s*- \*\*Review:\*\*', lines[i])), None)
    if rev_i is not None: lines[rev_i] = newline
    else:                 lines.insert(t['end'] - 1, newline)
    open(LOG, 'w').write('\n'.join(lines))
    print(f"Lesson {num}: {result} (FSRS g{g}) -> S {oldS or 0:.2f}->{S2:.2f}, D {D2:.2f}, "
          f"next due {newdue.isoformat()} (in {iv}d)")
    sys.exit(0)

sys.stderr.write(f"unknown command: {cmd}\nusage: cogito-review.sh {{due [--quiet] | list | grade N <result>}}\n")
sys.exit(2)
PY
