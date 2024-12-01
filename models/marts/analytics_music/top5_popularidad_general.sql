with 
-- Canciones más populares
top_songs as (
    select
        c.cancion_id,
        c.desc_song as song_title,
        listagg(distinct a.name_artist, ', ') within group (order by a.name_artist) as artists, -- Consolidar artistas
        al.desc_album as album_title,
        listagg(distinct g.desc_genero, ', ') within group (order by g.desc_genero) as genres, -- Consolidar géneros
        c.popularity as song_popularity
    from {{ ref('dim_cancion') }} c
    left join {{ ref('dim_artista') }} a
        on c.artista_id = a.artista_id
    left join {{ ref('dim_album') }} al
        on c.album_id = al.album_id
    left join {{ ref('dim_genero') }} g
        on a.genero = g.desc_genero
    group by c.cancion_id, c.desc_song, al.desc_album, c.popularity
    order by c.popularity desc
    limit 5
),

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
),

-- Álbumes más populares (ajustado)
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
),

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

-- Consolidar el resultado final
select
    'Song' as category,
    t.song_title as title,
    t.artists as artist,
    t.album_title as album,
    t.genres as genre,
    t.song_popularity as popularity
from top_songs t

union all

select
    'Artist' as category,
    null as title,
    ta.artist as artist,
    null as album,
    ta.genres as genre,
    ta.artist_popularity as popularity
from top_artists ta

union all

select
    'Album' as category,
    null as title,
    null as artist,
    ta.album_title as album,
    ta.genres as genre,
    ta.album_popularity as popularity
from top_albums ta

union all

select
    'Genre' as category,
    null as title,
    null as artist,
    null as album,
    tg.genre as genre,
    tg.genre_popularity as popularity
from top_genres tg
