resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

locals {
  naming_prefix = "${var.application_name}-${random_string.this.result}"
}

###########
# AWS VPC #
###########


###############
# ECS CLUSTER #
###############

data "aws_iam_policy_document" "ecs_execution_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${local.naming_prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_assume_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "this" {
  name = "${local.naming_prefix}-ecs-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.naming_prefix
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name       = local.naming_prefix
      image      = var.container_image_uri
      cpu        = 0
      essential  = true
      entryPoint = var.container_entry_point
      command    = var.container_command
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.naming_prefix}"
          awslogs-create-group  = "true"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  # task_role_arn = ""
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
}

##########################
# Elastic Load Balancer #
##########################