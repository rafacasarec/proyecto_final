{% test test_valid_url_format(model, column_name) %}
    WITH invalid_urls AS (
        SELECT *
        FROM {{ model }}
        WHERE {{ column_name }} NOT LIKE 'https://%'
    )
    SELECT COUNT(*) AS invalid_count
    FROM invalid_urls
{% endtest %}
