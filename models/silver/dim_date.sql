-- Date range is derived from the actual order data (not hardcoded), with a
-- 60-day buffer past the last purchase so delivery-milestone dates that
-- fall after the purchase date are still covered.
with bounds as (
    select
        min(order_purchase_timestamp)::date as min_date,
        (max(order_purchase_timestamp)::date + interval '60 days')::date as max_date
    from {{ ref('stg_orders') }}
),

spine as (
    select unnest(generate_series(min_date, max_date, interval '1 day'))::date as full_date
    from bounds
)

select
    cast(strftime(full_date, '%Y%m%d') as integer) as date_key,
    full_date,
    extract(year from full_date) as year,
    extract(month from full_date) as month,
    -- YYYYMM, e.g. 201809: sorts and groups correctly across years, unlike
    -- `month` alone (which would merge Jan 2017 and Jan 2018 together).
    cast(strftime(full_date, '%Y%m') as integer) as year_month,
    strftime(full_date, '%A') as weekday
from spine
