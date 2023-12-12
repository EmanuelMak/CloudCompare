#!/bin/bash

# Fetch values from Terraform outputs
DB_HOST=$(terraform output -raw postgres_endpoint)
DB_NAME=$(terraform output -raw db_name)
DB_USERNAME_BASE=$(terraform output -raw db_administrator_login)
POSTGRES_SERVER_NAME=$(terraform output -raw postgres_server_name)
DB_USERNAME="${DB_USERNAME_BASE}@${POSTGRES_SERVER_NAME}"
DB_PASSWORD=$(terraform output -raw db_password)  # Ensure this is securely handled

# Check if values are fetched
if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Unable to fetch database details from Terraform."
    exit 1
fi

# Generate external-values.yaml content
cat <<EOF > external-values.yaml
checkPrime:
  db:
    host: $DB_HOST
    name: $DB_NAME
    username: $DB_USERNAME
    password: $DB_PASSWORD
EOF

echo "external-values.yaml file generated successfully."