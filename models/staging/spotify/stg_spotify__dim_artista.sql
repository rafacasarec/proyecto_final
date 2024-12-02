with 

source as (

    select * from {{ source('spotify', 'dim_artista') }}

),

renamed as (

    select
        nombre,
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as artist_id,
        case
            when trim(generos) = '' or generos is null then 'unknown'
            else generos
        end as desc_generos, -- Reemplaza valores nulos o vacíos por 'unknown'
        _dlt_load_id,
        _dlt_id
    from source

),

split_generos as (
    select
        nombre,
        artist_id,
        _dlt_load_id,
        _dlt_id,
        -- Dividir desc_generos en una lista
        split(desc_generos, ',') as genero_list
    from renamed
),

normalized as (
    select
        nombre,
        artist_id,
        _dlt_load_id,
        _dlt_id,
        trim(value) as genero -- Extraer y limpiar cada género
    from split_generos,
    lateral flatten(input => genero_list)
),

hashed as (
    select
        nombre,
        artist_id,
        _dlt_load_id,
        _dlt_id,
        genero,
        -- Generar un hash único para cada género
        {{ dbt_utils.generate_surrogate_key(['genero']) }} as genero_id
    from normalized
)

select
    nombre as name_artist,
    artist_id,
    _dlt_load_id,
    _dlt_id,
    genero,
    genero_id
from hashed
