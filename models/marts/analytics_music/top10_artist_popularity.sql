WITH 

-- Relacionar fct_artista con dim_artista para obtener géneros
artists_with_genres AS (
    SELECT
        fa.artist_id AS id_artist,
        fa.nombre AS artist,
        fa.popularity AS artist_popularity,
        da.genero AS genre -- Género desde dim_artista
    FROM {{ ref('fct_artista') }} fa
    LEFT JOIN {{ ref('dim_artista') }} da
        ON fa.artist_id = da.artist_id -- Relación entre fct_artista y dim_artista
),

-- Consolidar géneros y calcular popularidad
top_artists AS (
    SELECT
        id_artist,
        artist,
        LISTAGG(DISTINCT genre, ', ') WITHIN GROUP (ORDER BY genre) AS genres, -- Consolidar géneros
        artist_popularity
    FROM artists_with_genres
    GROUP BY id_artist, artist, artist_popularity
    ORDER BY artist_popularity DESC -- Ordenar por popularidad
    LIMIT 10 -- Los 10 artistas más populares
)

-- Resultado final
SELECT
    id_artist,
    artist,
    genres,
    artist_popularity AS popularity
FROM top_artists
