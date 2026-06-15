#!/usr/bin/env bash
# Cogito spaced-repetition review for the LEARNING LOG (docs/learning/log.md) —
# the human-growth twin of the lessons ledger. A Leitner ladder schedules when to
# revisit each lesson so the spacing + testing effects actually fire, instead of
# hoping we remember to recap. Plain-integer intervals; no FSRS, no floats.
#
#   cogito-review.sh due [--quiet]    the most-overdue lesson's recap cue (--quiet
#                                     prints just the cue, for the SessionStart hook)
#   cogito-review.sh list             every lesson with box / due / overdue
#   cogito-review.sh grade N pass|fail  record a recall: pass promotes a box (longer
#                                     interval), fail resets to box 1
#
# Boxes 1..6 = 1, 3, 7, 16, 35, 90 days. box:0 = seeded (not yet in rotation).
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG="$ROOT/docs/learning/log.md"
[ -f "$LOG" ] || { echo "cogito-review: no learning log at $LOG" >&2; exit 1; }

exec python3 - "$LOG" "$@" <<'PY'
import sys, re, datetime
LOG = sys.argv[1]
args = sys.argv[2:]
cmd = args[0] if args else 'due'
INTERVALS = {1:1, 2:3, 3:7, 4:16, 5:35, 6:90}
today = datetime.date.today()

def parse(text):
    lines = text.split('\n')
    heads = [i for i,l in enumerate(lines) if re.match(r'## Lesson \d+', l)]
    out=[]
    for k,start in enumerate(heads):
        end = heads[k+1] if k+1 < len(heads) else len(lines)
        block = '\n'.join(lines[start:end])
        m = re.match(r'## Lesson (\d+) — (.*)', lines[start])
        bm = re.search(r'box:(\d+)', block)
        dm = re.search(r'due:(\d{4}-\d{2}-\d{2})', block)
        cm = re.search(r'\*\*Recap cue[^:]*:\*\*\s*(.+?)(?=\n\s*- \*\*|\n## |\Z)', block, re.DOTALL)
        cue = re.sub(r'\s+', ' ', cm.group(1)).strip() if cm else '(no recap cue)'
        out.append(dict(num=int(m.group(1)), title=m.group(2).strip(),
                        box=int(bm.group(1)) if bm else 0,
                        due=dm.group(1) if dm else None,
                        cue=cue, start=start, end=end))
    return lines, out

lines, lessons = parse(open(LOG).read())

def overdue(l):
    if l['box'] < 1 or not l['due']: return None
    return (today - datetime.date.fromisoformat(l['due'])).days

if cmd == 'due':
    quiet = '--quiet' in args
    due_items = sorted(((overdue(l), l) for l in lessons
                        if overdue(l) is not None and overdue(l) >= 0),
                       key=lambda x: -x[0])
    if not due_items:
        if not quiet: print("Nothing due for review.")
        sys.exit(0)
    od, l = due_items[0]
    if quiet:
        print(f"Lesson {l['num']} — {l['title']}")
        print(l['cue'])
    else:
        print(f"Most overdue: Lesson {l['num']} — {l['title']}  (box {l['box']}, due {l['due']}, {od}d overdue)")
        print(f"  Recap cue: {l['cue']}")
        print(f"  After recapping, record it:  scripts/cogito-review.sh grade {l['num']} pass|fail")
        if len(due_items) > 1:
            print(f"  (+{len(due_items)-1} more due)")
    sys.exit(0)

if cmd == 'list':
    for l in lessons:
        od = overdue(l)
        if l['box'] < 1: st = 'seeded'
        elif od is None: st = 'no due'
        elif od >= 0:    st = f'{od}d overdue'
        else:            st = f'in {-od}d'
        due = ('due:'+l['due']) if l['due'] else 'due:—'
        print(f"  L{l['num']}  box:{l['box']}  {due:<16}[{st}]  {l['title']}")
    sys.exit(0)

if cmd == 'grade':
    if len(args) < 3:
        sys.stderr.write('usage: cogito-review.sh grade <lesson-number> <pass|fail>\n'); sys.exit(2)
    try: num = int(args[1])
    except ValueError: sys.stderr.write('lesson number must be an integer\n'); sys.exit(2)
    result = args[2]
    if result not in ('pass','fail'):
        sys.stderr.write("result must be 'pass' or 'fail'\n"); sys.exit(2)
    t = next((l for l in lessons if l['num']==num), None)
    if not t: sys.stderr.write(f"no Lesson {num} in the log\n"); sys.exit(1)
    box = t['box'] if t['box'] >= 1 else 1
    newbox = min(box+1, 6) if result == 'pass' else 1
    newdue = today + datetime.timedelta(days=INTERVALS[newbox])
    newline = f"- **Review:** box:{newbox} due:{newdue.isoformat()}"
    rev = next((i for i in range(t['start'], t['end'])
                if re.match(r'\s*- \*\*Review:\*\*', lines[i])), None)
    if rev is not None: lines[rev] = newline
    else: lines.insert(t['end']-1, newline)
    open(LOG,'w').write('\n'.join(lines))
    print(f"Lesson {num}: {result} -> box {box}->{newbox}, next due {newdue.isoformat()}")
    sys.exit(0)

sys.stderr.write(f"unknown command: {cmd}\nusage: cogito-review.sh {{due [--quiet] | list | grade N pass|fail}}\n")
sys.exit(2)
PY
