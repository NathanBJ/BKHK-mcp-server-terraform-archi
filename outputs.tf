# =============================================================================
# outputs.tf - Output Values
# =============================================================================

# -----------------------------------------------------------------------------
# MCP Server URL
# -----------------------------------------------------------------------------

output "mcp_server_url" {
  description = "Public URL for the MCP server (HTTPS)"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/mcp"
}

output "api_gateway_url" {
  description = "API Gateway base URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

# -----------------------------------------------------------------------------
# ECS Information
# -----------------------------------------------------------------------------

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}

# -----------------------------------------------------------------------------
# Commands
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
    
    # Force new deployment
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --force-new-deployment
    
  EOT
}

output "ecs_exec_command" {
  description = "Command to connect to running container"
  value       = <<-EOT
    
    # Get task ID
    TASK_ID=$(aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --service-name ${aws_ecs_service.app.name} --query 'taskArns[0]' --output text | rev | cut -d'/' -f1 | rev)
    
    # Connect to container
    aws ecs execute-command --cluster ${aws_ecs_cluster.main.name} --task $TASK_ID --container app --interactive --command "/bin/sh"
    
  EOT
}

output "useful_commands" {
  description = "Useful AWS CLI commands"
  value       = <<-EOT
    
    # Check service status
    aws ecs describe-services --cluster ${aws_ecs_cluster.main.name} --services ${aws_ecs_service.app.name} --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
    
    # View ECS logs
    aws logs tail /ecs/${var.project_name}-${var.environment} --follow
    
    # View API Gateway logs
    aws logs tail /aws/apigateway/${var.project_name}-${var.environment} --follow
    
    # Force new deployment
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --force-new-deployment
    
    # Scale to 0
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --desired-count 0
    
    # Scale to 1
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --desired-count 1
    
    # Test
    curl ${aws_apigatewayv2_api.main.api_endpoint}/mcp
    
  EOT
}

output "mcp_client_config" {
  description = "Configuration for your MCP client"
  value       = <<-EOT
    
    # Update your MCP client:
    return streamablehttp_client("${aws_apigatewayv2_api.main.api_endpoint}/mcp")
    
  EOT
}
