{{config(
    schema = 'mpi_metadata',

    materialized = 'table',

    pre_hook="""create or replace table `go-cxb-bcx-data9-p02dt9p01-poc.mpi_metadata.prueba_ddl` (id_prueba INTEGER, desc_prueba STRING, fe_prueba DATE);""",

    persist_docs={"relation": true, "columns": true}

) }}

 

select * from `go-cxb-bcx-data9-p02dt9p01-poc.mpi_metadata.prueba_ddl`