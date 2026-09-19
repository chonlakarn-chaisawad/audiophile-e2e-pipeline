with stg as (
    select * from `default`.`stg_audiophile`
    where device_type = 'iems'
)

select distinct
    cityHash64(device_type, model) as device_id,
    model,
    signature,
    driver_type,
    status,
from stg