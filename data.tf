# =============================================================================
# data.tf - Reference Existing Resources
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_efs_file_system" "main" {
  file_system_id = var.efs_file_system_id
}

data "aws_efs_access_point" "main" {
  access_point_id = var.efs_access_point_id
}
