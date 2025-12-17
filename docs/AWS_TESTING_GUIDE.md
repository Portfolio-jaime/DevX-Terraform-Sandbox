# AWS Testing Guide - LocalStack Integration

## Overview

The DevX Sandbox provides complete AWS service mocking via LocalStack, enabling safe, cost-free testing of infrastructure commands without touching real AWS resources. This guide covers setup, usage, testing workflows, and troubleshooting.

## Table of Contents

1. [LocalStack Setup](#localstack-setup)
2. [Available AWS Services](#available-aws-services)
3. [Quick Start](#quick-start)
4. [Running E2E Tests](#running-e2e-tests)
5. [AWS Service Details](#aws-service-details)
6. [Testing Workflows](#testing-workflows)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)
9. [Advanced Usage](#advanced-usage)

---

## LocalStack Setup

### Prerequisites

- Docker installed and running
- Docker Compose v1.29+ or Docker Compose V2
- 4GB+ available RAM for LocalStack

### Starting LocalStack

```bash
# Start LocalStack with all AWS services
make setup-aws

# This will:
# 1. Start LocalStack container on port 4566
# 2. Initialize all AWS services (IAM, ECR, S3, DynamoDB, Redis, RDS)
# 3. Create mock resources for testing
# 4. Configure environment variables
```

### Verifying LocalStack Status

```bash
# Check if LocalStack is running
make status-aws

# Expected output:
# {
#   "services": {
#     "s3": "running",
#     "ecr": "running",
#     "dynamodb": "running",
#     "rds": "running",
#     "iam": "running",
#     "sts": "running"
#   }
# }
```

### Stopping LocalStack

```bash
# Stop LocalStack (keeps data)
make stop-aws

# Restart LocalStack with fresh data
make restart-aws

# Remove LocalStack and all data
make clean-aws
```

---

## Available AWS Services

LocalStack provides the following AWS service mocks:

### Core Services

| Service | Port | Description | Testing Use |
|---------|------|-------------|-------------|
| **IAM** | 4566 | Identity & Access Management | Service accounts, roles, policies |
| **STS** | 4566 | Security Token Service | Temporary credentials, role assumption |
| **S3** | 4566 | Simple Storage Service | Artifact storage, Terraform state |
| **ECR** | 4566 | Elastic Container Registry | Docker image repositories |
| **DynamoDB** | 4566 | NoSQL Database | Application data, session storage |
| **ElastiCache** | 4566 | Redis/Memcached | Caching layer testing |
| **RDS** | 4566 | Relational Database Service | PostgreSQL/MySQL testing |
| **CloudFormation** | 4566 | Infrastructure as Code | Stack testing |

### Service Endpoints

All services are accessible via: `http://localhost:4566`

```bash
# Environment variables for AWS CLI
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

---

## Quick Start

### 1. Complete Setup

```bash
# Clone and setup sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make setup

# Start LocalStack
make setup-aws
```

### 2. Verify Services

```bash
# Check LocalStack health
make status-aws

# View LocalStack logs
make logs-aws
```

### 3. Run First Test

```bash
# Test with AWS services
make test-e2e
```

---

## Running E2E Tests

### Complete Test Suite

```bash
# Run all E2E tests with AWS services
make test-e2e

# This executes:
# - Artifact lifecycle tests
# - Multi-environment testing
# - CLI command testing
# - Error recovery scenarios
# - Performance validation
```

### E2E Test Components

#### 1. Artifact Lifecycle Test
Tests complete artifact creation, deployment, and cleanup:

```bash
# Tests:
# - List artifacts before creation
# - Create new artifact with infrastructure
# - Verify artifact exists in inventory
# - Deploy to mock AWS services
# - Cleanup and verify removal
```

#### 2. Multi-Environment Test
Validates commands across all environments:

```bash
# Tests artifacts in:
# - dev1 (development)
# - sit1 (system integration)
# - uat1 (user acceptance)
# - prod1 (production simulation)
```

#### 3. Infrastructure Component Test
Tests individual AWS resources:

```bash
# Tests:
# - ECR repository creation
# - IAM role creation
# - S3 bucket operations
# - DynamoDB table creation
# - Redis cluster setup
# - RDS instance initialization
```

---

## AWS Service Details

### IAM (Identity and Access Management)

**Initialization**: Automatically creates roles and policies

**Resources Created**:
```bash
# Service account roles
- nx-artifact-service-account
- nx-artifact-execution-role

# Layer-specific roles
- nx-al-service-role
- nx-bal-service-role
- nx-bb-service-role
- nx-bc-service-role
- nx-bff-service-role
- nx-ch-service-role
- nx-tc-service-role
- nx-xp-service-role

# Policies
- nx-ecr-access-policy
- nx-s3-access-policy
- nx-dynamodb-access-policy
```

**Testing IAM**:
```bash
# List all roles
aws iam list-roles --endpoint-url=http://localhost:4566

# Get specific role
aws iam get-role \
  --role-name nx-artifact-service-account \
  --endpoint-url=http://localhost:4566

# List attached policies
aws iam list-attached-role-policies \
  --role-name nx-artifact-service-account \
  --endpoint-url=http://localhost:4566
```

**Use Cases**:
- Test service account creation via `/service-account` command
- Validate IAM policy generation
- Test role assumption in ECS tasks

---

### ECR (Elastic Container Registry)

**Initialization**: Creates repositories for all artifact layers

**Repositories Created**:
```bash
# Layer-specific repositories
- nx-al-*
- nx-bal-*
- nx-bb-*
- nx-bc-*
- nx-bff-web-offer-seat
- nx-bff-mobile-checkin
- nx-bff-booking-flow
- nx-ch-*
- nx-tc-order-creator
- nx-tc-payment-processor
- nx-xp-*

# Common repositories
- nx-base-image
- nx-sidecar-monitoring
- nx-init-container
```

**Testing ECR**:
```bash
# List repositories
aws ecr describe-repositories --endpoint-url=http://localhost:4566

# Get repository details
aws ecr describe-repositories \
  --repository-names nx-bff-web-offer-seat \
  --endpoint-url=http://localhost:4566

# Test image push (mock)
docker tag myimage:latest localhost:4566/nx-bff-test:latest
docker push localhost:4566/nx-bff-test:latest
```

**Use Cases**:
- Test `/create-artifact` ECR repository creation
- Validate lifecycle policies
- Test image push/pull workflows

---

### S3 (Simple Storage Service)

**Initialization**: Creates buckets for artifacts and Terraform state

**Buckets Created**:
```bash
# Environment-specific buckets
- nx-artifacts-dev1
- nx-artifacts-sit1
- nx-artifacts-uat1
- nx-artifacts-prod1

# Terraform state buckets
- nx-terraform-state-dev1
- nx-terraform-state-sit1
- nx-terraform-state-uat1
- nx-terraform-state-prod1

# Common buckets
- nx-deployment-packages
- nx-logs
```

**Testing S3**:
```bash
# List all buckets
aws s3 ls --endpoint-url=http://localhost:4566

# Create test bucket
aws s3 mb s3://test-bucket --endpoint-url=http://localhost:4566

# Upload file
aws s3 cp file.txt s3://test-bucket/ --endpoint-url=http://localhost:4566

# List bucket contents
aws s3 ls s3://nx-artifacts-dev1/ --endpoint-url=http://localhost:4566
```

**Use Cases**:
- Test artifact deployment packages
- Validate Terraform state storage
- Test configuration file uploads

---

### DynamoDB

**Initialization**: Creates tables for application data

**Tables Created**:
```bash
# Per environment
- nx-artifacts-dev1
- nx-sessions-dev1
- nx-cache-dev1
- nx-config-dev1

# Repeated for sit1, uat1, prod1
```

**Table Schema**:
```json
{
  "TableName": "nx-artifacts-dev1",
  "KeySchema": [
    { "AttributeName": "ArtifactId", "KeyType": "HASH" },
    { "AttributeName": "Version", "KeyType": "RANGE" }
  ],
  "AttributeDefinitions": [
    { "AttributeName": "ArtifactId", "AttributeType": "S" },
    { "AttributeName": "Version", "AttributeType": "S" },
    { "AttributeName": "Environment", "AttributeType": "S" }
  ],
  "GlobalSecondaryIndexes": [
    {
      "IndexName": "EnvironmentIndex",
      "KeySchema": [
        { "AttributeName": "Environment", "KeyType": "HASH" }
      ]
    }
  ]
}
```

**Testing DynamoDB**:
```bash
# List tables
aws dynamodb list-tables --endpoint-url=http://localhost:4566

# Describe table
aws dynamodb describe-table \
  --table-name nx-artifacts-dev1 \
  --endpoint-url=http://localhost:4566

# Put item
aws dynamodb put-item \
  --table-name nx-artifacts-dev1 \
  --item '{"ArtifactId": {"S": "nx-bff-test"}, "Version": {"S": "1.0.0"}}' \
  --endpoint-url=http://localhost:4566

# Get item
aws dynamodb get-item \
  --table-name nx-artifacts-dev1 \
  --key '{"ArtifactId": {"S": "nx-bff-test"}, "Version": {"S": "1.0.0"}}' \
  --endpoint-url=http://localhost:4566
```

**Use Cases**:
- Test `/add-dynamodb` command
- Validate table creation with indexes
- Test data operations

---

### ElastiCache (Redis)

**Initialization**: Creates Redis clusters per environment

**Clusters Created**:
```bash
# Per environment
- nx-redis-dev1
- nx-redis-sit1
- nx-redis-uat1
- nx-redis-prod1

# Per artifact (on demand)
- nx-bff-web-offer-seat-redis-dev1
```

**Configuration**:
```json
{
  "CacheClusterId": "nx-redis-dev1",
  "Engine": "redis",
  "CacheNodeType": "cache.t3.micro",
  "NumCacheNodes": 1,
  "Port": 6379
}
```

**Testing Redis**:
```bash
# List cache clusters
aws elasticache describe-cache-clusters \
  --endpoint-url=http://localhost:4566

# Create cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id nx-test-redis \
  --engine redis \
  --cache-node-type cache.t3.micro \
  --num-cache-nodes 1 \
  --endpoint-url=http://localhost:4566

# Connect to Redis (if exposed)
redis-cli -h localhost -p 6379
```

**Use Cases**:
- Test `/add-redis` command
- Validate cluster creation
- Test Redis configuration parameters

---

### RDS (Relational Database Service)

**Initialization**: Creates database instances per environment

**Instances Created**:
```bash
# PostgreSQL instances
- nx-postgres-dev1
- nx-postgres-sit1
- nx-postgres-uat1
- nx-postgres-prod1

# MySQL instances
- nx-mysql-dev1
- nx-mysql-sit1
- nx-mysql-uat1
- nx-mysql-prod1
```

**Configuration**:
```json
{
  "DBInstanceIdentifier": "nx-postgres-dev1",
  "DBInstanceClass": "db.t3.micro",
  "Engine": "postgres",
  "MasterUsername": "admin",
  "MasterUserPassword": "password",
  "AllocatedStorage": 20
}
```

**Testing RDS**:
```bash
# List DB instances
aws rds describe-db-instances --endpoint-url=http://localhost:4566

# Create DB instance
aws rds create-db-instance \
  --db-instance-identifier nx-test-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password password \
  --allocated-storage 20 \
  --endpoint-url=http://localhost:4566

# Get instance details
aws rds describe-db-instances \
  --db-instance-identifier nx-test-db \
  --endpoint-url=http://localhost:4566
```

**Use Cases**:
- Test `/add-rds` command
- Validate database instance creation
- Test connection parameters

---

## Testing Workflows

### Workflow 1: Create Artifact with Full Infrastructure

```bash
# 1. Start LocalStack
make setup-aws

# 2. Create artifact with all components
./test-review-artifact.sh --artifact my-test-app --environment dev1

# 3. Verify resources created:

# Check IAM role
aws iam get-role \
  --role-name nx-bff-service-role \
  --endpoint-url=http://localhost:4566

# Check ECR repository
aws ecr describe-repositories \
  --repository-names nx-bff-my-test-app \
  --endpoint-url=http://localhost:4566

# Check S3 bucket
aws s3 ls s3://nx-artifacts-dev1/ --endpoint-url=http://localhost:4566

# 4. Run E2E tests
make test-e2e
```

### Workflow 2: Test Redis Addition to Existing Artifact

```bash
# 1. Ensure LocalStack running
make status-aws

# 2. Add Redis to artifact (if CLI command exists)
# $CLI_BIN add-redis -a nx-bff-web-offer-seat -e dev1

# 3. Verify Redis cluster
aws elasticache describe-cache-clusters \
  --cache-cluster-id nx-bff-web-offer-seat-redis-dev1 \
  --endpoint-url=http://localhost:4566

# 4. Check configuration in inventory
cat repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml | grep -A 5 redis
```

### Workflow 3: Multi-Environment Deployment Test

```bash
# 1. Test across all environments
for env in dev1 sit1 uat1 prod1; do
  echo "Testing in $env..."
  ./test-review-artifact.sh --artifact web-offer-seat --environment $env
done

# 2. Verify resources per environment
for env in dev1 sit1 uat1 prod1; do
  echo "Checking S3 bucket for $env..."
  aws s3 ls s3://nx-artifacts-$env/ --endpoint-url=http://localhost:4566
done

# 3. Run integration tests
make test-integration
```

### Workflow 4: Error Recovery Testing

```bash
# 1. Start fresh LocalStack
make restart-aws

# 2. Test error scenarios
./tests/security_test.sh

# 3. Test with invalid inputs
./test-review-artifact.sh --artifact invalid-artifact || echo "Error handled correctly"

# 4. Verify LocalStack still healthy
make status-aws
```

---

## Troubleshooting

### LocalStack Won't Start

**Problem**: `make setup-aws` fails or hangs

**Solutions**:
```bash
# Check Docker is running
docker ps

# Check port 4566 not in use
lsof -i :4566
# If in use, kill the process
kill -9 <PID>

# Remove old LocalStack container
docker rm -f localstack

# Clean Docker volumes
make clean-aws

# Restart Docker
# macOS: Restart Docker Desktop
# Linux: sudo systemctl restart docker

# Try again
make setup-aws
```

### Health Check Fails

**Problem**: `make status-aws` returns error or shows services down

**Solutions**:
```bash
# View LocalStack logs
make logs-aws

# Common issues:

# 1. LocalStack still starting (wait 30s)
sleep 30 && make status-aws

# 2. Memory issues (increase Docker memory)
# Docker Desktop → Settings → Resources → Memory: 4GB+

# 3. Corrupted state
make restart-aws

# 4. Network issues
docker network ls
docker network inspect ba-sandbox-net
```

### AWS CLI Commands Fail

**Problem**: AWS CLI returns connection errors

**Solutions**:
```bash
# Verify environment variables
echo $AWS_ENDPOINT_URL  # Should be http://localhost:4566
echo $AWS_ACCESS_KEY_ID  # Should be 'test'

# Set if missing
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Test connection
curl http://localhost:4566/_localstack/health

# Use explicit endpoint
aws s3 ls --endpoint-url=http://localhost:4566
```

### Service Not Initialized

**Problem**: Specific AWS service returns "does not exist" errors

**Solutions**:
```bash
# Re-run initialization
./config/aws-setup/init-all.sh

# Or initialize specific service
./config/aws-setup/init-ecr.sh
./config/aws-setup/init-iam.sh
./config/aws-setup/init-s3.sh
./config/aws-setup/init-dynamodb.sh
./config/aws-setup/init-redis.sh
./config/aws-setup/init-rds.sh

# Verify service initialized
aws <service> list-<resources> --endpoint-url=http://localhost:4566
```

### Port Conflicts

**Problem**: Port 4566 already in use

**Solutions**:
```bash
# Find process using port
lsof -i :4566

# Option 1: Kill existing process
kill -9 <PID>

# Option 2: Stop existing LocalStack
docker stop localstack

# Option 3: Use different port (advanced)
# Edit config/docker-compose.yml and change port mapping
```

### E2E Tests Fail

**Problem**: `make test-e2e` shows failures

**Solutions**:
```bash
# Check LocalStack running
make status-aws

# View E2E test logs
cat /tmp/e2e-test-*/test-*.log

# Run specific test with debug
bash -x ./tests/e2e_test.sh

# Common failures:

# 1. CLI not built
./tests/setup-real-cli.sh

# 2. Services not initialized
./config/aws-setup/init-all.sh

# 3. Repository structure changed
make clean && make setup

# 4. Timing issues (increase wait times in tests)
```

### Data Persistence Issues

**Problem**: Data lost between LocalStack restarts

**Solutions**:
```bash
# LocalStack data stored in Docker volume
docker volume ls | grep localstack

# To persist data across restarts:
# 1. Don't use 'make clean-aws'
# 2. Use 'make stop-aws' instead

# To reset data:
make restart-aws
```

---

## Best Practices

### 1. Always Start Fresh for Critical Tests

```bash
# Before important test runs
make restart-aws
./config/aws-setup/init-all.sh
```

### 2. Use Environment Variables Consistently

```bash
# Add to your shell profile (~/.bashrc or ~/.zshrc)
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Or use shell function
aws-local() {
  aws --endpoint-url=http://localhost:4566 "$@"
}
```

### 3. Verify Services Before Testing

```bash
# Pre-test checklist
make status-aws                    # LocalStack health
aws s3 ls --endpoint-url=$AWS_ENDPOINT_URL  # S3 working
aws ecr describe-repositories --endpoint-url=$AWS_ENDPOINT_URL | head  # ECR working
```

### 4. Clean Up After Tests

```bash
# In test scripts, always cleanup
trap cleanup EXIT

cleanup() {
  # Remove test resources
  aws s3 rm s3://test-bucket --recursive --endpoint-url=$AWS_ENDPOINT_URL || true
  aws ecr delete-repository --repository-name test-repo --force --endpoint-url=$AWS_ENDPOINT_URL || true
}
```

### 5. Use Docker Compose Profiles

```bash
# Run specific services only
docker-compose -f config/docker-compose.yml --profile github up -d

# Run with monitoring
docker-compose -f config/docker-compose.yml --profile monitoring up -d
```

### 6. Monitor Resource Usage

```bash
# Check Docker resource usage
docker stats localstack

# If memory issues:
# - Reduce number of concurrent tests
# - Increase Docker memory limit
# - Use specific services instead of all
```

### 7. Log Everything

```bash
# Save test logs
make test-e2e 2>&1 | tee test-run-$(date +%Y%m%d-%H%M%S).log

# Save LocalStack logs
docker logs localstack > localstack-$(date +%Y%m%d-%H%M%S).log
```

---

## Advanced Usage

### Running Specific Services Only

```bash
# Edit config/docker-compose.yml
# Change SERVICES environment variable:
- SERVICES=s3,ecr,iam  # Only these services

# Or override at runtime
SERVICES=s3,ecr docker-compose -f config/docker-compose.yml up -d
```

### Custom Initialization Scripts

```bash
# Add your own init script
cat > config/aws-setup/init-custom.sh << 'EOF'
#!/bin/bash
set -e
AWS_ENDPOINT="http://localhost:4566"

# Your custom resources
aws s3 mb s3://my-custom-bucket --endpoint-url=$AWS_ENDPOINT
# ... more commands ...

echo "✅ Custom resources initialized!"
EOF

chmod +x config/aws-setup/init-custom.sh

# Add to init-all.sh
echo "7/7 Running custom initialization..."
./config/aws-setup/init-custom.sh
```

### Using LocalStack Pro Features

```bash
# If you have LocalStack Pro license
export LOCALSTACK_API_KEY=your-key-here

# Update docker-compose.yml
environment:
  - LOCALSTACK_API_KEY=${LOCALSTACK_API_KEY}

# Pro features include:
# - IAM policy enforcement
# - Real RDS databases
# - Advanced ECR features
# - CloudFront, API Gateway, etc.
```

### Integration with CI/CD

```yaml
# .github/workflows/test-with-localstack.yml
name: Test with LocalStack

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      localstack:
        image: localstack/localstack:latest
        ports:
          - 4566:4566
        env:
          SERVICES: s3,ecr,dynamodb,iam,rds
          DEBUG: 1

    steps:
      - uses: actions/checkout@v3

      - name: Wait for LocalStack
        run: |
          max_attempts=30
          attempt=0
          until curl -s http://localhost:4566/_localstack/health; do
            sleep 2
            attempt=$((attempt + 1))
            if [ $attempt -ge $max_attempts ]; then exit 1; fi
          done

      - name: Initialize AWS Services
        run: ./config/aws-setup/init-all.sh

      - name: Run E2E Tests
        run: make test-e2e
        env:
          AWS_ENDPOINT_URL: http://localhost:4566
          AWS_ACCESS_KEY_ID: test
          AWS_SECRET_ACCESS_KEY: test
          AWS_DEFAULT_REGION: us-east-1
```

### Performance Optimization

```bash
# 1. Use RAM disk for LocalStack data (Linux)
sudo mkdir -p /mnt/ramdisk
sudo mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk
export TMPDIR=/mnt/ramdisk

# 2. Disable debug mode in production tests
# Edit docker-compose.yml:
- DEBUG=0

# 3. Limit service initialization
# Only initialize services you need

# 4. Use persistent volumes strategically
# Keep frequently used data, recreate test data
```

---

## Summary

This guide covered:

- Complete LocalStack setup and configuration
- All 6 AWS services (IAM, ECR, S3, DynamoDB, Redis, RDS)
- Running E2E tests with AWS mocks
- Detailed testing workflows
- Comprehensive troubleshooting
- Best practices and advanced usage

For questions or issues:
1. Check `make logs-aws` for LocalStack logs
2. Review `make status-aws` for service health
3. Consult docs at: https://docs.localstack.cloud/
4. Check DevX team documentation

**Remember**: All testing is 100% local, safe, and cost-free. Test fearlessly!
