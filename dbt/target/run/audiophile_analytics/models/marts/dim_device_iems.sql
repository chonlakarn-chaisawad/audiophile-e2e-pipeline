
  
    
    
    
        


        
  

  insert into `default`.`dim_device_iems__dbt_backup`
        ("device_id", "model", "signature", "driver_type", "status")with stg as (
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
  