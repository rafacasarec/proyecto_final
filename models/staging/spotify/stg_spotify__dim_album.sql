WITH source AS (

    SELECT * 
    FROM {{ source('spotify', 'dim_album') }}

),

renamed AS (

    SELECT
        album_id,
        titulo AS desc_album,
        artista_principal_id AS artista_id,
        artista_principal_name AS name_artist,
        DATE(fecha_lanzamiento) AS release_date,
        total_canciones AS total_songs,
        spotify_url,
        _dlt_load_id,
        _dlt_id
    FROM source

),

deduplicated AS (

    SELECT
        *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY desc_album ORDER BY _dlt_load_id) AS row_num
        FROM renamed
    ) 
    WHERE row_num = 1

)

SELECT 
    album_id,
    desc_album,
    artista_id,
    name_artist,
    release_date,
    total_songs,
    spotify_url,
    _dlt_load_id,
    _dlt_id
FROM deduplicated

