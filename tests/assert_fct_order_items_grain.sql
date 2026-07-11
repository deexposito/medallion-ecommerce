-- A dbt test passes when it returns zero rows. This checks the declared
-- grain of fct_order_items (one row per order_id + order_item_id) actually
-- holds, since dbt's built-in `unique` test only covers a single column.
select order_id, order_item_id, count(*) as n_rows
from {{ ref('fct_order_items') }}
group by 1, 2
having count(*) > 1
