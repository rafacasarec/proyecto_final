with 

source as (

    select * from {{ source('spotify', 'fct_top_50') }}

),

renamed as (

    select
        playlist_id,
        fecha,
        convert_timezone('UTC', timestamp) as date,
        position,
        track_id as id_song,
        track_name as desc_song,
        artist_id,
        artist_name,
        album_id,
        album_name as desc_album,
        date(release_date) as release_date,
        duration_ms,
        popularity,
        streams_estimados as streams_estimated,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
