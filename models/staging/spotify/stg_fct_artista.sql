with 

source as (

    select * from {{ source('spotify', 'dim_artista') }}

),

renamed as (

    select
        nombre,
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as artist_id,
        seguidores as followers,
        popularidad as popularity
    from source
)

select * from renamed