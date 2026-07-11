select
    oi.order_id,
    oi.order_item_id,
    d.full_date,
    d.year,
    d.month,
    d.weekday,
    p.category_name_english as product_category_name_english,
    s.seller_state,
    s.seller_state_name,
    c.customer_state,
    c.customer_state_name,
    o.order_status,
    oi.price,
    oi.freight_value
from {{ ref('fct_order_items') }} as oi
inner join {{ ref('fct_orders') }} as o on oi.order_id = o.order_id
left join {{ ref('dim_date') }} as d on o.purchase_date_key = d.date_key
left join {{ ref('dim_products') }} as p on oi.product_id = p.product_id
left join {{ ref('dim_sellers') }} as s on oi.seller_id = s.seller_id
left join {{ ref('dim_customers') }} as c on o.customer_id = c.customer_id
