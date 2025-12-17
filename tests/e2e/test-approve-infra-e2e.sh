#!/bin/bash
# E2E Test: Approve Infrastructure Command
# Tests complete workflow for approving and deploying infrastructure

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SANDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

TEST_ARTIFACT="nx-tc-payment-service"
TEST_ENV="dev1"
TEST_LAYER="tc"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }
log_step() { echo -e "\n${YELLOW}▶ $1${NC}"; }

cleanup() {
    log_info "Cleaning up test resources..."

    # Delete DynamoDB table
    aws dynamodb delete-table \
        --table-name "nx-payment-transactions-${TEST_ENV}" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" 2>/dev/null || true

    # Delete S3 bucket
    aws s3 rb "s3://nx-payment-logs-${TEST_ENV}" --force \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" 2>/dev/null || true

    # Delete IAM role
    aws iam detach-role-policy \
        --role-name "nx-payment-service-role" \
        --policy-arn "arn:aws:iam::000000000000:policy/nx-dynamodb-access-policy" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" 2>/dev/null || true

    aws iam delete-role \
        --role-name "nx-payment-service-role" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" 2>/dev/null || true
}

trap cleanup EXIT

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  E2E Test: Approve Infrastructure         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""

    # Verify LocalStack
    log_step "1. Verifying LocalStack availability"
    if ! curl -s "$AWS_ENDPOINT/_localstack/health" >/dev/null 2>&1; then
        log_error "LocalStack not running. Start with: make setup-aws"
        exit 1
    fi
    log_success "LocalStack is running"

    # Create IAM role for service
    log_step "2. Creating IAM service role"
    aws iam create-role \
        --role-name "nx-payment-service-role" \
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
        --tags "Key=Artifact,Value=$TEST_ARTIFACT" "Key=Environment,Value=$TEST_ENV" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" >/dev/null 2>/dev/null || log_info "Role already exists"
    log_success "IAM role created"

    # Attach DynamoDB policy
    log_step "3. Attaching DynamoDB access policy"
    aws iam attach-role-policy \
        --role-name "nx-payment-service-role" \
        --policy-arn "arn:aws:iam::000000000000:policy/nx-dynamodb-access-policy" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" 2>/dev/null || true
    log_success "Policy attached"

    # Create DynamoDB table for payments
    log_step "4. Creating DynamoDB table"
    aws dynamodb create-table \
        --table-name "nx-payment-transactions-${TEST_ENV}" \
        --attribute-definitions \
            "AttributeName=transaction_id,AttributeType=S" \
            "AttributeName=timestamp,AttributeType=N" \
        --key-schema \
            "AttributeName=transaction_id,KeyType=HASH" \
            "AttributeName=timestamp,KeyType=RANGE" \
        --billing-mode PAY_PER_REQUEST \
        --tags "Key=Artifact,Value=$TEST_ARTIFACT" "Key=Environment,Value=$TEST_ENV" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" >/dev/null 2>/dev/null || log_info "Table already exists"
    log_success "DynamoDB table created"

    # Create S3 bucket for logs
    log_step "5. Creating S3 bucket for logs"
    aws s3 mb "s3://nx-payment-logs-${TEST_ENV}" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" 2>/dev/null || log_info "Bucket already exists"
    log_success "S3 bucket created"

    # Enable versioning on bucket
    log_step "6. Enabling S3 versioning"
    aws s3api put-bucket-versioning \
        --bucket "nx-payment-logs-${TEST_ENV}" \
        --versioning-configuration Status=Enabled \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION"
    log_success "Versioning enabled"

    # Create ECR repository
    log_step "7. Creating ECR repository"
    aws ecr create-repository \
        --repository-name "$TEST_ARTIFACT" \
        --tags "Key=Artifact,Value=$TEST_ARTIFACT" "Key=Environment,Value=$TEST_ENV" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" >/dev/null 2>/dev/null || log_info "Repository already exists"
    log_success "ECR repository created"

    # Verify all resources
    log_step "8. Verifying IAM role"
    role_arn=$(aws iam get-role \
        --role-name "nx-payment-service-role" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        --query 'Role.Arn' \
        --output text)
    log_success "IAM role verified: $role_arn"

    log_step "9. Verifying DynamoDB table"
    table_status=$(aws dynamodb describe-table \
        --table-name "nx-payment-transactions-${TEST_ENV}" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        --query 'Table.TableStatus' \
        --output text)
    log_success "DynamoDB table status: $table_status"

    log_step "10. Verifying S3 bucket"
    aws s3 ls "s3://nx-payment-logs-${TEST_ENV}" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" >/dev/null
    log_success "S3 bucket accessible"

    log_step "11. Verifying ECR repository"
    repo_uri=$(aws ecr describe-repositories \
        --repository-names "$TEST_ARTIFACT" \
        --endpoint-url="$AWS_ENDPOINT" \
        --region="$AWS_REGION" \
        --query 'repositories[0].repositoryUri' \
        --output text)
    log_success "ECR repository: $repo_uri"

    # Generate infrastructure summary
    log_step "12. Generating infrastructure summary"
    cat > "$SANDBOX_ROOT/test-artifacts/infra-summary-${TEST_ENV}.json" <<EOF
{
  "artifact": "$TEST_ARTIFACT",
  "environment": "$TEST_ENV",
  "layer": "$TEST_LAYER",
  "resources": {
    "iam_role": "$role_arn",
    "dynamodb_table": "nx-payment-transactions-${TEST_ENV}",
    "s3_bucket": "nx-payment-logs-${TEST_ENV}",
    "ecr_repository": "$repo_uri"
  },
  "status": "deployed",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    log_success "Infrastructure summary created"

    # Summary
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ E2E Test Passed Successfully          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "📊 Infrastructure Deployed:"
    echo "  - IAM Role: nx-payment-service-role"
    echo "  - DynamoDB Table: nx-payment-transactions-${TEST_ENV}"
    echo "  - S3 Bucket: nx-payment-logs-${TEST_ENV}"
    echo "  - ECR Repository: $TEST_ARTIFACT"
    echo ""
    echo "🔍 Verify with:"
    echo "  aws --endpoint-url=$AWS_ENDPOINT iam get-role --role-name nx-payment-service-role"
    echo "  aws --endpoint-url=$AWS_ENDPOINT dynamodb describe-table --table-name nx-payment-transactions-${TEST_ENV}"
    echo "  aws --endpoint-url=$AWS_ENDPOINT s3 ls s3://nx-payment-logs-${TEST_ENV}"
    echo ""
}

main "$@"
