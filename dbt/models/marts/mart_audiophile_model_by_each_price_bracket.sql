// show data number of model by device_type by each price_bracket

with stg as (
    select * from {{ ref('stg_audiophile') }}
    where price_usd is not null
        and not is_discontinued
),

bracketed as (
    select
        *,
        multiIf(
            price_usd < 100, 'Under $100',
            price_usd < 300, '$100-$300',
            price_usd < 700, '$300-$700',
            price_usd < 1500, '$700-$1500',
            'Above $1500'
        ) as price_bracket
    from stg
)

select
    device_type,
    price_bracket,
    count(*)                as model_count,
    round(avg(price_usd), 2) as avg_price_usd
from bracketed
group by device_type, price_bracket
order by
    multiIf(
        price_bracket = 'Under $100', 1,
        price_bracket = '$100-$300', 2,
        price_bracket = '$300-$700', 3,
        price_bracket = '$700-$1500', 4,
        5
    ),
    device_type