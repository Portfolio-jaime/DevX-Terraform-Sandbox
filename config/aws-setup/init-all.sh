#!/bin/bash
# Master LocalStack Initialization Script
# Runs all AWS service initialization scripts in correct order

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting LocalStack initialization sequence..."
echo "=================================================="
echo ""

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack to be ready..."
max_attempts=30
attempt=0
while ! curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "❌ LocalStack failed to start after ${max_attempts} attempts"
    exit 1
  fi
  echo "  Attempt $attempt/$max_attempts..."
  sleep 2
done
echo "✅ LocalStack is ready!"
echo ""

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Run initialization scripts in order
# IAM first (roles and policies needed by other services)
if [ -f "$SCRIPT_DIR/init-iam.sh" ]; then
  echo "1/6 Running IAM initialization..."
  "$SCRIPT_DIR/init-iam.sh"
  echo ""
fi

# S3 (needed for Terraform state and artifacts)
if [ -f "$SCRIPT_DIR/init-s3.sh" ]; then
  echo "2/6 Running S3 initialization..."
  "$SCRIPT_DIR/init-s3.sh"
  echo ""
fi

# ECR (container registry)
if [ -f "$SCRIPT_DIR/init-ecr.sh" ]; then
  echo "3/6 Running ECR initialization..."
  "$SCRIPT_DIR/init-ecr.sh"
  echo ""
fi

# DynamoDB (database tables)
if [ -f "$SCRIPT_DIR/init-dynamodb.sh" ]; then
  echo "4/6 Running DynamoDB initialization..."
  "$SCRIPT_DIR/init-dynamodb.sh"
  echo ""
fi

# Redis (caching layer)
if [ -f "$SCRIPT_DIR/init-redis.sh" ]; then
  echo "5/6 Running Redis initialization..."
  "$SCRIPT_DIR/init-redis.sh"
  echo ""
fi

# RDS (relational databases)
if [ -f "$SCRIPT_DIR/init-rds.sh" ]; then
  echo "6/6 Running RDS initialization..."
  "$SCRIPT_DIR/init-rds.sh"
  echo ""
fi

echo "=================================================="
echo "✅ LocalStack initialization completed successfully!"
echo ""
echo "📊 Service Status:"
echo "  - IAM: Roles and policies configured"
echo "  - S3: Buckets created and configured"
echo "  - ECR: Repositories ready for images"
echo "  - DynamoDB: Tables created with indexes"
echo "  - Redis: Clusters configured per environment"
echo "  - RDS: Database instances initialized"
echo ""
echo "🌐 Access LocalStack services at:"
echo "  http://localhost:4566"
echo ""
echo "🔧 AWS CLI usage:"
echo "  export AWS_ENDPOINT_URL=http://localhost:4566"
echo "  aws --endpoint-url=\$AWS_ENDPOINT_URL <service> <command>"
echo ""
