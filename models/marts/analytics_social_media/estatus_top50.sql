WITH 

-- Base del estatus desde dim_artist_status
estatus AS (
    SELECT
        first_name,
        followers_insta,
        followers_X,
        desc_estatus
    FROM {{ ref('dim_artist_status') }}
),

-- Base del Top 50 desde fct_top_50
top50 AS (
    SELECT
        song_id,
        desc_song,
        position,
        SPLIT(artist_name, ',') AS artist_name_list
    FROM {{ ref('fct_top_50') }}
),

-- Normalizar artistas desde Top 50
normalized_top50 AS (
    SELECT
        t.position,
        TRIM(a.value) AS artist_name -- Extraer nombres de artistas desde la lista
    FROM top50 t,
    LATERAL FLATTEN(input => t.artist_name_list) AS a
),

-- Información de seguidores en Spotify desde fct_artista
spotify_followers AS (
    SELECT
        nombre AS artist_name, -- Corregido: el nombre del artista está en `nombre`
        followers AS spotify_followers
    FROM {{ ref('fct_artista') }}
),

-- Consolidar datos
consolidated AS (
    SELECT
        e.first_name,
        e.followers_insta,
        e.followers_X,
        s.spotify_followers,
        e.desc_estatus,
        MIN(t.position) AS top50_position -- Obtener la mejor posición en el Top 50
    FROM estatus e
    LEFT JOIN normalized_top50 t
        ON LOWER(e.first_name) = LOWER(t.artist_name) -- Relacionar por nombre del artista
    LEFT JOIN spotify_followers s
        ON LOWER(e.first_name) = LOWER(s.artist_name) -- Relacionar por nombre del artista
    GROUP BY e.first_name, e.followers_insta, e.followers_X, s.spotify_followers, e.desc_estatus
)

-- Resultado final
SELECT
    first_name,
    followers_insta,
    followers_X,
    spotify_followers,
    desc_estatus,
    top50_position
FROM consolidated
ORDER BY desc_estatus DESC
