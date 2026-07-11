select
    seller_id,
    seller_zip_code_prefix::integer as seller_zip_code_prefix,
    seller_city,
    seller_state
from {{ source('olist_raw', 'sellers') }}
