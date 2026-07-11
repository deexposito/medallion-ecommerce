-- Same idea as assert_fct_order_items_grain.sql: verifies the declared
-- grain of fct_payments (one row per order_id + payment_sequential).
select order_id, payment_sequential, count(*) as n_rows
from {{ ref('fct_payments') }}
group by 1, 2
having count(*) > 1
