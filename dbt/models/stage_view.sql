-- {{ config(materialized='view', schema='temporal_us') }}

SELECT *
FROM `bigquery-public-data.iowa_liquor_sales.sales`
WHERE date >= '2023-01-01'
AND category_name LIKE '%GIN%'
