terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

// Variables
variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

variable "MYSQL_ROOT_PASSWORD" {
  type        = string
  default     = "MYSQL_ROOT_PASSWORD"
}

variable "MYSQL_DATABASE" {
  type        = string
  default     = "MYSQL_DATABASE"
}

variable "MYSQL_USER" {
  type        = string
  default     = "MYSQL_USER"
}

variable "MYSQL_PASSWORD" {
  type        = string
  default     = "MYSQL_PASSWORD"
}

variable "MYSQL_SG" {
  type        = string
  default     = "MYSQL_SG"
}

variable "MYSQL_HOST" {
  type        = string
  default     = "MYSQL_HOST"
}

variable "AWS_ACCESS_KEY_ID"{
  type        = string
  default     = "AWS_ACCESS_KEY_ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  default     = "AWS_SECRET_ACCESS_KEY"
}

variable "BUCKET_NAME" {
  type        = string
  default     = "BUCKET_NAME"
}

variable "USER_POOL_ID" {
  type        = string
  default     = "USER_POOL_ID"
}

variable "COGNITO_USER_CLIENT_ID" {
  type        = string
  default     = "COGNITO_USER_CLIENT_ID"
}

variable "COGNITO_DOMAIN" {
  type        = string
  default     = "COGNITO_DOMAIN"
}

variable "AUTH_URL" {
  type        = string
  default     = "AUTH_URL"
}

variable "TOKEN_URL" {
  type        = string
  default     = "TOKEN_URL"
}

variable "LOGOUT_URL" {
  type        = string
  default     = "LOGOUT_URL"
}

variable "MAKERS_URL_API" {
  type        = string
  default     = "MAKERS_URL_API"
}

variable "FRONTEND_SIGN_UP_IDP_LINK" {
  type = string
  default = "FRONTEND_SIGN_UP_IDP_LINK"
}

variable "STRIPE_KEY" {
  type       = string
  default    = "STRIPE_KEY"
}

variable "API_KEY_EMAIL"{
  type       = string
  default    = "API_KEY_EMAIL"
}

variable "VITE_STRIPE_KEY"{
  type       = string
  default    = "VITE_STRIPE_KEY"
}

variable "VITE_GOOGLE_AUTH_URL"{
  type       = string
  default    = "VITE_GOOGLE_AUTH_URL"
}

variable "SSL_CERTIFICATE_ARN" {
  type        = string
  default     = "SSL_CERTIFICATE_ARN"
}

variable "VPC_ID" {
  type    = string
  default = "VPC_ID"
}

variable "PUBLIC_SUBNET_1" {
  type    = string
  default = "PUBLIC_SUBNET_1"
}

variable "PUBLIC_SUBNET_2" {
  type    = string
  default = "PUBLIC_SUBNET_2"
}

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "makers5"
}

// CODE

resource "aws_ecr_repository" "api_ecr_repo" {
  name = "api-repo"
}

resource "aws_ecr_repository" "frontend_ecr_repo" {
  name = "frontend-repo"
}

data "aws_ecr_image" "latest_api_image" {
  repository_name = aws_ecr_repository.api_ecr_repo.name
  image_tag       = "latest" # Assuming you are using the 'latest' tag
}

data "aws_ecr_image" "latest_frontend_image" {
  repository_name = aws_ecr_repository.frontend_ecr_repo.name
  image_tag       = "latest" # Assuming you are using the 'latest' tag
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "makers-market-cluster" # Name your cluster here
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name = "api-logs"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = "frontend-logs"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "api_task" {
  family                   = "api-task"
  container_definitions    = jsonencode([ # Use jsonencode for better readability
    {
      "name": "fastapi-server",
      "image": "${aws_ecr_repository.api_ecr_repo.repository_url}@${data.aws_ecr_image.latest_api_image.image_digest}", # Replace with your FastAPI Docker image
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000, # FastAPI runs on port 8000
          "hostPort": 8000
        }
      ],
      "memory": 512,
      "cpu": 256,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": aws_cloudwatch_log_group.api_log_group.name,
          "awslogs-region": var.aws_region,
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment": [
        {
          "name": "UVICORN_PORT",
          "value": "8000"
        },
        {
          "name": "AWS_URL",
          "value": "https://makers-market.pt"
        },
        {
        "name": "MYSQL_ROOT_PASSWORD",
        "value": var.MYSQL_ROOT_PASSWORD
        },
        {
          "name": "MYSQL_DATABASE",
          "value": var.MYSQL_DATABASE
        },
        {
          "name": "MYSQL_USER",
          "value": var.MYSQL_USER
        },
        {
          "name": "MYSQL_PASSWORD",
          "value": var.MYSQL_PASSWORD
        },
        {
          "name": "MYSQL_HOST",
          "value": var.MYSQL_HOST
        },
        {
          "name": "AWS_REGION",
          "value": var.aws_region
        },
        {
          "name": "AWS_ACCESS_KEY_ID",
          "value": var.AWS_ACCESS_KEY_ID
        },
        {
          "name": "AWS_SECRET_ACCESS_KEY",
          "value": var.AWS_SECRET_ACCESS_KEY
        },
        {
          "name": "BUCKET_NAME",
          "value": var.BUCKET_NAME
        },
        {
          "name": "USER_POOL_ID",
          "value": var.USER_POOL_ID
        },
        {
          "name": "COGNITO_USER_CLIENT_ID",
          "value": var.COGNITO_USER_CLIENT_ID
        },
        {
          "name": "COGNITO_DOMAIN",
          "value": var.COGNITO_DOMAIN
        },
        {
          "name": "AUTH_URL",
          "value": var.AUTH_URL
        },
        {
          "name": "TOKEN_URL",
          "value": var.TOKEN_URL
        },
        {
          "name": "LOGOUT_URL",
          "value": var.LOGOUT_URL
        },
        {
          "name": "STRIPE_KEY",
          "value": var.STRIPE_KEY
        },
        {
          "name": "API_KEY_EMAIL",
          "value": var.API_KEY_EMAIL
        },
        {
          "name": "MAKERS_URL_API",
          "value": var.MAKERS_URL_API
        },
        {
          "name": "FRONTEND_SIGN_UP_IDP_LINK",
          "value": var.FRONTEND_SIGN_UP_IDP_LINK
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  container_definitions    = jsonencode([
    {
      "name": "frontend-server",
      "image": "${aws_ecr_repository.frontend_ecr_repo.repository_url}@${data.aws_ecr_image.latest_frontend_image.image_digest}"
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": aws_cloudwatch_log_group.frontend_log_group.name,
          "awslogs-region": var.aws_region,
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 4173,
          "hostPort": 4173
        }
      ],
      "memory": 4096,
      "cpu": 512,
      "environment": [
        {
          "name": "VITE_API_URL",
          "value": "https://makers-market.pt/api"
        },
        {
          "name": "VITE_STRIPE_KEY",
          "value": var.VITE_STRIPE_KEY
        },
        {
          "name": "VITE_GOOGLE_AUTH_URL",
          "value": var.VITE_GOOGLE_AUTH_URL
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 4096
  cpu                      = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-prod" #load balancer name
  load_balancer_type = "application"
  subnets            = [var.PUBLIC_SUBNET_1, var.PUBLIC_SUBNET_2]
  # security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = var.VPC_ID
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow HTTPS traffic from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "api_target_group" {
  name        = "target-group"
  port        = 8000 # Update to match FastAPI port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id = var.VPC_ID

  health_check {
    enabled             = true
    interval            = 120
    path                = "/api/health" # Update the health check path to /api/health
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    matcher             = "200-299" # Assuming /api returns HTTP 200 on success
  }
}

resource "aws_lb_target_group" "frontend_target_group" {
  name        = "frontend-target-group"
  port        = 4173
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id = var.VPC_ID

  health_check {
    enabled             = true
    interval            = 120
    path                = "/" # Adjust if your frontend has a specific health check path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Default policy, adjust as needed
  certificate_arn   = var.SSL_CERTIFICATE_ARN

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "api_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"] # Adjust if your frontend has a specific path
    }
  }
}

resource "aws_lb_listener_rule" "frontend_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"] # Adjust if your frontend has a specific path
    }
  }
}

resource "aws_ecs_service" "api_service" {
  name            = "api-service"     # Name the service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.api_task.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.api_target_group.arn
    container_name   = "fastapi-server"
    container_port   = 8000 # Update to match FastAPI port
  }

  network_configuration {
    subnets          = [var.PUBLIC_SUBNET_1, var.PUBLIC_SUBNET_2]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
    container_name   = "frontend-server"
    container_port   = 4173
  }

  network_configuration {
    subnets          = [var.PUBLIC_SUBNET_1, var.PUBLIC_SUBNET_2]
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id = var.VPC_ID
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.MYSQL_SG] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "service_security_group_id" {
  value = aws_security_group.service_security_group.id
}

output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}