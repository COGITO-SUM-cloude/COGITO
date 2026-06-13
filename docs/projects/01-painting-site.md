# Project plan — first build: the Painting Website
_Decision + checklist. 2026-06-13._

## The three projects on the table
1. **Painting website** — a real site for a painting business: services, gallery of past jobs, quote form. Assets already in hand (photos, logo, brand colors). Smallest, most concrete.
2. **Paint Visualizer** — upload a room photo, AI recolors the walls to a chosen paint color, show the result, capture the lead. Strong differentiator, but needs AI image work. Best added later, as a feature.
3. **Mini-Squarespace / Contractor OS** — the big platform: a dashboard to build, host, manage, and bill client websites, with a CMS and editor. Partially started (CMS + a weak "change-the-words" editor). The dream, and the largest, riskiest build.

## Decision: build the Painting Website first

Your draft said: finish the CMS editor first, then rebuild the paint site to fit it. I'd flip that order. The honest reason:

**An editor edits a structure — and the structure doesn't exist yet.** You said it yourself: "the ultimate structure has yet to be found." You find that structure by building one real site *well*, not by building an editor in the dark. Build the site first, pull the clean structure out of it, and *then* the editor has something solid to edit. Building the editor first is polishing the top floor before the foundation is poured.

So the painting site is step one — but we build it deliberately, as the **reference build** that defines the reusable structure everything else stands on.

Why it's the lean win:
- Ships something real and fast — a site you can show people.
- Teaches you the whole web stack (the learning goal).
- ~$12/yr (a domain) vs ~$200+/yr for Squarespace; your Chromebook is irrelevant because I build in the cloud.
- **Not throwaway** — the structure we extract is the seed of the platform.

## Checklist

### Phase 0 — Setup (mostly me)
- [ ] I create a new repo for the site and add it to our session (separate from the cogito repo).
- [ ] You gather what you have: job photos, logo, brand colors.
- [ ] Decide: real business or practice run? (Changes the words, not the steps.)
- [ ] Domain: skip for now — deploy free first, add a domain later if you want.

### Phase 1 — Spec, no code (you + me, ~15 min)
- [ ] Services list (one line each)
- [ ] Service area (cities/region)
- [ ] Why customers pick you (3 reasons)
- [ ] Pages: Home, Services, Gallery, Contact/Quote
- [ ] The ONE action a visitor should take (call, or fill a quote form)

### Phase 2 — Sources of truth first (me)
- [ ] One file holding all the words + details (name, phone, services).
- [ ] One file holding the brand (colors, fonts).
- [ ] Reason: change your phone number once and it updates everywhere. This is the start of the "ultimate structure."

### Phase 3 — Build in pieces, each one live (I build, you react)
- [ ] Hero (top banner) → live link → you check on your phone
- [ ] Services section → live link → check
- [ ] Gallery of your job photos → live link → check
- [ ] Quote form / contact → live link → check

### Phase 4 — Verify + polish (you + me)
- [ ] You send screenshots of anything off; I fix the cause, not the symptom.
- [ ] Deploy settings set explicitly on day one (we already learned the 404 lesson).
- [ ] Check it on a phone.

### Phase 5 — Ship + checkpoint (me)
- [ ] Deploy live, get the public link.
- [ ] I write a one-page checkpoint (decisions, link, lessons) for you to keep.

## How this reaches the bigger goal — Cogito
- The reusable parts (structure, components, deploy recipe) get saved into the **cogito repo as a "build-a-site" skill**. Site #2 is faster than site #1 — that is Cogito compounding.
- Once the structure is solid, the **CMS editor** finally has something clean to edit. Editor comes *after* structure.
- Eventually that saved structure + skill let the AI build a whole site from one prompt — which is exactly your "Mini-Squarespace, AI version."
- So this one painting site is **step one of the platform**, not a side quest.

## To start
All I need is your Phase 1 answers and your assets. I do the building.
