WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="'2000-01-01 00:00:00'::timestamp",
        end_date="'2024-12-31 23:00:00'::timestamp"
    ) }}
)

SELECT
    date_day AS datetime,
    DATE(date_day) AS date,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(MONTH FROM date_day) AS month,
    EXTRACT(DAY FROM date_day) AS day,
    EXTRACT(DOW FROM date_day) AS day_of_week,
    TO_CHAR(date_day, 'Month') AS month_name
FROM date_spine