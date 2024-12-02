{{ config(
    materialized='incremental',
    unique_key = 'id'
    ) 
}}

with 

posts_artist as (

    select * from {{ ref('stg_bluesky__dim_posts_artist') }}

{% if is_incremental() %}

	  WHERE _dlt_load_id > (SELECT MAX(_dlt_load_id) FROM {{ this }} )

{% endif %}
    ),

renamed as (

    select
        id,
        id_user_bluesky,
        desc_user_bluesky,
        content,
        post_created,
        reply_count,
        repost_count,
        like_count,
        id_artist,
        mentioned_artist,
        _dlt_load_id,
        _dlt_id

    from posts_artist

)

select * from renamed
