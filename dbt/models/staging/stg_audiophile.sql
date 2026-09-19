with source as (
    select * from {{ source('raw', 'raw_audiophile') }}
),

cleaned as (
    select
        trim(device_type)        as device_type,
        trim(rank)                as rank,
        trim(value_rating)        as value_rating,
        trim(model)                as model,
        trim(price)                as price_raw,

        case
            when match(trim(price), '^[0-9]+(\.[0-9]+)?$')
                then toFloat64OrNull(trim(price))
            else NULL
        end as price_usd,

        trim(price) = 'Discont.' as is_discontinued,

        trim(signature)           as signature,
        trim(comments)             as comments,
        trim(tone_grade)           as tone_grade,
        trim(technical_grade)      as technical_grade,
        trim(driver_type)          as driver_type,
        trim(status)                as status
    from source
)

select * from cleaned
