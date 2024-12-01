with 
-- Base del estatus desde redes sociales
estatus as (
    select
        artist_name,
        followers_insta,
        followers_X,
        desc_estatus
    from {{ ref('dim_artist_status') }}
),

-- Base del Top 50 desde Spotify
top50 as (
    select
        id_song,
        desc_song,
        position,
        split(artist_name, ',') as artist_name_list
    from {{ ref('fct_top_50') }}
),

-- Normalizar artistas desde Top 50
normalized_top50 as (
    select
        t.position,
        trim(a.value) as artist_name -- Extraer nombres de artistas desde la lista
    from top50 t,
    lateral flatten(input => t.artist_name_list) as a
),

-- Información de seguidores en Spotify desde dim_artista
spotify_followers as (
    select
        name_artist as artist_name,
        followers as spotify_followers
    from {{ ref('dim_artista') }}
),

-- Consolidar datos
consolidated as (
    select
        e.artist_name,
        e.followers_insta,
        e.followers_X,
        s.spotify_followers,
        e.desc_estatus,
        min(t.position) as top50_position -- Obtener la mejor posición en el Top 50
    from estatus e
    left join normalized_top50 t
        on lower(e.artist_name) = lower(t.artist_name) -- Relacionar por nombre del artista
    left join spotify_followers s
        on lower(e.artist_name) = lower(s.artist_name) -- Relacionar por nombre del artista
    group by e.artist_name, e.followers_insta, e.followers_X, s.spotify_followers, e.desc_estatus
)

select
    artist_name,
    followers_insta,
    followers_X,
    spotify_followers,
    desc_estatus,
    top50_position
from consolidated
order by desc_estatus desc
