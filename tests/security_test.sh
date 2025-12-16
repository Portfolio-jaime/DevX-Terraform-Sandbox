#!/bin/bash
# Security Testing Suite
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SANDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_count=0
pass_count=0
fail_count=0

log_test() {
    test_count=$((test_count + 1))
    echo -e "\n${YELLOW}🔒 Test $test_count: $1${NC}"
}

pass() {
    pass_count=$((pass_count + 1))
    echo -e "${GREEN}✓ PASS${NC}"
}

fail() {
    fail_count=$((fail_count + 1))
    echo -e "${RED}✗ FAIL: $1${NC}"
}

# Test 1: Path Traversal Prevention
test_path_traversal() {
    log_test "Path Traversal Prevention"

    cd "$SANDBOX_ROOT"

    # Intentar acceder fuera del sandbox
    if ./artifact-selector.sh 2>&1 | grep -q "../../etc/passwd"; then
        fail "Path traversal possible"
    else
        pass
    fi
}

# Test 2: Command Injection
test_command_injection() {
    log_test "Command Injection Prevention"

    # Intentar inyectar comandos
    if cd "$SANDBOX_ROOT/nx-sandbox" && go run main.go list --layer "bff; rm -rf /" 2>&1 | grep -q "removed"; then
        fail "Command injection possible"
    else
        pass
    fi
}

# Test 3: Input Validation
test_input_validation() {
    log_test "Input Validation"

    # Caracteres inválidos
    invalid_inputs=("../../../" "<script>" "'; DROP TABLE" "rm -rf /")

    for input in "${invalid_inputs[@]}"; do
        if $SANDBOX_ROOT/test-review-artifact.sh --artifact "$input" 2>&1 | grep -q "Error"; then
            pass
            return
        fi
    done

    fail "Invalid inputs not rejected"
}

# Test 4: Secret Scanning
test_secret_exposure() {
    log_test "Secret Exposure Check"

    # Buscar secrets en logs
    if find "$SANDBOX_ROOT" -name "*.log" -exec grep -l "password\|token\|secret\|key" {} \; 2>/dev/null | grep -q .; then
        fail "Potential secrets in logs"
    else
        pass
    fi
}

# Test 5: File Permissions
test_file_permissions() {
    log_test "File Permissions"

    # Verificar que scripts no son world-writable
    if find "$SANDBOX_ROOT" -name "*.sh" -perm -002 | grep -q .; then
        fail "World-writable scripts found"
    else
        pass
    fi
}

echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║       SECURITY TEST SUITE             ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"

test_path_traversal
test_command_injection
test_input_validation
test_secret_exposure
test_file_permissions

echo -e "\n${YELLOW}═══════════════════════════════════════${NC}"
echo "Total: $test_count | Pass: $pass_count | Fail: $fail_count"

[ $fail_count -eq 0 ] && echo -e "${GREEN}✓ Security tests passed${NC}" || echo -e "${RED}✗ Security issues found${NC}"
