# =============================================================================
# variables.tf - Input Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Project Settings
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "mcp-server"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

# -----------------------------------------------------------------------------
# References to Existing Resources (from podcast pipeline)
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID where EFS is located (from podcast pipeline)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks (same as podcast pipeline)"
  type        = list(string)
}

variable "efs_file_system_id" {
  description = "EFS File System ID (from podcast pipeline output)"
  type        = string
}

variable "efs_access_point_id" {
  description = "EFS Access Point ID (from podcast pipeline output)"
  type        = string
}

variable "efs_security_group_id" {
  description = "Security Group ID that allows EFS access (from podcast pipeline)"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the MCP server image"
  type        = string
}

# -----------------------------------------------------------------------------
# Container Configuration
# -----------------------------------------------------------------------------

variable "container_image_tag" {
  description = "Docker image tag for MCP server"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the MCP server listens on"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "CPU units for Fargate (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "container_memory" {
  description = "Memory in MB for Fargate"
  type        = number
  default     = 1024
}

variable "efs_mount_path" {
  description = "Path where EFS is mounted inside the container"
  type        = string
  default     = "/mnt/efs"
}

variable "chromadb_path" {
  description = "Path to ChromaDB inside the EFS mount"
  type        = string
  default     = "/mnt/efs/chromadb"
}

# -----------------------------------------------------------------------------
# Scaling Configuration
# -----------------------------------------------------------------------------

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto-scaling"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 2
}

variable "scale_in_cooldown" {
  description = "Seconds to wait before scaling in"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Seconds to wait before scaling out"
  type        = number
  default     = 60
}

# -----------------------------------------------------------------------------
# Environment Variables for MCP Server
# -----------------------------------------------------------------------------

variable "container_environment" {
  description = "Environment variables for the MCP server container"
  type        = map(string)
  default     = {}
}

variable "hf_token" {
  description = "HuggingFace API token (for embeddings)"
  type        = string
  sensitive   = true
  default     = ""
}
