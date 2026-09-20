// number of model by each driver_type	

with stg as (
    select * from {{ ref('stg_audiophile') }}
    where price_usd is not null
        and not is_discontinued
),

rated as (
    select
        *,
        lengthUTF8(replaceAll(value_rating, ' ', '')) as value_stars
    from stg
)

select
    device_type,
    driver_type,
    fit_cup,
    count(*)                   as model_count,
    round(avg(price_usd), 2)   as avg_price_usd
from rated
where driver_type != ''
group by device_type, driver_type, fit_cup
having model_count >= 3
order by device_type, avg(value_stars) desc