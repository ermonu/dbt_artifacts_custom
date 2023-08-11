{% macro create_table_log() %}

 {% set bq_project = 'go-cxb-bcx-data9-p02dt9p01-poc' %}
 {% set bq_dataset = 'mpi_dbt_monitoring_metadata' %}
 {% set bq_table = 'dbt_query_log' %}

 {% set create_table %}
  CREATE TABLE IF NOT EXISTS `{{ bq_project }}.{{ bq_dataset }}.{{ bq_table }}` (
       job_start_DTS TIMESTAMP,
       project_id STRING,
       job_user STRING,
       job_id STRING,
       job_nature STRING,
       statement_type STRING,
       err_reason STRING,
       err_message STRING,
       query STRING,
       invocation_id STRING,
       destination_table STRING
  );
  {% endset %}
  {% do run_query(create_table) %}
{% endmacro %}
