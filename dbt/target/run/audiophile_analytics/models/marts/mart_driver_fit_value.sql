
  
    
    
    
        


        
  

  insert into `default`.`mart_driver_fit_value__dbt_backup`
        ("device_type", "driver_type", "fit_cup", "model_count", "avg_value_stars", "avg_price_usd")with stg as (
    select * from `default`.`stg_audiophile`
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
    round(avg(value_stars), 2) as avg_value_stars,
    round(avg(price_usd), 2)   as avg_price_usd
from rated
where driver_type != ''
group by device_type, driver_type, fit_cup
having model_count >= 3
order by device_type, avg_value_stars desc
  