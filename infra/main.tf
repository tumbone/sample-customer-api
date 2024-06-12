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

resource "aws_security_group" "ecs_sg" {
  name        = "${local.naming_prefix}-sg"
  description = "Security Group for ECS"
  vpc_id      = "vpc-0cd43b3f77c7d9126"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs_sg_outbound_rule" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow internet egress"
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.ecs_sg.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "ecs_sg_inbound_rule" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow tcp inbound"
  from_port         = var.host_port
  protocol          = -1
  security_group_id = aws_security_group.ecs_sg.id
  to_port           = var.host_port
  type              = "ingress"
}

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

data "aws_iam_policy_document" "ecs_execution_role_logs_policy" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_execution_role_logs_policy" {
  name   = "${local.naming_prefix}-ecs-logs-policy"
  policy = data.aws_iam_policy_document.ecs_execution_role_logs_policy.json
}


resource "aws_iam_role" "ecs_execution_role" {
  name               = "${local.naming_prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_assume_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_logs_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_role_logs_policy.arn
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

resource "aws_ecs_service" "this" {
  name            = "${local.naming_prefix}-ecs-svc"
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  depends_on      = [aws_iam_role.ecs_execution_role]

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.this.arn
  #   container_name   = local.naming_prefix
  #   container_port   = var.container_port
  # }

  network_configuration {
    subnets          = ["subnet-0b48a9de2e556576a", "subnet-081c0813a049c90ad"]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# TODO: Configure service auto-scaling

##########################
# Elastic Load Balancer #
##########################