# Cogito — Lessons Archive (consolidated / retired raw lessons)

This file holds raw lessons that a consolidation pass (skill: `cogito-consolidate`)
has **merged or superseded** into a higher-tier rule in the active ledger
(`LESSONS.md`). Nothing here is deleted — archiving keeps the specific, causal
detail while removing it from the always-loaded set, so the active ledger stays
small and the session-start load stays cheap. Git history is the deeper backstop.

The session loader reads only `LESSONS.md` (`grep '^- '`), so lines parked here no
longer load into context — that is the whole point of archiving.

## How an entry gets here
A consolidation pass cuts a raw `- ...` lesson line **verbatim** out of `LESSONS.md`
into the matching block below, under the higher-tier rule that now supersedes it.
The active rule cites these lines as provenance (e.g. "consolidates 3 process
scars"). The runnable gate `scripts/cogito-consolidate.sh verify` enforces the
invariant: every line removed from the active ledger must reappear here — no
lesson is ever lost, only relocated.

Format of each archived block (the raw `- ` lines stay at **column 0** — they are
moved *verbatim*, so `scripts/cogito-consolidate.sh verify` can match them against
the lines removed from the active ledger; only the `###` header and the `>` quote
are added around them):

    ### <YYYY-MM-DD> — <short cluster name>
    > superseded by: <the merged higher-tier rule, quoted>

    - <raw lesson line, verbatim>
    - <raw lesson line, verbatim>

---

## Archived lessons

### 2026-06-15 — communication style for the user (3 raw -> 1 #critical rule)
> Early targeted pass (not the ~60 bulk trigger): the council's judge verified two of these lines CONTRADICTED each other and both loaded — the obsolete "baby steps" line was `#critical`/always-load while its correction was untagged/deferred. Merged into one current rule; raw lines kept here verbatim.
> superseded by: `[#critical][#comms] How to talk to THIS user -> talk adult-to-adult: plain everyday words, short replies, explain by analogy not jargon, do the tech myself; NO emojis, no cheerleading, no "baby steps"/"tiny concepts" framing — "simpler" means less jargon, not talking down; re-read when a task feels complex.`

- [#critical] Explained the work in dense jargon and long finish-line reviews -> the user is non-technical, has a limited vocabulary, and can't retain much, so technical replies don't help them and add friction -> ALWAYS use plain everyday words, short replies, and baby steps (one action at a time); do the tech myself; teach tiny concepts simply. This is a standing rule for this user.
- User said "treat me like I'm 20, tired of the emojis" -> after being asked to simplify, I over-corrected into an emoji-heavy, over-cheerful, hand-holding tone that read as patronizing -> talk adult-to-adult: plain, simple words but NO emojis, no cheerleading, no "baby steps" framing. "Simpler" means less jargon, not treating them like a child.
- [#critical][#comms] Slipped back into dense technical prose and a long diagnosis on a complex task, despite the standing non-technical-user rule -> under heavy cognitive load I defaulted to engineer-to-engineer register -> the user is non-technical: keep every reply short and plain, explain by analogy not jargon, no long reviews; re-read this rule the moment a task feels complex, because that is exactly when the slip happens.

### 2026-06-18 — pkill -f self-match (2 raw -> 1)
> superseded by: `[#shell][#process] pkill -f SELF-MATCH killed its own shell (exit 144), even with the lesson loaded -> pkill -f matches the FULL command line incl. the running shell, and a loaded lesson does not auto-fire at the decision point (recall != application) -> never pkill -f a pattern that can match the kill command itself; stop by explicit PID (pgrep then kill "$PID") or a port check, and consult the relevant lesson before destructive/process ops. Now also enforced by scripts/cogito-guard.sh.`

- [#shell] `pkill -f "next dev"` returned exit 144 and killed its own shell before the chained git commit ran -> pkill -f matches the FULL command line, and the running shell's argv literally contained the pattern string -> never `pkill -f` a string that also appears in the current command; kill by pid (pgrep then kill) or use a pattern that can't match the pkill invocation itself.
- [#shell][#process] Ran `pkill -f "http.server 8099"` to stop a dev server and it exited 144 by killing its own shell — the exact documented pkill scar, despite that lesson being loaded into context at session start -> a ledger loaded into context does not auto-fire at the decision point; recall is not application -> stop processes by explicit PID or by a port check, never a `pkill -f` pattern that also matches the running command, and actively consult the relevant lesson before destructive/process ops.


### 2026-06-18 — headless eyes in the locked web sandbox (4 raw -> 1)
> superseded by: `[#eyes][#network] Getting headless "eyes" (Chrome) in the locked web sandbox — registry-served binary, install method, TLS/root launch flags, ephemeral cache (consolidates 4 raw lines; codified in scripts/ensure-eyes.sh) -> the web env blocks general egress, intercepts TLS, and runs as root on an ephemeral disk, so CDN browser installs fail and a system Chrome never persists -> install a registry-served Chromium (npx @puppeteer/browsers install chrome@stable, or puppeteer-core + @sparticuz/chromium), launch with --no-sandbox --ignore-certificate-errors, keep ensure-eyes.sh idempotent (re-install per session + stable symlink), point --executablePath at it.`

- [#eyes][#network] Needed Claude to "see" the site but the env had no browser, and Playwright's browser CDN 403'd -> this workspace allowlists only the npm registry; general web (vercel.app, *.vercel-storage.com, cdn.playwright.dev, even example.com) all 403 -> for a headless browser here install a REGISTRY-SERVED Chromium: `puppeteer-core` + `@sparticuz/chromium` (API under `mod.default`, executablePath() extracts to /tmp) launches and screenshots; Playwright/puppeteer CDN downloads will not.
- [#eyes][#network] storage.googleapis.com/chrome-for-testing returned 403 and read like an egress block -> it was Google's own `server: UploadServer` refusing a *bucket listing* (no `x-deny-reason` header), while the real binary host was reachable -> before calling a host blocked, read the 403's headers; with Network=Full, install eyes via `npx @puppeteer/browsers install chrome@stable` (§2 transport-before-logic).
- [#eyes][#network] Headless Chrome here rendered "Your connection is not private" on every https page and refused to start as root -> this environment's egress intercepts TLS with an untrusted proxy cert, and Chrome won't run sandboxed as root -> launch with `--ignore-certificate-errors` AND `--no-sandbox` (chrome-devtools-mcp: `--acceptInsecureCerts` + `--chrome-arg=--no-sandbox` + `--executablePath`, since there is no system Chrome).
- [#eyes] Chrome installs into /root/.cache (ephemeral), so eyes break on every new session -> ephemeral container + locked egress means there is no durable binary cache -> keep an idempotent `scripts/ensure-eyes.sh` (install Chrome-for-Testing once per session, maintain a stable symlink) and point config `--executablePath` at the symlink; pay the ~170MB install once on first eyes use, never at every session start.


### 2026-06-18 — free OpenRouter slug is brittle (2 raw -> 1)
> superseded by: `[#network][#process] Free OpenRouter slugs keep breaking the council/teacher voice — the wired one moved to paid (404), popular free ones 429'd, and the chain swapped models silently (consolidates 2 raw scars) -> a single free slug is brittle (rotated to paid or throttled; popularity correlates with throttling) and a silent fallback hides which model served -> use a fallback CHAIN preferring the named slug then less-contended ones (openrouter/free now leads it), query /models for what is currently free, and surface on stderr WHICH model answered so a silent swap is visible.`

- [#process][#web] [I:5] The wired OpenRouter free model (deepseek-r1:free) had been moved to paid (404), and the popular free models (Hermes-405b, llama-3.3-70b, qwen3-next) all 429'd "rate-limited upstream" on a $0-credit account, while a less-popular free model (nemotron-nano-30b) answered fine -> a single free-tier slug is brittle: free models get rotated to paid or throttled, and popularity correlates with throttling -> use a FALLBACK CHAIN of free models (prefer the named one, then less-contended ones), query /models for what is currently free, and verify live which actually answers; never hardcode one free slug.
- [#verify][#network] assumed "Hermes is our council voice" -> a live ping showed hermes-3-405b:free returns HTTP 429 and the chain silently fell through to nemotron-nano (only a stderr line, invisible to the owner, noted it) -> free slugs rate-limit/rotate and the fallback swaps models silently; surface/read WHICH model actually answered, never assume the first slug is serving.


### 2026-06-18 — same-base council consensus (2 raw -> 1)
> superseded by: `[#council][#verify] Same-base-model panelists repeatedly "independently" converged on the project's own loudest rule and it read as strong consensus (consolidates 2 raw scars) -> one base model agreeing with itself is correlation, not independent triangulation; panelists echo the house thesis -> discount same-base consensus, force divergence (distinct lenses, independence, demand dissent), and make the judge's core job a grounded REPO check (already built? will the hook fire? cite file:line) — weight a clean grep + an unmet need over a confident agreement.`

- [#council][#agents] [I:5] A free Claude-only council ran live: 3 panelists with distinct lenses converged hard and the judge flagged the consensus as "one voice in triplicate" -> same-base-model agreement reads like high confidence but is not independent triangulation -> force divergence (distinct lenses, independence, demand dissent) and make the judge explicitly flag same-base consensus and hunt the blind spot all panelists shared; the judge's value is catching what the panel collectively missed, not averaging them.
- [#council][#verify] Three same-base-model panelists "independently" converged on the project's own loudest rule (anti-fabrication) and it read as strong consensus — then the judge's REPO read found 2 of 3 picks already built and the 3rd's hook mechanically impossible -> same-model panelists echo the house thesis back, so their agreement is correlation not confirmation; the decorrelating signal was a grounded repo check, not more reasoning -> discount same-model council consensus, and make the judge's core job the REPO-GROUNDED "is it already built / will it actually fire" check (cite file:line) — weight a clean grep + an unmet need over a confident agreement.


### 2026-06-18 — forked per-session branches (2 raw, superseded by the critical canonical-ref rule)
> superseded by: `[#memory][#git][#critical] [I:9] ... load the brain from ONE canonical ref (git fetch origin <brain-branch>, read THAT), keep the working tree as offline fallback, and converge each session's lessons + mission back to that ref at checkpoint.`

- [#memory][#git] Cogito lessons were captured every session but on separate auto-named session branches, so the ledgers forked and never reconverged; 'next session inherits them' silently failed -> per-session branches with no merge step = forked memory -> consolidate all branch ledgers into one canonical LESSONS.md, and add a session-start step that fetches and unions lessons from every branch so the loop actually compounds.
- [#git][#memory] Asked "will the next session have today's work?" exposed that the Cogito repo's *default* branch was a session branch (`gallant-babbage`) while the session's work sat on a different session branch (`awesome-ramanujan`); new sessions start from the default, so they'd inherit none of it -> per-session branches with no merge-to-default = forked work, the branch-level twin of the forked-ledger scar -> at session end, fast-forward the session branch into the repo's default (`git merge-base --is-ancestor <default> HEAD` to confirm clean) so the next session inherits eyes + lessons; ideally establish one real `main` trunk so memory stops forking per session.

