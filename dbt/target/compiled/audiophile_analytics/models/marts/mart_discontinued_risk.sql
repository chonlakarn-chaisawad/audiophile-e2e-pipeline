// show data summary modal and discontinued model by device_type

with stg as (
    select * from `default`.`stg_audiophile`
)

select
    device_type,
    count(*)                                         as total_models,
    sum(is_discontinued)                              as discontinued_models,
    countIf(not is_discontinued)                      as active_models,
    round(sum(is_discontinued) / count(*) * 100, 1)   as discontinued_pct
from stg
group by device_type
order by discontinued_pct desc