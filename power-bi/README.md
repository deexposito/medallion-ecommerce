# Power BI dashboard

This part is built by hand in Power BI Desktop — there's no CLI or API to
author report visuals, so this file is the step-by-step guide instead of
generated code. It doubles as PL-300 practice (measures, relationships,
visuals).

## 1. Generate the data

```bash
dbt build
.venv\Scripts\python.exe scripts\export_gold_to_parquet.py
```

This writes `power-bi/data/mart_sales.parquet`,
`mart_customer_experience.parquet`, `mart_logistics.parquet` and
`dim_date.parquet` (gitignored — regenerate them, don't commit them).

## 2. Import into Power BI Desktop

`Get Data` → `Parquet` → the connector asks for a path/URL, not a file
browser — paste the local path directly, e.g.
`C:\path\to\power-bi\data\mart_sales.parquet` (or prefix with `file:///`
and forward slashes if that's rejected). Repeat for all 4 files
(3 marts + `dim_date`). Import mode, not DirectQuery — these are static
snapshots, not a live source.

**No relationships between the 3 marts.** Each is an intentionally flat,
denormalized table built for a single purpose — don't wire them together
with the customer/product/seller keys they happen to share. If a future
question genuinely needs cross-mart analysis, that's a sign a new mart
(or going back to Silver) is the right answer, not ad-hoc relationships
bolted onto Gold.

**`dim_date` is the one exception — it's meant to relate to every mart.**
It's the shared calendar table (already designed for exactly this in
Silver, with a surrogate `date_key` for the reason explained there):

1. Select `dim_date` → `Table tools` → `Mark as date table` → pick `full_date`.
2. Build relationships (`Model` view, drag `full_date` from `dim_date` to
   the matching column on each mart): `dim_date[full_date]` →
   `mart_sales[full_date]`, → `mart_logistics[purchase_date]`. For
   `mart_customer_experience[review_creation_date]`, first check its data
   type is `Date` (not `Date/Time`) in Power Query — Olist review
   timestamps are always midnight, so truncating to date loses nothing —
   otherwise the relationship may not match rows correctly.
3. This is what makes real time-intelligence measures
   (`SAMEPERIODLASTYEAR`, `TOTALYTD`, etc.) and a single date slicer that
   filters every page actually work — without a marked date table they
   either error or silently give wrong numbers.

## 3. Measures table

Before creating any measure: `Home` → `Enter Data` → a one-column,
one-row placeholder table → name it `_Measures` → `Load`. Hide its
placeholder column. Every measure below gets created **on `_Measures`**
(select it in the Fields pane before `New Measure`), not on the mart
tables — keeps each mart's field list to its actual columns, and groups
all KPIs in one place. Optionally set each measure's `Display Folder`
(Model view → measure → Properties) to `Sales`, `Customer Experience` or
`Logistics` to sub-group them inside `_Measures`.

## 4. Why `DIVIDE(...)` instead of `AVERAGE(...)`

`Avg Order Value` and `Pct On Time Deliveries` use `DIVIDE`, not
`AVERAGE`, for two separate reasons:

1. **Grain mismatch.** `mart_sales` has one row per *order item*, not per
   order. `AVERAGE(mart_sales[price])` would average item prices, not
   order values — an order with 3 items counts as 3 rows, not 1. To get
   "average value per order" you need a ratio of two aggregates at
   different grains: total revenue over distinct order count, i.e.
   `DIVIDE([Total Revenue], [Total Orders])`. `AVERAGE` only gives the
   right answer when a table row already *is* the unit you want to
   average (which is why `Avg Review Score` legitimately uses `AVERAGE`
   directly — each row already is one review).
2. **Safe division.** Even where the grain matches, the raw `/` operator
   throws `#DIV/0!`/Infinity the moment a filter drives the denominator
   to zero (e.g. a month with no orders). `DIVIDE(numerator,
   denominator)` returns blank instead of breaking the visual.

## 5. Measures and pages

### Page 1 — Sales (source table: `mart_sales`)

Measures (create on `_Measures`):

```dax
Total Revenue = SUM(mart_sales[price])
Total Freight = SUM(mart_sales[freight_value])
Total Orders = DISTINCTCOUNT(mart_sales[order_id])
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])
Freight Pct of Revenue = DIVIDE([Total Freight], [Total Revenue])
```

`Freight Pct of Revenue` is the reason `Total Freight` earns its own
measure instead of being folded into `Total Revenue`: shipping cost as a
share of revenue is a real logistics-efficiency KPI, not just a leftover
number.

Visuals:
- Cards: `Total Revenue`, `Total Orders`, `Avg Order Value`, `Total Freight`, `Freight Pct of Revenue`.
- Line chart: `Total Revenue` by `full_date` (year/month drill-down).
- Bar chart: `Total Revenue` by `product_category_name_english` (top 10).
- Bar or map: `Total Revenue` by `customer_state_name` (full state name,
  not the raw 2-letter code — enriched in Silver via the `br_state_names`
  seed for readability).

### Page 2 — Customer experience (source table: `mart_customer_experience`)

Measures (create on `_Measures`):

```dax
Avg Review Score = AVERAGE(mart_customer_experience[review_score])
Avg Review Score (On Time) = CALCULATE([Avg Review Score], mart_customer_experience[is_late] = FALSE)
Avg Review Score (Late) = CALCULATE([Avg Review Score], mart_customer_experience[is_late] = TRUE)
```

Visuals:
- Card: `Avg Review Score`.
- **Clustered bar: `Avg Review Score (On Time)` vs `Avg Review Score (Late)`** — this is the
  headline finding (4.29 vs 2.27), make it the centerpiece of this page.
- Column chart: count of reviews by `review_score` (1-5 distribution).
- Line chart: `Avg Review Score` by `review_creation_date` (month).

### Page 3 — Logistics (source table: `mart_logistics`)

Measures (create on `_Measures`):

```dax
Pct On Time Deliveries =
DIVIDE(
    CALCULATE(COUNTROWS(mart_logistics), mart_logistics[is_late] = FALSE),
    COUNTROWS(mart_logistics)
)
Avg Delivery Days = AVERAGE(mart_logistics[delivery_days])
Avg Delay Days (Late Only) = CALCULATE(AVERAGE(mart_logistics[delay_days]), mart_logistics[is_late] = TRUE)
Late Deliveries Count = CALCULATE(COUNTROWS(mart_logistics), mart_logistics[is_late] = TRUE)
```

Visuals:
- Cards: `Pct On Time Deliveries`, `Avg Delivery Days`.
- Bar chart: `Pct On Time Deliveries` by `seller_state_name` (full state name).
- Table: `seller_id`, `Avg Delay Days (Late Only)`, `Late Deliveries Count` —
  sorted by `Avg Delay Days (Late Only)` descending, **with a visual-level
  filter `Late Deliveries Count >= 5`**. Without it, a seller with exactly
  one 167-day-late delivery outranks a seller with 50 deliveries
  averaging 20 days late — an average over n=1 isn't a pattern, and a
  "worst sellers" leaderboard should rank patterns, not one-off outliers.

## 6. Save and commit

Save as `power-bi/olist-medallion.pbix`. In Import mode the data is
embedded in the file itself, so it's self-contained — **commit the
`.pbix`**, unlike the parquet staging files.

## 7. Screenshots

Export each page as an image (`File` → `Export` → `Export to PDF`, or a
plain screenshot) into `power-bi/screenshots/` for the README and the
portfolio — useful for anyone browsing the repo without Power BI
installed.
