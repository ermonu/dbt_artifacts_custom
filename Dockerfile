FROM europe-west4-docker.pkg.dev/go-cxb-bcx-data9-p02dt9p01-poc/datanow-dbt-core/base:0.0.0

 

# Copy files to the image

WORKDIR /dbt/

COPY .  .

 

# Run dbt

ENTRYPOINT ["dbt"]