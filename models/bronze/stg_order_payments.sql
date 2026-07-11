select
    order_id,
    payment_sequential::integer as payment_sequential,
    payment_type,
    payment_installments::integer as payment_installments,
    payment_value::decimal(10, 2) as payment_value
from {{ source('olist_raw', 'order_payments') }}
