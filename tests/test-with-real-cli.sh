#!/bin/bash
# Test CLI Real - Executes tests against actual nx-terraform-builder
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SANDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_BIN="$SANDBOX_ROOT/tf_nx"
TEST_DIR="/tmp/cli-real-test-$$"
LOG_FILE="$TEST_DIR/test-real-cli.log"

# Contadores
test_count=0
pass_count=0
fail_count=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }

setup_test_env() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Testing REAL CLI - nx-terraform-builder  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

    mkdir -p "$TEST_DIR"

    # Verificar CLI existe
    if [ ! -f "$CLI_BIN" ]; then
        log_error "CLI not found. Run: ./tests/setup-real-cli.sh"
        exit 1
    fi

    log_success "CLI found: $CLI_BIN"

    # Setup repos
    export NEXUS_INFRASTRUCTURE_REPO="$SANDBOX_ROOT/repos/nexus-infrastructure"
    export NX_BOLT_ENV_REPO="$SANDBOX_ROOT/repos/nx-bolt-environment-dev1"
    export NX_INVENTORY_REPO="$SANDBOX_ROOT/repos/nx-artifacts-inventory"

    log_info "Environment configured"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_output="$3"

    test_count=$((test_count + 1))
    echo -e "\n${BLUE}🧪 Test $test_count: $test_name${NC}"

    local output
    local exit_code

    if output=$(eval "$test_command" 2>&1); then
        exit_code=0

        # Validar output esperado
        if [ -n "$expected_output" ]; then
            if echo "$output" | grep -q "$expected_output"; then
                log_success "PASS: $test_name"
                pass_count=$((pass_count + 1))
            else
                log_error "FAIL: Expected output not found"
                log_error "Expected: $expected_output"
                log_error "Got: $output"
                fail_count=$((fail_count + 1))
                exit_code=1
            fi
        else
            log_success "PASS: $test_name"
            pass_count=$((pass_count + 1))
        fi
    else
        exit_code=$?
        log_error "FAIL: $test_name (exit $exit_code)"
        log_error "Output: $output"
        fail_count=$((fail_count + 1))
    fi

    echo "[$exit_code] $test_name" >> "$LOG_FILE"
    echo "$output" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
}

# Tests con CLI real
test_cli_help() {
    echo -e "\n${YELLOW}📖 Testing Help Command${NC}"
    run_test "CLI Help" "$CLI_BIN --help" "Usage"
    run_test "CLI Version" "$CLI_BIN --version || $CLI_BIN version" ""
}

test_artifact_commands() {
    echo -e "\n${YELLOW}📦 Testing Artifact Commands${NC}"

    local test_artifact="nx-bff-web-test"
    local test_env="dev1"

    # Test create artifact
    run_test "Create Artifact" \
        "$CLI_BIN create-artifact --name=$test_artifact --env=$test_env --layer=bff" \
        "created\|success\|Created"

    # Test list artifacts
    run_test "List Artifacts" \
        "$CLI_BIN list-artifacts --env=$test_env" \
        ""

    # Test artifact info
    run_test "Artifact Info" \
        "$CLI_BIN artifact info --name=$test_artifact" \
        ""
}

test_infrastructure_commands() {
    echo -e "\n${YELLOW}☁️  Testing Infrastructure Commands${NC}"

    local test_artifact="nx-tc-test-infra"

    # Redis
    run_test "Redis Create" \
        "$CLI_BIN redis create --artifact=$test_artifact --env=dev1" \
        ""

    # ECR
    run_test "ECR Create" \
        "$CLI_BIN ecr create --artifact=$test_artifact --env=dev1" \
        ""
}

test_error_handling() {
    echo -e "\n${YELLOW}❌ Testing Error Scenarios${NC}"

    # Comandos inválidos deben fallar
    if $CLI_BIN invalid-command 2>/dev/null; then
        log_error "Invalid command should fail"
        fail_count=$((fail_count + 1))
    else
        log_success "Invalid command correctly rejected"
        pass_count=$((pass_count + 1))
    fi
    test_count=$((test_count + 1))
}

generate_report() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         TEST RESULTS SUMMARY          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Total tests: $test_count"
    echo -e "Passed: ${GREEN}$pass_count${NC}"
    echo -e "Failed: ${RED}$fail_count${NC}"

    if [ $fail_count -eq 0 ]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}"
        echo -e "CLI is working correctly"
        return 0
    else
        echo -e "\n${RED}✗ Some tests failed${NC}"
        echo -e "Check logs: $LOG_FILE"
        return 1
    fi
}

cleanup() {
    log_info "Cleaning up..."
    # No borrar cli-real, solo test artifacts
}

trap cleanup EXIT

# Main execution
main() {
    setup_test_env
    test_cli_help
    test_artifact_commands
    test_infrastructure_commands
    test_error_handling
    generate_report
}

main "$@"
