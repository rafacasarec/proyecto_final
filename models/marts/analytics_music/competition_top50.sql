with 
-- Filtrar el Top 5 del Top 50
top5 as (
    select
        position,
        split(artist_name, ',') as artist_name_list,
        desc_song as song_title,
        popularity as artist_popularity,
        streams_estimated,
        split(artist_id, ',') as artist_id_list
    from {{ ref('fct_top_50') }}
    where position <= 5
),

-- Normalizar artistas desde el Top 5
normalized_top5 as (
    select
        trim(a.value) as artist_name, -- Extraer nombres de artistas desde la lista
        trim(i.value) as artist_id,
        t.song_title,
        t.artist_popularity,
        t.position,
        t.streams_estimated
    from top5 t,
    lateral flatten(input => t.artist_name_list) as a,
    lateral flatten(input => t.artist_id_list) as i
),

-- Relacionar artistas del Top 5 con géneros y seguidores
top5_with_genres as (
    select
        t.artist_name,
        t.song_title,
        t.artist_popularity,
        t.position,
        t.streams_estimated,
        a.followers as artist_followers,
        a.genero
    from normalized_top5 t
    left join {{ ref('dim_artista') }} a
        on t.artist_id = a.artista_id
),

-- Obtener el competidor con más seguidores por género
top_competitor_by_genre as (
    select
        genero,
        name_artist as competitor_name,
        followers as competitor_followers,
        popularity as competitor_popularity
    from {{ ref('dim_competidores') }}
    where genero is not null
    qualify row_number() over (
        partition by genero
        order by followers desc
    ) = 1
),

-- Relacionar el competidor con los artistas del Top 5
joined_data as (
    select
        t.position,
        t.artist_name as top5_artist_name,
        t.song_title,
        t.artist_popularity as top5_popularity,
        t.artist_followers as top5_followers,
        t.genero,
        c.competitor_name,
        c.competitor_popularity,
        c.competitor_followers
    from top5_with_genres t
    left join top_competitor_by_genre c
        on t.genero = c.genero
),

-- Evitar géneros repetidos
unique_genres as (
    select 
        *,
        row_number() over (partition by genero order by position, top5_popularity desc) as genre_rank
    from joined_data
)

-- Seleccionar solo la primera aparición de cada género
select
    position,
    top5_artist_name,
    song_title,
    top5_popularity,
    top5_followers,
    genero,
    competitor_name,
    competitor_popularity,
    competitor_followers
from unique_genres
where genre_rank = 1
order by position, competitor_popularity desc
