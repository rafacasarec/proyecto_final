with 

source as (
    select * from {{ source('redes_sociales', 'resultados_rrss') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre_del_artista']) }} as id_rrss,
        nombre_del_artista as first_name, 
        numero_de_seguidores_en_instagram::int as followers_insta,
        total_de_likes_en_instagram::int as total_likes_insta,
        total_de_comentarios_en_instagram::int as total_coment_insta,
        total_de_menciones_en_historias_instagramx::int as mentioned_history_insta,
        total_de_uso_de_canciones_en_reels_e_historias_instagramx::int as songs_played_insta,
        n_mero_de_seguidores_en_x::int as followers_X,
        total_de_likes_en_x::int as total_likes_X,
        total_de_reposts_en_x::int as total_reposts_X,
        numero_de_seguidores_en_tik_tok::int as followers_tiktok,
        total_de_uso_de_canciones_en_tik_tok::int as songs_played_tiktok,
        engagement_rate_instagramx::decimal(10,2) as engagement_rate_instagram,
        engagement_rate_xx::decimal(10,2) as engagement_rate_X,
        escalada_de_seguidores_ltima_semanax::int as social_improve,
        lower(estatus) as desc_estatus,
        {{ dbt_utils.generate_surrogate_key(['estatus']) }} as id_estatus,
        lower(en_tendencia) as desc_tendencia,
        {{ dbt_utils.generate_surrogate_key(['en_tendencia']) }} as id_tendencia,
        to_timestamp(fecha) as date,
        _dlt_load_id,
        _dlt_id
    from source
),

-- Eliminar duplicados seleccionando el registro con más relevancia
deduplicated as (
    select
        *,
        row_number() over (
            partition by first_name
            order by 
                followers_insta desc, 
                followers_X desc, 
                followers_tiktok desc
        ) as row_num -- Priorizar registros por relevancia
    from renamed
)

-- Filtrar solo el primer registro por artista
select 
    id_rrss,
    first_name,
    followers_insta,
    total_likes_insta,
    total_coment_insta,
    mentioned_history_insta,
    songs_played_insta,
    followers_X,
    total_likes_X,
    total_reposts_X,
    followers_tiktok,
    songs_played_tiktok,
    engagement_rate_instagram,
    engagement_rate_X,
    social_improve,
    desc_estatus,
    id_estatus,
    desc_tendencia,
    id_tendencia,
    date,
    _dlt_load_id,
    _dlt_id
from deduplicated
where row_num = 1
