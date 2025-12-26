# System Architecture

This diagram illustrates how the different components in this Docker stack interact with each other and with AWS services.

```mermaid
graph TD
    subgraph "Docker Host"
        User[User / Developer]
        
        subgraph "Visualization Layer"
            Superset["Apache Superset<br/>(Port 8088)"]
            Postgres[("Postgres DB<br/>Metadata")]
            Redis[("Redis<br/>Cache")]
        end
        
        subgraph "Transformation Layer"
            dbt[dbt Container]
        end
        
        subgraph "Query Engine"
            Trino["Trino Coordinator/Worker<br/>(Port 8080)"]
        end
    end
    
    subgraph "AWS Cloud"
        Glue["AWS Glue Catalog<br/>(Metastore)"]
        S3["AWS S3 Bucket<br/>(Data Storage)"]
    end

    %% Interactions
    User -->|Browser| Superset
    User -->|CLI| dbt
    User -->|CLI / JDBC| Trino
    
    Superset -->|SQL / Trino Driver| Trino
    Superset -->|Metadata| Postgres
    Superset -->|Cache| Redis
    
    dbt -->|SQL / HTTP| Trino
    
    Trino -->|Get Table Metadata| Glue
    Glue -->|Read/Write Iceberg| S3
```

## Component Roles

*   **Trino**: The central query engine. It processes SQL queries from dbt and Superset and executes them against data stored in S3.
*   **AWS Glue**: Acts as the catalog (metastore) for Iceberg tables, storing schema definitions and table locations.
*   **AWS S3**: The actual storage layer where data files (Parquet/Iceberg) are kept.
*   **dbt**: Handles data transformation. It compiles SQL models and runs them on Trino to create/update tables in S3.
*   **Superset**: The BI tool. It connects to Trino to visualize the data.
    *   **Postgres**: Stores Superset's internal configuration (dashboards, users, etc.).
    *   **Redis**: Caches query results for Superset to improve dashboard performance.
