WITH 

-- Base normalizada desde fct_top_50
top50 AS (
    SELECT * 
    FROM {{ ref('fct_top_50') }}
),

-- Expandir artistas en filas y normalizar datos
split_artists AS (
    SELECT
        playlist_id,
        fecha,
        date,
        position,
        song_id, -- Corregido: `song_id` es el nombre correcto en fct_top_50
        desc_song AS song_title,
        SPLIT(artist_id, ',') AS artist_id_list,
        SPLIT(artist_name, ',') AS artist_name_list,
        album_id,
        desc_album AS album_title,
        DATE(release_date) AS release_date,
        duration_ms,
        popularity,
        streams_estimated,
        _dlt_load_id,
        _dlt_id
    FROM top50
),

-- Normalizar los datos con artistas en filas
normalized AS (
    SELECT
        playlist_id,
        fecha,
        date,
        position,
        song_id,
        song_title,
        album_id,
        album_title,
        release_date,
        duration_ms,
        popularity,
        streams_estimated,
        _dlt_load_id,
        _dlt_id,
        TRIM(artist_id_list[index]) AS artist_id,
        TRIM(artist_name_list[index]) AS artist_name
    FROM split_artists,
    LATERAL FLATTEN(input => artist_id_list) AS index
),

-- Consolidar información por canción
aggregated AS (
    SELECT
        song_id,
        song_title,
        LISTAGG(DISTINCT artist_name, ', ') WITHIN GROUP (ORDER BY artist_name) AS artists, -- Consolidar artistas
        album_title,
        MAX(popularity) AS song_popularity, -- Popularidad de la canción
        SUM(streams_estimated) AS total_streams, -- Sumar streams estimados
        MIN(position) AS min_position -- Mejor posición de la canción en el Top 50
    FROM normalized
    GROUP BY song_id, song_title, album_title
),

-- Seleccionar las 10 canciones más populares
top_songs AS (
    SELECT *
    FROM aggregated
    ORDER BY song_popularity DESC -- Ordenar por popularidad
    LIMIT 10 -- Seleccionar las 10 canciones más populares
)

-- Resultado final
SELECT
    song_id AS id_song,
    song_title,
    artists,
    album_title,
    song_popularity AS popularity,
    total_streams AS streams_estimated,
    min_position AS position -- Mostrar la mejor posición de cada canción en el Top 50
FROM top_songs
ORDER BY popularity DESC
