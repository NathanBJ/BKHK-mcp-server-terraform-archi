# =============================================================================
# apprunner.tf - App Runner Service for MCP Server
# =============================================================================

# -----------------------------------------------------------------------------
# App Runner Service
# -----------------------------------------------------------------------------

resource "aws_apprunner_service" "mcp_server" {
  service_name = "${var.project_name}-${var.environment}"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access.arn
    }

    image_repository {
      image_configuration {
        port = tostring(var.container_port)

        runtime_environment_variables = merge(
          {
            CHROMADB_PATH = var.chromadb_path
            EFS_MOUNT     = var.efs_mount_path
            PORT          = tostring(var.container_port)
          },
          var.hf_token != "" ? { HF_TOKEN = var.hf_token } : {},
          var.container_environment
        )
      }

      image_identifier      = "${var.ecr_repository_url}:${var.container_image_tag}"
      image_repository_type = "ECR"
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = tostring(var.container_cpu)
    memory            = tostring(var.container_memory)
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.main.arn
    }

    ingress_configuration {
      is_publicly_accessible = true
    }
  }

  health_check_configuration {
    protocol            = "TCP"
    #path                = "/mcp"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.apprunner_ecr,
    aws_iam_role_policy.apprunner_efs,
    aws_security_group_rule.efs_from_apprunner
  ]
}

# -----------------------------------------------------------------------------
# Auto Scaling Configuration
# -----------------------------------------------------------------------------

resource "aws_apprunner_auto_scaling_configuration_version" "main" {
  auto_scaling_configuration_name = "${var.project_name}-${var.environment}-scaling"

  min_size        = var.min_instances
  max_size        = var.max_instances
  max_concurrency = var.max_concurrency

  tags = {
    Name = "${var.project_name}-${var.environment}-scaling"
  }
}

# -----------------------------------------------------------------------------
# Custom Domain (Optional - uncomment if needed)
# -----------------------------------------------------------------------------

# resource "aws_apprunner_custom_domain_association" "main" {
#   domain_name = "mcp.yourdomain.com"
#   service_arn = aws_apprunner_service.mcp_server.arn
# }
