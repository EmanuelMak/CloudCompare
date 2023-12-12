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

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "my-beanstalk-vpc"
  cidr = "10.0.0.0/16"

  azs             = [format("%s%s", var.AWS_DEFAULT_REGION, "a"),format("%s%s", var.AWS_DEFAULT_REGION, "b")] 
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "my_beanstalk_db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = var.DB_NAME
  username             = var.DB_USERNAME
  password             = var.DB_PASSWORD
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.beanstalk_db_subnetgroup.name

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  #publicly_accessible = true
  tags = {
    "thesis-cost-general" = "lambda"
    "thesis-cost-db" = "lambda"
  }
}

resource "aws_db_subnet_group" "beanstalk_db_subnetgroup" {
  name       = "my-beanstalk-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "db_sg" {
  name        = "my-beanstalk-db-sg"
  description = "Database security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # specify ingress from security group needet if subnet goup is moved to different subnets then beanstalk applications 
    security_groups = [aws_security_group.eb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eb_sg" {
  name        = "eb-sg"
  description = "test Security group with open settings for Elastic Beanstalk"
  vpc_id      = module.vpc.vpc_id

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

  tags = {
    Name = "eb-sg"
  }
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "my_beanstalk_app" {
  name = "beanstalk-app"
}

# Elastic Beanstalk Environment - Camelcase
resource "aws_elastic_beanstalk_environment" "camelcase_env" {
  name                = "my-camelcase-env"
  application         = aws_elastic_beanstalk_application.my_beanstalk_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Docker"
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", module.vpc.private_subnets)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_sg.id
  }
  # Additional settings like environment variables, instance type, etc.
}

# Elastic Beanstalk Environment - Checkprime
resource "aws_elastic_beanstalk_environment" "checkprime_env" {
  name                = "my-checkprime-env"
  application         = aws_elastic_beanstalk_application.my_beanstalk_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Docker"
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_sg.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", module.vpc.private_subnets)
  }

   setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = aws_db_instance.my_beanstalk_db.address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USER"
    value     = var.DB_USERNAME
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD"
    value     = var.DB_PASSWORD
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_NAME"
    value     = var.DB_NAME
  }
}

########### specific for each container ###########

resource "aws_s3_bucket" "default" {
  bucket = "beanstalk-runconfig"
}
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "camelcase_object" {
  bucket = aws_s3_bucket.default.bucket
  key    = "beanstalkRunConfig/camelcaseRunConf.json"
  source = "beanstalkRunConfig/camelcaseRunConf.json"
}


resource "aws_s3_object" "checkprime_object" {
  bucket = aws_s3_bucket.default.bucket
  key    = "beanstalkRunConfig/checkprimeRunConf.json"
  source = "beanstalkRunConfig/checkprimeRunConf.json"
}

resource "aws_elastic_beanstalk_application_version" "camelcase_version" {
  name        = "camelcase-version"
  application = aws_elastic_beanstalk_application.my_beanstalk_app.name
  description = "Camelcase Version"
  bucket      = aws_s3_bucket.default.bucket
  key         = aws_s3_object.camelcase_object.key
}

resource "aws_elastic_beanstalk_application_version" "checkprime_version" {
  name        = "checkprime-version"
  application = aws_elastic_beanstalk_application.my_beanstalk_app.name
  description = "Checkprime Version"
  bucket      = aws_s3_bucket.default.bucket
  key         = aws_s3_object.checkprime_object.key
}

# policies
# IAM Role for Elastic Beanstalk
resource "aws_iam_role" "eb_iam_role" {
  name = "eb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# Policy for S3 Access
resource "aws_iam_policy" "s3_access" {
  name        = "eb-s3-access"
  description = "Policy for Elastic Beanstalk to access S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect = "Allow",
        Resource = "arn:aws:s3:::${aws_s3_bucket.default.bucket}/*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.eb_iam_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Instance Profile for Elastic Beanstalk
resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "eb-instance-profile"
  role = aws_iam_role.eb_iam_role.name
}


output "camelcase_env_url" {
  description = "URL of the camelcase Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.camelcase_env.endpoint_url
}

output "checkprime_env_url" {
  description = "URL of the checkprime Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.checkprime_env.endpoint_url
}

