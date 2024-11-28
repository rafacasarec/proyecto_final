with 

source as (

    select * from {{ source('spotify', 'dim_artista') }}

),

renamed as (

    select
        artista_id,
        nombre as name_artist,
        case
            when trim(generos) = '' or generos is null then 'unknown'
            else generos
        end as desc_generos, -- Reemplaza valores nulos o vacíos por 'unknown'
        seguidores as followers,
        popularidad as popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id
    from source

),

split_generos as (
    select
        artista_id,
        name_artist,
        followers,
        popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,
        -- Dividir desc_generos en una lista
        split(desc_generos, ',') as genero_list
    from renamed
),

normalized as (
    select
        artista_id,
        name_artist,
        followers,
        popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,
        trim(value) as genero -- Extraer y limpiar cada género
    from split_generos,
    lateral flatten(input => genero_list)
),

hashed as (
    select
        artista_id,
        name_artist,
        followers,
        popularity,
        spotify_url,
        _dlt_load_id,
        _dlt_id,
        genero,
        -- Generar un hash único para cada género
        {{ dbt_utils.generate_surrogate_key(['genero']) }} as genero_id
    from normalized
)

select
    artista_id,
    name_artist,
    followers,
    popularity,
    spotify_url,
    _dlt_load_id,
    _dlt_id,
    genero,
    genero_id
from hashed
