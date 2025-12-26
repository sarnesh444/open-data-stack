#!/bin/bash
set -e

# Initialize the database
superset db upgrade

# Create an admin user
superset fab create-admin \
    --username admin \
    --firstname Superset \
    --lastname Admin \
    --email admin@superset.com \
    --password admin

# Initialize Superset
superset init
