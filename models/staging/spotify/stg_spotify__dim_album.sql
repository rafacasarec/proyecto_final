with 

source as (

    select * from {{ source('spotify', 'dim_album') }}

),

renamed as (

    select
        album_id,
        titulo as desc_album,
        artista_principal_id as artista_id,
        artista_principal_name as name_artist,
        date(fecha_lanzamiento) as release_date,
        total_canciones as total_songs,
        spotify_url,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
