# Temporal Features Creation Project

## Overview

This project leverages PySpark, DBT, and Terraform to build a robust data processing pipeline that generates temporal features from structured data. The primary functionality revolves around enhancing datasets with calculated temporal aggregates, which are crucial for time-series analyses and predictive modeling. By applying rolling window calculations and aggregations based on configurable window lengths, this project provides a dynamic way to extract insightful features from date-indexed data.

### Why is this Valuable?

Temporal features are invaluable for understanding trends over time, predicting future values, and detecting anomalies. By systematically transforming time-stamped data into features that capture trends, seasonality, and cycles, businesses can improve decision-making processes and build more accurate predictive models.

## Prerequisites
Ensure you have the following installed to use this project effectively:

Python 3.6+
Apache Spark 2.4+ or 3.x
DBT (Data Build Tool)
Terraform 0.14+
An initialized backend (e.g., AWS, GCP, or Azure) for Terraform
Setup Instructions
Clone the Repository
Start by cloning this repository to your local machine:

## Setting Up Terraform
Navigate to the `terraform` directory and initialize Terraform to set up the infrastructure:

```
cd terraform
terraform init
terraform apply
```

## Configuring DBT
Switch to the `dbt` directory and run:

```
cd dbt
dbt run
```

## Change The Dataset

Right now the `dbt/models/stage_view.sql` takes some data from a public dataset for this example. Feel free to modify that to your use case, and update the `dbt/dbt_project.yml` to add the required meta data and configuration of temporal features you would like to create!

![DBT Diagram](assets/dbt_diagram.png)

## Contact
If you have any questions, please open an issue or contact the repository owner!