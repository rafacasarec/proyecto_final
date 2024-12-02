WITH 

-- Relacionar fct_artista con dim_artista para obtener los géneros
artists_with_genres AS (
    SELECT
        fa.artist_id,
        fa.popularity,
        da.genero AS genre -- Obtenemos el género desde dim_artista
    FROM {{ ref('fct_artista') }} fa
    LEFT JOIN {{ ref('dim_artista') }} da
        ON fa.artist_id = da.artist_id -- Relación entre fct_artista y dim_artista
),

-- Calcular la popularidad por género
top_genres AS (
    SELECT
        g.id_genero AS id_genre,
        g.desc_genero AS genre,
        SUM(ag.popularity) AS genre_popularity -- Sumar la popularidad de los artistas asociados al género
    FROM {{ ref('dim_genero') }} g
    LEFT JOIN artists_with_genres ag
        ON g.desc_genero = ag.genre -- Relación entre dim_genero y géneros obtenidos de dim_artista
    GROUP BY g.id_genero, g.desc_genero
    ORDER BY genre_popularity DESC -- Ordenar por popularidad
    LIMIT 10 -- Seleccionar los 10 géneros más populares
)

-- Resultado final
SELECT
    id_genre,
    genre,
    genre_popularity AS popularity
FROM top_genres
