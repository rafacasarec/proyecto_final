with top50 as (
    select * from {{ ref('stg_spotify__fct_top_50') }}
),

split_artists as (
    select
        playlist_id,
        fecha,
        date,
        position,
        id_song,
        desc_song,
        split(artist_id, ',') as artist_id_list,
        split(artist_name, ',') as artist_name_list,
        album_id,
        desc_album,
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
        desc_song,
        album_id,
        desc_album,
        release_date,
        duration_ms,
        popularity,
        streams_estimated,
        _dlt_load_id,
        _dlt_id,
        artist_id_list[index] as artist_id,
        artist_name_list[index] as artist_name
    from split_artists,
    lateral flatten(input => artist_id_list) as index
)

select
    playlist_id,
    fecha,
    date,
    position,
    id_song,
    desc_song,
    album_id,
    desc_album,
    release_date,
    duration_ms,
    popularity,
    streams_estimated,
    _dlt_load_id,
    _dlt_id,
    trim(artist_id) as artist_id,
    trim(artist_name) as artist_name
from normalized
