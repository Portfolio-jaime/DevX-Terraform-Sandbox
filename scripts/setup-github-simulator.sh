#!/bin/bash
# GitHub Actions Simulator for British Airways DevX Terraform Sandbox
# Simulates GitHub workflows that respond to issue comments

set -e

echo "🐙 Setting up GitHub Actions simulator..."

# Create workflow directory structure
mkdir -p github-simulator/workflows/{create-artifact,add-redis,approve-infra-creation,add-dynamo,env-var,resources}

# Create create-artifact workflow
cat > github-simulator/workflows/create-artifact/create-artifact.yml << 'EOF'
name: Create Artifact Workflow

on:
  repository_dispatch:
    types: [create-artifact-command]
  workflow_dispatch:
    inputs:
      artifact_name:
        description: 'Artifact name'
        required: true
        type: string
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
        - dev1
        - sit1
        - uat1
        - prod1

jobs:
  validate-artifact:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        repository: 'britishairways-nexus/nx-artifacts-inventory'
        token: ${{ secrets.GITHUB_TOKEN }}
        
    - name: Validate artifact structure
      run: |
        echo "🔍 Validating artifact structure for ${{ github.event.client_payload.artifact_name }}"
        
        # Check if artifact follows naming convention
        if [[ "${{ github.event.client_payload.artifact_name }}" =~ ^nx-(al|bal|bb|bc|bff|tc|xp)-(.+)$ ]]; then
          echo "✅ Artifact naming convention valid"
        else
          echo "❌ Invalid artifact naming convention"
          exit 1
        fi
        
    - name: Create inventory entry
      run: |
        ARTIFACT_NAME="${{ github.event.client_payload.artifact_name }}"
        ENVIRONMENT="${{ github.event.client_payload.environment }}"
        
        # Create inventory file structure
        mkdir -p "nx-artifacts/$(echo $ARTIFACT_NAME | cut -d'-' -f2)/$ARTIFACT_NAME"
        
        # Generate inventory YAML
        cat > "nx-artifacts/$(echo $ARTIFACT_NAME | cut -d'-' -f2)/$ARTIFACT_NAME/nx-$ENVIRONMENT-inventory.yaml" << INVENTORY_EOF
schema_version: "1.0"

artifact_metadata:
  artifact_name: "$ARTIFACT_NAME"
  layer: "$(echo $ARTIFACT_NAME | cut -d'-' -f2)"
  domain: "web"
  service: "$(echo $ARTIFACT_NAME | cut -d'-' -f3)"
  description: "Newly created artifact"
  owner: "${{ github.actor }}"

infrastructure:
  enabled: false
  deployed: false
  component: "service_account"
  environment: "$ENVIRONMENT"

components:
  service_account:
    name: "sa-$ARTIFACT_NAME"
    namespace: "nexus-$ENVIRONMENT"
    enabled: false
    
  redis:
    name: ""
    cluster_id: ""
    endpoint: ""
    enabled: false
    
  ecr:
    repository_name: "$ARTIFACT_NAME"
    image_tag: "latest"
    enabled: false
INVENTORY_EOF
        
        echo "📝 Inventory file created successfully"
        
    - name: Commit and push changes
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add .
        git commit -m "feat: Create artifact inventory for ${{ github.event.client_payload.artifact_name }}" || echo "No changes to commit"
        git push
        
    - name: Create approval comment
      uses: actions/github-script@v7
      with:
        script: |
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## ✅ Artifact Created Successfully
            
            **Artifact Name**: ${{ github.event.client_payload.artifact_name }}
            **Environment**: ${{ github.event.client_payload.environment }}
            **Layer**: $(echo ${{ github.event.client_payload.artifact_name }} | cut -d'-' -f2)
            
            The artifact has been registered in the inventory and is ready for infrastructure approval.
            
            Next steps:
            1. Run \`/approve-infra-creation --env=${{ github.event.client_payload.environment }}\` to deploy infrastructure
            2. Or run \`/add-redis --env=${{ github.event.client_payload.environment }}\` to add Redis cache
            
            ---
            *Workflow completed at: ${new Date().toISOString()}*`
          })
EOF

# Create add-redis workflow
cat > github-simulator/workflows/add-redis/add-redis.yml << 'EOF'
name: Add Redis Workflow

on:
  repository_dispatch:
    types: [add-redis-command]
  workflow_dispatch:
    inputs:
      artifact_name:
        description: 'Artifact name'
        required: true
        type: string
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
        - dev1
        - sit1
        - uat1
        - prod1

jobs:
  pre-validate-inventory:
    runs-on: ubuntu-latest
    outputs:
      changes_detected: ${{ steps.check.outputs.changes_detected }}
    steps:
    - name: Validate Redis prerequisites
      id: check
      run: |
        echo "🔍 Pre-validating Redis setup for ${{ github.event.client_payload.artifact_name }}"
        
        # Check if service account is deployed
        echo "Checking service account deployment..."
        # Mock check - in real scenario would check AWS/nexus-infrastructure
        echo "changes_detected=true" >> $GITHUB_OUTPUT
        
    - name: Update inventory for Redis
      run: |
        ARTIFACT_NAME="${{ github.event.client_payload.artifact_name }}"
        ENVIRONMENT="${{ github.event.client_payload.environment }}"
        
        INVENTORY_FILE="nx-artifacts/$(echo $ARTIFACT_NAME | cut -d'-' -f2)/$ARTIFACT_NAME/nx-$ENVIRONMENT-inventory.yaml"
        
        if [ -f "$INVENTORY_FILE" ]; then
          # Update inventory to enable Redis
          sed -i 's/redis:/redis:\n    enabled: true\n    name: "redis-'"$ARTIFACT_NAME"'-'"$ENVIRONMENT"'"\n    cluster_id: "'"$ENVIRONMENT"'-bc-'"$ARTIFACT_NAME"'"' $INVENTORY_FILE
          echo "✅ Redis configuration updated in inventory"
        else
          echo "❌ Inventory file not found: $INVENTORY_FILE"
          exit 1
        fi

  modify-inventory:
    needs: pre-validate-inventory
    runs-on: ubuntu-latest
    if: needs.pre-validate-inventory.outputs.changes_detected == 'true'
    steps:
    - name: Commit Redis configuration
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add .
        git commit -m "feat(redis): Enable Redis for ${{ github.event.client_payload.artifact_name }} in ${{ github.event.client_payload.environment }}" || echo "No changes"
        git push

  comments-handler:
    needs: [pre-validate-inventory, modify-inventory]
    runs-on: ubuntu-latest
    steps:
    - name: Notify Redis readiness
      uses: actions/github-script@v7
      with:
        script: |
          const changesDetected = context.payload.inputs?.changes_detected || 'true';
          
          if (changesDetected === 'true') {
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🟢 Redis Configuration Updated
            
            **Artifact**: ${{ github.event.client_payload.artifact_name }}
            **Environment**: ${{ github.event.client_payload.environment }}
            
            Redis has been enabled for this artifact. Now run:
            
            \`/approve-infra-creation --env=${{ github.event.client_payload.environment }}\`
            
            This will provision:
            - Redis ElastiCache cluster
            - Security groups
            - Subnet groups
            - Auto-configuration in Helm values
            
            ---
            *Ready for infrastructure deployment*`
            });
          } else {
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## ⚠️ Infrastructure Already Exists
            
            **Artifact**: ${{ github.event.client_payload.artifact_name }}
            **Environment**: ${{ github.event.client_payload.environment }}
            
            Redis infrastructure is already deployed for this artifact.
            
            **Action Required**: Contact a Platform Engineer to verify the configuration.
            
            ---
            *Manual review required*`
            });
          }
EOF

# Create approve-infra-creation workflow
cat > github-simulator/workflows/approve-infra-creation/approve-infra-creation.yml << 'EOF'
name: Approve Infrastructure Creation

on:
  repository_dispatch:
    types: [approve-infra-creation-command]
  workflow_dispatch:
    inputs:
      artifact_name:
        description: 'Artifact name'
        required: true
        type: string
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
        - dev1
        - sit1
        - uat1
        - prod1
      architecture:
        description: 'Architecture type'
        required: false
        type: choice
        options:
        - centralized
        - individual
        default: centralized

jobs:
  validate-permissions:
    runs-on: ubuntu-latest
    steps:
    - name: Check approver permissions
      run: |
        echo "🔐 Validating approver permissions..."
        
        # In real implementation, this would check GitHub teams/roles
        APPROVER_TEAMS=("platform-engineers" "devx-team" "sre-team")
        USER_TEAMS=("devs" "developers")  # Mock user teams
        
        echo "User: ${{ github.actor }}"
        echo "Required teams: ${APPROVER_TEAMS[@]}"
        echo "❌ User not in approver teams - would fail in real scenario"
        echo "✅ Proceeding in sandbox mode..."

  terraform-plan:
    needs: validate-permissions
    runs-on: ubuntu-latest
    steps:
    - name: Checkout nexus-infrastructure
      uses: actions/checkout@v4
      with:
        repository: 'britishairways-nexus/nexus-infrastructure'
        token: ${{ secrets.GITHUB_TOKEN }}
        path: nexus-infrastructure

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.5.0

    - name: Generate Terraform configuration
      run: |
        ARTIFACT_NAME="${{ github.event.client_payload.artifact_name }}"
        ENVIRONMENT="${{ github.event.client_payload.environment }}"
        ARCHITECTURE="${{ github.event.inputs.architecture || 'centralized' }}"
        
        echo "🏗️ Generating Terraform plan for:"
        echo "  Artifact: $ARTIFACT_NAME"
        echo "  Environment: $ENVIRONMENT"
        echo "  Architecture: $ARCHITECTURE"
        
        # Mock Terraform plan generation
        cat > terraform-plan.txt << PLAN_EOF
# Terraform Plan for $ARTIFACT_NAME in $ENVIRONMENT

## Resources to be created:

### Service Account
- aws_iam_role.service_account-$ARTIFACT_NAME-$ENVIRONMENT
- aws_iam_role_policy_attachment.service_account-$ARTIFACT_NAME-$ENVIRONMENT
- kubernetes_service_account.sa-$ARTIFACT_NAME-$ENVIRONMENT

### ECR Repository
- aws_ecr_repository.$ARTIFACT_NAME-$ENVIRONMENT
- aws_ecr_lifecycle_policy.$ARTIFACT_NAME-$ENVIRONMENT

### Redis (if enabled)
- aws_elasticache_subnet_group.redis-$ARTIFACT_NAME-$ENVIRONMENT
- aws_security_group.redis-$ARTIFACT_NAME-$ENVIRONMENT
- aws_elasticache_replication_group.redis-$ARTIFACT_NAME-$ENVIRONMENT

## Cost Estimate:
- Monthly: $45-75 depending on configuration
- Annual: $540-900
PLAN_EOF
        
        echo "📋 Terraform plan generated successfully"

    - name: Comment plan results
      uses: actions/github-script@v7
      with:
        script: |
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## 🏗️ Infrastructure Plan Generated
            
            **Artifact**: ${{ github.event.client_payload.artifact_name }}
            **Environment**: ${{ github.event.client_payload.environment }}
            **Architecture**: ${{ github.event.inputs.architecture || 'centralized' }}
            
            ### Resources to be created:
            - ✅ Service Account (IAM Role + Kubernetes SA)
            - ✅ ECR Repository with lifecycle policies
            - ✅ Redis ElastiCache (if enabled)
            - ✅ Security groups and networking
            
            ### Estimated Costs:
            - Monthly: $45-75
            - Annual: $540-900
            
            **Next Step**: Terraform will be applied automatically in 2 minutes.
            
            ---
            *Plan generated at: ${new Date().toISOString()}*`
          })

  apply-infrastructure:
    needs: [validate-permissions, terraform-plan]
    runs-on: ubuntu-latest
    steps:
    - name: Simulate infrastructure deployment
      run: |
        echo "🚀 Simulating infrastructure deployment..."
        
        # Simulate AWS API calls with mock responses
        sleep 5  # Simulate deployment time
        
        echo "✅ Service Account created (mock)"
        echo "✅ ECR Repository created (mock)"
        echo "✅ Redis cluster created (mock)"
        
        # Generate mock outputs
        cat > infrastructure-outputs.json << OUTPUTS_EOF
{
  "service_account_role_arn": "arn:aws:iam::123456789012:role/sa-${{ github.event.client_payload.artifact_name }}-${{ github.event.client_payload.environment }}",
  "ecr_repository_url": "123456789012.dkr.ecr.us-east-1.amazonaws.com/${{ github.event.client_payload.artifact_name }}-${{ github.event.client_payload.environment }}",
  "redis_endpoint": "redis-${{ github.event.client_payload.artifact_name }}-${{ github.event.client_payload.environment }}.abcdef.cache.amazonaws.com",
  "redis_port": 6379,
  "redis_auth_token": "mock-auth-token-$(date +%s)"
}
OUTPUTS_EOF
        
        echo "📋 Infrastructure outputs generated"

    - name: Update inventory status
      run: |
        ARTIFACT_NAME="${{ github.event.client_payload.artifact_name }}"
        ENVIRONMENT="${{ github.event.client_payload.environment }}"
        
        INVENTORY_FILE="nx-artifacts/$(echo $ARTIFACT_NAME | cut -d'-' -f2)/$ARTIFACT_NAME/nx-$ENVIRONMENT-inventory.yaml"
        
        if [ -f "$INVENTORY_FILE" ]; then
          # Update deployed status
          sed -i 's/deployed: false/deployed: true/' $INVENTORY_FILE
          sed -i 's/enabled: false/enabled: true/' $INVENTORY_FILE
          
          # Add infrastructure outputs
          echo "" >> $INVENTORY_FILE
          echo "infrastructure_outputs:" >> $INVENTORY_FILE
          echo "  service_account_arn: \"arn:aws:iam::123456789012:role/sa-$ARTIFACT_NAME-$ENVIRONMENT\"" >> $INVENTORY_FILE
          echo "  ecr_repository: \"123456789012.dkr.ecr.us-east-1.amazonaws.com/$ARTIFACT_NAME-$ENVIRONMENT\"" >> $INVENTORY_FILE
          echo "  redis_endpoint: \"redis-$ARTIFACT_NAME-$ENVIRONMENT.abcdef.cache.amazonaws.com\"" >> $INVENTORY_FILE
          
          echo "✅ Inventory updated with deployment status"
        fi

    - name: Commit deployment changes
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add .
        git commit -m "deploy: Infrastructure deployment for ${{ github.event.client_payload.artifact_name }} in ${{ github.event.client_payload.environment }}" || echo "No changes"
        git push

    - name: Notify deployment completion
      uses: actions/github-script@v7
      with:
        script: |
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## ✅ Infrastructure Deployed Successfully!
            
            **Artifact**: ${{ github.event.client_payload.artifact_name }}
            **Environment**: ${{ github.event.client_payload.environment }}
            **Deployment ID**: deploy-$(date +%s)
            
            ### Deployed Resources:
            - ✅ **Service Account**: sa-${{ github.event.client_payload.artifact_name }}-${{ github.event.client_payload.environment }}
            - ✅ **ECR Repository**: ${{ github.event.client_payload.artifact_name }}-${{ github.event.client_payload.environment }}
            - ✅ **Redis Cluster**: redis-${{ github.event.client_payload.artifact_name }}-${{ github.event.client_payload.environment }}
            
            ### Next Steps:
            1. Run \`/promote --env=${{ github.event.client_payload.environment }} --version=latest\` to deploy your application
            2. Configure environment variables with \`/env-var\`
            3. Set resource limits with \`/resources\`
            
            ---
            🎉 **Deployment completed successfully!**`
          })
EOF

# Create additional workflows for other commands
cat > github-simulator/workflows/add-dynamo/add-dynamo.yml << 'EOF'
name: Add DynamoDB Workflow

on:
  repository_dispatch:
    types: [add-dynamo-command]

jobs:
  create-dynamo-table:
    runs-on: ubuntu-latest
    steps:
    - name: Create DynamoDB table
      run: |
        echo "🗃️ Creating DynamoDB table for ${{ github.event.client_payload.artifact_name }}"
        # Mock DynamoDB creation logic
        sleep 3
        echo "✅ DynamoDB table created successfully"
EOF

cat > github-simulator/workflows/env-var/env-var.yml << 'EOF'
name: Environment Variables Workflow

on:
  repository_dispatch:
    types: [env-var-command]

jobs:
  manage-env-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Manage environment variables
      run: |
        echo "🔧 Managing environment variables for ${{ github.event.client_payload.artifact_name }}"
        # Mock environment variable management
        echo "✅ Environment variables updated"
EOF

echo "✅ GitHub Actions simulator created successfully!"
echo ""
echo "📁 Workflows created:"
echo "  create-artifact/     - Creates new artifact inventory"
echo "  add-redis/          - Adds Redis to existing artifact"
echo "  approve-infra-creation/ - Deploys infrastructure"
echo "  add-dynamo/         - Creates DynamoDB tables"
echo "  env-var/            - Manages environment variables"
echo ""
echo "🎯 Workflow simulation commands:"
echo "  dispatch-workflow create-artifact artifact-name environment"
echo "  dispatch-workflow add-redis artifact-name environment"
echo "  dispatch-workflow approve-infra-creation artifact-name environment"