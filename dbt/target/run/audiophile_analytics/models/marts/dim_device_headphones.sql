
  
    
    
    
        


        
  

  insert into `default`.`dim_device_headphones__dbt_backup`
        ("device_id", "model", "signature", "driver_type", "fit_cup", "based_on")with stg as (
    select * from `default`.`stg_audiophile`
    where device_type = 'headphones'
)

select distinct
    cityHash64(device_type, model) as device_id,
    model,
    signature,
    driver_type,
    fit_cup,
    based_on
from stg
  