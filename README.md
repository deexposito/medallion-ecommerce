# Medallion Architecture — E-commerce (Olist)

Sample data pipeline (Bronze → Silver → Gold) built with **dbt + DuckDB**,
as a hands-on exercise in the Medallion architecture and as a portfolio
piece. Built on public e-commerce (retail) data, unrelated to any
employer's real data.

## Why this project

A small-scale replica, with open data, of the classic three-layer pattern
(Landing/Staging → Semantic → Domains) — known in the industry as
Bronze/Silver/Gold, and covered by the Microsoft Fabric DP-600/DP-700
certifications.

| Industry vocabulary | This repo |
|---|---|
| Bronze (Landing/Staging) | `models/bronze/` |
| Silver (Semantic layer) | `models/silver/` |
| Gold (Domains / data products) | `models/gold/` |
| Consumption | Power BI (`power-bi/`) |

## Architecture

```mermaid
flowchart LR
    subgraph Sources["Sources (Olist CSVs)"]
        A1[customers]
        A2[orders]
        A3[order_items]
        A4[products]
        A5[sellers]
        A6[payments]
        A7[reviews]
        A8[geolocation]
    end

    subgraph Bronze["🥉 Bronze — Landing/Staging"]
        B[stg_*.sql]
    end

    subgraph Silver["🥈 Silver — Semantic layer"]
        S[dim_* / fct_*.sql]
    end

    subgraph Gold["🥇 Gold — Domains"]
        G1[mart_sales]
        G2[mart_customer_experience]
        G3[mart_logistics]
    end

    Sources --> Bronze --> Silver --> Gold --> PowerBI[📊 Power BI]
```

## Data model (Silver layer)

A star schema (technically a fact constellation: four fact tables sharing
conformed dimensions), designed grain-first before writing any SQL:

- `fct_orders` — one row per order (an **accumulating snapshot fact**: the
  row fills in as the order moves through purchase → approval → carrier →
  delivery).
- `fct_order_items` — one row per order item.
- `fct_payments` — one row per payment (an order can have more than one).
- `fct_reviews` — one row per review.

All four share the same conformed dimensions (`dim_customers`,
`dim_products`, `dim_sellers`, `dim_date`), so metrics from different
facts stay comparable under the same filters in Power BI.

**Keys**: natural keys are kept for `dim_customers`/`dim_products`/
`dim_sellers` — this is a single source system with already-unique, stable
IDs, so a surrogate key would add overhead without solving a real problem.
`dim_date` is the one exception: it always gets an integer surrogate key
(`date_key`, e.g. `20180724`), the universal convention that makes Power
BI/DAX time intelligence (`SAMEPERIODLASTYEAR`, etc.) work without
friction.

**No SCD2**: this dataset is a static historical snapshot, not a
continuously refreshed pipeline, so Slowly Changing Dimension history
tracking would be engineering for a problem we don't have. `dim_customers`
would be the natural SCD2 candidate if this ever became a live pipeline.

**Referential integrity**: DuckDB (like most analytical engines) doesn't
enforce foreign keys. dbt tests (`not_null`, `unique`, `relationships`)
are the real substitute and will be added alongside the models.

```mermaid
erDiagram
  dim_customers ||--o{ fct_orders : places
  dim_date ||--o{ fct_orders : "purchased on"
  fct_orders ||--o{ fct_order_items : contains
  dim_products ||--o{ fct_order_items : is
  dim_sellers ||--o{ fct_order_items : sells
  fct_orders ||--o{ fct_payments : "paid via"
  fct_orders ||--o{ fct_reviews : receives

  dim_customers {
    VARCHAR customer_id PK
    VARCHAR customer_unique_id
    VARCHAR customer_city
    VARCHAR customer_state
  }
  dim_products {
    VARCHAR product_id PK
    VARCHAR product_category_name
    VARCHAR category_name_english
    INTEGER product_weight_g
  }
  dim_sellers {
    VARCHAR seller_id PK
    VARCHAR seller_city
    VARCHAR seller_state
  }
  dim_date {
    INTEGER date_key PK
    DATE full_date
    INTEGER year
    INTEGER month
    VARCHAR weekday
  }
  fct_orders {
    VARCHAR order_id PK
    VARCHAR customer_id FK
    INTEGER purchase_date_key FK
    VARCHAR order_status
    INTEGER items_count
    DECIMAL(10,2) order_total_value
    DECIMAL(10,2) freight_total_value
  }
  fct_order_items {
    VARCHAR order_id FK
    INTEGER order_item_id PK
    VARCHAR product_id FK
    VARCHAR seller_id FK
    DECIMAL(10,2) price
    DECIMAL(10,2) freight_value
  }
  fct_payments {
    VARCHAR order_id FK
    INTEGER payment_sequential PK
    VARCHAR payment_type
    INTEGER installments
    DECIMAL(10,2) payment_value
  }
  fct_reviews {
    VARCHAR review_id PK
    VARCHAR order_id FK
    INTEGER review_score
    TIMESTAMP review_creation_date
  }
```

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(Kaggle, CC BY-NC-SA 4.0 license). ~100k anonymized real orders from a
Brazilian marketplace, split across 9 CSVs — a realistic stand-in for a
"multiple source systems" scenario (customers, orders, payments,
logistics, reviews), which makes landing/staging per source meaningful.

**Raw data is not distributed in this repo** (size and license). To
reproduce:

1. Download the dataset from Kaggle (free account required).
2. Unzip the CSVs into `data/raw/`.

## Setup

```bash
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt

cp profiles.yml.example profiles.yml   # adjust the path if needed
dbt debug
dbt build
```

## Roadmap

- [x] **Phase 0 — Setup**: project skeleton, dbt + DuckDB installed, Git repo initialized.
- [x] **Phase 1 — Bronze**: dataset downloaded, `sources.yml` (8 tables via `external_location`) + 1 `dbt seed` (small reference table), 9 `stg_*.sql` models. Decision documented in `docs/decisions/0001-seeds-vs-external-sources.md`.
- [ ] **Phase 2 — Silver**: dimensional model (`dim_*`/`fct_*`), joins and business rules, first dbt tests (`not_null`, `unique`, `relationships`).
- [ ] **Phase 3 — Gold**: 3 domain data marts (`mart_sales`, `mart_customer_experience`, `mart_logistics`).
- [ ] **Phase 4 — Consumption**: Power BI dashboard connected to Gold, screenshots in `power-bi/`.
- [ ] **Phase 5 — Polish**: `dbt docs generate`, final README, optional CI with GitHub Actions (`dbt build` on every push).
- [ ] **Phase 6 — Publish**: public GitHub repo, linked from the portfolio.

## Status

🚧 In progress — Phase 1 (Bronze) complete, Phase 2 (Silver) underway.
