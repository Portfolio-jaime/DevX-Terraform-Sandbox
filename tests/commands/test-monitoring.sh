#!/bin/bash
# Test script for monitoring command

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

TEST_ARTIFACT="nx-bff-monitoring-test"
TEST_ENV="dev1"

test_monitoring_creation() {
    log_info "Testing monitoring command creation..."

    # Test help command
    if cli-tester/tf_nx monitoring --help > /dev/null 2>&1; then
        log_success "Help command works"
    else
        log_error "Help command failed"
        return 1
    fi

    # Test create action
    if ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx monitoring create -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_success "Create action works"
    else
        log_error "Create action failed"
        return 1
    fi

    # Check if monitoring.tf was created
    if [ -f "/tmp/tf_nx_repos/nexus-infrastructure/components/tool/monitoring.tf" ]; then
        log_success "Monitoring Terraform file created"
    else
        log_error "Monitoring Terraform file missing"
        return 1
    fi

    # Check if our artifact monitoring resources are in the file
    if grep -q "$TEST_ARTIFACT-dashboard" /tmp/tf_nx_repos/nexus-infrastructure/components/tool/monitoring.tf; then
        log_success "Dashboard resource created"
    else
        log_error "Dashboard resource missing"
        return 1
    fi

    if grep -q "$TEST_ARTIFACT-cpu-alarm" /tmp/tf_nx_repos/nexus-infrastructure/components/tool/monitoring.tf; then
        log_success "CPU alarm resource created"
    else
        log_error "CPU alarm resource missing"
        return 1
    fi

    # Test delete action
    if ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx monitoring delete -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_success "Delete action works"
    else
        log_error "Delete action failed"
        return 1
    fi
}

test_error_scenarios() {
    log_info "Testing error scenarios..."

    # Test invalid action
    if cli-tester/tf_nx monitoring invalid-action -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_error "Should have failed with invalid action"
        return 1
    else
        log_success "Invalid action properly rejected"
    fi
}

main() {
    echo -e "${BLUE}Testing Monitoring Command${NC}"
    echo "=========================="

    test_monitoring_creation
    test_error_scenarios

    echo -e "${GREEN}All monitoring tests passed! ✅${NC}"
}

main "$@"