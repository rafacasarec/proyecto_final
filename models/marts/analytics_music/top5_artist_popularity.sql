with 
-- Artistas más populares
top_artists as (
    select
        a.artista_id,
        a.name_artist as artist,
        listagg(distinct g.desc_genero, ', ') within group (order by g.desc_genero) as genres, -- Consolidar géneros
        a.popularity as artist_popularity
    from {{ ref('dim_artista') }} a
    left join {{ ref('dim_genero') }} g
        on a.genero = g.desc_genero
    group by a.artista_id, a.name_artist, a.popularity
    order by a.popularity desc
    limit 5
)
select
    artista_id as id_artist,
    artist,
    genres,
    artist_popularity as popularity
from top_artists
