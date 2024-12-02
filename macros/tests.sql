{% macro test_validate_song_vs_album_popularity(model, song_popularity_column, album_id_column, album_model, album_popularity_column) %}
    with 
    song_data as (
        select
            {{ song_popularity_column }} as song_popularity,
            {{ album_id_column }} as album_id
        from {{ model }}
    ),
    album_data as (
        select
            {{ album_popularity_column }} as album_popularity,
            id as album_id
        from {{ album_model }}
    ),
    validation as (
        select
            s.song_popularity,
            a.album_popularity,
            case
                when s.song_popularity > a.album_popularity then 'ERROR: Song popularity exceeds album popularity'
                else 'PASS'
            end as validation_status
        from song_data s
        left join album_data a
        on s.album_id = a.album_id
    )
    select *
    from validation
{% endmacro %}
