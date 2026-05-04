{{ config(
    materialized='external',
    location = env_var('AWS_BUCKET_URL') ~ '/gold/' ~ this.name ~ '.parquet'
) }}

with carts as (
    select * from {{ ref('silver_carts') }}
),

products as (
    select * from {{ ref('silver_products') }}
),

users as (
    select * from {{ ref('silver_users') }}
)

select
    c.cart_item_id,
    c.cart_id,
    c.cart_date,
    u.user_id,
    u.city,
    u.latitude,
    u.longitude,
    p.product_id,
    p.product_name,
    p.category,
    c.quantity,
    p.price as unit_price,
    cast((c.quantity * p.price) as decimal(10,2)) as revenue

from carts c
left join products p on c.product_id = p.product_id
left join users u on c.user_id = u.user_id
