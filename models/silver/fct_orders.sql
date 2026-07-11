-- Accumulating snapshot fact: order_status reflects wherever the order
-- currently sits in its lifecycle (purchase -> approval -> carrier ->
-- delivery). Milestone timestamps beyond purchase are kept as plain
-- descriptive columns (not surrogate FKs) to keep the dimension model simple.
select
    o.order_id,
    o.customer_id,
    cast(strftime(o.order_purchase_timestamp, '%Y%m%d') as integer) as purchase_date_key,
    o.order_status,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    count(oi.order_item_id) as items_count,
    coalesce(sum(oi.price), 0) as order_total_value,
    coalesce(sum(oi.freight_value), 0) as freight_total_value
from {{ ref('stg_orders') }} as o
left join {{ ref('stg_order_items') }} as oi
    on o.order_id = oi.order_id
group by 1, 2, 3, 4, 5, 6, 7, 8
