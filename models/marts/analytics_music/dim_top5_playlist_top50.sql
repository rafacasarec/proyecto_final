WITH 

-- Base del Top 50 con listas de IDs y nombres de artistas
base AS (
    SELECT 
        f.position,
        f.desc_song,
        SPLIT(f.artist_id, ',') AS artist_id_list, -- Dividir IDs de artistas en lista
        SPLIT(f.artist_name, ',') AS artist_name_list, -- Dividir nombres de artistas en lista
        f.album_id,
        f.desc_album,
        f.popularity,
        f.streams_estimated
    FROM 
        {{ ref('fct_top_50') }} f
),

-- Expandir artistas en múltiples filas
expanded_artists AS (
    SELECT
        b.position,
        b.desc_song,
        b.artist_name_list[index] AS artist_name, -- Extraer nombre del artista
        b.artist_id_list[index] AS artist_id, -- Extraer ID del artista
        b.desc_album,
        b.popularity,
        b.streams_estimated
    FROM 
        base b,
        LATERAL FLATTEN(input => b.artist_id_list) AS index
),

-- Relacionar artistas con sus géneros
artists_with_genres AS (
    SELECT
        ea.position,
        ea.desc_song,
        ea.artist_name,
        ea.artist_id,
        ea.desc_album,
        ea.popularity,
        ea.streams_estimated,
        ag.genero AS desc_genero -- Traer géneros desde la tabla de artistas
    FROM expanded_artists ea
    LEFT JOIN {{ ref('dim_artista') }} ag
    ON TRIM(ea.artist_id) = ag.artist_id
),

-- Consolidar artistas y géneros por canción
consolidated AS (
    SELECT 
        position,
        desc_song,
        LISTAGG(DISTINCT artist_name, ', ') WITHIN GROUP (ORDER BY artist_name) AS artists, -- Consolidar artistas
        desc_album,
        popularity,
        streams_estimated,
        LISTAGG(DISTINCT desc_genero, ', ') WITHIN GROUP (ORDER BY desc_genero) AS desc_genero -- Consolidar géneros
    FROM artists_with_genres
    GROUP BY 
        position, desc_song, desc_album, popularity, streams_estimated
),

-- Filtrar el Top 5
filtered AS (
    SELECT *
    FROM consolidated
    WHERE position <= 10
),

-- Renombrar y enriquecer la salida
renamed AS (
    SELECT 
        position,
        desc_song AS song_title,
        artists,
        desc_album AS album_title,
        desc_genero,
        popularity,
        streams_estimated
    FROM filtered
    ORDER BY position
)

SELECT 
    *
FROM renamed
