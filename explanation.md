# Trino Configuration Explanation

This document explains the purpose of each file in the Trino setup and details every parameter used.

## 1. `docker-compose.yml`

**Purpose**: Orchestrates the Trino container service.

*   **`services`**: Defines the list of containers to run.
*   **`trino`**: The name of our service.
    *   **`image: trinodb/trino:latest`**: Specifies the Docker image to use. We are using the official latest Trino image.
    *   **`container_name: trino`**: Sets a fixed name for the container, making it easier to reference (e.g., in `docker exec` commands).
    *   **`ports`**: Maps ports from the container to your host machine.
        *   **`"8080:8080"`**: Maps port 8080 inside the container (Trino's default UI/API port) to port 8080 on your computer.
    *   **`volumes`**: Mounts files from your local machine into the container.
        *   **`./etc/trino:/etc/trino`**: Maps your local configuration directory to the standard configuration path inside the container. This allows us to edit config files locally without rebuilding the image.
    *   **`environment`**: Sets environment variables inside the container.
        *   **`AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}`**: Passes your AWS key from the `.env` file to the container.
        *   **`AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}`**: Passes your AWS secret from the `.env` file.
        *   **`AWS_REGION=${AWS_REGION}`**: Passes your AWS region from the `.env` file.

## 2. `.env`

**Purpose**: Stores sensitive credentials and environment-specific variables. This file is automatically read by Docker Compose.

*   **`AWS_ACCESS_KEY_ID`**: Your AWS identity.
*   **`AWS_SECRET_ACCESS_KEY`**: Your AWS password.
*   **`AWS_REGION`**: The AWS region where your S3 bucket and Glue catalog reside (e.g., `us-east-1`).

## 3. `etc/trino/node.properties`

**Purpose**: Configures the specific Trino node (server instance).

*   **`node.environment=production`**: The name of the environment. Nodes with the same environment name can form a cluster.
*   **`node.id=ffffffff-ffff-ffff-ffff-ffffffffffff`**: A unique identifier for this node. In a real cluster, this must be unique for every machine.
*   **`node.data-dir=/data/trino`**: The directory where Trino stores logs and other local data. We changed this to `/data/trino` because the default user has write permissions there.

## 4. `etc/trino/jvm.config`

**Purpose**: Configures the Java Virtual Machine (JVM) options for running Trino.

*   **`-server`**: Selects the "server" VM, optimized for long-running applications.
*   **`-Xmx2G`**: Sets the maximum heap memory size to 2GB. This limits how much RAM Trino can use.
*   **`-XX:+UseG1GC`**: Enables the G1 Garbage Collector, which is recommended for Trino.
*   **`-XX:G1HeapRegionSize=32M`**: Sets the size of G1 heap regions.
*   **`-XX:+UseGCOverheadLimit`**: Policy to limit time spent in GC.
*   **`-XX:+ExplicitGCInvokesConcurrent`**: Optimizes explicit GC calls.
*   **`-XX:+HeapDumpOnOutOfMemoryError`**: Tells the JVM to create a dump file if it runs out of memory (useful for debugging).
*   **`-XX:+ExitOnOutOfMemoryError`**: Tells the JVM to crash and exit if it runs out of memory (so Docker can restart it).

## 5. `etc/trino/config.properties`

**Purpose**: Configures the Trino server role and global query settings.

*   **`coordinator=true`**: Configures this node to act as a coordinator (accepts queries and manages execution).
*   **`node-scheduler.include-coordinator=true`**: Allows the coordinator to also do work (act as a worker). This is essential for a single-node setup.
*   **`http-server.http.port=8080`**: The port the HTTP server listens on.
*   **`query.max-memory=5GB`**: The maximum amount of distributed memory a query can use across the entire cluster.
*   **`query.max-memory-per-node=1GB`**: The maximum amount of memory a query can use on a single node.
*   **`discovery.uri=http://localhost:8080`**: The URL where the discovery service is running. Since this is a single node, it points to itself.

## 6. `etc/trino/catalog/iceberg.properties`

**Purpose**: Configures the connection to a specific data source (catalog). We named it `iceberg`, so you use it in SQL as `iceberg.schema.table`.

*   **`connector.name=iceberg`**: Tells Trino to use the Iceberg connector plugin.
*   **`iceberg.catalog.type=glue`**: Tells Trino to use AWS Glue as the metastore (to store table definitions).
*   **`fs.native-s3.enabled=true`**: Enables Trino's native high-performance S3 file system implementation. This is required to read/write data in S3.
*   **`s3.region=${ENV:AWS_REGION}`**: Sets the region for S3 requests, using the environment variable passed from Docker.
