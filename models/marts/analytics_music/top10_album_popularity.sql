WITH 

-- Álbumes más populares
top_albums AS (
    SELECT
        al.album_id AS id_album,
        al.desc_album AS album_title,
        LISTAGG(DISTINCT g.desc_genero, ', ') WITHIN GROUP (ORDER BY g.desc_genero) AS genres, -- Consolidar géneros
        SUM(c.popularity) AS album_popularity -- Sumar popularidad de todas las canciones del álbum
    FROM {{ ref('dim_album') }} al
    LEFT JOIN {{ ref('dim_cancion') }} c
        ON al.album_id = c.album_id -- Relación álbum-canción
    LEFT JOIN {{ ref('dim_artista') }} a
        ON c.artist_id = a.artist_id -- Relación canción-artista
    LEFT JOIN {{ ref('dim_genero') }} g
        ON a.genero = g.desc_genero -- Relación artista-género
    WHERE c.popularity IS NOT NULL -- Aseguramos que la canción tiene popularidad válida
    GROUP BY al.album_id, al.desc_album
    ORDER BY album_popularity DESC
    LIMIT 10 -- Los 10 álbumes más populares
)

-- Resultado final
SELECT
    id_album,
    album_title,
    genres,
    album_popularity AS popularity
FROM top_albums
