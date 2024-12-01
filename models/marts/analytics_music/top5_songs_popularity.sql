with 
-- Base normalizada desde stg_spotify__fct_top_50
top50 as (
    select * from {{ ref('fct_top_50') }}
),

split_artists as (
    select
        playlist_id,
        fecha,
        date,
        position,
        id_song,
        desc_song as song_title,
        split(artist_id, ',') as artist_id_list,
        split(artist_name, ',') as artist_name_list,
        album_id,
        desc_album as album_title,
        date(release_date) as release_date,
        duration_ms,
        popularity,
        streams_estimated,
        _dlt_load_id,
        _dlt_id
    from top50
),

normalized as (
    select
        playlist_id,
        fecha,
        date,
        position,
        id_song,
        song_title,
        album_id,
        album_title,
        release_date,
        duration_ms,
        popularity,
        streams_estimated,
        _dlt_load_id,
        _dlt_id,
        trim(artist_id_list[index]) as artist_id,
        trim(artist_name_list[index]) as artist_name
    from split_artists,
    lateral flatten(input => artist_id_list) as index
),

-- Agrupar información para consolidar artistas
aggregated as (
    select
        id_song,
        song_title,
        listagg(distinct artist_name, ', ') within group (order by artist_name) as artists, -- Consolidar artistas
        album_title,
        popularity as song_popularity,
        streams_estimated,
        min(position) as min_position -- Obtener la posición más alta (menor número) de las canciones más populares
    from normalized
    group by id_song, song_title, album_title, popularity, streams_estimated
),

-- Seleccionar las 5 canciones más populares y ordenar por popularidad
top_songs as (
    select *
    from aggregated
    order by song_popularity desc -- Ordenar por popularidad
    limit 5 -- Seleccionar las 5 canciones más populares
)

select
    id_song,
    song_title,
    artists,
    album_title,
    song_popularity as popularity,
    streams_estimated,
    min_position as position -- Mostrar la posición de las canciones más populares en el Top 50
from top_songs
order by popularity desc
