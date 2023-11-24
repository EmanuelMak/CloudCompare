#!/bin/bash

echo "Enter the database host (default: localhost):"
read DB_HOST
DB_HOST=${DB_HOST:-localhost}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}

# SQL command to create table if it does not exist
CREATE_TABLE_SQL="CREATE TABLE IF NOT EXISTS checkt_numbers (
    number BIGINT PRIMARY KEY,
    is_prime BOOLEAN NOT NULL
);"

# Connect to the PostgreSQL database and execute the SQL command using Docker
docker run -it --rm \
    --network="host" \
    postgres:latest \
    bash -c "export PGPASSWORD=$DB_PASSWORD && psql -h $DB_HOST -U $DB_USERNAME -d $DB_NAME -c '$CREATE_TABLE_SQL'"


echo "Table creation script executed successfully."