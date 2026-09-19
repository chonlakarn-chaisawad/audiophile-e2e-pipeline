with stg as (
    select * from `default`.`stg_audiophile`
    where device_type = 'iems'
)

select
    cityHash64(device_type, model) as device_id,
    rank,
    value_rating,
    price_raw,
    price_usd,
    is_discontinued,
    tone_grade,
    technical_grade,
    comments,
    status
from stg