#!/bin/bash
# LocalStack ElastiCache Redis Initialization Script
# Creates Redis clusters for artifact testing

set -e

AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

echo "🔴 Initializing Redis clusters in LocalStack..."

# Define environments and their configurations
ENVIRONMENTS=(
  "dev1:cache.t3.micro:1"
  "sit1:cache.t3.small:1"
  "uat1:cache.t3.medium:2"
  "prod1:cache.r6g.large:3"
)

# Create Redis cluster for each environment
for env_config in "${ENVIRONMENTS[@]}"; do
  IFS=':' read -r env node_type num_nodes <<< "$env_config"

  cluster_id="nx-shared-redis-${env}"

  echo "Creating Redis cluster: $cluster_id ($node_type, $num_nodes nodes)"

  aws elasticache create-cache-cluster \
    --cache-cluster-id "$cluster_id" \
    --cache-node-type "$node_type" \
    --engine redis \
    --engine-version "7.0" \
    --num-cache-nodes "$num_nodes" \
    --cache-subnet-group-name "nx-${env}-subnet-group" \
    --security-group-ids "sg-default" \
    --tags "Key=Environment,Value=${env}" "Key=ManagedBy,Value=DevX" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Cluster $cluster_id already exists"
done

# Create Redis parameter groups
PARAM_GROUPS=(
  "nx-redis-default:redis7.0"
  "nx-redis-session:redis7.0"
  "nx-redis-cache:redis7.0"
)

for param_config in "${PARAM_GROUPS[@]}"; do
  IFS=':' read -r group_name family <<< "$param_config"

  echo "Creating parameter group: $group_name"
  aws elasticache create-cache-parameter-group \
    --cache-parameter-group-name "$group_name" \
    --cache-parameter-group-family "$family" \
    --description "DevX Redis parameter group" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Parameter group $group_name already exists"
done

echo "✅ Redis clusters initialized successfully!"
