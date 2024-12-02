with cancion as (
    select * from {{ ref('stg_spotify__dim_cancion') }}
),

exploded as (
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
        split(artist_id, ',') as artist_id_list,
        split(artist_name, ',') as artist_name_list
    from cancion
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
        trim(artist_id_list[index]) as artist_id, 
        trim(artist_name_list[index]) as artist_name 
    from exploded,
    lateral flatten(input => artist_id_list) as index
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
    artist_id,
    artist_name
from normalized
