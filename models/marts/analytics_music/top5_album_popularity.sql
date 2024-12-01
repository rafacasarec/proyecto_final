with 
-- Álbumes más populares
top_albums as (
    select
        al.album_id,
        al.desc_album as album_title,
        listagg(distinct g.desc_genero, ', ') within group (order by g.desc_genero) as genres, -- Consolidar géneros
        sum(c.popularity) as album_popularity -- Sumar popularidad de todas las canciones del álbum
    from {{ ref('dim_album') }} al
    left join {{ ref('dim_cancion') }} c
        on al.album_id = c.album_id -- Relación álbum-canción
    left join {{ ref('dim_artista') }} a
        on c.artista_id = a.artista_id -- Relación canción-artista
    left join {{ ref('dim_genero') }} g
        on c.album_id = al.album_id -- Relación álbum-género
    where c.popularity is not null -- Aseguramos que la canción tiene popularidad válida
    group by al.album_id, al.desc_album
    order by album_popularity desc
    limit 5
)
select
    album_id as id_album,
    album_title,
    genres,
    album_popularity as popularity
from top_albums
