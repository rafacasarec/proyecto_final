{{ config(
    materialized='incremental',
    unique_key = '_dlt_load_id'
    ) 
}}

with 

posts_songs as (

    select * from {{ ref('stg_bluesky__dim_posts_songs') }}

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
        id_song,
        mentioned_song,
        _dlt_load_id,
        _dlt_id

    from posts_songs

)

select * from renamed
