with source as (
    select * from {{ source('spotify', 'dim_cancion') }}
),

exploded as (
    select
        -- Mantén otros campos de la tabla de canciones
        {{ dbt_utils.generate_surrogate_key(['trim(titulo)']) }} as song_id,
        titulo as desc_song,
        album_id,
        album_name as desc_album,
        album_release_date,
        duracion_ms,
        explicit,
        popularidad as popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,

        -- Dividir los IDs y nombres de los artistas en listas
        split(artista_id, ',') as artista_id_list,
        split(artista_name, ',') as artist_name_list
    from source
),

normalized as (
    select
        song_id,
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
    song_id,
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
    {{ dbt_utils.generate_surrogate_key(['artist_name']) }} as artist_id,
    artist_name
from normalized
