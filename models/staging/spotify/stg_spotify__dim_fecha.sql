with 

source as (

    select * from {{ source('spotify', 'dim_fecha') }}

),

renamed as (

    select
        fecha,
        dia,
        mes,
        nombre_mes,
        a_o,
        trimestre,
        dia_semana,
        es_fin_semana,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed
