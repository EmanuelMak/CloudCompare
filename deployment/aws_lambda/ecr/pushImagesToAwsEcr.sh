#!/bin/bash

# AWS CLI region and AWS ID
AWS_REGION=${AWS_CLI_REGION}
AWS_ACCOUNT_ID=${AWS_ID}
DOCKERHUB_USERNAME="emanuelmak"

# ECR repository names
ECR_REPO_NAMES=("camelcase-lambda-function" "checkprime-lambda-function" "create-table-lambda")

# Login to AWS ECR
echo "Logging into AWS ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Process each repository
for REPO_NAME in "${ECR_REPO_NAMES[@]}"
do
    # Create ECR repository if it doesn't exist
    if ! aws ecr describe-repositories --repository-names "${REPO_NAME}" --region ${AWS_REGION} 2>/dev/null; then
        echo "Creating ECR repository: ${REPO_NAME}"
        aws ecr create-repository --repository-name "${REPO_NAME}" --region ${AWS_REGION}
    fi

    # Define DockerHub and ECR image names
    DOCKERHUB_IMAGE_NAME="${DOCKERHUB_USERNAME}/${REPO_NAME}:latest"
    ECR_IMAGE_NAME="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest"

    # Pull the image from DockerHub
    echo "Pulling image from DockerHub: ${DOCKERHUB_IMAGE_NAME}"
    docker pull "${DOCKERHUB_IMAGE_NAME}"

    # Tag the image for ECR
    echo "Tagging image for ECR: ${ECR_IMAGE_NAME}"
    docker tag "${DOCKERHUB_IMAGE_NAME}" "${ECR_IMAGE_NAME}"

    # Push the image to ECR
    echo "Pushing image to ECR: ${ECR_IMAGE_NAME}"
    docker push "${ECR_IMAGE_NAME}"
done

echo "ECR setup complete."
