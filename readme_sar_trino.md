# Root Directory Documentation (`sar_trino`)

This folder contains the core orchestration files for the entire data stack.

## `docker-compose.yml`

This file defines the multi-container application services.

```yaml
services:
  trino:
    image: trinodb/trino:latest  # Uses the official Trino image
    container_name: trino         # Names the container 'trino' for easy reference
    ports:
      - "8080:8080"               # Maps host port 8080 to container port 8080 (Trino UI/API)
    volumes:
      - ./etc/trino:/etc/trino    # Mounts local config files to the container's config dir
    environment:                  # Passes AWS credentials from .env to the container
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}

  dbt:
    build: ./dbt_project          # Builds the dbt image from the ./dbt_project directory
    volumes:
      - ./dbt_project:/usr/app    # Mounts local dbt project code for live editing
    depends_on:
      - trino                     # Ensures dbt starts after Trino

  redis:
    image: redis:7                # Uses Redis 7 for Superset caching
    container_name: superset_cache
    restart: unless-stopped       # Auto-restart if it crashes
    volumes:
      - redis_data:/data          # Persists Redis data to a Docker volume

  postgres:
    image: postgres:15            # Uses Postgres 15 for Superset metadata
    container_name: superset_db
    restart: unless-stopped
    volumes:
      - db_home:/var/lib/postgresql/data # Persists DB data to a Docker volume
    environment:
      POSTGRES_DB: superset       # Creates 'superset' database
      POSTGRES_USER: superset     # Sets username
      POSTGRES_PASSWORD: superset # Sets password

  superset:
    build: ./superset             # Builds custom Superset image (with drivers)
    container_name: superset
    restart: unless-stopped
    ports:
      - "8088:8088"               # Maps host port 8088 to Superset UI
    depends_on:                   # Startup order dependencies
      superset-init:
        condition: service_completed_successfully # Waits for init script to finish
      postgres:
        condition: service_started
      redis:
        condition: service_started
    environment:
      SUPERSET_CONFIG_PATH: /app/superset_config.py # Points to config file
    volumes:
      - ./superset/superset_config.py:/app/superset_config.py # Mounts config file

  superset-init:
    build: ./superset             # Uses same image as superset service
    container_name: superset_init
    depends_on:
      - postgres
      - redis
    environment:
      SUPERSET_CONFIG_PATH: /app/superset_config.py
    volumes:
      - ./superset/superset_config.py:/app/superset_config.py
      - ./superset/docker-init.sh:/app/docker-init.sh # Mounts init script
    command: ["/app/docker-init.sh"] # Runs the initialization script
    user: "root"                  # Runs as root to ensure permissions (if needed)

volumes:
  redis_data:                     # Named volume for Redis persistence
  db_home:                        # Named volume for Postgres persistence
```

## `.env`

Stores environment variables (secrets).

```bash
AWS_ACCESS_KEY_ID=...     # AWS Access Key for S3/Glue access
AWS_SECRET_ACCESS_KEY=... # AWS Secret Key
AWS_REGION=...            # AWS Region (e.g., us-east-1)
```

## `.gitignore`

Specifies files to ignore in git.

```
.env  # Ignores the secrets file so it's not committed
```
