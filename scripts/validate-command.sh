#!/bin/bash
# Command Validator for British Airways DevX Terraform Sandbox
# Validates new CLI commands before submission to production

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if command name provided
if [ $# -eq 0 ]; then
    log_error "Usage: $0 <command-name>"
    echo "Example: $0 myservice"
    exit 1
fi

COMMAND_NAME=$1
COMMAND_DIR=$(echo $COMMAND_NAME | tr '[:upper:]' '[:lower:]')

log_info "Validating command: $COMMAND_NAME"

# Validation results
VALIDATION_PASSED=true
WARNINGS_FOUND=false

# Test 1: Check command structure
echo -e "\n${YELLOW}🔍 Checking Command Structure${NC}"
echo "=============================="

if [ -f "cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go" ]; then
    log_success "Command file exists: cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go"
else
    log_error "Command file missing: cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go"
    VALIDATION_PASSED=false
fi

# Test 2: Check component structure
echo -e "\n${YELLOW}🔍 Checking Component Structure${NC}"
echo "================================="

if [ -f "cli-tester/tf_infra_components/$COMMAND_DIR/$COMONENT_DIR.go" ]; then
    log_success "Component file exists: cli-tester/tf_infra_components/$COMMAND_DIR/$COMMAND_DIR.go"
else
    log_error "Component file missing: cli-tester/tf_infra_components/$COMMAND_DIR/$COMMAND_DIR.go"
    VALIDATION_PASSED=false
fi

# Test 3: Check Go syntax
echo -e "\n${YELLOW}🔍 Checking Go Syntax${NC}"
echo "========================"

cd cli-tester

# Check command syntax
if [ -f "cmd/$COMMAND_DIR/$COMMAND_DIR.go" ]; then
    if go vet ./cmd/$COMMAND_DIR/ >/dev/null 2>&1; then
        log_success "Command syntax valid"
    else
        log_error "Command syntax errors found"
        go vet ./cmd/$COMMAND_DIR/
        VALIDATION_PASSED=false
    fi
fi

# Check component syntax
if [ -f "tf_infra_components/$COMMAND_DIR/$COMMAND_DIR.go" ]; then
    if go vet ./tf_infra_components/$COMMAND_DIR/ >/dev/null 2>&1; then
        log_success "Component syntax valid"
    else
        log_error "Component syntax errors found"
        go vet ./tf_infra_components/$COMMAND_DIR/
        VALIDATION_PASSED=false
    fi
fi

# Test 4: Check imports
echo -e "\n${YELLOW}🔍 Checking Imports${NC}"
echo "====================="

if [ -f "cmd/$COMMAND_DIR/$COMMAND_DIR.go" ]; then
    if grep -q "\"terraform_nexus_builder/cmd/$COMMAND_DIR\"" main.go 2>/dev/null; then
        log_success "Command imported in main.go"
    else
        log_warning "Command not imported in main.go"
        WARNINGS_FOUND=true
    fi
fi

# Test 5: Check template files
echo -e "\n${YELLOW}🔍 Checking Template Files${NC}"
echo "============================"

if [ -d "tf_infra_components/$COMMAND_DIR/templates" ]; then
    TEMPLATE_COUNT=$(find tf_infra_components/$COMMAND_DIR/templates -name "*.tpl" 2>/dev/null | wc -l)
    if [ $TEMPLATE_COUNT -gt 0 ]; then
        log_success "Template files found: $TEMPLATE_COUNT"
    else
        log_warning "No template files found"
        WARNINGS_FOUND=true
    fi
else
    log_warning "Templates directory not found"
    WARNINGS_FOUND=true
fi

# Test 6: Check test files
echo -e "\n${YELLOW}🔍 Checking Test Files${NC}"
echo "========================="

if [ -f "../tests/commands/test-$COMMAND_DIR.sh" ]; then
    if [ -x "../tests/commands/test-$COMMAND_DIR.sh" ]; then
        log_success "Test file exists and is executable"
    else
        log_warning "Test file exists but is not executable"
        WARNINGS_FOUND=true
    fi
else
    log_warning "Test file not found: tests/commands/test-$COMMAND_DIR.sh"
    WARNINGS_FOUND=true
fi

# Test 7: Check README
echo -e "\n${YELLOW}🔍 Checking Documentation${NC}"
echo "=========================="

if [ -f "cmd/$COMMAND_DIR/README.md" ]; then
    log_success "Command README exists"
else
    log_warning "Command README missing"
    WARNINGS_FOUND=true
fi

# Test 8: Build test
echo -e "\n${YELLOW}🔍 Testing Build${NC}"
echo "=================="

if go build -o tf_nx_test . 2>/dev/null; then
    log_success "CLI builds successfully"
    rm -f tf_nx_test
else
    log_error "CLI build failed"
    VALIDATION_PASSED=false
fi

cd ..

# Test 9: Basic functionality test
echo -e "\n${YELLOW}🔍 Testing Basic Functionality${NC}"
echo "================================="

cd cli-tester

# Test help command
if ./tf_nx_test $COMMAND_DIR --help >/dev/null 2>&1; then
    log_success "Help command works"
else
    log_error "Help command failed"
    VALIDATION_PASSED=false
fi

# Test with mock values
if ARTIFACT_NAME=nx-bff-test ENVIRONMENT=dev1 ./tf_nx_test $COMMAND_DIR create -a nx-bff-test -e dev1 >/dev/null 2>&1; then
    log_success "Command executes successfully"
else
    log_warning "Command execution has issues"
    WARNINGS_FOUND=true
fi

rm -f tf_nx_test
cd ..

# Test 10: Code quality checks
echo -e "\n${YELLOW}🔍 Checking Code Quality${NC}"
echo "==========================="

cd cli-tester

# Check for TODO comments
TODO_COUNT=$(grep -r "TODO" cmd/$COMMAND_DIR/ tf_infra_components/$COMMAND_DIR/ 2>/dev/null | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    log_warning "Found $TODO_COUNT TODO comments - consider addressing before submission"
    WARNINGS_FOUND=true
else
    log_success "No TODO comments found"
fi

# Check for debug statements
DEBUG_COUNT=$(grep -r "fmt.Println.*Debug\|log.Debug\|debug" cmd/$COMMAND_DIR/ tf_infra_components/$COMMAND_DIR/ 2>/dev/null | wc -l)
if [ $DEBUG_COUNT -gt 0 ]; then
    log_warning "Found $DEBUG_COUNT debug statements - ensure these don't leak to production"
    WARNINGS_FOUND=true
else
    log_success "No debug statements found"
fi

cd ..

# Final results
echo -e "\n${BLUE}============================================${NC}"
echo -e "${BLUE}Validation Results for $COMMAND_NAME${NC}"
echo -e "${BLUE}============================================${NC}"

if [ "$VALIDATION_PASSED" = true ]; then
    if [ "$WARNINGS_FOUND" = true ]; then
        echo -e "${YELLOW}⚠️  VALIDATION PASSED with warnings${NC}"
        echo -e "${YELLOW}Command is functional but has some issues to address${NC}"
    else
        echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
        echo -e "${GREEN}Command is ready for production submission${NC}"
    fi
else
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo -e "${RED}Command has critical issues that must be fixed${NC}"
fi

echo ""
echo -e "${BLUE}Summary:${NC}"
echo "- Command structure: $([ -f "cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go" ] && echo "✅" || echo "❌")"
echo "- Component structure: $([ -f "cli-tester/tf_infra_components/$COMMAND_DIR/$COMMAND_DIR.go" ] && echo "✅" || echo "❌")"
echo "- Go syntax: $(cd cli-tester && go vet ./cmd/$COMMAND_DIR/ ./tf_infra_components/$COMMAND_DIR/ >/dev/null 2>&1 && echo "✅" || echo "❌")"
echo "- Build test: $(cd cli-tester && go build -o tf_nx_test . >/dev/null 2>&1 && echo "✅" || echo "❌")"
echo "- Test file: $([ -f "tests/commands/test-$COMMAND_DIR.sh" ] && echo "✅" || echo "❌")"
echo "- Documentation: $([ -f "cli-tester/cmd/$COMMAND_DIR/README.md" ] && echo "✅" || echo "❌")"

if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "\n${GREEN}Next steps:${NC}"
    echo "1. Address any warnings above"
    echo "2. Run comprehensive tests: make test-cli COMMAND=$COMMAND_NAME"
    echo "3. Test with real CLI: cd cli-tester && make build"
    echo "4. Submit to production repository"
else
    echo -e "\n${RED}Please fix the issues above before submission${NC}"
fi

exit $([ "$VALIDATION_PASSED" = true ] && echo 0 || echo 1)