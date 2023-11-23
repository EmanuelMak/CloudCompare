# Kubernetes Cluster Deployment and Management

## Overview

This documentation provides detailed instructions for deploying and managing Kubernetes clusters using Azure Kubernetes Service (AKS), Amazon Elastic Kubernetes Service (EKS), and MiniKube for local development. The workflow is designed to be consistent across these environments, ensuring a standardized process for deployment. This is part of a larger repository and the README.md file for this section is located on the second level.

## Repository Structure

- **AKS Directory**: Contains Terraform files for provisioning and managing an AKS cluster.
- **EKS Directory**: Contains Terraform files for provisioning and managing an EKS cluster.
- **MiniKube Directory**: Scripts and instructions for setting up a local Kubernetes environment using MiniKube.
- **k8s Directory**: Contains Kubernetes deployment configurations, Helm charts, and deployment scripts.
- **Makefiles**: Automate routine tasks such as setting the Kubernetes context and deploying to AWS.

## Detailed Setup Instructions

### Prerequisites

- Ensure Terraform, Helm, and Kubernetes CLI (kubectl) are installed.
- MiniKube should be installed for local development.
- Configure environment variables for settings and secrets as per the main `README.md` of the project.

### Configuring Kubernetes Clusters

#### AKS and EKS Setup

1. **Navigate to Cluster Directory**:
   - For AKS: `cd AKS`
   - For EKS: `cd EKS`

2. **Update Terraform Configuration**:
   - Modify `main.tf` to include your cloud provider credentials and desired cluster settings.

3. **Initialize and Apply Terraform**:
   ```bash
   terraform init
   terraform apply


### Set Kubernetes Context

- Use the `make setKubectlAwsContext` command to set the appropriate kubectl context for AKS and EKS.
- For MiniKube, the context is set automatically when you start MiniKube.

### Deploying the Project

1. **Navigate to the k8s Directory**:
   - Run `cd ../k8s` (adjust the path based on your current location within the repo).

2. **Deploy Using Makefile**:
   - Execute `make deployToAWS` to deploy the project to an AWS EKS cluster.

3. **Deploy Ingress Controllers**:
   - Run `./deploy-ingress.sh` to set up Ingress controllers using Helm.

4. **Continuous Integration**:
   - For CI/CD pipelines, refer to `makefile.ci` for automating deployments and other tasks.

### Post-Deployment

- **Verify Deployment**:
  - Use `kubectl get pods` and similar kubectl commands to check the status of your deployment.
  - Ensure that all services are running as expected.

- **Accessing Applications**:
  - For AKS and EKS, access your applications using the provided external IP or DNS.
  - For MiniKube, use `minikube service list` to find the URLs to access services.
