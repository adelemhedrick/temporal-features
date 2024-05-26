from pyspark.sql import SparkSession
from pyspark.sql.functions import col, min, max, count, to_date, window, sum
from pyspark.sql.window import Window
import logging
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_temporal_features(data, columns, window_lengths, id_column, date_column):
    logger.info("[TRANSFORM_LOG] Starting create_temporal_features")
    logger.info(f"[TRANSFORM_LOG] Data columns: {data.columns}")
    logger.info(f"[TRANSFORM_LOG] Columns: {columns}, Window lengths: {window_lengths}, ID column: {id_column}, Date column: {date_column}")

    data = data.withColumn(date_column, to_date(col(date_column)))
    
    date_range = data.select(min(col(date_column)).alias("start_date"), max(col(date_column)).alias("end_date")).first()
    start_date, end_date = date_range.start_date.strftime('%Y-%m-%d'), date_range.end_date.strftime('%Y-%m-%d')
    all_dates = spark.sql(f"SELECT explode(sequence(to_date('{start_date}'), to_date('{end_date}'), interval 1 day)) as date")

    original_data = data

    for column in columns:
        logger.info(f"[TRANSFORM_LOG] Processing column: {column}")
        count_column_name = f'{column}_count'
        grouped_data = data.groupBy(column, date_column).agg(count(col(id_column)).alias(count_column_name))
        logger.info(f"[TRANSFORM_LOG] Grouped Data columns: {grouped_data.columns}")

        distinct_groups = grouped_data.select(column).distinct()
        full_group_dates = distinct_groups.crossJoin(all_dates)
        complete_data = full_group_dates.join(grouped_data, on=[column, date_column], how="left_outer")

        for window_length in window_lengths:
            window_spec = Window.partitionBy(column).orderBy(col(date_column)).rowsBetween(-window_length, -1)
            window_column_name = f'{column}_{window_length}d'
            complete_data = complete_data.withColumn(window_column_name, sum(col(count_column_name)).over(window_spec))


        complete_data = complete_data.drop(count_column_name)
        original_data = original_data.join(complete_data, on=[column, date_column], how='left')

    logger.info("[TRANSFORM_LOG] Finished create_temporal_features")
    return original_data

def model(dbt, session):
    dbt.config(materialized="table")

    data = dbt.ref('stage_table')

    columns = dbt.config.get('columns')
    window_lengths = dbt.config.get('window_lengths')
    id_column = dbt.config.get('id_column')
    date_column = dbt.config.get('date_column')
    
    transformed_df = create_temporal_features(data, columns, window_lengths, id_column, date_column)
    
    return transformed_df