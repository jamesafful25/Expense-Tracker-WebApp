# --------------------------------------------------
# ECS Cluster
# --------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Project     = var.project_name
    Environment = var.environment
  }
}


# --------------------------------------------------
# CloudWatch Log Group
# --------------------------------------------------

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project_name}-${var.environment}-backend"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}


# --------------------------------------------------
# ECS Task Execution Role
# --------------------------------------------------

resource "aws_iam_role" "execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-execution-role"
    Project     = var.project_name
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# --------------------------------------------------
# ECS Application Task Role
# --------------------------------------------------

resource "aws_iam_role" "task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------
# Temporary Database Migration Task Role
# --------------------------------------------------

resource "aws_iam_role" "migration_task" {
  name = "${var.project_name}-${var.environment}-migration-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-migration-task-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------
# Temporary Migration Permission to Store App Credentials
# --------------------------------------------------

resource "aws_iam_role_policy" "migration_task_secrets" {
  name = "${var.project_name}-${var.environment}-migration-task-secrets-policy"
  role = aws_iam_role.migration_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue"
      ]

      Resource = var.db_app_secret_arn
    }]
  })
}

# --------------------------------------------------
# Secrets Manager Permissions for ECS Execution Role
# --------------------------------------------------

resource "aws_iam_role_policy" "execution_secrets" {
  name = "${var.project_name}-${var.environment}-ecs-secrets-policy"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = [
        var.db_app_secret_arn,
        var.app_secrets_arn
      ]
    }]
  })
}

# --------------------------------------------------
# Temporary Database Migration Execution Role
# --------------------------------------------------

resource "aws_iam_role" "migration_execution" {
  name = "${var.project_name}-${var.environment}-migration-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-migration-execution-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "migration_execution" {
  role = aws_iam_role.migration_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "migration_secrets" {
  name = "${var.project_name}-${var.environment}-migration-secrets-policy"
  role = aws_iam_role.migration_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = var.db_master_secret_arn
    }]
  })
}

# --------------------------------------------------
# ECS Backend Task Definition
# --------------------------------------------------

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-${var.environment}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = tostring(var.task_cpu)
  memory = tostring(var.task_memory)

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.ecr_repository_url}:${var.container_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = tostring(var.container_port)
        },
        {
          name  = "DB_HOST"
          value = var.db_address
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "FRONTEND_URL"
          value = var.frontend_url
        },
        {
          name  = "GOOGLE_CALLBACK_URL"
          value = var.google_callback_url
        },
        {
          name  = "MAX_FILE_SIZE"
          value = "10485760"
        },
        {
          name  = "JWT_EXPIRES_IN"
          value = "7d"
        }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${var.db_app_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_app_secret_arn}:password::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "${var.app_secrets_arn}:JWT_SECRET::"
        },
        {
          name      = "GOOGLE_CLIENT_ID"
          valueFrom = "${var.app_secrets_arn}:GOOGLE_CLIENT_ID::"
        },
        {
          name      = "GOOGLE_CLIENT_SECRET"
          valueFrom = "${var.app_secrets_arn}:GOOGLE_CLIENT_SECRET::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-task"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------
# One-Time Database Initialization Task Definition
# --------------------------------------------------

resource "aws_ecs_task_definition" "migration" {
  family                   = "${var.project_name}-${var.environment}-db-migration"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = tostring(var.task_cpu)
  memory = tostring(var.task_memory)

  execution_role_arn = aws_iam_role.migration_execution.arn
  task_role_arn      = aws_iam_role.migration_task.arn

  container_definitions = jsonencode([
    {
      name      = "db-migration"
      image     = "${var.ecr_repository_url}:${var.container_image_tag}"
      essential = true

      command = [
        "node",
        "migrations/initialize-database.js"
      ]

      environment = [
        {
          name  = "DB_HOST"
          value = var.db_address
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_APP_SECRET_ARN"
          value = var.db_app_secret_arn
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]

      secrets = [
        {
          name      = "DB_MASTER_USERNAME"
          valueFrom = "${var.db_master_secret_arn}:username::"
        },
        {
          name      = "DB_MASTER_PASSWORD"
          valueFrom = "${var.db_master_secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "db-migration"
        }
      }
    }
  ])

  depends_on = [
    aws_iam_role_policy_attachment.migration_execution,
    aws_iam_role_policy.migration_secrets,
    aws_iam_role_policy.migration_task_secrets
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-migration"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------
# ECS Backend Service
# --------------------------------------------------

resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-${var.environment}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  platform_version = "LATEST"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "backend"
    container_port   = var.container_port
  }

  depends_on = [
    aws_iam_role_policy_attachment.execution,
    aws_iam_role_policy.execution_secrets
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-service"
    Project     = var.project_name
    Environment = var.environment
  }
}