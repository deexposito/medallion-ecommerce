select
    geolocation_zip_code_prefix::integer as geolocation_zip_code_prefix,
    geolocation_lat::double as geolocation_lat,
    geolocation_lng::double as geolocation_lng,
    geolocation_city,
    geolocation_state
from {{ source('olist_raw', 'geolocation') }}
