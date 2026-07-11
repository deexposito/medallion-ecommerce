select
    s.seller_id,
    s.seller_city,
    s.seller_state,
    n.state_name as seller_state_name
from {{ ref('stg_sellers') }} as s
left join {{ ref('stg_br_state_names') }} as n on s.seller_state = n.state_code
