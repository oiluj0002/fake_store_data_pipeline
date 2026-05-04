{{ config(
    materialized='external',
    location = env_var('AWS_BUCKET_URL') ~ '/gold/' ~ this.name ~ '.parquet'
) }}

with cart_analytics as (
    -- You can even ref other Gold models!
    select * from {{ ref('gold_cart_analytics') }}
)

select
    date_trunc('day', cart_date) as sales_date,
    category,
    count(distinct cart_id) as total_carts,
    sum(quantity) as total_items_sold,
    sum(revenue) as total_revenue
from
    cart_analytics
group by
    1, 2
