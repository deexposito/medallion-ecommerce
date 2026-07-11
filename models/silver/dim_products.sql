select
    p.product_id,
    p.product_category_name,
    t.product_category_name_english as category_name_english,
    p.product_weight_g
from {{ ref('stg_products') }} as p
left join {{ ref('stg_product_category_translation') }} as t
    on p.product_category_name = t.product_category_name
