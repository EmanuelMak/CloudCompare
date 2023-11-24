#!/bin/bash

echo "Listing AWS Resources..."

# Use AWS_DEFAULT_REGION environment variable, or prompt for input if not set
AWS_REGION=${AWS_DEFAULT_REGION:-$(read -p "Enter AWS Region: " region; echo $region)}

# Check if AWS_REGION is set
if [ -z "$AWS_REGION" ]; then
    echo "AWS region is not set. Exiting..."
    exit 1
fi

echo "Using AWS Region: $AWS_REGION"

# EC2 Instances
echo "EC2 Instances:"
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name}' --output table --region $AWS_REGION

# EC2 Security Groups
echo "EC2 Security Groups:"
aws ec2 describe-security-groups --query 'SecurityGroups[*].{ID:GroupId,Name:GroupName}' --output table --region $AWS_REGION

# Load Balancers
echo "Load Balancers:"
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].{ARN:LoadBalancerArn,Name:LoadBalancerName}' --output table --region $AWS_REGION

# RDS Instances
echo "RDS Instances:"
aws rds describe-db-instances --query 'DBInstances[*].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Status:DBInstanceStatus}' --output table --region $AWS_REGION

# VPCs
echo "VPCs:"
aws ec2 describe-vpcs --query 'Vpcs[*].{ID:VpcId,CIDR:CidrBlock}' --output table --region $AWS_REGION

# IAM Roles
echo "IAM Roles:"
aws iam list-roles --query 'Roles[*].{Name:RoleName,ARN:Arn}' --output table --region $AWS_REGION

# Internet Gateways
echo "Internet Gateways:"
aws ec2 describe-internet-gateways --query 'InternetGateways[*].{ID:InternetGatewayId}' --output table --region $AWS_REGION

# NAT Gateways
echo "NAT Gateways:"
aws ec2 describe-nat-gateways --query 'NatGateways[*].{ID:NatGatewayId,State:State,SubnetId:SubnetId}' --output table --region $AWS_REGION

echo "Listing completed."
