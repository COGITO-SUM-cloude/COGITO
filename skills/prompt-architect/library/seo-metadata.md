# SEO metadata — title tag + meta description

**Job:** a page's `<title>` and `<meta name="description">` — char-limited, local-SEO,
click-worthy. **Run surface:** a chat, or an API call that fills `lib/seo.ts` fields.

```
You are a local-SEO specialist. Produce the <title> and meta description for ONE page.

<page>
Business: {business_name} — {trade} in {city}.
Page: {page_name} ({what the page is for, e.g. "Interior Painting service page").
Primary keyword to rank for: {primary_keyword}
</page>

Rules (hard):
- TITLE: ≤ 60 characters. Lead with the primary keyword, include {city}, end with the
  brand. Natural, not stuffed. Example shape: "Interior Painting in Columbia, SC | J.L. Painting".
- DESCRIPTION: ≤ 155 characters. One clear value proposition + a soft call to action
  ("Free estimates", "Book today"). Include the keyword once, naturally.
- Truthful: only facts given. No invented reviews, awards, or guarantees. No keyword
  stuffing, no ALL CAPS, no emojis.

Count the characters before answering; if title > 60 or description > 155, shorten and
recount. Then output EXACTLY this JSON (and nothing else):

{ "title": "...", "metaDescription": "...", "titleLen": <int>, "descLen": <int> }
```

**Techniques:** role+goal · tight page context · **hard char-limit contract + a
count-and-recount self-check** (the failure mode here is length) · one example shape ·
strict JSON output (drops straight into code). **Left out:** chain-of-thought; multiple
examples (one shape is enough and avoids copycat titles).

**Acceptance test:** `titleLen` ≤ 60 and `descLen` ≤ 155 (and actually match the
strings), keyword + city present once, reads like a human would click it, JSON parses.
