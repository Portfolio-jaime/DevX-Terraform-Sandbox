#!/bin/bash
# Run All E2E Tests
# Executes complete end-to-end test suite with LocalStack

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AWS_ENDPOINT="http://localhost:4566"

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }
log_header() { echo -e "${CYAN}$1${NC}"; }

run_test() {
    local test_name="$1"
    local test_script="$2"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    echo ""
    log_header "═══════════════════════════════════════════════════════"
    log_header "  Running: $test_name"
    log_header "═══════════════════════════════════════════════════════"

    if [ ! -f "$test_script" ]; then
        log_error "Test script not found: $test_script"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    if bash "$test_script"; then
        log_success "Test passed: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "Test failed: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

main() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║         DevX E2E Test Suite with LocalStack          ║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Verify LocalStack is running
    log_info "Checking LocalStack availability..."
    if ! curl -s "$AWS_ENDPOINT/_localstack/health" >/dev/null 2>&1; then
        log_error "LocalStack is not running!"
        echo ""
        echo "Start LocalStack with:"
        echo "  make setup-aws"
        echo ""
        exit 1
    fi
    log_success "LocalStack is ready"

    # Display LocalStack service status
    echo ""
    log_info "LocalStack Service Status:"
    curl -s "$AWS_ENDPOINT/_localstack/health" | jq '.' 2>/dev/null || echo "  Services running"

    # Make all test scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh

    # Run E2E tests
    echo ""
    log_header "Starting E2E Test Execution..."
    echo ""

    run_test "Create Artifact E2E" "$SCRIPT_DIR/test-create-artifact-e2e.sh" || true

    run_test "Add Redis E2E" "$SCRIPT_DIR/test-add-redis-e2e.sh" || true

    run_test "Approve Infrastructure E2E" "$SCRIPT_DIR/test-approve-infra-e2e.sh" || true

    # Summary
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                   Test Summary                        ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Total Tests:  $TESTS_TOTAL"
    echo -e "  ${GREEN}Passed:       $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed:       $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                       ║${NC}"
        echo -e "${GREEN}║          ✅ All E2E Tests Passed! ✅                  ║${NC}"
        echo -e "${GREEN}║                                                       ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        exit 0
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                                                       ║${NC}"
        echo -e "${RED}║          ❌ Some Tests Failed ❌                      ║${NC}"
        echo -e "${RED}║                                                       ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        exit 1
    fi
}

main "$@"
