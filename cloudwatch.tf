# =============================================================================
# cloudwatch.tf - CloudWatch Log Groups
# =============================================================================

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-${var.environment}-api-gateway"
  }
}
