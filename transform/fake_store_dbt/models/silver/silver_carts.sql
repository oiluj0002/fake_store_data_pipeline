{{ config(
    location = env_var('AWS_BUCKET_URL') ~ '/silver/' ~ this.name ~ '.parquet'
) }}

with raw_carts as (
    select * from {{ source('bronze', 'carts') }}
),

raw_carts_unnested as (
    select
        cast(id as int) as cart_id,
        cast(user_id as int) as user_id,
        cast(date as timestamp) as date,
        unnest(
            cast(products as struct(
                productId int,
                quantity int)[]
            )) as products
    from
        raw_carts
)

select
    uuid() as cart_item_id,
    cart_id,
    user_id,
    date as cart_date,
    products.productId as product_id,
    products.quantity as quantity

from raw_carts_unnested
