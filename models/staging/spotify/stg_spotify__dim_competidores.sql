with 

source as (

    select * from {{ source('spotify', 'dim_competidores') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as artist_id,
        nombre as name_artist,
        genero_asociado as genero,
        {{ dbt_utils.generate_surrogate_key(['genero_asociado']) }} as genero_id,
        seguidores as followers,
        popularidad as popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
