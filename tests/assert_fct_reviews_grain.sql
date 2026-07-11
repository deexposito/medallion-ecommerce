-- Discovered while testing: review_id alone is NOT unique (789 duplicate
-- groups) - the same review_id string can appear for different orders, and
-- an order can legitimately receive more than one review (different dates/
-- scores). The composite (review_id, order_id) is the real grain.
select review_id, order_id, count(*) as n_rows
from {{ ref('fct_reviews') }}
group by 1, 2
having count(*) > 1
