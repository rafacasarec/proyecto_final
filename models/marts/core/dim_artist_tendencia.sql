with 

tendencia as (

    select * from {{ ref('stg_redes_sociales__tendencia') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['desc_tendencia']) }} as id_tendencia,
        desc_tendencia,
        first_name,
        social_improve,
    from tendencia

)

select * from renamed
