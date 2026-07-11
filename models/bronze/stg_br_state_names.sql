select
    state_code,
    state_name
from {{ ref('br_state_names') }}
