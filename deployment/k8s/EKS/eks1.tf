terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  required_version = ">= 0.13"
}


provider "aws" {
  # region     = var.AWS_DEFAULT_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-ecs-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  enable_vpn_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    thesis-cost-general = "eks"
  }
  public_subnet_tags = {
    Name                                        = "Public Subnets"
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
  private_subnet_tags = {
    Name                                        = "private-subnets"
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    disk_size = 30
  }

  eks_managed_node_groups = {
    spot_group = {
      instance_types = ["t2.small", "t3.small"]  # Variety helps in spot availability
      capacity_type  = "SPOT"
      min_size       = 1  # For base workload
      max_size       = 10  # Can scale significantly based on demand
      labels = {
        lifecycle = "spot"
      }
      taints = [
        {
          key    = "lifecycle"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      ]
      tags = {
        lifecycle = "spot"
        thesis-cost-vm = "eks-spot"
        thesis-cost-general = "eks"
      }
    }
    on_demand_group = {
      instance_types = ["t2.small"]
      capacity_type  = "ON_DEMAND"
      min_size       = 0
      max_size       = 5  # Backup for when spot instances are unavailable
      labels = {
        lifecycle = "on-demand"
      }
      tags = {
        lifecycle = "on-demand"
        thesis-cost-vm = "eks-on-demand"
        thesis-cost-general = "eks"
      }
    }
  }
  tags = {
    Environment = "dev"
    thesis-cost-vm   = "eks"
    thesis-cost-general = "eks"
  }
}



###################### DB ######################

# DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "my-db-subnet-group"
    Environment = "dev"
    thesis-cost-db = "eks"
    thesis-cost-general = "eks"
  }
}

resource "aws_db_instance" "my_db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "dbuser"
  password             = "init1000"
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name        = "my-db-instance"
    Environment = "dev"
    thesis-cost-db = "eks"
    thesis-cost-general = "eks"
  }
}



resource "aws_security_group" "db_sg" {
  name        = "my-db-sg"
  description = "Database security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  tags = {
    Name        = "my-db-sg"
    Environment = "dev"
    thesis-cost-db = "eks"
    thesis-cost-general = "eks"
  }
}

output "db_endpoint" {
  value = aws_db_instance.my_db.address
}

output "db_port" {
  value = aws_db_instance.my_db.port
}



