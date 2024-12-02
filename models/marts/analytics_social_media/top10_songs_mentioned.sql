with 

-- Base de menciones de canciones
posts_songs as (
    select
        lower(trim(mentioned_song)) as song_title,
        count(*) as total_mentions
    from {{ ref('dim_posts_songs') }}
    where 
        lower(trim(mentioned_song)) not in ('no song mentioned on text', '', 'who') -- Excluir menciones irrelevantes
    group by lower(trim(mentioned_song))
),

-- Base del Top 50
top50 as (
    select
        song_id,
        lower(trim(desc_song)) as song_title,
        position as top_position,
        streams_estimated
    from {{ ref('fct_top_50') }}
),

-- Combinar datos de menciones con estadísticas del Top 50
final_data as (
    select
        p.song_title,
        sum(p.total_mentions) as total_mentions, -- Asegurar suma de menciones en caso de duplicados
        coalesce(t.top_position, -1) as top_position, -- Usar -1 como indicador de "No en el Top 50"
        coalesce(t.streams_estimated, 0) as total_streams -- Usar 0 si no tiene streams
    from posts_songs p
    left join top50 t
        on lower(p.song_title) = lower(t.song_title)
    group by p.song_title, t.top_position, t.streams_estimated
    order by total_mentions desc
    limit 10
),

-- Convertir el indicador numérico de posición en un string para facilitar la lectura
final_output as (
    select
        song_title,
        total_mentions,
        case 
            when top_position = -1 then 'Not in Top 50'
            else cast(top_position as string)
        end as top_position,
        total_streams
    from final_data
)

select *
from final_output
