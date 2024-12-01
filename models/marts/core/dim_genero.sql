with 

genero as (

    select * from {{ ref('stg_spotify__dim_genero') }}

),

renamed as (

    select
        id_genero,
        desc_genero,
        rate_popularity,
        artist_top50,
        song_top50,
        _dlt_load_id,
        _dlt_id

    from genero

)

select * from renamed
