WITH 
-- Base del Top 50
top50 AS (
    SELECT
        position,
        split(artist_name, ',') AS artist_name_list,
        desc_song AS song_title,
        popularity AS artist_popularity,
        streams_estimated,
        split(artist_id, ',') AS artist_id_list
    FROM {{ ref('fct_top_50') }}
),

-- Normalizar artistas desde el Top 50
normalized_top50 AS (
    SELECT
        t.position,
        trim(a.value) AS artist_name, -- Extraer nombres de artistas desde la lista
        trim(i.value) AS artist_id,
        t.song_title,
        t.artist_popularity,
        t.streams_estimated
    FROM top50 t,
    LATERAL FLATTEN(input => t.artist_name_list) AS a,
    LATERAL FLATTEN(input => t.artist_id_list) AS i
    WHERE a.index = i.index -- Relacionar correctamente nombres e IDs
),

-- Relacionar artistas del Top 50 con géneros desde `dim_artista` y seguidores desde `fct_artista`
top50_with_genres AS (
    SELECT DISTINCT
        t.position,
        t.artist_name,
        t.artist_id,
        t.song_title,
        t.artist_popularity,
        t.streams_estimated,
        COALESCE(f.followers, 0) AS artist_followers, -- Manejar valores nulos en seguidores
        COALESCE(a.genero, 'unknown') AS genre -- Manejar valores nulos en géneros
    FROM normalized_top50 t
    LEFT JOIN {{ ref('dim_artista') }} a
        ON t.artist_id = a.artist_id
    LEFT JOIN {{ ref('fct_artista') }} f
        ON t.artist_id = f.artist_id
),

-- Obtener los 10 últimos géneros únicos del Top 50
last_10_genres AS (
    SELECT DISTINCT
        genre,
        MAX(position) AS max_position -- Aseguramos que podemos ordenar por posición
    FROM top50_with_genres
    WHERE genre IS NOT NULL AND genre != 'unknown' -- Excluir géneros nulos o desconocidos
    GROUP BY genre
    ORDER BY max_position DESC
    LIMIT 10
),

-- Obtener el competidor con más seguidores por género desde `dim_competidores`
top_competitors AS (
    SELECT
        genero AS genre,
        name_artist AS competitor_name,
        followers AS competitor_followers,
        popularity AS competitor_popularity
    FROM {{ ref('dim_competidores') }}
    WHERE genero IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY genero
        ORDER BY followers DESC
    ) = 1
),

-- Relacionar competidores con los géneros del Top 50
joined_data AS (
    SELECT DISTINCT
        g.genre,
        c.competitor_name,
        c.competitor_followers,
        c.competitor_popularity,
        t.artist_name AS top50_artist_name,
        t.artist_popularity AS top50_artist_popularity,
        t.artist_followers AS top50_artist_followers,
        t.song_title AS top50_song_title,
        t.position AS top50_position
    FROM last_10_genres g
    LEFT JOIN top_competitors c
        ON LOWER(g.genre) = LOWER(c.genre)
    LEFT JOIN top50_with_genres t
        ON LOWER(g.genre) = LOWER(t.genre)
),

-- Filtrar para evitar canciones repetidas
unique_songs AS (
    SELECT DISTINCT
        genre,
        competitor_name,
        competitor_followers,
        competitor_popularity,
        top50_artist_name,
        top50_artist_popularity,
        top50_artist_followers,
        top50_song_title,
        top50_position,
        ROW_NUMBER() OVER (PARTITION BY top50_artist_name ORDER BY top50_position ASC) AS song_rank
    FROM joined_data
)

-- Seleccionar solo una canción por artista
SELECT 
    genre,
    competitor_name,
    competitor_followers,
    competitor_popularity,
    top50_artist_name,
    top50_artist_popularity,
    top50_artist_followers,
    top50_song_title,
    top50_position
FROM unique_songs
WHERE song_rank = 1
ORDER BY top50_position ASC
