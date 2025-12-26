FROM python:3.10-slim

WORKDIR /usr/app

# Install git (often needed for dbt packages)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install dbt-trino
RUN pip install dbt-trino

# Copy project files
COPY . .

# Keep container running for development
CMD ["tail", "-f", "/dev/null"]
