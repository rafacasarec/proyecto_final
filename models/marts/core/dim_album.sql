WITH album AS (

    SELECT * 
    FROM {{ ref('stg_spotify__dim_album') }}

),

renamed AS (

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
    FROM album

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

