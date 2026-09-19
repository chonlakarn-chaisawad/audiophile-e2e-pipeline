
  
    
    
    
        


        
  

  insert into `default`.`mart_audiophile_grade_summary__dbt_backup`
        ("device_type", "technical_grade", "model_count", "discontinued_count", "avg_price_usd", "min_price_usd", "max_price_usd")// show data summary of audiophile models by device type and technical grade
// show many of each technical grade , average price, min price, and max price

with stg as (
    select * from `default`.`stg_audiophile`
)

select
    device_type,
    technical_grade,
    count(*)                                   as model_count,
    countIf(is_discontinued)                   as discontinued_count,
    round(avg(price_usd), 2)                   as avg_price_usd,
    round(min(price_usd), 2)                   as min_price_usd,
    round(max(price_usd), 2)                   as max_price_usd
from stg
group by device_type, technical_grade
order by
    device_type,
    multiIf(
        technical_grade like 'S%', 1,
        technical_grade like 'A%', 2,
        technical_grade like 'B%', 3,
        technical_grade like 'C%', 4,
        technical_grade like 'D%', 5,
        technical_grade like 'E%', 6,
        technical_grade like 'F%', 7,
        8
    ),
    technical_grade
  