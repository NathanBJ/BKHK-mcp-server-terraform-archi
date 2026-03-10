# =============================================================================
# iam.tf - IAM Roles for App Runner
# =============================================================================

# -----------------------------------------------------------------------------
# App Runner Access Role (for pulling images from ECR)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "apprunner_access" {
  name = "${var.project_name}-${var.environment}-apprunner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "build.apprunner.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr" {
  role       = aws_iam_role.apprunner_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# -----------------------------------------------------------------------------
# App Runner Instance Role (for EFS access)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "apprunner_instance" {
  name = "${var.project_name}-${var.environment}-apprunner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "tasks.apprunner.amazonaws.com"
      }
    }]
  })
}

# EFS access policy for App Runner instance
resource "aws_iam_role_policy" "apprunner_efs" {
  name = "${var.project_name}-${var.environment}-apprunner-efs-policy"
  role = aws_iam_role.apprunner_instance.id

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

# CloudWatch Logs policy (App Runner needs this)
resource "aws_iam_role_policy" "apprunner_logs" {
  name = "${var.project_name}-${var.environment}-apprunner-logs-policy"
  role = aws_iam_role.apprunner_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apprunner/*"
      }
    ]
  })
}
