-- {{ config(materialized='table', schema='temporal') }}

SELECT *
FROM {{ ref('stage_view') }}