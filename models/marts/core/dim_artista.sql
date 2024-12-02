with 

source as (
    select * from {{ ref('stg_spotify__dim_artista') }} -- Referencia al modelo en staging
),

split_generos as (
    select
        artist_id,
        name_artist, -- Nombre correcto desde staging
        _dlt_load_id,
        _dlt_id,
        -- Dividir generos en una lista (ajustado a lo que debería venir de staging)
        split(genero, ',') as genero_list -- Ajusta "genero" al nombre correcto de la columna en staging
    from source
),

normalized as (
    select
        artist_id,
        name_artist,
        _dlt_load_id,
        _dlt_id,
        trim(value) as genero -- Extraer y limpiar cada género
    from split_generos,
    lateral flatten(input => genero_list)
),

hashed as (
    select
        artist_id,
        name_artist,
        _dlt_load_id,
        _dlt_id,
        genero,
        -- Generar un hash único para cada género
        {{ dbt_utils.generate_surrogate_key(['genero']) }} as genero_id
    from normalized
)

select
    artist_id,
    name_artist,
    _dlt_load_id,
    _dlt_id,
    genero,
    genero_id
from hashed
