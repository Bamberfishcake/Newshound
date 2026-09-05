-- Newshound — illustrative schema (NOT the production schema)
--
-- This is a simplified, generic example showing the general shape of the
-- pipeline's storage layer: one table for human-reviewed bulletin copy, one
-- for structured machine-readable facts, both keyed on a content hash for
-- deduplication. Table names, column names, and constraints below are
-- illustrative — they do not match the real database.

create table example_sources (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  url           text not null,
  created_at    timestamptz default now()
);

create table example_articles (
  id              uuid primary key default gen_random_uuid(),
  source_id       uuid references example_sources(id),
  headline        text not null,
  body            text not null,
  source_url      text not null unique,
  content_hash    text not null unique,
  published_at    timestamptz,
  status          text default 'pending', -- e.g. pending | verified | needs_review
  created_at      timestamptz default now()
);

create table example_structured_facts (
  id              uuid primary key default gen_random_uuid(),
  content_hash    text not null unique,
  facts           jsonb not null,   -- array of {claim, status, date, figures}
  confidence      integer,
  extracted_at    timestamptz default now()
);
