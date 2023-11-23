provider "aws" {
  region = "your-aws-region" # e.g., us-west-2
}

# VPC
resource "aws_vpc" "lambda_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Subnet for the Lambda Functions
resource "aws_subnet" "lambda_subnet" {
  vpc_id     = aws_vpc.lambda_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Subnet for RDS
resource "aws_subnet" "rds_subnet" {
  vpc_id     = aws_vpc.lambda_vpc.id
  cidr_block = "10.0.2.0/24"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet.id]
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.lambda_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.lambda_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t3.micro"
  db_name                 = "mydb"
  username             = "dbuser"
  password             = "dbpassword"
  parameter_group_name = "default.postgres13"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
}

# Lambda Function for CamelCase - Using Docker Image
resource "aws_lambda_function" "camel_case_lambda" {
  function_name = "camelCaseLambdaFunction"
  role          = "arn:aws:iam::your-aws-account-id:role/lambda-role"
  
  package_type = "Image"
  image_uri    = "emanuelmak/camel-case-lambda-function:latest"

  # Assuming you are using the same VPC as in your previous setup
  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

# Lambda Function for CheckPrime - Using Docker Image
resource "aws_lambda_function" "check_prime_lambda" {
  function_name = "checkPrimeLambdaFunction"
  role          = "arn:aws:iam::your-aws-account-id:role/lambda-role"

  package_type = "Image"
  image_uri    = "emanuelmak/check-prime-lambda-function:latest"

  # Assuming you are using the same VPC as in your previous setup
  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  # Environment variables, assuming they are required for this function
  environment {
    variables = {
      DB_ENDPOINT = aws_db_instance.postgres_db.address
      DB_USER     = "dbuser"
      DB_PASSWORD = "dbpassword"
      DB_NAME     = "mydb"
    }
  }
}
