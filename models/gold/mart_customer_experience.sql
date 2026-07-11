-- delivery_days/delay_days are null when the order hasn't been delivered
-- yet - that's intentional, "unknown" is not the same as "on time".
select
    r.review_id,
    r.order_id,
    r.review_score,
    r.review_creation_date,
    c.customer_state,
    {{ days_between('d.full_date', 'o.order_delivered_customer_date::date') }} as delivery_days,
    {{ days_between('o.order_estimated_delivery_date::date', 'o.order_delivered_customer_date::date') }} as delay_days,
    {{ days_between('o.order_estimated_delivery_date::date', 'o.order_delivered_customer_date::date') }} > 0 as is_late
from {{ ref('fct_reviews') }} as r
inner join {{ ref('fct_orders') }} as o on r.order_id = o.order_id
left join {{ ref('dim_customers') }} as c on o.customer_id = c.customer_id
left join {{ ref('dim_date') }} as d on o.purchase_date_key = d.date_key
