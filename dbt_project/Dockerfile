FROM python:3.10-slim

WORKDIR /usr/app

# Install git (often needed for dbt packages)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install dbt-trino
RUN pip install dbt-trino

# Copy project files
COPY . .

# Run dbt commands
CMD bash -c "dbt debug && dbt run && dbt test"
