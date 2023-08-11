# ../sqltest.sql

# ver 0.0.1



{{ config(materialized='table') }}
WITH CTE AS (
     SELECT
      name AS nombres,
      COUNT(name) AS frecuencia,
        SUM(age) AS suma,
       MIN(age) AS joven,
       MAX(age) AS mayor

FROM
{{ source('data','py_data') }}

GROUP BY

 nombres

)

select * from CTE ORDER BY nombres