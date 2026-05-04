{{ config(
    location = env_var('AWS_BUCKET_URL') ~ '/silver/' ~ this.name ~ '.parquet'
) }}

with raw_users as (
    select * from {{ source('bronze', 'users') }}
)

select
    cast(id as int) as user_id,
    username,
    concat(
        upper(trim(nullif(name->>'$.firstname', ''))),
        ' ',
        upper(trim(nullif(name->>'$.lastname', '')))
    ) as full_name,
    upper(trim(nullif(address->>'$.city', ''))) as city,
    cast(address->>'$.geolocation'->>'$.lat' as decimal(10,4)) as latitude,
    cast(address->>'$.geolocation'->>'$.long' as decimal(10,4)) as longitude
from
    raw_users
