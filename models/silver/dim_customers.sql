select
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    n.state_name as customer_state_name
from {{ ref('stg_customers') }} as c
left join {{ ref('stg_br_state_names') }} as n on c.customer_state = n.state_code
