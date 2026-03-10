# MCP Server on AWS App Runner

Deploy your MCP server on AWS App Runner with EFS access (ChromaDB) and automatic scale-to-zero.

## Architecture

```
┌─────────────────┐
│   MCP Client    │
│ (outside AWS)   │
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────────────────────────────────────────────┐
│                    AWS App Runner                       │
│  ┌───────────────────────────────────────────────────┐ │
│  │              MCP Server Container                 │ │
│  │  - Public HTTPS endpoint                          │ │
│  │  - Auto scale-to-zero                             │ │
│  │  - ~20-30s cold start                             │ │
│  └───────────────────────────────────────────────────┘ │
└────────────────────────┬────────────────────────────────┘
                         │ VPC Connector
                         ▼
┌─────────────────────────────────────────────────────────┐
│                        EFS                              │
│              /chromadb (read-only)                      │
│         (from podcast pipeline)                         │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Podcast pipeline deployed** - You need the EFS and VPC from that project
2. **Docker image** - Your MCP server image pushed to ECR
3. **Terraform 1.5+** installed

## Quick Start

### 1. Get Values from Podcast Pipeline

In your podcast pipeline Terraform directory:

```bash
cd ../podcast-pipeline-terraform
terraform output
```

Note down:
- `vpc_id`
- `subnet_ids`
- `efs_file_system_id`
- `efs_access_point_id`
- `efs_security_group_id` (or `ecs_security_group_id`)
- `ecr_repository_url`

### 2. Configure This Project

```bash
cd mcp-server-terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values.

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Push Your MCP Server Image

```bash
# Get the push commands
terraform output docker_push_commands

# Follow the commands to push your image
```

### 5. Test

```bash
# Get the URL
terraform output mcp_server_url

# Test health endpoint
curl $(terraform output -raw mcp_server_url)/health
```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `vpc_id` | VPC where EFS is located | `vpc-12345678` |
| `subnet_ids` | Subnets for VPC connector (min 2) | `["subnet-xxx", "subnet-yyy"]` |
| `efs_file_system_id` | EFS filesystem ID | `fs-12345678` |
| `efs_access_point_id` | EFS access point ID | `fsap-12345678` |
| `efs_security_group_id` | Security group for EFS | `sg-12345678` |
| `ecr_repository_url` | ECR repository URL | `123456.dkr.ecr.eu-west-3.amazonaws.com/repo` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `container_port` | `8080` | Port your MCP server listens on |
| `container_cpu` | `1024` | CPU units (1024 = 1 vCPU) |
| `container_memory` | `2048` | Memory in MB |
| `min_instances` | `1` | Minimum instances |
| `max_instances` | `2` | Maximum instances |
| `hf_token` | `""` | HuggingFace API token (if needed) |

## Cost Estimation

| State | Approximate Cost |
|-------|-----------------|
| Running (1 vCPU, 2GB) | ~$0.064/hour (~$46/month) |
| Paused | $0 |
| Scale-to-zero (waiting) | Minimal |

**Cost saving tips:**
- App Runner pauses automatically after inactivity
- Use `aws apprunner pause-service` when not needed
- Cold start is ~20-30s

## Operations

### Pause Service (Save Costs)

```bash
aws apprunner pause-service --service-arn $(terraform output -raw mcp_server_arn)
```

### Resume Service

```bash
aws apprunner resume-service --service-arn $(terraform output -raw mcp_server_arn)
```

### View Logs

```bash
# Get the log command
terraform output useful_commands

# Or directly
aws logs tail /aws/apprunner/mcp-server-dev/SERVICE_ID --follow
```

### Deploy New Image

```bash
# After pushing new image to ECR
aws apprunner start-deployment --service-arn $(terraform output -raw mcp_server_arn)
```

## MCP Client Configuration

After deployment, configure your MCP client:

```python
# Python example
from mcp import Client

client = Client(
    server_url="https://xxxxx.eu-west-3.awsapprunner.com"
)
```

Or get the URL:

```bash
terraform output mcp_server_url
```

## Troubleshooting

### Service Not Starting

```bash
# Check service status
aws apprunner describe-service \
  --service-arn $(terraform output -raw mcp_server_arn) \
  --query 'Service.{Status:Status,Message:ServiceUrl}'
```

### EFS Connection Issues

1. Check security group rules allow NFS (port 2049)
2. Verify VPC connector is in same subnets as EFS mount targets
3. Check IAM role has EFS permissions

```bash
# Test from a container
aws apprunner describe-service \
  --service-arn $(terraform output -raw mcp_server_arn) \
  --query 'Service.NetworkConfiguration'
```

### Image Pull Errors

```bash
# Verify image exists
aws ecr describe-images \
  --repository-name YOUR_REPO \
  --query 'imageDetails[*].imageTags'
```

## Clean Up

```bash
terraform destroy
```

This will **not** delete the EFS (it's in the podcast pipeline).
