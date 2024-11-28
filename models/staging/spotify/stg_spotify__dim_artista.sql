with 

source as (

    select * from {{ source('spotify', 'dim_artista') }}

),

renamed as (

    select
        artista_id,
        nombre as name_artist,
        generos as desc_generos,
        seguidores as followers,
        popularidad as popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,

    from source

)

select * from renamed