with base as (
    select * from {{ ref('stg_spotify__dim_cancion') }}
),

exploded as (
    select
        -- Mantén otros campos de la tabla de canciones
        cancion_id,
        desc_song,
        album_id,
        desc_album,
        album_release_date,
        duracion_ms,
        explicit,
        popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,

        -- Dividir los IDs y nombres de los artistas en listas
        split(artista_id, ',') as artista_id_list,
        split(artist_name, ',') as artist_name_list
    from base
),

normalized as (
    select
        cancion_id,
        desc_song,
        album_id,
        desc_album,
        album_release_date,
        duracion_ms,
        explicit,
        popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,

        -- Extraer el artista_id y el artist_name correspondientes
        trim(artista_id_list[index]) as artista_id, -- Extraer y limpiar artista_id
        trim(artist_name_list[index]) as artist_name -- Extraer y limpiar artist_name
    from exploded,
    lateral flatten(input => artista_id_list) as index
)

select
    cancion_id,
    desc_song,
    album_id,
    desc_album,
    album_release_date,
    duracion_ms,
    explicit,
    popularity,
    spotify_url,
    _dlt_load_id,
    _dlt_id,
    artista_id,
    artist_name
from normalized
