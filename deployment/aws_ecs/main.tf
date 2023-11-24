# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}
###################  Provider definition ######################
provider "aws" {
  region     = var.AWS_DEFAULT_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
#############################  Virtual Private cloud  ######################
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name                = "em-thesis-ecs-cluster-vpc"
    EM_ECS_Overall_Cost = "VPC"
  }

}
#############################  Internet gateway for communication from the internet ######################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name                  = "internet_gateway"
    EM_ECS_Endpoints_Cost = "Internet Gateway"
  }
}
#############################  Subnet definition ######################
# public subnets
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = format("%s%s", var.AWS_DEFAULT_REGION, "a")
  tags = {
    Name                = "subnet"
    EM_ECS_Overall_Cost = "Subnet"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = format("%s%s", var.AWS_DEFAULT_REGION, "b")
  tags = {
    Name                = "subnet2"
    EM_ECS_Overall_Cost = "Subnet"
  }
}
# Additional Private Subnets for ECS Services
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 3)
  availability_zone       = format("%s%s", var.AWS_DEFAULT_REGION, "a")
  map_public_ip_on_launch = false
  tags = {
    Name                = "private_subnet1"
    EM_ECS_Overall_Cost = "Private Subnet"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 4)
  availability_zone       = format("%s%s", var.AWS_DEFAULT_REGION, "b")
  map_public_ip_on_launch = false
  tags = {
    Name                = "private_subnet2"
    EM_ECS_Overall_Cost = "Private Subnet"
  }
}
# Additional subnets for RDS
resource "aws_subnet" "rds_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 5)
  availability_zone = format("%s%s", var.AWS_DEFAULT_REGION, "a")
  tags = {
    Name                  = "rds_subnet"
    EM_ECS_DB_Subnet_Cost = "RDS Subnet"
  }
}
resource "aws_subnet" "rds_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 6)
  availability_zone = format("%s%s", var.AWS_DEFAULT_REGION, "b")
  tags = {
    Name                  = "rds_subnet1"
    EM_ECS_DB_Subnet_Cost = "RDS Subnet"
  }
}

#############################  NAT Gateway for Private Subnet Internet Access ######################
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet.id  # Assuming aws_subnet.subnet is a public subnet
  tags = {
    Name = "nat_gateway"
  }
}

#############################  Route table definition ######################
# public route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}
# private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_route_table_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
# resource "aws_route_table" "rds_route_table" {
#   vpc_id = aws_vpc.main_vpc.id
# }

# resource "aws_route" "rds_route" {
#   route_table_id         = aws_route_table.rds_route_table.id               
#   destination_cidr_block = aws_subnet.rds_subnet.cidr_block  
# }
# resource "aws_route_table_association" "rds_route_table_association" {
#   subnet_id      = aws_subnet.rds_subnet.id
#   route_table_id = aws_route_table.rds_route_table.id
# }


#############################  Security group definition ######################
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name                = "ecs_sg"
    EM_ECS_Overall_Cost = "Security Group"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name           = "rds_sg"
    EM_ECS_DB_Cost = "RDS Security Group"
  }
  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#############################  IAM role ######################
data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent-instance-profile"
  role = aws_iam_role.ecs_agent.name
}
#############################  ECS Autoscaling Group ######################

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template"
  image_id      = "ami-062c116e449466e7f"
  instance_type = "t3.micro"
  tags = {
    Name           = "ecs-instance"
    EM_ECS_VM_Cost = "Launch Template"
  }
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }

  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config")

}







resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
  desired_capacity = 1
  min_size         = 1
  max_size         = 8

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  tag {
    key                 = "EM_ECS_VM_Cost"
    value               = "Auto Scaling Group"
    propagate_at_launch = true
  }
}
#############################  loadbalancer #######################
resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.subnet.id, aws_subnet.subnet2.id]

  tags = {
    Name                = "ecs-alb"
    EM_ECS_Traffic_Cost = "Load Balancer"
  }
}

resource "aws_lb_listener" "lb_pub_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg_camelcase.arn
  }
}

resource "aws_lb_listener_rule" "prime_numbers_checker_rule" {
  listener_arn = aws_lb_listener.lb_pub_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prime_numbers_checker_tg.arn
  }

  condition {
    path_pattern {
      values = ["/checkIsPrimeNumber", "/getPrimeNumbers", "/greeting"]
    }
  }
}

resource "aws_lb_listener_rule" "springboot_greet_rule" {
  listener_arn = aws_lb_listener.lb_pub_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg_camelcase.arn
  }

  condition {
    path_pattern {
      values = ["/convertToCamelCase"]
    }
  }
}
resource "aws_lb_target_group" "ecs_tg_camelcase" {
  name        = "ecs-tg-camel-case-name"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main_vpc.id

  health_check {
    path = "/actuator/health"
  }
}
resource "aws_lb_target_group" "prime_numbers_checker_tg" {
  name        = "ecs-tg-prime-numbers-checker"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main_vpc.id

  health_check {
    path = "/actuator/health"
  }
}

#############################  VPC DB subnet group ######################
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my_db_subnet_group"
  subnet_ids = [ aws_subnet.rds_subnet.id, aws_subnet.rds_subnet1.id]

  tags = {
    Name = "my_db_subnet_group"
  }
}



#############################  RDS DB instance ######################

resource "aws_db_instance" "my_db" {
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  db_name                = var.DB_NAME
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD
  parameter_group_name   = "default.postgres15"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [ aws_security_group.ecs_sg.id]
  tags = {
    Name           = "my_db"
    EM_ECS_DB_Cost = "RDS Instance"
  }
  #publicly_accessible = true
}


#############################  ECS cluster ######################

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

################### ecs capacity provider ######################
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "test1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}


###################  ECS task/service definition ######################


resource "aws_ecs_task_definition" "task_definition_camelCaseConverer" {
  family             = "ecsCamelCaseConverer"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_agent.arn
  cpu                = 256
  memory             = 512
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      "name" : "ecsCamelCaseConverer",
      "image" : "${var.ECR_REPO_URI}:latest",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp"
        }
      ],
      "memory" : 512,
      "cpu" : 256,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "ecs-primeNumbersChecker-logs",
          "awslogs-region" : var.AWS_DEFAULT_REGION,
          "awslogs-stream-prefix" :"camelCase"
        }
      }
    }
  ])
}


resource "aws_ecs_task_definition" "prime_numbers_checker_task_def" {
  family             = "primeNumbersChecker"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_agent.arn
  cpu                = 256
  memory             = 512
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      "name" : "primeNumbersChecker",
      "image" : "emanuelmak/prime-numbers-checker-springboot-app:latest",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp"
        }
      ],
      "memory" : 512,
      "cpu" : 256,
      "environment" : [
        {
          "name" : "DB_HOST",
          "value" : aws_db_instance.my_db.address
        },
        {
          "name" : "DB_USERNAME",
          "value" : var.DB_USERNAME
        },
        {
          "name" : "DB_PASSWORD",
          "value" : var.DB_PASSWORD
        },
        {
          "name" : "DB_NAME",
          "value" : var.DB_NAME
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "ecs-primeNumbersChecker-logs",
          "awslogs-region" : var.AWS_DEFAULT_REGION,
          "awslogs-stream-prefix" : "checkPrime"
        }
      }
    }
  ])
}


resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "ecs-primeNumbersChecker-logs"
}


resource "aws_ecs_service" "ecsCamelCaseConverer" {
  name            = "ecsCamelCaseConverer"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition_camelCaseConverer.arn
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg_camelcase.arn
    container_name   = "ecsCamelCaseConverer"
    container_port   = 8080
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}
resource "aws_ecs_service" "prime_numbers_checker_service" {
  name            = "primeNumbersCheckerService"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.prime_numbers_checker_task_def.arn
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prime_numbers_checker_tg.arn
    container_name   = "primeNumbersChecker"
    container_port   = 8080
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}

output "my_db_endpoint" {
  value = aws_db_instance.my_db.endpoint
}

# Output for Load Balancer DNS Name
output "load_balancer_dns_name" {
  value = aws_lb.ecs_alb.dns_name
}
