#!/bin/bash
# LocalStack S3 Initialization Script
# Creates S3 buckets for artifact testing

set -e

AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

echo "🪣 Initializing S3 buckets in LocalStack..."

# Define buckets
BUCKETS=(
  "nx-artifacts:Artifact storage bucket"
  "nx-terraform-state:Terraform state storage"
  "nx-deployment-logs:Deployment logs and audit trails"
  "nx-backup:Backup storage"
  "nx-config:Configuration files"
  "nx-static-assets:Static assets for web applications"
)

# Create buckets
for bucket_config in "${BUCKETS[@]}"; do
  IFS=':' read -r bucket_name description <<< "$bucket_config"

  echo "Creating S3 bucket: $bucket_name"
  aws s3 mb "s3://${bucket_name}" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Bucket $bucket_name already exists"

  # Enable versioning
  aws s3api put-bucket-versioning \
    --bucket "$bucket_name" \
    --versioning-configuration Status=Enabled \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || true

  # Add bucket tags
  aws s3api put-bucket-tagging \
    --bucket "$bucket_name" \
    --tagging "TagSet=[{Key=ManagedBy,Value=DevX},{Key=Description,Value=\"${description}\"}]" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || true
done

# Create environment-specific folders in artifacts bucket
echo "Creating environment folders in nx-artifacts bucket"
for env in dev1 sit1 uat1 prod1; do
  aws s3api put-object \
    --bucket "nx-artifacts" \
    --key "${env}/" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || true
done

# Set lifecycle policy for logs bucket
echo "Setting lifecycle policy for nx-deployment-logs"
aws s3api put-bucket-lifecycle-configuration \
  --bucket "nx-deployment-logs" \
  --lifecycle-configuration '{
    "Rules": [{
      "Id": "DeleteOldLogs",
      "Status": "Enabled",
      "Expiration": {
        "Days": 90
      },
      "Filter": {
        "Prefix": ""
      }
    }]
  }' \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || true

echo "✅ S3 buckets initialized successfully!"
