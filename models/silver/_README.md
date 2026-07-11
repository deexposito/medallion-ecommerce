# Silver (Semantic layer)

Models that consolidate the `stg_*` tables from bronze into a clean
relational model with business logic: joins, deduplication, business
rules (e.g. order status, "active customer" definition), consistent keys
across entities (`dim_customers`, `dim_products`, `dim_sellers`,
`fct_orders`, `fct_order_items`, `fct_payments`, `fct_reviews`...).

Independent of where each piece of data originally came from — this is
where we speak the language of the business, not of each source system.

Delete this file once real content exists.
