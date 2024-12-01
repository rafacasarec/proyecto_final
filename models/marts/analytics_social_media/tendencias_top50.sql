with 
-- Base de redes sociales
artist_trends as (
    select
        desc_tendencia as trend,
        social_improve,
        first_name as artist_name
    from {{ ref('dim_artist_tendencia') }}
),

-- Base del Top 50
top50 as (
    select
        split(artist_name, ',') as artist_name_list,
        desc_song as song_title,
        streams_estimated,
        position,
        artist_id
    from {{ ref('fct_top_50') }}
),

-- Normalizar artistas desde el Top 50
normalized_top50 as (
    select
        trim(a.value) as artist_name, -- Extraer nombres de artistas desde la lista
        t.song_title,
        t.streams_estimated,
        t.position
    from top50 t,
    lateral flatten(input => t.artist_name_list) as a
),

-- Agregar streams totales por artista y calcular la mejor posición
aggregated_streams_and_position as (
    select
        artist_name,
        sum(streams_estimated) as total_streams,
        min(position) as best_position -- Obtener la mejor posición (menor valor)
    from normalized_top50
    group by artist_name
),

-- Unir datos de tendencias, streams y posición
final_data as (
    select
        t.trend,
        t.social_improve,
        t.artist_name,
        listagg(n.song_title, ', ') within group (order by n.song_title) as songs_in_top50, -- Consolidar canciones
        coalesce(a.total_streams, 0) as total_streams, -- Usar 0 si no tiene streams
        coalesce(a.best_position, null) as top50_position -- Mejor posición en el Top 50
    from artist_trends t
    left join normalized_top50 n
        on lower(t.artist_name) = lower(n.artist_name)
    left join aggregated_streams_and_position a
        on lower(t.artist_name) = lower(a.artist_name)
    group by t.trend, t.social_improve, t.artist_name, a.total_streams, a.best_position
)

select *
from final_data
order by trend, total_streams desc
