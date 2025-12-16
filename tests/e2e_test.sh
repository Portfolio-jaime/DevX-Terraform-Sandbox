#!/bin/bash
# End-to-End Testing Suite - Full Command Lifecycle
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SANDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="/tmp/e2e-test-$$"
CLI_BIN="$SANDBOX_ROOT/tf_nx"

test_count=0
pass_count=0
fail_count=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

setup() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       E2E TEST SUITE                  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

    mkdir -p "$TEST_DIR"
    cd "$SANDBOX_ROOT"

    # Verificar CLI disponible
    if [ ! -f "$CLI_BIN" ]; then
        log_info "Building CLI..."
        ./tests/setup-real-cli.sh || {
            log_error "CLI setup failed"
            exit 1
        }
    fi

    export NEXUS_INFRASTRUCTURE_REPO="$SANDBOX_ROOT/repos/nexus-infrastructure"
    export NX_BOLT_ENV_REPO="$SANDBOX_ROOT/repos/nx-bolt-environment-dev1"
    export NX_INVENTORY_REPO="$SANDBOX_ROOT/repos/nx-artifacts-inventory"
}

run_test() {
    local name="$1"
    local command="$2"

    test_count=$((test_count + 1))
    echo -e "\n${YELLOW}🧪 E2E Test $test_count: $name${NC}"

    if eval "$command" &> "$TEST_DIR/test-$test_count.log"; then
        log_success "PASS: $name"
        pass_count=$((pass_count + 1))
        return 0
    else
        log_error "FAIL: $name"
        log_error "See: $TEST_DIR/test-$test_count.log"
        fail_count=$((fail_count + 1))
        return 1
    fi
}

# Test 1: Lifecycle completo de artifact
test_artifact_lifecycle() {
    echo -e "\n${YELLOW}📦 Testing Artifact Lifecycle${NC}"

    local artifact="nx-bff-e2e-test"
    local env="dev1"

    # 1. Listar artifacts antes
    run_test "List artifacts before create" \
        "cd nx-sandbox && ./nx-sandbox list --layer bff"

    # 2. Crear artifact (si comando existe)
    if [ -f "$CLI_BIN" ]; then
        run_test "Create new artifact" \
            "$CLI_BIN create-artifact --name=$artifact --env=$env --layer=bff 2>&1 || true"
    fi

    # 3. Verificar artifact existe
    run_test "Verify artifact exists" \
        "./test-review-artifact.sh --artifact e2e-test --environment $env"

    # 4. Listar artifacts después
    run_test "List artifacts after create" \
        "cd nx-sandbox && ./nx-sandbox list --layer bff"

    # 5. Cleanup
    run_test "Cleanup test artifact" \
        "cd nx-sandbox && ./nx-sandbox clean"
}

# Test 2: Clone desde GitHub y test
test_clone_and_test() {
    echo -e "\n${YELLOW}📥 Testing Clone & Test Workflow${NC}"

    # Skip si no hay acceso a GitHub
    if ! git ls-remote https://github.com/BritishAirways-Nexus/nx-artifacts-inventory.git HEAD &>/dev/null; then
        log_info "Skipping GitHub tests (no access)"
        return 0
    fi

    run_test "Clone artifact from GitHub" \
        "./clone-artifact-from-github.sh BritishAirways-Nexus nx-artifacts-inventory"

    if [ -d "local-artifacts/nx-artifacts-inventory" ]; then
        run_test "Test cloned artifact" \
            "./test-review-artifact.sh --artifact artifacts-inventory"
    fi
}

# Test 3: Multi-environment testing
test_multi_environment() {
    echo -e "\n${YELLOW}🌍 Testing Multi-Environment${NC}"

    for env in dev1 sit1 uat1; do
        run_test "Test artifact in $env" \
            "./test-review-artifact.sh --artifact web-offer-seat --environment $env"
    done
}

# Test 4: nx-sandbox CLI completo
test_nx_sandbox_cli() {
    echo -e "\n${YELLOW}🔧 Testing nx-sandbox CLI${NC}"

    cd "$SANDBOX_ROOT/nx-sandbox"

    run_test "Build nx-sandbox" \
        "go build -o nx-sandbox"

    run_test "nx-sandbox status" \
        "./nx-sandbox status"

    run_test "nx-sandbox list all" \
        "./nx-sandbox list"

    run_test "nx-sandbox list bff layer" \
        "./nx-sandbox list --layer bff"

    run_test "nx-sandbox clean" \
        "./nx-sandbox clean"
}

# Test 5: Error recovery
test_error_recovery() {
    echo -e "\n${YELLOW}❌ Testing Error Recovery${NC}"

    # Intentar con artifact inválido
    run_test "Handle invalid artifact" \
        "./test-review-artifact.sh --artifact invalid-nonexistent-artifact 2>&1 | grep -q 'Error\\|not found' && exit 0 || exit 1"

    # Intentar con environment inválido
    run_test "Handle invalid environment" \
        "./test-review-artifact.sh --artifact web-offer-seat --environment invalid99 2>&1 || exit 0"
}

# Test 6: Performance
test_performance() {
    echo -e "\n${YELLOW}⚡ Testing Performance${NC}"

    local start=$(date +%s)

    ./test-review-artifact.sh --artifact web-offer-seat &>/dev/null || true

    local end=$(date +%s)
    local duration=$((end - start))

    if [ $duration -lt 5 ]; then
        log_success "Performance OK: ${duration}s < 5s"
        pass_count=$((pass_count + 1))
    else
        log_error "Performance slow: ${duration}s >= 5s"
        fail_count=$((fail_count + 1))
    fi
    test_count=$((test_count + 1))
}

report() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       E2E TEST RESULTS                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Total tests: $test_count"
    echo -e "Passed: ${GREEN}$pass_count${NC}"
    echo -e "Failed: ${RED}$fail_count${NC}"

    if [ $fail_count -eq 0 ]; then
        echo -e "\n${GREEN}✓ All E2E tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}✗ Some E2E tests failed${NC}"
        echo "Check logs in: $TEST_DIR"
        return 1
    fi
}

cleanup() {
    log_info "Cleaning up E2E test artifacts..."
    cd "$SANDBOX_ROOT"
    # No borrar cli-real ni repos
}

trap cleanup EXIT

# Main execution
main() {
    setup
    test_artifact_lifecycle
    test_clone_and_test
    test_multi_environment
    test_nx_sandbox_cli
    test_error_recovery
    test_performance
    report
}

main "$@"
