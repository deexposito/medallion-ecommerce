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
