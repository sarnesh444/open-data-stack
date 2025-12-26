# Superset Documentation (`superset`)

This folder contains configuration and build files for Apache Superset.

## `Dockerfile`

Custom image definition to include necessary drivers.

```dockerfile
FROM apache/superset:latest        # Base official Superset image

USER root                          # Switch to root to install packages

# Install pip (bootstrap) and then install drivers
# psycopg2-binary: Driver for Postgres (metadata DB)
# trino: Driver for Trino (data source)
RUN /app/.venv/bin/python -m ensurepip && \
    /app/.venv/bin/python -m pip install psycopg2-binary trino

USER superset                      # Switch back to superset user for security
```

## `superset_config.py`

Python configuration file for Superset application settings.

```python
# ...
SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://superset:superset@postgres:5432/superset'
# Connection string for Superset's internal metadata database (Postgres).

CACHE_CONFIG = { ... }
# Configures Redis as the caching backend to speed up queries/dashboards.

ENABLE_CORS = True
# Enables Cross-Origin Resource Sharing (useful for development/embedding).
```

## `docker-init.sh`

Shell script to initialize the Superset application on first run.

```bash
#!/bin/bash
set -e

# Upgrades the metadata database schema to the latest version
superset db upgrade

# Creates the default admin user
superset fab create-admin \
    --username admin \
    --firstname Superset \
    --lastname Admin \
    --email admin@superset.com \
    --password admin

# Initializes roles and permissions
superset init
```
