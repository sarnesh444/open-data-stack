# Trino Configuration Documentation (`etc/trino`)

This folder contains the configuration files mounted into the Trino container at `/etc/trino`.

## `node.properties`

Configures the specific Trino node instance.

```properties
node.environment=production        # Environment name. Nodes must match to form a cluster.
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff # Unique ID for this node.
node.data-dir=/data/trino          # Directory for logs/data. Set to /data/trino for permission compatibility.
```

## `jvm.config`

Configures the Java Virtual Machine running Trino.

```config
-server                            # Optimizes for server performance.
-Xmx2G                             # Max heap size 2GB. Limits memory usage.
-XX:+UseG1GC                       # Uses G1 Garbage Collector (best for Trino).
-XX:G1HeapRegionSize=32M           # Tuning parameter for G1GC.
-XX:+UseGCOverheadLimit            # Prevents GC from using too much CPU.
-XX:+ExplicitGCInvokesConcurrent   # Optimizes manual GC calls.
-XX:+HeapDumpOnOutOfMemoryError    # Dumps heap if OOM occurs (for debugging).
-XX:+ExitOnOutOfMemoryError        # Restarts container if OOM occurs.
```

## `config.properties`

Configures the Trino server role.

```properties
coordinator=true                   # This node is the coordinator (master).
node-scheduler.include-coordinator=true # This node also does work (worker). Required for single-node.
http-server.http.port=8080         # Port to listen on.
query.max-memory=5GB               # Max memory for a query across the cluster.
query.max-memory-per-node=1GB      # Max memory for a query on one node.
discovery.uri=http://localhost:8080 # URI to find other nodes (points to self).
```

## `catalog/iceberg.properties`

Configures the connection to the data source (Iceberg on S3).

```properties
connector.name=iceberg             # Uses the Iceberg connector.
iceberg.catalog.type=glue          # Uses AWS Glue as the metastore.
fs.native-s3.enabled=true          # Enables high-performance native S3 file system.
s3.region=${ENV:AWS_REGION}        # Sets S3 region from environment variable.
```
