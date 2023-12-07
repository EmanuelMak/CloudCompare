# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}
#  Provider definition
provider "aws" {
  region     = var.AWS_DEFAULT_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# VPC Configuration
resource "aws_vpc" "lambda_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Subnets Configuration
resource "aws_subnet" "lambda_subnet_1" {
  vpc_id     = aws_vpc.lambda_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = format("%s%s", var.AWS_DEFAULT_REGION, "a")
}

resource "aws_subnet" "lambda_subnet_2" {
  vpc_id            = aws_vpc.lambda_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = format("%s%s", var.AWS_DEFAULT_REGION, "b")
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-rds-subnet-group"
  subnet_ids = [aws_subnet.lambda_subnet_1.id, aws_subnet.lambda_subnet_2.id]
}

# Security Groups Configuration
resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.lambda_vpc.id
  // Allow all inbound and outbound traffic for simplicity
  // Adjust as per your security requirements
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

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.lambda_vpc.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "em_thesis_lambda_db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = var.DB_NAME
  username             = var.DB_USERNAME
  password             = var.DB_PASSWORD
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  #publicly_accessible = true
}




# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the basic execution role policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


#polocies for lambda functions to access ecr repos
resource "aws_iam_policy" "lambda_ecr_read_policy" {
  name        = "lambdaECRReadPolicy"
  description = "Policy for Lambda functions to access ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ecr_read_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ecr_read_policy.arn
}
#lambda function loggin policy
resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "LambdaLoggingPolicy"
  description = "IAM policy for Lambda logging to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# Lambda Functions Configuration
resource "aws_lambda_function" "camel_case_lambda" {
  function_name = "camelCaseLambdaFunction"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${var.AWS_ID}.dkr.ecr.${var.AWS_CLI_REGION}.amazonaws.com/camelcase-lambda-function:latest"
  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet_1.id, aws_subnet.lambda_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_iam_policy" "lambda_vpc_access_policy" {
  name        = "lambdaVPCAccessPolicy"
  description = "Policy for Lambda functions to access VPC resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access_policy.arn
}


resource "aws_lambda_function" "check_prime_lambda" {
  function_name = "checkPrimeLambdaFunction"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${var.AWS_ID}.dkr.ecr.${var.AWS_CLI_REGION}.amazonaws.com/checkprime-lambda-function:latest"
  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet_1.id, aws_subnet.lambda_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      DB_HOST     = aws_db_instance.em_thesis_lambda_db.address
      DB_USER     = var.DB_USERNAME
      DB_PASSWORD = var.DB_PASSWORD
      DB_NAME     = var.DB_NAME
    }
  }
}

# API Gateway Configuration
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "API Gateway for Lambda functions"
}

resource "aws_api_gateway_resource" "camel_case_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "camelcase"
}

resource "aws_api_gateway_resource" "check_prime_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "checkprime"
}

resource "aws_api_gateway_method" "camel_case_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.camel_case_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "check_prime_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.check_prime_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "camel_case_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.camel_case_resource.id
  http_method             = aws_api_gateway_method.camel_case_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.camel_case_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "check_prime_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.check_prime_resource.id
  http_method             = aws_api_gateway_method.check_prime_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.check_prime_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.camel_case_integration,
    aws_api_gateway_integration.check_prime_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
}




# lambda function to create table on db on creation
# Lambda function to run the setup script
resource "aws_lambda_function" "db_setup_lambda" {
  function_name    = "dbSetupFunction"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${var.AWS_ID}.dkr.ecr.${var.AWS_CLI_REGION}.amazonaws.com/create-table-lambda:latest"
  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet_1.id, aws_subnet.lambda_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      DB_HOST     = aws_db_instance.em_thesis_lambda_db.address
      DB_USERNAME = var.DB_USERNAME
      DB_PASSWORD = var.DB_PASSWORD
      DB_NAME     = var.DB_NAME
    }
  }
}

# Trigger Lambda function after RDS creation
resource "null_resource" "db_setup_trigger" {
  depends_on = [aws_db_instance.em_thesis_lambda_db, aws_lambda_function.db_setup_lambda]

  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${aws_lambda_function.db_setup_lambda.function_name} response.json"
  }
}






output "api_gateway_endpoint" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
output "db_port" {
  value = aws_db_instance.em_thesis_lambda_db.address
}
