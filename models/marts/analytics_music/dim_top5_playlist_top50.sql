with 

-- Base del Top 50 con listas de IDs y nombres de artistas
base as (
    select 
        f.position,
        f.desc_song,
        split(f.artist_id, ',') as artist_id_list, -- Dividir IDs de artistas en lista
        split(f.artist_name, ',') as artist_name_list, -- Dividir nombres de artistas en lista
        f.album_id,
        f.desc_album,
        f.popularity,
        f.streams_estimated
    from 
        {{ ref('fct_top_50') }} f -- Ajustado a la referencia en marts
),

-- Expandir artistas en múltiples filas
expanded_artists as (
    select
        b.position,
        b.desc_song,
        b.artist_name_list[index] as artist_name, -- Extraer nombre del artista
        b.artist_id_list[index] as artist_id, -- Extraer ID del artista
        b.desc_album,
        b.popularity,
        b.streams_estimated
    from 
        base b,
        lateral flatten(input => b.artist_id_list) as index
),

-- Relacionar artistas con sus géneros
artists_with_genres as (
    select
        ea.position,
        ea.desc_song,
        ea.artist_name,
        ea.artist_id,
        ea.desc_album,
        ea.popularity,
        ea.streams_estimated,
        ag.genero as desc_genero -- Traer géneros desde la tabla de artistas
    from expanded_artists ea
    left join {{ ref('dim_artista') }} ag -- Ajustado a la referencia en marts
    on trim(ea.artist_id) = ag.artista_id
),

-- Consolidar artistas y géneros por canción
consolidated as (
    select 
        position,
        desc_song,
        listagg(distinct artist_name, ', ') within group (order by artist_name) as artists, -- Consolidar artistas
        desc_album,
        popularity,
        streams_estimated,
        listagg(distinct desc_genero, ', ') within group (order by desc_genero) as desc_genero -- Consolidar géneros
    from artists_with_genres
    group by 
        position, desc_song, desc_album, popularity, streams_estimated
),

-- Filtrar el Top 5
filtered as (
    select *
    from consolidated
    where position <= 5
),

-- Renombrar y enriquecer la salida
renamed as (
    select 
        position,
        desc_song as song_title,
        artists,
        desc_album as album_title,
        desc_genero,
        popularity,
        streams_estimated
    from filtered
    order by position
)

select 
    *
from renamed
