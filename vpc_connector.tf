# =============================================================================
# vpc_connector.tf - VPC Connector for App Runner
# =============================================================================
# App Runner needs a VPC connector to access EFS (which is in a VPC)
# =============================================================================

# -----------------------------------------------------------------------------
# Security Group for App Runner VPC Connector
# -----------------------------------------------------------------------------

resource "aws_security_group" "apprunner" {
  name        = "${var.project_name}-${var.environment}-apprunner-sg"
  description = "Security group for App Runner VPC connector"
  vpc_id      = var.vpc_id

  # Egress: Allow NFS to EFS
  egress {
    description     = "NFS to EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.efs_security_group_id]
  }

  # Egress: Allow HTTPS for external APIs (HuggingFace, etc.)
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow HTTP (if needed)
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow DNS
  egress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-apprunner-sg"
  }
}

# -----------------------------------------------------------------------------
# Add Ingress Rule to EFS Security Group
# -----------------------------------------------------------------------------
# Allow App Runner to connect to EFS

resource "aws_security_group_rule" "efs_from_apprunner" {
  type                     = "ingress"
  description              = "NFS from App Runner"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.apprunner.id
  security_group_id        = var.efs_security_group_id
}

# -----------------------------------------------------------------------------
# VPC Connector
# -----------------------------------------------------------------------------

resource "aws_apprunner_vpc_connector" "main" {
  vpc_connector_name = "${var.project_name}-${var.environment}-connector"

  subnets         = var.subnet_ids
  security_groups = [aws_security_group.apprunner.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-connector"
  }
}
