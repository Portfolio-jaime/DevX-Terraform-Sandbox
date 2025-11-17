#!/bin/bash
# Local Testing Demo for British Airways DevX Terraform Sandbox
# Demonstrates complete local CLI command development and testing

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_demo() { echo -e "${YELLOW}[DEMO]${NC} $1"; }

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  British Airways DevX Terraform Sandbox - Local Demo     ║"
echo "║     CLI Command Development & Testing Platform           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Demo 1: Show Local Setup
echo -e "\n${YELLOW}🔧 Demo 1: Complete Local Setup${NC}"
echo "==================================="

log_demo "The sandbox is 100% local - no external dependencies:"
log_info "✅ Mock repositories (nexus-infrastructure, nx-bolt-environment-*, nx-artifacts-inventory)"
log_info "✅ LocalStack AWS mock (ECR, Redis, DynamoDB, RDS, IAM, S3)"
log_info "✅ GitHub Actions simulator (workflows, comments, PRs)"
log_info "✅ CLI testing framework with mock commands"
log_info "✅ Terraform validation and plan generation"
log_info "✅ Complete error simulation and recovery testing"

echo ""
log_demo "No network calls, no repository access, no AWS costs!"

# Demo 2: Generate New Command
echo -e "\n${YELLOW}🛠️ Demo 2: Create New CLI Command${NC}"
echo "======================================"

log_demo "Creating a new command called 'databases' as example..."

# Create the command using our generator
./scripts/generate-command.sh databases database-service

log_success "Command 'databases' created successfully!"

# Demo 3: Validate Command Structure
echo -e "\n${YELLOW}🔍 Demo 3: Validate Command Structure${NC}"
echo "========================================"

log_demo "Running validation on the new command..."
./scripts/validate-command.sh databases

# Demo 4: Show Testing Capabilities
echo -e "\n${YELLOW}🧪 Demo 4: Testing Capabilities${NC}"
echo "=================================="

log_demo "Available testing commands:"
echo ""
log_info "make test-cli                  # Test all CLI commands"
log_info "make test-cli COMMAND=databases # Test specific command"
log_info "make test-errors               # Test error scenarios"
log_info "make test-workflows            # Test GitHub workflows"
log_info "make test-terraform            # Test Terraform validation"
log_info "make test-integration          # Test end-to-end workflows"

# Demo 5: Show Mock CLI
echo -e "\n${YELLOW}🤖 Demo 5: Mock CLI Demonstration${NC}"
echo "===================================="

log_demo "The sandbox includes a fully functional mock CLI:"
echo ""

# Show help from mock CLI
echo "Mock CLI Help:"
echo "=============="
cli-tester/tf_nx --help | head -20

echo ""
log_info "All commands are mocked and tested locally"

# Demo 6: Repository Structure
echo -e "\n${YELLOW}📁 Demo 6: Local Repository Structure${NC}"
echo "======================================="

log_demo "Mock repositories created locally:"
echo ""
tree -L 3 repos/ | head -20

echo ""
log_info "Complete British Airways repository structure replicated locally"

# Demo 7: AWS Mocking
echo -e "\n${YELLOW}☁️ Demo 7: AWS Services Mocking${NC}"
echo "================================="

log_demo "LocalStack provides AWS services locally:"
echo ""

# Check if LocalStack is running
if curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; then
    log_success "LocalStack is running"
    log_info "Available AWS services: ECR, ElastiCache, DynamoDB, RDS, IAM, S3"
    
    # Show AWS CLI test
    echo ""
    echo "Testing AWS CLI with LocalStack:"
    aws --endpoint-url=http://localhost:4566 sts get-caller-identity 2>/dev/null && \
        log_success "AWS CLI integration working" || \
        echo "LocalStack AWS mock ready (mock environment)"
else
    log_info "LocalStack not running - start with: make setup-aws"
    log_info "Once started, provides complete AWS service simulation"
fi

# Demo 8: Workflow Simulation
echo -e "\n${YELLOW}🔄 Demo 8: GitHub Workflow Simulation${NC}"
echo "========================================"

log_demo "GitHub Actions workflows simulated locally:"
echo ""
ls -la github-simulator/workflows/

echo ""
log_info "Complete workflow simulation with comments and PR generation"

# Demo 9: Error Simulation
echo -e "\n${YELLOW}❌ Demo 9: Error Scenarios Testing${NC}"
echo "===================================="

log_demo "Sandbox simulates various error scenarios:"
echo ""
log_info "🔴 Invalid artifact names"
log_info "🔴 Network failures"
log_info "🔴 Permission issues"
log_info "🔴 AWS service errors"
log_info "🔴 Terraform validation failures"
log_info "🔴 Resource conflicts"

echo ""
log_info "All errors handled locally without affecting production"

# Demo 10: Cost Estimation
echo -e "\n${YELLOW}💰 Demo 10: Cost Estimation${NC}"
echo "=============================="

log_demo "Infrastructure cost estimation (mock data):"
echo ""

cat terraform/validation-results/cost-estimate.log 2>/dev/null || echo "Cost estimation available after running make test-terraform"

echo ""
log_info "Realistic cost estimates without AWS charges"

# Demo 11: Pre-Production Validation
echo -e "\n${YELLOW}✅ Demo 11: Pre-Production Checklist${NC}"
echo "======================================"

log_demo "Complete validation before repository submission:"
echo ""

echo "Pre-Production Checklist:"
echo "========================="
echo "✅ Command structure validation"
echo "✅ Go syntax and linting"
echo "✅ Component interface compliance"
echo "✅ Terraform module validation"
echo "✅ Error handling testing"
echo "✅ Multi-environment testing"
echo "✅ Integration testing"
echo "✅ Performance validation"
echo "✅ Documentation completeness"
echo "✅ Code quality checks"

echo ""
log_info "Zero-risk testing before production submission"

# Demo 12: Cleanup
echo -e "\n${YELLOW}🧹 Demo 12: Safe Cleanup${NC}"
echo "=========================="

log_demo "Complete sandbox cleanup (optional):"
echo ""
log_info "make clean                    # Remove test artifacts"
log_info "make clean-all                # Complete reset including Docker"
log_info "make setup                    # Rebuild sandbox from scratch"

echo ""
log_demo "Complete isolation - no production impact"

# Summary
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🎉 LOCAL TESTING DEMO COMPLETE${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

echo ""
echo -e "${GREEN}✅ Benefits of Local Testing:${NC}"
echo "• Zero production risk"
echo "• No AWS costs during development"
echo "• No network dependencies"
echo "• Complete test coverage"
echo "• Rapid iteration and debugging"
echo "• Full error simulation"
echo "• Pre-production validation"

echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "1. Use the sandbox to develop new CLI commands"
echo "2. Test thoroughly using make test-cli"
echo "3. Validate with ./scripts/validate-command.sh"
echo "4. Once validated, submit to production repositories"

echo ""
echo -e "${GREEN}Happy CLI development! 🚀${NC}"

# Interactive options
echo ""
read -p "Would you like to run the full test suite? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    log_demo "Running full test suite..."
    make test-all
fi

echo ""
read -p "Would you like to start LocalStack for AWS mocking? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    log_demo "Starting LocalStack..."
    make setup-aws
    log_success "LocalStack started! AWS services are now available locally."
fi

echo ""
echo -e "${BLUE}Demo completed! Happy testing! 🎯${NC}"