#!/bin/bash

# Create an empty tfvars file
> terraform.tfvars
export ECR_REPO_URI=$(aws ecr describe-repositories --region $AWS_DEFAULT_REGION --repository-names myrepo --query "repositories[0].repositoryUri" --output text)
# Specify excluded variable names
EXCLUDED_VARIABLES=("COLORTERM" "_" "__CF_USER_TEXT_ENCODING" "__CFBundleIdentifier")

# Create a separate variables.tf file for variable declarations
> variables.tf

# Iterate through all environment variables
for VAR in $(env | cut -d'=' -f1); do
  # Check if the variable is not in the excluded list
  if [[ ! " ${EXCLUDED_VARIABLES[@]} " =~ " ${VAR} " ]]; then
    # Write the variable to the tfvars file
    echo "$VAR = \"${!VAR}\"" >> terraform.tfvars
    # Write the variable declaration to the variables.tf file
    echo "variable \"$VAR\" {}" >> variables.tf
  fi
done



