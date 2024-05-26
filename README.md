# temporal-features

For this project, we will be using Google Big Query for our data source, and then do the transformations locally.

## Install required dbt tools

```
pip install dbt-core
pip install dbt-bigquery
sudo apt install postgresql postgresql-contrib
pip install dbt-postgres
```

## Populate postgres database from BigQuery

Run the shell script to run the python script in the scripts folder
`./setup_data.sh`

# Then run models to load data to PostgreSQL
dbt run --target local --select load_postgres
