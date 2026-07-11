select
    review_id,
    order_id,
    review_score,
    review_creation_date
from {{ ref('stg_order_reviews') }}
