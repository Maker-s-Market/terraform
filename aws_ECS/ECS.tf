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
  default     = "us-erast-1"
}

variable "PUBLIC_SUBNET_CIDR_BLOCKSAWS_SECRET_ACCESS_KEY" {
  type        = string
  default     = "api_AWS_SECRET_ACCESS_KEY"
}

variable "PUBLIC_SUBNET_CIDR_BLOCKSBUCKET_NAME" {
  type        = string
  default     = "api_BUCKET_NAME"
}

variable "PUBLIC_SUBNET_CIDR_BLOCKSUSER_POOL_ID" {
  type        = string
  default     = "api_USER_POOL_ID"
}

variable "PUBLIC_SUBNET_CIDR_BLOCKSCOGNITO_USER_CLIENT_ID" {
  type        = string
  default     = "api_COGNITO_USER_CLIENT_ID"
}

variable "PUBLIC_SUBNET_CIDR_BLOCKSCOGNITO_DOMAIN" {
  type        = string
  default     = "api_COGNITO_DOMAIN"
}
/*
variable "PUBLIC_SUBNET_CIDR_BLOCKSAUTH_URL" {
  type        = string
  default     = "https://${var.COGNITO_DOMAIN}/oauth2/authorize"
} */

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "makers3"
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
  name = "makers-test-cluster" # Name your cluster here
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
  family                   = "app-first-task"
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
          "value": "http://${aws_alb.application_load_balancer.dns_name}"
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
          "value": "http://${aws_alb.application_load_balancer.dns_name}/api"
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

resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}

resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-dev" #load balancer name
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}"
  ]
  # security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
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
  vpc_id      = aws_default_vpc.default_vpc.id

  health_check {
    enabled             = true
    interval            = 30
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
  vpc_id      = aws_default_vpc.default_vpc.id

  health_check {
    enabled             = true
    interval            = 30
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
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "api_listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
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
  listener_arn = aws_lb_listener.listener.arn
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
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
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
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}