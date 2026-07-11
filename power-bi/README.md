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
`mart_customer_experience.parquet` and `mart_logistics.parquet`
(gitignored — regenerate them, don't commit them).

## 2. Import into Power BI Desktop

`Get Data` → `Parquet` → select each of the 3 files → `Load` (Import
mode, not DirectQuery — these are static snapshots, not a live source).

**No relationships needed.** Each mart is an intentionally flat,
denormalized table built for a single purpose — don't wire them together
with the customer/product/seller keys they happen to share. If a future
question genuinely needs cross-mart analysis, that's a sign a new mart
(or going back to Silver) is the right answer, not ad-hoc relationships
bolted onto Gold.

## 3. Measures table

Before creating any measure: `Home` → `Enter Data` → a one-column,
one-row placeholder table → name it `_Measures` → `Load`. Hide its
placeholder column. Every measure below gets created **on `_Measures`**
(select it in the Fields pane before `New Measure`), not on the mart
tables — keeps each mart's field list to its actual columns, and groups
all KPIs in one place. Optionally set each measure's `Display Folder`
(Model view → measure → Properties) to `Sales`, `Customer Experience` or
`Logistics` to sub-group them inside `_Measures`.

## 4. Measures and pages

### Page 1 — Sales (source table: `mart_sales`)

Measures (create on `_Measures`):

```dax
Total Revenue = SUM(mart_sales[price])
Total Freight = SUM(mart_sales[freight_value])
Total Orders = DISTINCTCOUNT(mart_sales[order_id])
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])
```

Visuals:
- Cards: `Total Revenue`, `Total Orders`, `Avg Order Value`.
- Line chart: `Total Revenue` by `full_date` (year/month drill-down).
- Bar chart: `Total Revenue` by `product_category_name_english` (top 10).
- Bar or map: `Total Revenue` by `customer_state`.

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
```

Visuals:
- Cards: `Pct On Time Deliveries`, `Avg Delivery Days`.
- Bar chart: `Pct On Time Deliveries` by `seller_state`.
- Table: `seller_id`, `Avg Delay Days (Late Only)`, count of items — sorted
  descending, to spot the worst-performing sellers.

## 5. Save and commit

Save as `power-bi/olist-medallion.pbix`. In Import mode the data is
embedded in the file itself, so it's self-contained — **commit the
`.pbix`**, unlike the parquet staging files.

## 6. Screenshots

Export each page as an image (`File` → `Export` → `Export to PDF`, or a
plain screenshot) into `power-bi/screenshots/` for the README and the
portfolio — useful for anyone browsing the repo without Power BI
installed.
