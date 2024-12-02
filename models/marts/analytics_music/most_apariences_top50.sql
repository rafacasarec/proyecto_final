WITH 

-- Base del Top 50
top50 AS (
    SELECT *
    FROM {{ ref('fct_top_50') }}
),

-- Dividir artistas en múltiples filas
split_artists AS (
    SELECT
        song_id,
        SPLIT(artist_id, ',') AS artist_id_list,
        SPLIT(artist_name, ',') AS artist_name_list,
        album_id,
        desc_album AS album_title,
        position
    FROM top50
),

normalized AS (
    SELECT
        song_id,
        position,
        album_id,
        album_title,
        artist_id_list[index] AS artist_id,
        artist_name_list[index] AS artist_name
    FROM split_artists,
    LATERAL FLATTEN(input => artist_id_list) AS index
),

-- Revisar si hay géneros nulos
genre_check AS (
    SELECT
        n.artist_id,
        a.genero AS genre_in_artista,
        g.desc_genero AS genre_in_genero
    FROM normalized n
    LEFT JOIN {{ ref('dim_artista') }} a
        ON TRIM(n.artist_id) = a.artist_id
    LEFT JOIN {{ ref('dim_genero') }} g
        ON TRIM(a.genero) = g.desc_genero
),

-- Contar las apariciones por género
genre_count AS (
    SELECT
        genre_in_genero AS genre,
        COUNT(*) AS count_presence
    FROM genre_check
    WHERE genre_in_genero IS NOT NULL -- Asegurarse de excluir valores nulos
    GROUP BY genre_in_genero
    ORDER BY count_presence DESC
    LIMIT 1
),

-- Contar las apariciones por artista
artist_count AS (
    SELECT
        n.artist_name,
        COUNT(*) AS count_presence
    FROM normalized n
    GROUP BY n.artist_name
    ORDER BY count_presence DESC
    LIMIT 1
),

-- Contar las apariciones por álbum
album_count AS (
    SELECT
        n.album_title,
        COUNT(*) AS count_presence
    FROM normalized n
    GROUP BY n.album_title
    ORDER BY count_presence DESC
    LIMIT 1
)

-- Consolidar resultados
SELECT 
    'Genre' AS category,
    g.genre AS value,
    g.count_presence AS presence
FROM genre_count g

UNION ALL

SELECT 
    'Artist' AS category,
    a.artist_name AS value,
    a.count_presence AS presence
FROM artist_count a

UNION ALL

SELECT 
    'Album' AS category,
    al.album_title AS value,
    al.count_presence AS presence
FROM album_count al
