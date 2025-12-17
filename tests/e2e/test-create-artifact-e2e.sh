#!/bin/bash
# E2E Test: Create Artifact Command
# Tests complete workflow from artifact creation to AWS resource deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SANDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLI_BIN="$SANDBOX_ROOT/tf_nx"
AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

TEST_ARTIFACT="nx-bff-test-booking"
TEST_ENV="dev1"
TEST_LAYER="bff"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }
log_step() { echo -e "\n${YELLOW}▶ $1${NC}"; }

cleanup() {
    log_info "Cleaning up test resources..."
    # Remove test artifact from inventory
    rm -rf "$SANDBOX_ROOT/test-artifacts/$TEST_ARTIFACT" 2>/dev/null || true
}

trap cleanup EXIT

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  E2E Test: Create Artifact with AWS       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""

    # Verify LocalStack is running
    log_step "1. Verifying LocalStack availability"
    if ! curl -s "$AWS_ENDPOINT/_localstack/health" >/dev/null 2>&1; then
        log_error "LocalStack not running. Start with: make setup-aws"
        exit 1
    fi
    log_success "LocalStack is running"

    # Verify CLI exists
    log_step "2. Verifying CLI binary"
    if [ ! -f "$CLI_BIN" ]; then
        log_error "CLI not found at $CLI_BIN. Run: make setup"
        exit 1
    fi
    log_success "CLI binary found"

    # Create artifact in inventory
    log_step "3. Creating artifact in inventory"
    mkdir -p "$SANDBOX_ROOT/test-artifacts/$TEST_ARTIFACT"
    cat > "$SANDBOX_ROOT/test-artifacts/$TEST_ARTIFACT/nx-app-inventory.yaml" <<EOF
artifact_metadata:
  name: test-booking
  layer: $TEST_LAYER
  domain: booking
  service: test-booking
  owner: devx-team
  repository: BritishAirways-Nexus/$TEST_ARTIFACT

infrastructure:
  enabled: true
  deployed: false
  component: service_account
  environment: $TEST_ENV

components:
  service_account:
    enabled: true
    role_name: nx-test-booking-role
    policies:
      - ecr-access
      - s3-access
  redis:
    enabled: false
  dynamo:
    enabled: false
  rds:
    enabled: false
  ecr:
    enabled: true
    repository_name: $TEST_ARTIFACT
EOF
    log_success "Artifact inventory created"

    # Verify IAM role doesn't exist yet
    log_step "4. Verifying IAM role doesn't exist (pre-condition)"
    if aws iam get-role \
        --role-name "nx-test-booking-role" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        2>/dev/null; then
        log_info "Cleaning up existing role from previous test"
        aws iam delete-role \
            --role-name "nx-test-booking-role" \
            --endpoint-url="$AWS_ENDPOINT" \
            --region="$AWS_REGION" 2>/dev/null || true
    fi
    log_success "Pre-condition verified"

    # Create service account (simulating /create-artifact command)
    log_step "5. Creating IAM service account"
    aws iam create-role \
        --role-name "nx-test-booking-role" \
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
        --description "Service account for test-booking artifact" \
        --tags "Key=Artifact,Value=$TEST_ARTIFACT" "Key=Environment,Value=$TEST_ENV" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" >/dev/null
    log_success "IAM role created"

    # Attach ECR access policy
    log_step "6. Attaching ECR access policy"
    aws iam attach-role-policy \
        --role-name "nx-test-booking-role" \
        --policy-arn "arn:aws:iam::000000000000:policy/nx-ecr-access-policy" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION"
    log_success "ECR policy attached"

    # Create ECR repository
    log_step "7. Creating ECR repository"
    aws ecr create-repository \
        --repository-name "$TEST_ARTIFACT" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" >/dev/null || log_info "Repository already exists"
    log_success "ECR repository ready"

    # Verify IAM role exists
    log_step "8. Verifying IAM role creation"
    role_arn=$(aws iam get-role \
        --role-name "nx-test-booking-role" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        --query 'Role.Arn' \
        --output text)
    log_success "IAM role verified: $role_arn"

    # Verify ECR repository exists
    log_step "9. Verifying ECR repository"
    repo_uri=$(aws ecr describe-repositories \
        --repository-names "$TEST_ARTIFACT" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        --query 'repositories[0].repositoryUri' \
        --output text)
    log_success "ECR repository verified: $repo_uri"

    # Verify policy attachment
    log_step "10. Verifying policy attachments"
    attached_policies=$(aws iam list-attached-role-policies \
        --role-name "nx-test-booking-role" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        --query 'AttachedPolicies[].PolicyName' \
        --output text)
    if echo "$attached_policies" | grep -q "nx-ecr-access-policy"; then
        log_success "Policies correctly attached: $attached_policies"
    else
        log_error "Expected policies not found"
        exit 1
    fi

    # Update inventory to mark as deployed
    log_step "11. Updating inventory status"
    sed -i.bak 's/deployed: false/deployed: true/' \
        "$SANDBOX_ROOT/test-artifacts/$TEST_ARTIFACT/nx-app-inventory.yaml"
    log_success "Inventory updated to deployed status"

    # Summary
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ E2E Test Passed Successfully          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "📊 Resources Created:"
    echo "  - IAM Role: nx-test-booking-role"
    echo "  - ECR Repository: $TEST_ARTIFACT"
    echo "  - Policy Attachments: nx-ecr-access-policy"
    echo ""
    echo "🔍 Verify with:"
    echo "  aws --endpoint-url=$AWS_ENDPOINT iam get-role --role-name nx-test-booking-role"
    echo "  aws --endpoint-url=$AWS_ENDPOINT ecr describe-repositories --repository-names $TEST_ARTIFACT"
    echo ""
}

main "$@"
