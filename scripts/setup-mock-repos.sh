#!/bin/bash
# Setup script for British Airways DevX Terraform Sandbox
# Creates mock repository structures for testing

set -e

echo "📁 Setting up mock repository structures..."

# Create directory structure
mkdir -p repos/{nexus-infrastructure,nx-bolt-environment-dev1,nx-bolt-environment-sit1,nx-bolt-environment-uat1,nx-bolt-environment-prod1,nx-artifacts-inventory}

# Setup nexus-infrastructure structure (main Terraform configurations)
echo "🏗️ Setting up nexus-infrastructure mock..."
mkdir -p repos/nexus-infrastructure/{components/{tool,eks-teams-resources,waf},modules/{backup,elasticache-redis,subnets}}
mkdir -p repos/nexus-infrastructure/components/tool/{templates,config}
mkdir -p repos/nexus-infrastructure/modules/elasticache-redis/{templates,variables,outputs}

# Create basic Terraform files for nexus-infrastructure
cat > repos/nexus-infrastructure/components/tool/provider_aws.tf << 'EOF'
provider "aws" {
  region = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}
EOF

# Setup nx-bolt-environment-{env} structures (Helm configurations)
for env in dev1 sit1 uat1 prod1; do
  echo "🚀 Setting up nx-bolt-environment-$env..."
  mkdir -p repos/nx-bolt-environment-$env/kuma-resources-default-mesh
  
  # Create sample Helm charts for each layer
  for layer in al bal bb bc bff tc xp; do
    mkdir -p repos/nx-bolt-environment-$env/$layer/nx-$layer-test-service
    
    # Create Chart.yaml
    cat > repos/nx-bolt-environment-$env/$layer/nx-$layer-test-service/Chart.yaml << EOF
apiVersion: v2
name: nx-$layer-test-service
description: British Airways Nexus $layer layer service
version: 1.0.0
appVersion: "1.0"
EOF

    # Create values.yaml with common structure
    cat > repos/nx-bolt-environment-$env/$layer/nx-$layer-test-service/values.yaml << 'EOF'
# British Airways Nexus Service Configuration
replicaCount: 2

image:
  repository: nx-registry.nexus.britishairways.com/bff/web-service
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  hosts:
    - host: web-service.dev1.nexus.britishairways.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

external:
  redis:
    enabled: false
    endpoint: ""
    user: ""
    group_id: ""
    master: ""
  
  dynamodb:
    enabled: false
    table_name: ""
    region: ""
    endpoint: ""
EOF
  done
  
  # Create Kuma service mesh configuration
  cat > repos/nx-bolt-environment-$env/kuma-resources-default-mesh/values.yaml << 'EOF'
# Kuma Service Mesh Configuration
externalServices: []
EOF
done

# Setup nx-artifacts-inventory structure
echo "📋 Setting up nx-artifacts-inventory mock..."
mkdir -p repos/nx-artifacts-inventory/nx-artifacts/{bff,ch,al,bal,bb,bc,tc,xp}
mkdir -p repos/nx-artifacts-inventory/nx-artifacts/{dev,lib,sdk}

# Create inventory schema
cat > repos/nx-artifacts-inventory/app-inventory-schema.yaml << 'EOF'
# British Airways Nexus Artifact Inventory Schema
schema_version: "1.0"

artifact_metadata:
  artifact_name: string  # Required: artifact identifier
  layer: string         # Required: al|bal|bb|bc|bff|tc|xp
  domain: string        # Required: web|mobile|customer|payment|etc
  service: string       # Required: specific service name
  description: string   # Optional: artifact description
  owner: string         # Required: team or owner

infrastructure:
  enabled: boolean      # Required: whether infra creation is enabled
  deployed: boolean     # Required: whether infra is deployed
  component: string     # Required: service_account|redis|dynamo|rds|ecr
  environment: string   # Required: dev1|sit1|uat1|prod1

# AWS Components Configuration
components:
  service_account:
    name: string
    namespace: string
    enabled: boolean
    
  redis:
    name: string
    cluster_id: string
    endpoint: string
    enabled: boolean
    
  dynamo:
    table_name: string
    partition_key: string
    sort_key: string
    enabled: boolean
    
  rds:
    instance_class: string
    engine: string
    enabled: boolean
    
  ecr:
    repository_name: string
    image_tag: string
    enabled: boolean
EOF

# Create sample artifact inventory files
create_sample_inventory() {
  local layer=$1
  local service=$2
  local env=$3
  
  mkdir -p repos/nx-artifacts-inventory/nx-artifacts/$layer/nx-$layer-$service-$env
  cat > repos/nx-artifacts-inventory/nx-artifacts/$layer/nx-$layer-$service-$env/nx-app-inventory.yaml << EOF
schema_version: "1.0"

artifact_metadata:
  artifact_name: "nx-$layer-$service-$env"
  layer: "$layer"
  domain: "web"
  service: "$service"
  description: "Nexus $service for $layer layer in $env"
  owner: "devx-team"

infrastructure:
  enabled: false
  deployed: false
  component: "service_account"
  environment: "$env"

components:
  service_account:
    name: "sa-nx-$layer-$service-$env"
    namespace: "nexus-$env"
    enabled: false
    
  redis:
    name: ""
    cluster_id: ""
    endpoint: ""
    enabled: false
    
  dynamo:
    table_name: ""
    partition_key: ""
    sort_key: ""
    enabled: false
    
  rds:
    instance_class: ""
    engine: ""
    enabled: false
    
  ecr:
    repository_name: "nx-$layer-$service-$env"
    image_tag: "latest"
    enabled: false
EOF
}

# Create sample inventories for different layers and services
create_sample_inventory "bff" "web-offer-seat" "dev1"
create_sample_inventory "bff" "web-payment" "dev1"
create_sample_inventory "ch" "web-checkout" "dev1"
create_sample_inventory "bff" "web-offer-seat" "sit1"
create_sample_inventory "bff" "web-offer-seat" "uat1"
create_sample_inventory "bff" "web-offer-seat" "prod1"

echo "✅ Mock repository structures created successfully!"
echo ""
echo "📁 Repository structure:"
echo "  repos/nexus-infrastructure/     - Terraform configurations"
echo "  repos/nx-bolt-environment-dev1/ - Helm charts for dev1"
echo "  repos/nx-bolt-environment-sit1/ - Helm charts for sit1"
echo "  repos/nx-bolt-environment-uat1/ - Helm charts for uat1"
echo "  repos/nx-bolt-environment-prod1/ - Helm charts for prod1"
echo "  repos/nx-artifacts-inventory/   - Artifact inventory system"
echo ""
echo "🔧 Next steps:"
echo "  1. Set environment variables for repository paths"
echo "  2. Initialize LocalStack for AWS mocking"
echo "  3. Start testing CLI commands"