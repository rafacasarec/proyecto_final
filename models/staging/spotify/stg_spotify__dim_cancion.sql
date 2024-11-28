with 

source as (

    select * from {{ source('spotify', 'dim_cancion') }}

),

renamed as (

    select
        cancion_id,
        titulo as desc_song,
        album_id,
        album_name as desc_album,
        date(album_release_date) as album_release_date,
        artista_id,
        artista_name as artist_name,
        duracion_ms,
        explicit,
        popularidad as popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
