# dbt Project Documentation (`dbt_project`)

This folder contains the dbt (data build tool) project for transforming data in Trino.

## `dbt_project.yml`

The main configuration file for the dbt project.

```yaml
name: 'my_dbt_project'             # Project name
version: '1.0.0'
config-version: 2

profile: 'trino_profile'           # Name of the profile to use in profiles.yml

model-paths: ["models"]            # Directory containing SQL models
# ... (other paths)

models:
  my_dbt_project:
    +materialized: table           # Default materialization: create tables (not views)
```

## `profiles.yml`

Configures the connection to the database (Trino).

```yaml
trino_profile:                     # Profile name (matches dbt_project.yml)
  target: dev                      # Default target
  outputs:
    dev:
      type: trino                  # Adapter type
      method: none                 # No special auth method (relies on network access)
      user: dbt_user               # User to connect as
      host: trino                  # Hostname (service name in docker-compose)
      port: 8080                   # Trino port
      catalog: iceberg             # Catalog to use
      schema: test_schema          # Default schema for models
      threads: 1                   # Number of concurrent threads
```

## `Dockerfile`

Defines the environment for running dbt.

```dockerfile
FROM python:3.10-slim              # Base Python image

WORKDIR /usr/app                   # Working directory inside container

# Install git (required for some dbt packages)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install dbt-trino adapter
RUN pip install dbt-trino

# Copy project files into container
COPY . .

# Keep container running so we can exec into it
CMD ["tail", "-f", "/dev/null"]
```

## `models/first_model.sql`

A sample dbt model.

```sql
select '1' as test_col_num, 'check' as test_col_str
```
*   Compiles to a `CREATE TABLE AS SELECT` statement in Trino.
*   Creates a table `iceberg.test_schema.first_model` with the selected data.
