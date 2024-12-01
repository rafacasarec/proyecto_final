with 

competidores as (

    select * from {{ ref('stg_spotify__dim_competidores') }}

),

renamed as (

    select
        artist_id,
        name_artist,
        genero,
        followers,
        popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id

    from competidores

)

select * from renamed
