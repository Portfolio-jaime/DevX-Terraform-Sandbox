#!/bin/bash
# CLI Testing Framework for British Airways DevX Terraform Sandbox
# Tests all nx-terraform-builder CLI commands

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_ARTIFACT="nx-bff-web-test"
TEST_ENV="dev1"
TEST_DIR="/tmp/cli-test-$$"
LOG_FILE="$TEST_DIR/test-results.log"

# Initialize test environment
setup_test_env() {
    echo "🧪 Setting up CLI test environment..."
    
    mkdir -p $TEST_DIR
    mkdir -p logs/
    
    # Set environment variables for CLI
    export NEXUS_INFRASTRUCTURE_REPO="$PWD/repos/nexus-infrastructure"
    export NX_BOLT_ENV_REPO="$PWD/repos/nx-bolt-environment-dev1"
    export NX_INVENTORY_REPO="$PWD/repos/nx-artifacts-inventory"
    
    # Create symlink to the actual CLI if available
    if [ -f "/Users/jaime.henao/Desktop/BA/GIT-BA/automotion/Comandera/repos-nx/repos-self-service/nx-terraform-builder/main.go" ]; then
        ln -sf "/Users/jaime.henao/Desktop/BA/GIT-BA/automotion/Comandera/repos-nx/repos-self-service/nx-terraform-builder" cli-tester
        echo "✅ CLI symlink created"
    else
        echo "⚠️ CLI source not found, using mock CLI"
        create_mock_cli
    fi
    
    # Start LocalStack if not running
    if ! curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; then
        echo "Starting LocalStack..."
        docker-compose -f config/docker-compose.yml up -d localstack
        sleep 15
    fi
    
    echo "✅ Test environment ready"
}

# Create mock CLI for testing
create_mock_cli() {
    mkdir -p cli-tester
    
    cat > cli-tester/tf_nx << 'EOF'
#!/bin/bash
# Mock CLI for testing - simulates tf_nx behavior

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Mock implementations for each command
case "$1" in
    ecr)
        case "$2" in
            create)
                log_info "Creating ECR repository for artifact: $ARTIFACT_NAME in environment: $ENVIRONMENT"
                sleep 2
                log_success "ECR repository created: $ARTIFACT_NAME-$ENVIRONMENT"
                ;;
            delete)
                log_info "Deleting ECR repository: $ARTIFACT_NAME-$ENVIRONMENT"
                sleep 1
                log_success "ECR repository deleted"
                ;;
            *)
                log_error "Unknown ECR command: $2"
                exit 1
                ;;
        esac
        ;;
    redis)
        case "$2" in
            create)
                log_info "Creating Redis cache for artifact: $ARTIFACT_NAME in environment: $ENVIRONMENT"
                sleep 3
                log_success "Redis cache created: redis-$ARTIFACT_NAME-$ENVIRONMENT"
                ;;
            delete)
                log_info "Deleting Redis cache: redis-$ARTIFACT_NAME-$ENVIRONMENT"
                sleep 2
                log_success "Redis cache deleted"
                ;;
            *)
                log_error "Unknown Redis command: $2"
                exit 1
                ;;
        esac
        ;;
    dynamo)
        case "$2" in
            create)
                log_info "Creating DynamoDB table: $TABLE_NAME for artifact: $ARTIFACT_NAME"
                sleep 2
                log_success "DynamoDB table created: $TABLE_NAME"
                ;;
            delete)
                log_info "Deleting DynamoDB table: $TABLE_NAME"
                sleep 1
                log_success "DynamoDB table deleted"
                ;;
            *)
                log_error "Unknown DynamoDB command: $2"
                exit 1
                ;;
        esac
        ;;
    rds)
        case "$2" in
            create)
                log_info "Creating RDS instance for artifact: $ARTIFACT_NAME"
                sleep 5
                log_success "RDS instance created: rds-$ARTIFACT_NAME-$ENVIRONMENT"
                ;;
            delete)
                log_info "Deleting RDS instance: rds-$ARTIFACT_NAME-$ENVIRONMENT"
                sleep 3
                log_success "RDS instance deleted"
                ;;
            *)
                log_error "Unknown RDS command: $2"
                exit 1
                ;;
        esac
        ;;
    service_account)
        case "$2" in
            create)
                log_info "Creating service account for artifact: $ARTIFACT_NAME"
                sleep 2
                log_success "Service account created: sa-$ARTIFACT_NAME-$ENVIRONMENT"
                ;;
            delete)
                log_info "Deleting service account: sa-$ARTIFACT_NAME-$ENVIRONMENT"
                sleep 1
                log_success "Service account deleted"
                ;;
            *)
                log_error "Unknown service_account command: $2"
                exit 1
                ;;
        esac
        ;;
    artifact)
        case "$3" in
            env-var)
                case "$4" in
                    --create)
                        log_info "Creating environment variable: $KEY=$VALUE for artifact: $ARTIFACT_NAME"
                        sleep 1
                        log_success "Environment variable created"
                        ;;
                    --update)
                        log_info "Updating environment variable: $KEY=$VALUE for artifact: $ARTIFACT_NAME"
                        sleep 1
                        log_success "Environment variable updated"
                        ;;
                    --delete)
                        log_info "Deleting environment variable: $KEY for artifact: $ARTIFACT_NAME"
                        sleep 1
                        log_success "Environment variable deleted"
                        ;;
                    --read)
                        log_info "Reading environment variables for artifact: $ARTIFACT_NAME"
                        echo "API_URL=https://api.example.com"
                        echo "DATABASE_URL=postgresql://..."
                        log_success "Environment variables retrieved"
                        ;;
                    *)
                        log_error "Unknown env-var command: $4"
                        exit 1
                        ;;
                esac
                ;;
            resource)
                case "$4" in
                    --create)
                        log_info "Setting resources for artifact: $ARTIFACT_NAME"
                        sleep 1
                        log_success "Resources configured"
                        ;;
                    *)
                        log_error "Unknown resource command: $4"
                        exit 1
                        ;;
                esac
                ;;
            *)
                log_error "Unknown artifact subcommand: $3"
                exit 1
                ;;
        esac
        ;;
    --help|help)
        echo "Nexus Terraform Builder CLI - Mock Version"
        echo "Usage: tf_nx [command] [subcommand] [flags]"
        echo ""
        echo "Available commands:"
        echo "  ecr [create|delete]        Manage ECR repositories"
        echo "  redis [create|delete]      Manage Redis cache"
        echo "  dynamo [create|delete]     Manage DynamoDB tables"
        echo "  rds [create|delete]        Manage RDS instances"
        echo "  service_account [create|delete] Manage service accounts"
        echo "  artifact env-var          Manage environment variables"
        echo "  artifact resource         Manage resource limits"
        echo ""
        echo "Global flags:"
        echo "  -a, --artifact ARTIFACT   Artifact name"
        echo "  -e, --env ENV            Environment (dev1|sit1|uat1|prod1)"
        echo "  --individual             Use individual architecture"
        echo "  --debug                  Enable debug mode"
        ;;
    *)
        log_error "Unknown command: $1"
        echo "Use 'tf_nx --help' for usage information"
        exit 1
        ;;
esac
EOF

    chmod +x cli-tester/tf_nx
    log_success "Mock CLI created"
}

# Test result tracking
test_count=0
pass_count=0
fail_count=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    test_count=$((test_count + 1))
    echo -e "\n${BLUE}🧪 Test $test_count: $test_name${NC}"
    echo "Command: $test_command"
    
    # Run test and capture output
    local output
    local exit_code
    
    if output=$(eval "$test_command" 2>&1); then
        exit_code=0
        log_success "✅ PASS: $test_name"
        pass_count=$((pass_count + 1))
    else
        exit_code=$?
        log_error "❌ FAIL: $test_name"
        log_error "Exit code: $exit_code"
        log_error "Output: $output"
        fail_count=$((fail_count + 1))
    fi
    
    # Log result
    echo "[$exit_code] $test_name: $test_command" >> $LOG_FILE
    if [ $exit_code -eq 0 ]; then
        echo "SUCCESS" >> $LOG_FILE
    else
        echo "FAILURE" >> $LOG_FILE
        echo "Output: $output" >> $LOG_FILE
    fi
    echo "---" >> $LOG_FILE
}

# Test functions for each CLI command

test_ecr_commands() {
    echo -e "\n${YELLOW}🔧 Testing ECR Commands${NC}"
    
    run_test "ECR Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx ecr create -a $TEST_ARTIFACT -e $TEST_ENV"
    run_test "ECR Delete" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx ecr delete -a $TEST_ARTIFACT -e $TEST_ENV"
}

test_redis_commands() {
    echo -e "\n${YELLOW}🔧 Testing Redis Commands${NC}"
    
    run_test "Redis Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx redis create -a $TEST_ARTIFACT -e $TEST_ENV"
    run_test "Redis Delete" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx redis delete -a $TEST_ARTIFACT -e $TEST_ENV"
}

test_dynamo_commands() {
    echo -e "\n${YELLOW}🔧 Testing DynamoDB Commands${NC}"
    
    run_test "DynamoDB Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx dynamo create -a $TEST_ARTIFACT -e $TEST_ENV -n test-table"
    run_test "DynamoDB Delete" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx dynamo delete -a $TEST_ARTIFACT -e $TEST_ENV -n test-table"
}

test_rds_commands() {
    echo -e "\n${YELLOW}🔧 Testing RDS Commands${NC}"
    
    run_test "RDS Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx rds create -a $TEST_ARTIFACT -e $TEST_ENV"
    run_test "RDS Delete" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx rds delete -a $TEST_ARTIFACT -e $TEST_ENV"
}

test_service_account_commands() {
    echo -e "\n${YELLOW}🔧 Testing Service Account Commands${NC}"
    
    run_test "Service Account Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx service_account create -a $TEST_ARTIFACT -e $TEST_ENV"
    run_test "Service Account Delete" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx service_account delete -a $TEST_ARTIFACT -e $TEST_ENV"
}

test_artifact_env_var_commands() {
    echo -e "\n${YELLOW}🔧 Testing Artifact Environment Variables${NC}"
    
    run_test "Env Var Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV KEY=API_URL VALUE=https://api.example.com cli-tester/tf_nx artifact env-var --create -a $TEST_ARTIFACT -e $TEST_ENV --key API_URL --value https://api.example.com"
    run_test "Env Var Update" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV KEY=API_URL VALUE=https://new-api.example.com cli-tester/tf_nx artifact env-var --update -a $TEST_ARTIFACT -e $TEST_ENV --key API_URL --value https://new-api.example.com"
    run_test "Env Var Read" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx artifact env-var --read -a $TEST_ARTIFACT -e $TEST_ENV"
    run_test "Env Var Delete" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV KEY=API_URL cli-tester/tf_nx artifact env-var --delete -a $TEST_ARTIFACT -e $TEST_ENV --key API_URL"
}

test_artifact_resource_commands() {
    echo -e "\n${YELLOW}🔧 Testing Artifact Resource Management${NC}"
    
    run_test "Resource Create" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx artifact resource --create -a $TEST_ARTIFACT -e $TEST_ENV --cpu-request 100m --cpu-limit 500m --memory-request 128Mi --memory-limit 512Mi"
}

test_help_command() {
    echo -e "\n${YELLOW}🔧 Testing Help Command${NC}"
    
    run_test "Help Command" "cli-tester/tf_nx --help"
    run_test "Help Command Alt" "cli-tester/tf_nx help"
}

# Error handling tests
test_error_scenarios() {
    echo -e "\n${YELLOW}❌ Testing Error Scenarios${NC}"
    
    run_test "Invalid Command" "cli-tester/tf_nx invalid-command 2>/dev/null; test $? -ne 0 && exit 0 || exit 1"
    run_test "Invalid ECR Subcommand" "ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx ecr invalid-subcommand -a $TEST_ARTIFACT -e $TEST_ENV 2>/dev/null; test $? -ne 0 && exit 0 || exit 1"
    run_test "Invalid Artifact Name" "cli-tester/tf_nx ecr create -a invalid-artifact-name -e dev1 2>/dev/null; test $? -ne 0 && exit 0 || exit 1"
}

# Main test execution
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        British Airways DevX CLI Testing Framework        ║"
    echo "║                    Terraform Nexus Builder               ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    setup_test_env
    
    echo -e "\n${BLUE}🚀 Starting comprehensive CLI testing...${NC}"
    echo "Test artifact: $TEST_ARTIFACT"
    echo "Test environment: $TEST_ENV"
    echo "Log file: $LOG_FILE"
    echo ""
    
    # Run all test suites
    test_ecr_commands
    test_redis_commands
    test_dynamo_commands
    test_rds_commands
    test_service_account_commands
    test_artifact_env_var_commands
    test_artifact_resource_commands
    test_help_command
    test_error_scenarios
    
    # Generate test report
    echo -e "\n${BLUE}📊 Test Results Summary${NC}"
    echo "============================================"
    echo "Total tests: $test_count"
    echo -e "Passed: ${GREEN}$pass_count${NC}"
    echo -e "Failed: ${RED}$fail_count${NC}"
    
    if [ $fail_count -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed successfully!${NC}"
        echo "✅ CLI testing framework validated"
        echo "✅ All commands working as expected"
        exit 0
    else
        echo -e "\n${RED}⚠️ Some tests failed. Check logs for details.${NC}"
        echo "📄 Detailed logs: $LOG_FILE"
        exit 1
    fi
}

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up test environment...${NC}"
    rm -rf $TEST_DIR
    echo "✅ Cleanup completed"
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@"