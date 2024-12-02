{{ config(
    materialized='incremental'
    ) 
}}

with 

source as (

    select * from {{ source('bluesky', 'dim_posts_artistas') }}

{% if is_incremental() %}

	  WHERE _dlt_load_id > (SELECT MAX(_dlt_load_id) FROM {{ this }} )

{% endif %}
    ),

renamed as (

    select
        id,
        {{ dbt_utils.generate_surrogate_key(['author_handle']) }} as id_user_bluesky,
        author_handle as desc_user_bluesky,
        content,
        convert_timezone('UTC', created_at) as post_created,
        reply_count,
        repost_count,
        like_count,
        {{ dbt_utils.generate_surrogate_key(['mentioned_artist']) }} as id_artist,
        coalesce(nullif(mentioned_artist, null), 'no artist mentioned on text') as mentioned_artist,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
