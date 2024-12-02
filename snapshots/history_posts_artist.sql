{% snapshot top50_snp%}

{{
    config(
        target_schema='snapshots',
        unique_key='track_id',
        strategy='timestamp',
        updated_at='timestamp'
    )
}}

SELECT
        playlist_id,
        fecha,
        timestamp,
        position,
        track_id,
        track_name,
        artist_id,
        artist_name,
        album_id,
        album_name,
        release_date,
        duration_ms,
        popularity,
        streams_estimados,
        _dlt_load_id,
        _dlt_id
FROM {{ source('top50_snp', 'fct_top_50') }}

{% endsnapshot %}