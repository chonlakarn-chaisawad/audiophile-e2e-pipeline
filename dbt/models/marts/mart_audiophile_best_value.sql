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
    model,
    price_usd,
    tone_grade,
    technical_grade,
    value_rating
from bracketed
where value_rating != ''
order by
    device_type,
    multiIf(
        price_bracket = 'Under $100', 1,
        price_bracket = '$100-$300', 2,
        price_bracket = '$300-$700', 3,
        price_bracket = '$700-$1500', 4,
        5
    ),
    length(value_rating) desc
