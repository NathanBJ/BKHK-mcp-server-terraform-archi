# =============================================================================
# outputs.tf - Output Values
# =============================================================================

# -----------------------------------------------------------------------------
# MCP Server URL
# -----------------------------------------------------------------------------

output "mcp_server_url" {
  description = "Public URL for the MCP server"
  value       = "https://${aws_apprunner_service.mcp_server.service_url}"
}

output "mcp_server_arn" {
  description = "ARN of the App Runner service"
  value       = aws_apprunner_service.mcp_server.arn
}

output "mcp_server_id" {
  description = "ID of the App Runner service"
  value       = aws_apprunner_service.mcp_server.service_id
}

# -----------------------------------------------------------------------------
# Connection Information
# -----------------------------------------------------------------------------

output "health_check_url" {
  description = "Health check endpoint"
  value       = "https://${aws_apprunner_service.mcp_server.service_url}/health"
}

# -----------------------------------------------------------------------------
# Docker Push Commands
# -----------------------------------------------------------------------------

output "docker_push_commands" {
  description = "Commands to build and push the MCP server image"
  value       = <<-EOT
    
    # Authenticate with ECR
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${split("/", var.ecr_repository_url)[0]}
    
    # Build the image
    docker build -t ${var.ecr_repository_url}:${var.container_image_tag} .
    
    # Push to ECR
    docker push ${var.ecr_repository_url}:${var.container_image_tag}
    
    # Trigger new deployment (after pushing new image)
    aws apprunner start-deployment --service-arn ${aws_apprunner_service.mcp_server.arn}
    
  EOT
}

# -----------------------------------------------------------------------------
# Useful Commands
# -----------------------------------------------------------------------------

output "useful_commands" {
  description = "Useful AWS CLI commands"
  value       = <<-EOT
    
    # Check service status
    aws apprunner describe-service --service-arn ${aws_apprunner_service.mcp_server.arn} --query 'Service.Status'
    
    # View logs
    aws logs tail /aws/apprunner/${var.project_name}-${var.environment}/${aws_apprunner_service.mcp_server.service_id} --follow
    
    # Trigger deployment (after pushing new image)
    aws apprunner start-deployment --service-arn ${aws_apprunner_service.mcp_server.arn}
    
    # Pause service (to save costs)
    aws apprunner pause-service --service-arn ${aws_apprunner_service.mcp_server.arn}
    
    # Resume service
    aws apprunner resume-service --service-arn ${aws_apprunner_service.mcp_server.arn}
    
    # Test the MCP server
    curl https://${aws_apprunner_service.mcp_server.service_url}/health
    
  EOT
}

# -----------------------------------------------------------------------------
# MCP Client Configuration
# -----------------------------------------------------------------------------

output "mcp_client_config" {
  description = "Configuration for your MCP client"
  value       = <<-EOT
    
    # Add this to your MCP client configuration:
    
    MCP_SERVER_URL=https://${aws_apprunner_service.mcp_server.service_url}
    
    # Example Python client:
    # client = MCPClient(server_url="https://${aws_apprunner_service.mcp_server.service_url}")
    
  EOT
}

# -----------------------------------------------------------------------------
# VPC Connector Info
# -----------------------------------------------------------------------------

output "vpc_connector_arn" {
  description = "ARN of the VPC connector"
  value       = aws_apprunner_vpc_connector.main.arn
}

output "apprunner_security_group_id" {
  description = "Security group ID for App Runner"
  value       = aws_security_group.apprunner.id
}
