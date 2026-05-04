{{ config(
    location = env_var('AWS_BUCKET_URL') ~ '/silver/' ~ this.name ~ '.parquet'
) }}

with raw_products as (
    select * from {{ source('bronze', 'products') }}
)

select
    cast(id as int) as product_id,
    upper(trim(nullif(title, ''))) as product_name,
    upper(trim(nullif(category, ''))) as category,
    cast(price as decimal(10,2)) as price,
    cast(rating->>'$.rate' as decimal(2,1)) as rate
from
    raw_products
