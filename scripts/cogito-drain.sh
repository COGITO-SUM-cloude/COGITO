#!/usr/bin/env bash
# cogito-drain.sh — the brain's write-back courier (Idea #1).
#
# Pulls lessons from satellite repos' PUBLIC outboxes, de-duplicates them against the
# master ledger, and stages the genuinely-new ones in a review queue. This ends the
# manual copy-paste relay: the human's job drops to reviewing a clean queue / git diff.
#
# SAFE BY DESIGN — this script holds NO credential. It only READS public files (anon,
# the verified-safe path the council settled 2026-06-16) and EDITS a LOCAL file (the
# ledger). The already-trusted converge Stop hook carries the ledger to main; the
# hub-write key never enters a session. If a source is PRIVATE, anon read fails — clone
# it locally and point the drain at the local path instead.
#
# Ledger mutation is centralized HERE (accept / reject / accept-all) so the dashboard's
# Accept/Reject buttons reuse this one authority instead of duplicating the append.
#
# Usage:
#   cogito-drain.sh [drain] [SOURCE ...]   fetch + dedupe + stage (default). Sources from
#                                          argv, else scripts/cogito-satellites.txt.
#   cogito-drain.sh list                   print the review queue (JSON)
#   cogito-drain.sh accept <id>            append queued lesson <id> to the ledger
#   cogito-drain.sh reject <id>            archive queued lesson <id>
#   cogito-drain.sh accept-all             accept every queued lesson (the git-diff flow)
#   cogito-drain.sh --selftest             end-to-end test on a synthetic fixture
#
# A SOURCE is one of: a raw https URL; an owner/repo slug (raw URL derived on main|master);
# or a local file path. Outbox filename defaults to cogito-outbox.md for slugs.
set -uo pipefail

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SELF/.." && pwd)"
export LEDGER="${COGITO_LEDGER:-$REPO/skills/cogito-protocol/LESSONS.md}"
export ARCHIVE="${COGITO_ARCHIVE:-$REPO/skills/cogito-protocol/LESSONS-ARCHIVE.md}"
export INSTALLED="${COGITO_INSTALLED_LEDGER:-$HOME/.claude/skills/cogito-protocol/LESSONS.md}"
export QUEUE="${COGITO_QUEUE:-$REPO/docs/inbox/queue.json}"
SATELLITES="${COGITO_SATELLITES:-$REPO/scripts/cogito-satellites.txt}"
OUTBOX_NAME="${COGITO_OUTBOX_NAME:-cogito-outbox.md}"

say(){ printf 'cogito-drain: %s\n' "$*"; }
die(){ printf 'cogito-drain: %s\n' "$*" >&2; exit 1; }

command -v python3 >/dev/null 2>&1 || die "python3 is required"

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
PYHELPER="$WORK/helper.py"
cat > "$PYHELPER" <<'PYEOF'
import os, sys, re, json, hashlib, time

LEDGER=os.environ["LEDGER"]; ARCHIVE=os.environ["ARCHIVE"]
INSTALLED=os.environ.get("INSTALLED",""); QUEUE=os.environ["QUEUE"]

LESSON_RE  = re.compile(r'^\s*-\s+.*->.*->')                 # bullet + at least two arrows
BRACKET_RE = re.compile(r'^\s*-\s+((?:\[[^\]]*\]\s*)*)(.*)$')# leading [..] groups, then body
TRAILER_RE = re.compile(r'\s*\{[^{}]*\}\s*$')               # trailing {provenance}

def is_lesson(line): return bool(LESSON_RE.match(line))

def split_body(line):
    m=BRACKET_RE.match(line)
    brackets=(m.group(1).strip() if m else "")
    body=((m.group(2) if m else line).strip())
    body=TRAILER_RE.sub("", body).strip()
    return brackets, body

def norm_key(line):
    _,body=split_body(line)
    return re.sub(r'\s+',' ',body).strip().lower()

def parse(line):
    brackets, body = split_body(line)
    tags=re.findall(r'\[#[^\]]*\]', brackets)
    imp=None
    mi=re.search(r'\[I:\s*(\d+)', brackets)
    if mi: imp=int(mi.group(1))
    parts=re.split(r'\s*->\s*', body, maxsplit=2)
    parts+=[""]*(3-len(parts))
    return {"tags":tags,"importance":imp,
            "symptom":parts[0],"root":parts[1],"rule":parts[2]}

def lessons_in(path):
    out=[]
    try:
        with open(path,encoding="utf-8") as f:
            for ln in f:
                ln=ln.rstrip("\n")
                if is_lesson(ln): out.append(ln)
    except (FileNotFoundError, IsADirectoryError): pass
    return out

def load_queue():
    try:
        with open(QUEUE,encoding="utf-8") as f: return json.load(f)
    except (FileNotFoundError, ValueError): return {"updated":None,"entries":[]}

def save_queue(q):
    os.makedirs(os.path.dirname(QUEUE), exist_ok=True)
    q["updated"]=time.strftime("%Y-%m-%d")
    with open(QUEUE,"w",encoding="utf-8") as f:
        json.dump(q,f,indent=2,ensure_ascii=False); f.write("\n")

def existing_keys():
    keys=set()
    for p in (LEDGER, ARCHIVE, INSTALLED):
        if p:
            for ln in lessons_in(p): keys.add(norm_key(ln))
    return keys

def lid(key): return hashlib.sha1(key.encode("utf-8")).hexdigest()[:8]

def append_line(path, line):
    data=""
    try:
        with open(path,encoding="utf-8") as f: data=f.read()
    except FileNotFoundError: pass
    if data and not data.endswith("\n"): data+="\n"
    with open(path,"w",encoding="utf-8") as f:
        f.write(data); f.write(line.rstrip("\n")+"\n")

def op_drain():
    manifest=os.environ.get("MANIFEST","")
    sources=[]
    if manifest and os.path.exists(manifest):
        with open(manifest,encoding="utf-8") as f:
            for ln in f:
                ln=ln.rstrip("\n")
                if ln.strip(): label,path=ln.split("\t",1); sources.append((label,path))
    keys=existing_keys()
    q=load_queue()
    qkeys={e.get("key") for e in q["entries"]}
    added=in_brain=in_queue=0
    for label,path in sources:
        for ln in lessons_in(path):
            key=norm_key(ln)
            if not key: continue
            if key in keys:   in_brain+=1; continue   # already in the brain
            if key in qkeys:  in_queue+=1; continue   # already pending review
            ent=parse(ln)
            ent.update({"id":lid(key),"key":key,"source":label,
                        "raw":ln.strip(),"ts":time.strftime("%Y-%m-%d"),"status":"pending"})
            q["entries"].append(ent); qkeys.add(key); added+=1
    save_queue(q)
    print("staged %d new lesson(s) for review" % added)
    print("  skipped %d already in the brain, %d already queued" % (in_brain,in_queue))
    print("  queue now holds %d lesson(s) -> %s" % (len(q["entries"]), QUEUE))
    if added:
        print("  review: cogito-drain.sh list  |  accept <id> / reject <id> / accept-all")

def op_list():
    print(json.dumps(load_queue(), indent=2, ensure_ascii=False))

def _accept_entry(e):
    raw=e["raw"]
    if not TRAILER_RE.search(raw):
        raw=raw+" {via:drain "+e.get("source","?")+" "+e.get("ts","")+"}"
    append_line(LEDGER, raw)

def _pull(qid):
    q=load_queue(); rest=[]; e=None
    for x in q["entries"]:
        if e is None and x["id"]==qid: e=x
        else: rest.append(x)
    return q, rest, e

def op_accept(qid):
    q,rest,e=_pull(qid)
    if not e: sys.exit("no queued lesson with id "+qid)
    _accept_entry(e); q["entries"]=rest; save_queue(q)
    print(json.dumps({"accepted":qid,"appended_to":LEDGER,"queue_size":len(rest)}))

def ensure_archive_header():
    hdr="## Rejected via drain"
    try:
        with open(ARCHIVE,encoding="utf-8") as f: data=f.read()
    except FileNotFoundError: data=""
    if hdr not in data:
        if data and not data.endswith("\n"): data+="\n"
        data+="\n"+hdr+"\n\nLessons a human reviewer rejected from the drain queue "\
              "(kept for the record, never deleted).\n"
        with open(ARCHIVE,"w",encoding="utf-8") as f: f.write(data)

def op_reject(qid):
    q,rest,e=_pull(qid)
    if not e: sys.exit("no queued lesson with id "+qid)
    body=split_body(e["raw"])[1]
    ensure_archive_header()
    append_line(ARCHIVE, "- [rejected via:drain "+e.get("source","?")+" "+e.get("ts","")+"] "+body)
    q["entries"]=rest; save_queue(q)
    print(json.dumps({"rejected":qid,"archived_to":ARCHIVE,"queue_size":len(rest)}))

def op_accept_all():
    q=load_queue(); n=0
    for e in q["entries"]: _accept_entry(e); n+=1
    q["entries"]=[]; save_queue(q)
    print(json.dumps({"accepted_all":n,"appended_to":LEDGER}))

def main():
    if len(sys.argv)<2: sys.exit("usage: helper.py <op> [arg]")
    op=sys.argv[1]
    if op=="accept":  return op_accept(sys.argv[2])
    if op=="reject":  return op_reject(sys.argv[2])
    {"drain":op_drain,"list":op_list,"accept-all":op_accept_all}.get(
        op, lambda: sys.exit("unknown op "+op))()

main()
PYEOF

# curl_get <url> <dest> -> 0 iff a non-empty body was fetched. NEVER disables TLS
# (that is exactly what cogito-guard blocks). Uses the proxy CA bundle if present.
curl_get(){
  local url="$1" dest="$2" ca=""
  command -v curl >/dev/null 2>&1 || return 1
  [ -n "${CURL_CA_BUNDLE:-}" ] && ca="$CURL_CA_BUNDLE"
  [ -z "$ca" ] && [ -f /root/.ccr/ca-bundle.crt ] && ca="/root/.ccr/ca-bundle.crt"
  curl -fsSL --connect-timeout 15 ${ca:+--cacert "$ca"} "$url" -o "$dest" 2>/dev/null && [ -s "$dest" ] && return 0
  curl -fsSL --connect-timeout 15 "$url" -o "$dest" 2>/dev/null && [ -s "$dest" ]
}

# fetch_source <source> <dest> -> echoes a label on success, non-zero on failure.
fetch_source(){
  local src="$1" dest="$2"
  if [ -f "$src" ]; then cp "$src" "$dest" 2>/dev/null && { printf '%s' "$src"; return 0; }; return 1; fi
  case "$src" in
    http://*|https://*) curl_get "$src" "$dest" && { printf '%s' "$src"; return 0; }; return 1 ;;
    */*)  local br
          for br in main master; do
            if curl_get "https://raw.githubusercontent.com/$src/$br/$OUTBOX_NAME" "$dest"; then
              printf '%s' "$src@$br"; return 0
            fi
          done
          return 1 ;;
    *) return 1 ;;
  esac
}

cmd_drain(){
  local sources=()
  if [ "$#" -gt 0 ]; then sources=("$@")
  elif [ -f "$SATELLITES" ]; then
    while IFS= read -r line; do
      line="${line%%#*}"; line="$(printf '%s' "$line" | xargs 2>/dev/null || true)"
      [ -n "$line" ] && sources+=("$line")
    done < "$SATELLITES"
  fi
  [ "${#sources[@]}" -gt 0 ] || die "no sources — pass a SOURCE, or add lines to $SATELLITES"

  local tmpd="$WORK/fetch"; mkdir -p "$tmpd"
  local manifest="$tmpd/manifest.tsv" i=0 ok=0 label dest
  : > "$manifest"
  for src in "${sources[@]}"; do
    i=$((i+1)); dest="$tmpd/outbox.$i"
    if label="$(fetch_source "$src" "$dest")"; then
      printf '%s\t%s\n' "$label" "$dest" >> "$manifest"; ok=$((ok+1)); say "fetched: $label"
    else
      say "SKIP (unreachable / private / not found): $src"
    fi
  done
  [ "$ok" -gt 0 ] || die "no sources could be read"
  MANIFEST="$manifest" python3 "$PYHELPER" drain
}

cmd_selftest(){
  local sb; sb="$(mktemp -d)"
  local L="$sb/LESSONS.md" A="$sb/ARCHIVE.md" Q="$sb/queue.json" OB="$sb/cogito-outbox.md"
  local fails=0
  qcount(){ python3 -c 'import json,sys
try: print(len(json.load(open(sys.argv[1]))["entries"]))
except Exception: print(-1)' "$Q"; }
  ids(){ python3 -c 'import json,sys
print(" ".join(e["id"] for e in json.load(open(sys.argv[1]))["entries"]))' "$Q"; }
  assert(){ if eval "$2"; then printf '  ok   %s\n' "$1"; else printf '  FAIL %s\n' "$1"; fails=$((fails+1)); fi; }

  cat > "$L" <<'EOF'
# Ledger
## Lessons
- [#known] [I:5] a known symptom -> a known cause -> a known rule
EOF
  : > "$A"
  cat > "$OB" <<'EOF'
# cogito-outbox — synthetic satellite
- [#known] [I:5] a known symptom -> a known cause -> a known rule
- [#new][I:7] outbox lesson one symptom -> cause one -> rule one
- [#new] outbox lesson two symptom -> cause two -> rule two
this line is not a lesson and must be ignored
EOF

  local E=(COGITO_LEDGER="$L" COGITO_ARCHIVE="$A" COGITO_QUEUE="$Q" COGITO_INSTALLED_LEDGER="$sb/none.md")
  echo "cogito-drain selftest"

  env "${E[@]}" "$SELF/cogito-drain.sh" drain "$OB" >/dev/null
  assert "first drain stages 2 new (1 duplicate dropped)"      '[ "$(qcount)" = "2" ]'
  assert "drain does NOT touch the ledger (still 1 lesson)"    '[ "$(grep -c -- "->" "$L")" = "1" ]'

  env "${E[@]}" "$SELF/cogito-drain.sh" drain "$OB" >/dev/null
  assert "second drain is idempotent (queue still 2)"          '[ "$(qcount)" = "2" ]'

  local id1 id2; read -r id1 id2 <<<"$(ids)"
  env "${E[@]}" "$SELF/cogito-drain.sh" accept "$id1" >/dev/null
  assert "accept appends the lesson to the ledger"             'grep -q "cause one" "$L"'
  assert "accept stamps provenance {via:drain ...}"            'grep -q "via:drain" "$L"'
  assert "accept removes it from the queue (1 left)"           '[ "$(qcount)" = "1" ]'

  env "${E[@]}" "$SELF/cogito-drain.sh" reject "$id2" >/dev/null
  assert "reject archives the lesson"                          'grep -q "cause two" "$A"'
  assert "reject does NOT add it to the ledger"                '! grep -q "cause two" "$L"'
  assert "reject empties the queue"                            '[ "$(qcount)" = "0" ]'

  rm -rf "$sb"
  echo
  if [ "$fails" -eq 0 ]; then echo "selftest: ALL PASS"; else echo "selftest: $fails FAILED"; return 1; fi
}

case "${1:-drain}" in
  -h|--help)  sed -n '2,28p' "${BASH_SOURCE[0]}" ;;
  --selftest) cmd_selftest ;;
  list)       shift; python3 "$PYHELPER" list ;;
  accept)     shift; [ -n "${1:-}" ] || die "accept needs an <id>"; python3 "$PYHELPER" accept "$1" ;;
  reject)     shift; [ -n "${1:-}" ] || die "reject needs an <id>"; python3 "$PYHELPER" reject "$1" ;;
  accept-all) shift; python3 "$PYHELPER" accept-all ;;
  drain)      shift; cmd_drain "$@" ;;
  *)          cmd_drain "$@" ;;
esac
