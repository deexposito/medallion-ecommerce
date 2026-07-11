select
    oi.order_id,
    oi.order_item_id,
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    s.seller_state_name,
    d.full_date as purchase_date,
    oi.freight_value,
    {{ days_between('d.full_date', 'o.order_delivered_customer_date::date') }} as delivery_days,
    {{ days_between('o.order_estimated_delivery_date::date', 'o.order_delivered_customer_date::date') }} as delay_days,
    {{ days_between('o.order_estimated_delivery_date::date', 'o.order_delivered_customer_date::date') }} > 0 as is_late
from {{ ref('fct_order_items') }} as oi
inner join {{ ref('fct_orders') }} as o on oi.order_id = o.order_id
left join {{ ref('dim_sellers') }} as s on oi.seller_id = s.seller_id
left join {{ ref('dim_date') }} as d on o.purchase_date_key = d.date_key
