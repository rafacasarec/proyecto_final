{% test tests_popularidad(model, column_name) %}
    WITH invalid_values AS (
        SELECT *
        FROM {{ model }}
        WHERE {{ column_name }} NOT BETWEEN 0 AND 100
    )
    SELECT COUNT(*) AS invalid_count
    FROM invalid_values
{% endtest %}
