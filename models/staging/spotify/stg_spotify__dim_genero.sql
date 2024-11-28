with 

source as (

    select * from {{ source('spotify', 'dim_genero') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as id_genero,
        nombre as desc_genero,
        popularidad_global:: DECIMAL(10,2) as rate_popularity,
        numero_artistas as artist_top50,
        numero_canciones as song_top50,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
