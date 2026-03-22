# =============================================================================
# iam.tf - IAM Roles for ECS
# =============================================================================

# -----------------------------------------------------------------------------
# ECS Task Execution Role (for pulling images, logging)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------------------------------------------------
# ECS Task Role (for application permissions - EFS, SSM)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# EFS access policy
resource "aws_iam_role_policy" "ecs_task_efs" {
  name = "${var.project_name}-${var.environment}-efs-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientRead",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeFileSystems"
        ]
        Resource = data.aws_efs_file_system.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientRead"
        ]
        Resource = data.aws_efs_access_point.main.arn
      }
    ]
  })
}

# SSM permissions for ECS Exec (debugging)
resource "aws_iam_role_policy" "ecs_task_ssm" {
  name = "${var.project_name}-${var.environment}-ssm-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "ecs_task_logs" {
  name = "${var.project_name}-${var.environment}-logs-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.ecs.arn}:*"
      }
    ]
  })
}
