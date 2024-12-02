WITH 

-- Base de menciones de artistas
posts_artists AS (
    SELECT
        LOWER(TRIM(mentioned_artist)) AS artist_name,
        COUNT(*) AS total_mentions
    FROM {{ ref('dim_posts_artistas') }}
    WHERE 
        LOWER(TRIM(mentioned_artist)) NOT IN ('no artist mentioned on text', '', 'unknown') -- Excluir menciones irrelevantes
    GROUP BY LOWER(TRIM(mentioned_artist))
),

-- Base del Top 50 con artistas normalizados
top50 AS (
    SELECT
        song_id,
        LOWER(TRIM(desc_song)) AS song_title,
        position AS song_position,
        SPLIT(artist_name, ',') AS artist_name_list
    FROM {{ ref('fct_top_50') }}
),

-- Expandir artistas del Top 50
normalized_top50 AS (
    SELECT
        TRIM(LOWER(a.value)) AS artist_name,
        t.song_id,
        t.song_title,
        t.song_position
    FROM top50 t,
    LATERAL FLATTEN(input => t.artist_name_list) AS a
),

-- Popularidad de artistas
artist_popularity AS (
    SELECT
        LOWER(TRIM(nombre)) AS artist_name,
        MAX(popularity) AS artist_popularity
    FROM {{ ref('fct_artista') }}
    GROUP BY LOWER(TRIM(nombre))
),

-- Obtener la mejor posición por artista en el Top 50
best_song_per_artist AS (
    SELECT
        nt.artist_name,
        MIN(nt.song_position) AS best_song_position, -- Mejor posición del artista en el Top 50
        ANY_VALUE(nt.song_title) AS best_song_title -- Título de la canción en esa posición
    FROM normalized_top50 nt
    GROUP BY nt.artist_name
),

-- Combinar menciones con datos de popularidad y posición
final_data AS (
    SELECT
        p.artist_name,
        SUM(p.total_mentions) AS total_mentions,
        COALESCE(b.best_song_position, -1) AS top_song_position, -- Usar -1 si no está en el Top 50
        COALESCE(b.best_song_title, 'No Song Found') AS top_song_title, -- Manejar casos sin canciones
        COALESCE(ap.artist_popularity, 0) AS artist_popularity -- Popularidad del artista
    FROM posts_artists p
    LEFT JOIN best_song_per_artist b
        ON p.artist_name = b.artist_name
    LEFT JOIN artist_popularity ap
        ON p.artist_name = ap.artist_name
    GROUP BY p.artist_name, b.best_song_position, b.best_song_title, ap.artist_popularity
    ORDER BY total_mentions DESC
    LIMIT 10
),

-- Convertir indicadores numéricos a texto para facilitar la lectura
final_output AS (
    SELECT
        artist_name,
        total_mentions,
        artist_popularity,
        CASE 
            WHEN top_song_position = -1 THEN 'Not in Top 50'
            ELSE CAST(top_song_position AS STRING)
        END AS top_song_position,
        top_song_title
    FROM final_data
)

SELECT *
FROM final_output
