with 

source as (

    select * from {{ source('spotify', 'dim_competidores') }}

),

renamed as (

    select
        competidor_id as artist_id,
        nombre as name_artist,
        genero_asociado as genero,
        seguidores as followers,
        popularidad as popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
