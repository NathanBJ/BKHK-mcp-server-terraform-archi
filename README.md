# MCP Server on ECS Fargate with API Gateway

Deploy your MCP server on AWS ECS Fargate with EFS access (ChromaDB) and public HTTPS endpoint via API Gateway.

## Architecture

```
MCP Client (HTTPS)
       │
       ▼
┌─────────────────────┐
│  API Gateway        │  ← Public HTTPS (~$1/mo)
│  HTTP API           │
└─────────┬───────────┘
          │ VPC Link
          ▼
┌─────────────────────┐
│  Cloud Map          │  ← Service Discovery
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│  ECS Fargate        │  ← With EFS mount
│  (MCP Server)       │
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│  EFS (ChromaDB)     │
└─────────────────────┘
```

## Quick Start

```bash
# 1. Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 2. Deploy
terraform init
terraform plan
terraform apply

# 3. Get URL
terraform output mcp_server_url
```

## Cost Estimation

| Component | Cost |
|-----------|------|
| API Gateway | ~$1/million requests |
| Cloud Map | ~$0.10/month |
| ECS Fargate (0.5 vCPU, 1GB) | ~$0.03/hour |
| **Total (running, low traffic)** | ~$22-25/month |
| **Total (scaled to 0)** | ~$1-3/month |

## Operations

### View Logs
```bash
aws logs tail /ecs/mcp-server-dev --follow
```

### Connect to Container (Debug)
```bash
TASK_ID=$(aws ecs list-tasks --cluster mcp-server-dev --service-name mcp-server-dev --query 'taskArns[0]' --output text | rev | cut -d'/' -f1 | rev)
aws ecs execute-command --cluster mcp-server-dev --task $TASK_ID --container app --interactive --command "/bin/sh"
```

### Deploy New Image
```bash
aws ecs update-service --cluster mcp-server-dev --service mcp-server-dev --force-new-deployment
```

### Scale to Zero
```bash
aws ecs update-service --cluster mcp-server-dev --service mcp-server-dev --desired-count 0
```

### Scale Up
```bash
aws ecs update-service --cluster mcp-server-dev --service mcp-server-dev --desired-count 1
```

## Files

| File | Description |
|------|-------------|
| `providers.tf` | AWS provider configuration |
| `variables.tf` | Input variables |
| `terraform.tfvars.example` | Example configuration |
| `data.tf` | Reference existing resources |
| `iam.tf` | IAM roles for ECS |
| `security_groups.tf` | Security groups |
| `cloudwatch.tf` | Log groups |
| `ecs.tf` | ECS cluster, task, service |
| `api_gateway.tf` | API Gateway + VPC Link + Cloud Map |
| `outputs.tf` | Output values |
