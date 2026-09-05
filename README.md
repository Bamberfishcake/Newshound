# Newshound

Newshound is an automated pipeline that turns raw crypto/web3 news sources
into two things: structured, machine-readable facts and human-reviewed
bulletin copy — both traceable back to the original source.

## Why

Most news aggregation either summarizes loosely (losing precision) or
republishes verbatim (no added value, no structure). Newshound extracts
discrete, verifiable claims from each article — what happened, its status
(shipped, planned, in progress, etc.), and the exact figures involved — then
independently verifies those claims before anything is published or served.

## Architecture

```
   Sources (feeds + site discovery)
            │
            ▼
      Scrape / Fetch  ──────────────────────  Firecrawl
            │
            ▼
   ┌─────────────────────────────────────┐
   │         Fact Extraction               │
   │  claim → verified against source      │  Google Gemini
   │  + a separate bulletin-ready phrasing │  (multiple models,
   │    of the same fact                   │   different tiers)
   └─────────────────────────────────────┘
            │
            ▼
   Completeness & consistency checks
            │
            ▼
   Draft synthesis → verification → (retry once if needed)
            │
     ┌──────┴──────┐
     ▼             ▼
 Structured     Human-reviewed
 fact store     bulletin copy
 (Supabase)     (Supabase)
```

**Orchestration:** [n8n](https://n8n.io) — the entire pipeline runs as a
scheduled workflow, checking for new source material on a fixed interval.

**Discovery/scraping:** [Firecrawl](https://firecrawl.dev) — resolves each
source to clean article text, and (for sources without a feed) discovers new
article URLs from an index page.

**Extraction & verification:** [Google Gemini](https://ai.google.dev) —
multiple models at different capability tiers, deliberately split so that the
model producing a piece of content is never the same model checking it.

**Storage:** [Supabase](https://supabase.com) (Postgres) — two output tables:
one holding the full structured fact set per article, one holding
human-reviewed bulletin drafts.

## The dual-field fact structure

Each extracted fact carries two independent representations of the same
claim:

- **A source-faithful form** — kept close to the original wording, used as
  the ground truth that every downstream check (accuracy, verification,
  consistency) compares against.
- **A bulletin-ready form** — the same fact, restructured for readable
  bulletin prose, used only when assembling the human-facing draft.

Keeping these separate means the wording used for publication is never the
same text used to verify accuracy — a draft is always checked against the
original claim, never against a paraphrase of itself.

## Verification, not just generation

Before anything reaches either output table, each article's extracted facts
pass through multiple independent checks:

- **Completeness** — does the extraction cover everything the source
  actually says?
- **Internal consistency** — do any two facts from the same article
  contradict each other?
- **Source grounding** — does every figure quoted in a fact actually appear
  in the source text?
- **Draft fidelity** — does the published bulletin draft accurately reflect
  the underlying facts, with nothing invented or lost?

Content that fails verification is held for manual review rather than
published automatically. The system is designed to prefer *no output* over
*wrong output*.

## Status

Actively developed and running on a live schedule. This repository contains
the public-facing architecture and scaffolding; production credentials,
prompt engineering, and the curated source list are kept private.
