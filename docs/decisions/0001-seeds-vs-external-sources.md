# 0001 — Seeds vs external sources for the Bronze layer

Status: Accepted
Date: 2026-07-11

## Context

The Olist dataset ships as 9 CSVs. Eight are transactional tables (orders,
order items, payments, reviews, customers, products, sellers,
geolocation), ranging from tens of thousands to over a million rows, and
represent data that in a real environment would be reloaded periodically
from source systems. The ninth (`product_category_name_translation`) is a
simple 71-row translation lookup that comes from no transactional system
and never changes. dbt needs all of them to end up queryable as "tables"
from `sources.yml`/models, but not all of them should get there the same
way.

## Decision

The 8 transactional tables are declared in `sources.yml` with
`meta.external_location`, pointing DuckDB directly at the original CSVs
(the local equivalent of an external table over a data lake). Only
`product_category_name_translation` is loaded as a `dbt seed`.

## Alternatives considered

- **All 9 as seeds**: rejected. `dbt seed` is meant for small, static
  reference data kept in the repo; loading hundreds of thousands of rows
  through it is a recognized anti-pattern (bloats the repo, defeats the
  tool's purpose, and doesn't reflect how transactional data is really
  ingested).
- **All 9 as external sources**: rejected for the translation table. It's
  exactly the use case `seed` is built for (small, static, hand-maintained)
  — making it external for the sake of consistency wouldn't add anything.

## Consequences

- The 8 large tables are not distributed in the Git repo (size and Kaggle
  license): anyone cloning the repo has to download the dataset and place
  it in `data/raw/` before running `dbt build` — documented in the README.
- The translation table does live in the repo (as
  `seeds/product_category_name_translation.csv`), version-controlled like
  any other code file.
- If one of the 8 "large" tables ever became small and static (unlikely
  here), it would be worth reconsidering whether it still makes sense as
  an external source or should move to a seed.

## Addendum (2026-07-11)

A second seed was added for the same reason: `br_state_names`, a 27-row
Brazilian state code → full name lookup (not part of the Olist dataset —
general reference data), used to enrich `dim_customers`/`dim_sellers`
with readable state names for Power BI instead of raw 2-letter codes.
Same reasoning as above, no new decision needed.
