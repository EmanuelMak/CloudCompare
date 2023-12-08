#!/bin/bash

# Run Terraform Apply (optional, uncomment if needed)
# terraform apply

# Get DB_HOST from Terraform output
DB_HOST=$(terraform output -raw db_endpoint)

# Get DB_NAME, DB_USERNAME, and DB_PASSWORD from environment variables
DB_NAME=${DB_NAME:-default_db_name}         # Replace 'default_db_name' with a default value or leave as is
DB_USERNAME=${DB_USERNAME:-default_username} # Replace 'default_username' with a default value or leave as is
DB_PASSWORD=${DB_PASSWORD:-default_password} # Replace 'default_password' with a default value or leave as is

# Generate external-values.yaml
cat << EOF > external-values.yaml
checkPrime:
  db:
    host: $DB_HOST
    name: $DB_NAME
    username: $DB_USERNAME
    password: $DB_PASSWORD
EOF

echo "external-values.yaml file has been generated."
