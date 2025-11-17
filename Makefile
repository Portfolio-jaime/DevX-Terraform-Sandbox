# British Airways DevX Terraform Sandbox Makefile

.PHONY: setup test-all test-cli clean setup-aws setup-github setup-repos test-workflows test-integration

# Default environment variables
ENVIRONMENT ?= dev1
ARTIFACT_NAME ?= test-artifact
CLI_PATH ?= ../cli-tester
AWS_MOCK_PORT ?= 4566

## Main Setup Commands

setup: ## Initialize complete sandbox environment
	@echo "🚀 Setting up British Airways DevX Terraform Sandbox..."
	@$(MAKE) setup-aws
	@$(MAKE) setup-github
	@$(MAKE) setup-repos
	@$(MAKE) build-cli
	@echo "✅ Sandbox setup complete!"

test-all: ## Run all test suites
	@echo "🧪 Running comprehensive test suite..."
	@$(MAKE) test-cli
	@$(MAKE) test-workflows
	@$(MAKE) test-integration
	@$(MAKE) test-terraform
	@echo "✅ All tests completed!"

## AWS Mocking Setup

setup-aws: ## Initialize LocalStack AWS mock environment
	@echo "☁️ Setting up AWS mock environment..."
	@docker-compose -f config/docker-compose.yml up -d localstack
	@sleep 10
	@aws --endpoint-url=http://localhost:4566 sts get-caller-identity || echo "LocalStack not ready yet"

clean-aws: ## Clean up AWS mock environment
	@echo "🧹 Cleaning up AWS mock environment..."
	@docker-compose -f config/docker-compose.yml down
	@docker system prune -f

## GitHub Simulation Setup

setup-github: ## Initialize GitHub Actions simulator
	@echo "🐙 Setting up GitHub Actions simulator..."
	@mkdir -p github-simulator/workflows
	@mkdir -p github-simulator/mock-repos
	@./scripts/setup-github-simulator.sh

## Repository Mocking Setup

setup-repos: ## Setup mock repository structures
	@echo "📁 Setting up mock repository structures..."
	@./scripts/setup-mock-repos.sh

build-cli: ## Build the Terraform Nexus Builder CLI
	@echo "🔨 Building Terraform Nexus Builder CLI..."
	@cd $(CLI_PATH) && make build

## Testing Commands

test-cli: ## Test all CLI commands
	@echo "🖥️ Testing CLI commands..."
	@./tests/test-cli-commands.sh

test-cli COMMAND=redis: ## Test specific CLI command
	@echo "🖥️ Testing CLI command: $(COMMAND)"
	@./tests/test-cli-command.sh $(COMMAND)

test-workflows: ## Test GitHub workflow simulations
	@echo "🔄 Testing workflow simulations..."
	@./tests/test-workflows.sh

test-integration: ## Test end-to-end integration
	@echo "🔗 Testing integration scenarios..."
	@./tests/test-integration.sh

test-terraform: ## Test Terraform validation
	@echo "🧱 Testing Terraform validation..."
	@./tests/test-terraform.sh

test-errors: ## Test error handling scenarios
	@echo "❌ Testing error handling..."
	@./tests/test-errors.sh

## Development Commands

dev-cli: ## Development mode for CLI testing
	@echo "👨‍💻 Starting CLI in development mode..."
	@cd $(CLI_PATH) && go run . --debug

shell-aws: ## Access LocalStack shell
	@echo "🐚 Opening LocalStack shell..."
	@aws --endpoint-url=http://localhost:4566 --profile=localstack shell

## Monitoring Commands

logs: ## Show all logs
	@echo "📊 Showing sandbox logs..."
	@docker-compose -f config/docker-compose.yml logs

monitor: ## Start monitoring dashboard
	@echo "📈 Starting monitoring dashboard..."
	@./scripts/start-monitoring.sh

## Cleanup Commands

clean: ## Clean up everything
	@echo "🧹 Cleaning up sandbox..."
	@$(MAKE) clean-aws
	@rm -rf cli-tester/bin
	@rm -rf github-simulator/mock-repos
	@rm -rf terraform/test-plans
	@rm -rf logs/
	@echo "✅ Cleanup complete!"

clean-all: clean ## Complete reset including Docker
	@echo "🔄 Complete reset..."
	@docker system prune -af
	@docker volume prune -f

## Documentation Commands

docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	@./scripts/generate-docs.sh

help: ## Show this help message
	@echo "British Airways DevX Terraform Sandbox"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)