with 
-- Géneros más populares
top_genres as (
    select
        g.id_genero,
        g.desc_genero as genre,
        sum(a.popularity) as genre_popularity
    from {{ ref('dim_genero') }} g
    left join {{ ref('dim_artista') }} a
        on g.desc_genero = a.genero
    group by g.id_genero, g.desc_genero
    order by genre_popularity desc
    limit 5
)
select
    id_genero as id_genre,
    genre,
    genre_popularity as popularity
from top_genres
