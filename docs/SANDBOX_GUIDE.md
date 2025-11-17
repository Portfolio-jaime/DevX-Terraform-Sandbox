# British Airways DevX Terraform Sandbox - User Guide

## 🏗️ Overview

This comprehensive sandbox provides a complete end-to-end testing environment for the **Terraform Nexus Builder CLI** (`tf_nx`) used by British Airways DevX team. It enables safe testing of infrastructure changes before deployment to production.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Make utility
- Bash shell
- AWS CLI (optional)

### Initial Setup

```bash
# 1. Navigate to sandbox directory
cd /Users/jaime.henao/arheanja/Sandbox-Project

# 2. Run complete setup
make setup

# 3. Run all tests to validate
make test-all
```

## 🧪 Testing Framework

### Individual Command Testing

```bash
# Test all CLI commands
make test-cli

# Test specific command
make test-cli COMMAND=redis

# Test error scenarios
make test-errors
```

### Workflow Testing

```bash
# Test GitHub Actions workflow simulations
make test-workflows

# Test end-to-end integration
make test-integration

# Test Terraform validation
make test-terraform
```

### Development Testing

```bash
# Run CLI in development mode
make dev-cli

# Access AWS LocalStack shell
make shell-aws

# View all logs
make logs
```

## 📋 Available CLI Commands

The sandbox supports testing all `tf_nx` commands:

| Command | Description | Example |
|---------|-------------|---------|
| `tf_nx ecr` | ECR repository management | `tf_nx ecr create -a nx-bff-web-test -e dev1` |
| `tf_nx redis` | Redis cache provisioning | `tf_nx redis create -a nx-bff-web-test -e dev1` |
| `tf_nx dynamo` | DynamoDB table creation | `tf_nx dynamo create -a nx-bff-web-test -e dev1 -n test-table` |
| `tf_nx rds` | RDS database setup | `tf_nx rds create -a nx-bff-web-test -e dev1` |
| `tf_nx service_account` | Service account management | `tf_nx service_account create -a nx-bff-web-test -e dev1` |
| `tf_nx artifact env-var` | Environment variables | `tf_nx artifact env-var --create -a nx-bff-web-test -e dev1 --key API_URL --value https://api.example.com` |
| `tf_nx artifact resource` | Resource limits | `tf_nx artifact resource --create -a nx-bff-web-test -e dev1 --cpu-request 100m --cpu-limit 500m` |

## 🔄 Workflow Simulation

The sandbox simulates GitHub Actions workflows for the following scenarios:

### Create Artifact Workflow
```bash
# Simulate creating a new artifact
dispatch-workflow create-artifact nx-bff-web-test dev1
```

### Add Redis Workflow
```bash
# Simulate adding Redis to an artifact
dispatch-workflow add-redis nx-bff-web-test dev1
```

### Approve Infrastructure Workflow
```bash
# Simulate infrastructure approval and deployment
dispatch-workflow approve-infra-creation nx-bff-web-test dev1
```

## 🏗️ Repository Structure

The sandbox creates mock repository structures:

```
repos/
├── nexus-infrastructure/     # Terraform configurations
├── nx-bolt-environment-dev1/ # Helm charts for dev1
├── nx-bolt-environment-sit1/ # Helm charts for sit1
├── nx-bolt-environment-uat1/ # Helm charts for uat1
├── nx-bolt-environment-prod1/ # Helm charts for prod1
└── nx-artifacts-inventory/   # Artifact inventory system
```

## ☁️ AWS Mocking (LocalStack)

LocalStack provides AWS service mocking for:
- ECR (Elastic Container Registry)
- ElastiCache Redis
- DynamoDB
- RDS
- IAM Service Accounts
- S3 buckets

### AWS CLI Testing

```bash
# Test AWS connectivity
aws --endpoint-url=http://localhost:4566 sts get-caller-identity

# List mock resources
aws --endpoint-url=http://localhost:4566 ecr describe-repositories
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

## 🧱 Terraform Integration

The sandbox validates Terraform configurations and generates test plans:

```bash
# Run Terraform tests
make test-terraform

# View generated plans
ls terraform/test-plans/
```

## 📊 Monitoring and Logging

### View Test Results

```bash
# View all test logs
make logs

# Check specific test results
cat logs/workflow-test-results.log
cat logs/cli-test-results.log
```

### Start Monitoring Dashboard

```bash
# Start Prometheus monitoring (if configured)
make monitor
```

## 🔧 Development Workflow

### 1. Testing New CLI Commands

```bash
# Add new command test to tests/test-cli-commands.sh
# Run specific test
make test-cli COMMAND=newcommand
```

### 2. Adding New Workflows

```bash
# Add new workflow to scripts/setup-github-simulator.sh
# Test the workflow
./tests/test-workflows.sh
```

### 3. Terraform Module Testing

```bash
# Add new Terraform module test
# Run terraform validation
make test-terraform
```

## 🐛 Troubleshooting

### Common Issues

**LocalStack not starting:**
```bash
# Check Docker status
docker-compose -f config/docker-compose.yml ps

# Restart LocalStack
make clean-aws
make setup-aws
```

**CLI commands failing:**
```bash
# Check environment variables
echo $NEXUS_INFRASTRUCTURE_REPO
echo $NX_BOLT_ENV_REPO
echo $NX_INVENTORY_REPO

# Re-run setup
make setup-repos
```

**Test failures:**
```bash
# Clean and restart
make clean
make setup
make test-all
```

### Debug Mode

```bash
# Enable debug logging
export DEBUG=1
make test-cli

# Run with verbose output
bash -x ./tests/test-cli-commands.sh
```

## 📈 Advanced Usage

### Custom Test Scenarios

Create custom test scenarios in `tests/custom/`:

```bash
# Example custom test
cat > tests/custom/my-test.sh << 'EOF'
#!/bin/bash
# Custom test scenario
echo "Running custom test..."
# Add your test logic here
EOF

chmod +x tests/custom/my-test.sh
```

### Environment-Specific Testing

```bash
# Test specific environment
export TEST_ENV=sit1
make test-cli

# Test multiple environments
for env in dev1 sit1 uat1 prod1; do
    make test-cli ENV=$env
done
```

## 🧹 Cleanup

```bash
# Clean up everything
make clean

# Complete reset including Docker
make clean-all
```

## 📚 Additional Resources

- **API Documentation**: `docs/API_REFERENCE.md`
- **Architecture Guide**: `docs/ARCHITECTURE.md`
- **Contributing Guide**: `docs/CONTRIBUTING.md`
- **Troubleshooting**: `docs/TROUBLESHOOTING.md`

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section
2. Review test logs with `make logs`
3. Open an issue in the repository
4. Contact the DevX team

---

**Version**: 1.0.0  
**Last Updated**: November 2025  
**Maintainer**: British Airways DevX Team