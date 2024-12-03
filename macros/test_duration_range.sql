{% test test_duration_range(model, column_name) %}
    WITH invalid_durations AS (
        SELECT *
        FROM {{ model }}
        WHERE {{ column_name }} NOT BETWEEN 30000 AND 1200000
    )
    SELECT COUNT(*) AS invalid_count
    FROM invalid_durations
{% endtest %}
