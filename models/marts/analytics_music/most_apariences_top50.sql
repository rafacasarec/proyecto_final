with 
-- Base normalizada desde stg_spotify__fct_top_50
top50 as (
    select * from {{ ref('fct_top_50') }}
),

split_artists as (
    select
        id_song,
        split(artist_id, ',') as artist_id_list,
        split(artist_name, ',') as artist_name_list,
        album_id,
        desc_album as album_title,
        position,
        _dlt_load_id,
        _dlt_id
    from top50
),

normalized as (
    select
        id_song,
        position,
        album_id,
        album_title,
        artist_id_list[index] as artist_id,
        artist_name_list[index] as artist_name
    from split_artists,
    lateral flatten(input => artist_id_list) as index
),

-- Contar las apariciones por género
genre_count as (
    select
        g.desc_genero as genre,
        count(*) as count_presence
    from normalized n
    left join {{ ref('dim_artista') }} a
        on n.artist_id = a.artista_id
    left join {{ ref('dim_genero') }} g
        on a.genero = g.desc_genero
    group by g.desc_genero
    order by count_presence desc
    limit 1 -- Tomar el género con mayor presencia
),

-- Contar las apariciones por artista
artist_count as (
    select
        n.artist_name,
        count(*) as count_presence
    from normalized n
    group by n.artist_name
    order by count_presence desc
    limit 1 -- Tomar el artista con mayor presencia
),

-- Contar las apariciones por álbum
album_count as (
    select
        n.album_title,
        count(*) as count_presence
    from normalized n
    group by n.album_title
    order by count_presence desc
    limit 1 -- Tomar el álbum con mayor presencia
)

-- Consolidar resultados
select 
    'Genre' as category,
    g.genre as value,
    g.count_presence as presence
from genre_count g

union all

select 
    'Artist' as category,
    a.artist_name as value,
    a.count_presence as presence
from artist_count a

union all

select 
    'Album' as category,
    al.album_title as value,
    al.count_presence as presence
from album_count al
