#!/bin/bash
# LocalStack IAM Initialization Script
# Creates IAM roles, policies, and service accounts for artifact testing

set -e

AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

echo "🔐 Initializing IAM resources in LocalStack..."

# Create DevX service account role
echo "Creating IAM role: nx-artifact-service-account"
aws iam create-role \
  --role-name "nx-artifact-service-account" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }]
  }' \
  --description "Service account for Nexus artifacts" \
  --tags "Key=ManagedBy,Value=DevX" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || echo "  Role already exists"

# Create artifact execution role
echo "Creating IAM role: nx-artifact-execution-role"
aws iam create-role \
  --role-name "nx-artifact-execution-role" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  }' \
  --description "Execution role for ECS tasks" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || echo "  Role already exists"

# Create ECR access policy
echo "Creating IAM policy: nx-ecr-access-policy"
aws iam create-policy \
  --policy-name "nx-ecr-access-policy" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }]
  }' \
  --description "ECR access for Nexus artifacts" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || echo "  Policy already exists"

# Create S3 access policy
echo "Creating IAM policy: nx-s3-access-policy"
aws iam create-policy \
  --policy-name "nx-s3-access-policy" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::nx-artifacts/*",
        "arn:aws:s3:::nx-artifacts"
      ]
    }]
  }' \
  --description "S3 access for Nexus artifacts" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || echo "  Policy already exists"

# Create DynamoDB access policy
echo "Creating IAM policy: nx-dynamodb-access-policy"
aws iam create-policy \
  --policy-name "nx-dynamodb-access-policy" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/nx-*"
    }]
  }' \
  --description "DynamoDB access for Nexus artifacts" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || echo "  Policy already exists"

# Attach policies to service account role
echo "Attaching policies to nx-artifact-service-account role"
for policy in nx-ecr-access-policy nx-s3-access-policy nx-dynamodb-access-policy; do
  policy_arn="arn:aws:iam::000000000000:policy/${policy}"
  aws iam attach-role-policy \
    --role-name "nx-artifact-service-account" \
    --policy-arn "$policy_arn" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || true
done

# Create artifact-specific roles for different layers
LAYERS=(al bal bb bc bff ch tc xp)
for layer in "${LAYERS[@]}"; do
  role_name="nx-${layer}-service-role"
  echo "Creating layer-specific role: $role_name"

  aws iam create-role \
    --role-name "$role_name" \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }]
    }' \
    --description "Service role for ${layer} layer artifacts" \
    --tags "Key=Layer,Value=${layer}" "Key=ManagedBy,Value=DevX" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Role $role_name already exists"
done

echo "✅ IAM resources initialized successfully!"
