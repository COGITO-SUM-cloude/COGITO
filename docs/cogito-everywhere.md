# Cogito everywhere — one shared brain across all repos

**Goal:** every session, in any repo, starts knowing every lesson Cogito has learned
(so it never repeats a past mistake), and new lessons flow back into one shared brain.

## Why this is needed
Claude Code web sessions are **walled off to one repo** — a paint session can't read or
write the Cogito repo, and the "add another repo" tool isn't always available. So the
brain can't live "in the session"; it has to live in **one public place every session
syncs with.** That place is this repo (it's public, so reading it needs no login).

## The design (two halves)
- **READ (free, automatic, no token):** each repo runs `scripts/cogito-sync.sh` at session
  start. It clones the public Cogito repo and copies the protocol + `LESSONS.md` into
  `~/.claude/skills/cogito-protocol/`. Proven: removing the local ledger and running it
  pulls all lessons back. This is the half that prevents repeating mistakes.
- **WRITE (needs a one-time key for *other* repos):** appending a *new* lesson to the
  central brain.
  - From a **Cogito-repo session**: already works — edit `LESSONS.md`, commit, push.
  - From **any other repo** (e.g. paint): the session can't push here without credentials,
    so it needs a stored key (below). Until that's set up, lessons learned elsewhere don't
    reach the brain automatically — the gap we're closing.

## Wire any repo to READ the brain (do once per repo)
1. Copy `scripts/cogito-sync.sh` into that repo (e.g. `scripts/cogito-sync.sh`).
2. Add a SessionStart hook in that repo's `.claude/settings.json`:
   ```json
   { "hooks": { "SessionStart": [ { "hooks": [
     { "type": "command", "command": "$CLAUDE_PROJECT_DIR/scripts/cogito-sync.sh" }
   ] } ] } }
   ```
3. Add one line to that repo's `CLAUDE.md`: *"Apply the cogito-protocol skill; say 'Cogito'
   to run the session loop. Lessons load from the central Cogito brain via
   scripts/cogito-sync.sh."*

That repo's sessions now start with all lessons loaded.

## Turn on WRITE-back from other repos (one-time, ~5 min — owner action)
A fine-grained GitHub token lets any repo's session push new lessons to this brain.
1. GitHub → **Settings → Developer settings → Personal access tokens → Fine-grained tokens
   → Generate new token**.
2. **Repository access:** only `COGITO-SUM-cloude/COGITO`. **Permissions:** *Contents →
   Read and write*. Generate, copy the token.
3. In Claude Code on the web → your **environment settings → Environment variables** → add
   `COGITO_TOKEN` = the token. (New sessions pick it up.)
4. Tell Cogito it's set. We'll then add `cogito-learn.sh` and **test it live** (push a real
   lesson, confirm it lands) — we don't ship lesson-capture unverified; a ledger that looks
   alive but isn't is the worst failure for a memory system.

> Alternative to a token: if your environment lets you add a *second* repo to every
> session's scope, add `COGITO` there and other sessions can push to it directly (no token).

## Paint package (do these in a paint-repo session — I can't reach paint from a Cogito session)
1. **Wire paint to the brain** — the 3 steps above.
2. **Fold in stranded lessons** — whatever the last paint session learned didn't reach the
   brain. List them and append (via the token, or paste them into a Cogito session).
3. **Hero headline contrast fix** (from the QA): the hero `<h1>` renders its non-gold lines
   in a dark slate on the dark navy hero — legible but weak. Lighten the light/white portion
   of the heading (toward cream/near-white) so all lines read clearly; keep the gold accent
   line. Verify with the eyes at desktop (1280) and mobile (390) before/after.
