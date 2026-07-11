"""Export the Gold marts (and the shared calendar dimension) to Parquet
for Power BI to import.

Power BI Desktop has no native DuckDB connector, and setting one up via
ODBC is extra friction for something that's just meant to be read once
per refresh. Parquet keeps types (unlike CSV) and Power BI reads it
natively, so this is the simplest reliable hand-off between dbt/DuckDB
and Power BI.

Run from anywhere (paths are resolved relative to the project root, not
the current working directory):
    .venv/Scripts/python.exe scripts/export_gold_to_parquet.py
"""

from pathlib import Path

import duckdb

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DUCKDB_PATH = PROJECT_ROOT / "medallion.duckdb"
OUTPUT_DIR = PROJECT_ROOT / "power-bi" / "data"

MARTS = ["mart_sales", "mart_customer_experience", "mart_logistics"]

# dim_date lives in Silver, not Gold - it's included here as an exception
# because it's the one table meant to be shared across marts in Power BI
# (the calendar table, related to each mart's date column via
# relationships), unlike the marts themselves which are intentionally
# flat and unrelated to each other.
SHARED_DIMENSIONS = {"dim_date": "main_silver"}

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
con = duckdb.connect(str(DUCKDB_PATH), read_only=True)

for mart in MARTS:
    out_path = OUTPUT_DIR / f"{mart}.parquet"
    con.execute(f"COPY main_gold.{mart} TO '{out_path}' (FORMAT PARQUET)")
    n_rows = con.execute(f"SELECT COUNT(*) FROM main_gold.{mart}").fetchone()[0]
    print(f"{mart}: {n_rows} rows -> {out_path}")

for table, schema in SHARED_DIMENSIONS.items():
    out_path = OUTPUT_DIR / f"{table}.parquet"
    con.execute(f"COPY {schema}.{table} TO '{out_path}' (FORMAT PARQUET)")
    n_rows = con.execute(f"SELECT COUNT(*) FROM {schema}.{table}").fetchone()[0]
    print(f"{table}: {n_rows} rows -> {out_path}")
