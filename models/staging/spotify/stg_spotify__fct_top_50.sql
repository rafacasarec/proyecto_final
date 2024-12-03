with source as (
    select * from {{ source('spotify', 'fct_top_50') }}
),

split_artists as (
    select
        playlist_id,
        fecha,
        convert_timezone('UTC', timestamp) as date,
        position,
        track_id as id_song,
        track_name as desc_song,
        split(artist_id, ',') as artist_id_list,
        split(artist_name, ',') as artist_name_list,
        {{ dbt_utils.generate_surrogate_key(['trim(album_name)']) }} as album_id,
        album_name as desc_album,
        date(release_date) as release_date,
        duration_ms,
        popularity,
        streams_estimados as streams_estimated,
        _dlt_load_id,
        _dlt_id
    from source
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
    {{ dbt_utils.generate_surrogate_key(['trim(desc_song)']) }} as song_id,
    desc_song,
    trim(artist_name) as artist_name,
    album_id,
    desc_album,
    release_date,
    duration_ms,
    popularity,
    streams_estimated,
    _dlt_load_id,
    _dlt_id,
    {{ dbt_utils.generate_surrogate_key(['trim(artist_name)']) }} as artist_id

from normalized
