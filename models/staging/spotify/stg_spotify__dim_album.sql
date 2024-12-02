WITH source AS (

    SELECT * 
    FROM {{ source('spotify', 'dim_album') }}

),

renamed AS (

    SELECT
        album_id,
        titulo AS desc_album,
        {{ dbt_utils.generate_surrogate_key(['artista_principal_name']) }} as artist_id,
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
    artist_id,
    name_artist,
    release_date,
    total_songs,
    spotify_url,
    _dlt_load_id,
    _dlt_id
FROM deduplicated

