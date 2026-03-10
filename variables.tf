# =============================================================================
# variables.tf - Input Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Project Settings
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "BKHK-mcp-server"
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
  description = "Subnet IDs for VPC connector (same as podcast pipeline, need at least 2)"
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
  description = "ECR repository URL for the MCP server image (can be same as podcast pipeline)"
  type        = string
}

# -----------------------------------------------------------------------------
# App Runner Configuration
# -----------------------------------------------------------------------------

variable "container_image_tag" {
  description = "Docker image tag for MCP server"
  type        = string
  default     = "mcp-server-latest"
}

variable "container_port" {
  description = "Port the MCP server listens on"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "CPU units for App Runner (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "container_memory" {
  description = "Memory in MB for App Runner"
  type        = number
  default     = 2048
}

variable "efs_mount_path" {
  description = "Path where EFS is mounted inside the container"
  type        = string
  default     = "/app"
}

variable "chromadb_path" {
  description = "Path to ChromaDB inside the EFS mount"
  type        = string
  default     = "/mnt/efs/chromadb"
}

# -----------------------------------------------------------------------------
# App Runner Scaling Configuration
# -----------------------------------------------------------------------------

variable "min_instances" {
  description = "Minimum number of instances (0 for scale-to-zero, but App Runner min is 1 for provisioned)"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 2
}

variable "max_concurrency" {
  description = "Maximum concurrent requests per instance before scaling"
  type        = number
  default     = 50
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
