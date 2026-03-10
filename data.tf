# =============================================================================
# data.tf - Reference Existing Resources
# =============================================================================
# These data sources reference resources created by the podcast pipeline
# =============================================================================

# Current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Reference the existing VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Reference the existing subnets
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

# Reference the existing EFS file system
data "aws_efs_file_system" "main" {
  file_system_id = var.efs_file_system_id
}

# Reference the existing EFS access point
data "aws_efs_access_point" "main" {
  access_point_id = var.efs_access_point_id
}

# Reference the existing security group for EFS
data "aws_security_group" "efs" {
  id = var.efs_security_group_id
}
