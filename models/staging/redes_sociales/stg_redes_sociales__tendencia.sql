with 

base_orders as (

    select * from {{ ref('base_redes_sociales__resultados_rrss') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['desc_tendencia']) }} as id_tendencia,
        desc_tendencia,
        first_name,
        {{ dbt_utils.generate_surrogate_key(['first_name']) }} as artist_id,
        social_improve
    from base_orders

)

select * from renamed
