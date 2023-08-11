{% macro get_query_run_details() %}
 
{% set bq_project = 'go-cxb-bcx-data9-p02dt9p01-poc' %}
{% set bq_dataset = 'mpi_dbt_monitoring_metadata' %}
{% set bq_table = 'dbt_query_log' %}


INSERT INTO `{{ bq_project }}.{{ bq_dataset }}.{{ bq_table }}`

WITH sub AS (
    SELECT
        jobs.start_time AS job_start_DTS,
        jobs.project_id,
        jobs.user_email AS job_user,
        jobs.job_id,
        jobs.job_type AS job_nature,
        jobs.statement_type,
        jobs.error_result.reason AS err_reason,
        jobs.error_result.message AS err_message,
        jobs.query,
        lbls.value AS invocation_id,
        jobs.destination_table.table_id AS destination_table
    FROM
        `region-europe-southwest1.INFORMATION_SCHEMA.JOBS_BY_USER` jobs
        CROSS JOIN UNNEST(jobs.labels) AS lbls
    WHERE
        lbls.value = '{{ invocation_id }}'
        AND DATE(creation_time) >= CURRENT_DATE() - 1
)

SELECT * FROM sub;

{% endmacro %}