with 

source as (
    select * from {{ ref('stg_fct_artista') }} -- Referencia al modelo en staging
),

renamed as (

    select
        nombre,
        artist_id,
        followers,
        popularity
    from source
)

select * from renamed
