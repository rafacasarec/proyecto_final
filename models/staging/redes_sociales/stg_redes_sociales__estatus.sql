with 

source as (
    select * from {{ ref('base_redes_sociales__resultados_rrss') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['desc_estatus']) }} as id_estatus,
        desc_estatus,
        first_name,
        {{ dbt_utils.generate_surrogate_key(['trim(first_name)']) }} as artist_id,
        followers_insta,
        total_likes_insta,
        total_coment_insta,
        mentioned_history_insta,
        songs_played_insta,
        engagement_rate_instagram,
        followers_X,
        total_likes_X,
        total_reposts_X,
        engagement_rate_X,
        followers_tiktok,
        songs_played_tiktok
    from source
)

select * from renamed
