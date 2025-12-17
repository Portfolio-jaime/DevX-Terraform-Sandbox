#!/bin/bash
# LocalStack ECR Initialization Script
# Creates ECR repositories for artifact testing

set -e

AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

echo "🐳 Initializing ECR repositories in LocalStack..."

# Define layers and their common artifacts
LAYERS=(
  "al:authentication-layer"
  "bal:booking-api-layer"
  "bb:booking-backend"
  "bc:booking-core"
  "bff:web-offer-seat:mobile-checkin:booking-flow"
  "ch:customer-hub"
  "tc:order-creator:payment-processor"
  "xp:experience-layer"
)

# Create ECR repositories for each layer
for layer_artifacts in "${LAYERS[@]}"; do
  IFS=':' read -r layer artifacts <<< "$layer_artifacts"

  IFS=':' read -ra ARTIFACT_LIST <<< "$artifacts"
  for artifact in "${ARTIFACT_LIST[@]}"; do
    repo_name="nx-${layer}-${artifact}"

    echo "Creating ECR repository: $repo_name"
    aws ecr create-repository \
      --repository-name "$repo_name" \
      --endpoint-url="$AWS_ENDPOINT" \
      --region="$AWS_REGION" \
      2>/dev/null || echo "  Repository $repo_name already exists"

    # Set lifecycle policy
    aws ecr put-lifecycle-policy \
      --repository-name "$repo_name" \
      --endpoint-url="$AWS_ENDPOINT" \
      --region="$AWS_REGION" \
      --lifecycle-policy-text '{
        "rules": [{
          "rulePriority": 1,
          "description": "Keep last 10 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": { "type": "expire" }
        }]
      }' 2>/dev/null || true
  done
done

# Create common infrastructure repositories
COMMON_REPOS=(
  "nx-base-image"
  "nx-sidecar-monitoring"
  "nx-init-container"
)

for repo in "${COMMON_REPOS[@]}"; do
  echo "Creating common repository: $repo"
  aws ecr create-repository \
    --repository-name "$repo" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Repository $repo already exists"
done

echo "✅ ECR repositories initialized successfully!"
