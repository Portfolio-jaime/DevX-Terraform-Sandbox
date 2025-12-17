# British Airways DevX Terraform Sandbox Makefile

.PHONY: setup test-all test-cli test-real-cli test-unit test-security clean

# Paths
CLI_PATH ?= cli-real
SANDBOX_ROOT := $(shell pwd)

## Setup Commands

setup: ## Initialize sandbox with real CLI
	@echo "🚀 Setting up DevX Sandbox..."
	@chmod +x tests/*.sh *.sh
	@./tests/setup-real-cli.sh
	@echo "✅ Sandbox ready!"

setup-local-cli: ## Use local CLI instead of cloning
	@echo "🔗 Linking local CLI..."
	@export LOCAL_CLI_PATH=$(CLI_PATH) && ./tests/setup-real-cli.sh

## Testing Commands

test-all: test-unit test-real-cli test-security test-integration test-e2e ## Run all test suites
	@echo "✅ All tests completed!"

test-unit: ## Run Go unit tests
	@echo "🧪 Running unit tests..."
	@cd nx-sandbox && go test -v ./...

test-real-cli: ## Test with real CLI
	@echo "🔧 Testing real CLI..."
	@./tests/test-with-real-cli.sh

test-cli: ## Test with mock CLI (legacy)
	@echo "🖥️  Testing mock CLI..."
	@./tests/test-cli-commands.sh

test-security: ## Run security tests
	@echo "🔒 Running security tests..."
	@./tests/security_test.sh

test-integration: ## Run integration tests
	@echo "🔗 Running integration tests..."
	@./tests/test-integration.sh

test-terraform: ## Run Terraform tests
	@echo "🏗️  Running Terraform tests..."
	@./tests/test-terraform.sh

test-e2e: ## Run end-to-end tests with LocalStack
	@echo "🔄 Running E2E tests..."
	@./tests/e2e/run-all-e2e-tests.sh

benchmark: ## Run Go benchmarks
	@echo "⚡ Running benchmarks..."
	@cd nx-sandbox && go test -bench=. ./...

## Development Commands

build-cli: ## Build nx-sandbox CLI
	@echo "🔨 Building nx-sandbox..."
	@cd nx-sandbox && go build -o nx-sandbox

run-sandbox: build-cli ## Run nx-sandbox
	@./nx-sandbox/nx-sandbox

dev-test: ## Quick development test cycle
	@make test-unit
	@make test-real-cli

## Validation Commands

validate: ## Validate before commit
	@echo "✓ Running pre-commit validation..."
	@make test-unit
	@make test-security
	@echo "✅ Validation passed!"

lint: ## Lint Go code
	@cd nx-sandbox && golangci-lint run || go fmt ./...

## AWS LocalStack Commands

setup-aws: ## Start LocalStack with AWS services
	@echo "🚀 Starting LocalStack..."
	@docker-compose -f config/docker-compose.yml up -d localstack
	@echo "⏳ Initializing AWS services..."
	@./config/aws-setup/init-all.sh
	@echo "✅ LocalStack ready!"

stop-aws: ## Stop LocalStack services
	@echo "⏸️  Stopping LocalStack..."
	@docker-compose -f config/docker-compose.yml stop localstack
	@echo "✅ LocalStack stopped!"

clean-aws: ## Remove LocalStack and all data
	@echo "🧹 Cleaning LocalStack..."
	@docker-compose -f config/docker-compose.yml down
	@docker volume rm devx-terraform-sandbox_localstack_data 2>/dev/null || true
	@echo "✅ LocalStack cleaned!"

restart-aws: clean-aws setup-aws ## Restart LocalStack with fresh data

status-aws: ## Check LocalStack status
	@echo "📊 LocalStack Status:"
	@curl -s http://localhost:4566/_localstack/health | jq '.' || echo "❌ LocalStack not running"

logs-aws: ## Show LocalStack logs
	@docker-compose -f config/docker-compose.yml logs -f localstack

shell-aws: ## Open shell with AWS CLI configured for LocalStack
	@echo "🐚 Opening AWS CLI shell (configured for LocalStack)"
	@echo "Use: aws --endpoint-url=http://localhost:4566 <service> <command>"
	@docker run --rm -it --network=host -e AWS_ACCESS_KEY_ID=test -e AWS_SECRET_ACCESS_KEY=test -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url=http://localhost:4566 configure list

## Cleanup Commands

clean: ## Clean test artifacts
	@echo "🧹 Cleaning..."
	@rm -rf test-artifacts/* local-artifacts/*
	@rm -f tf_nx
	@echo "✅ Cleaned!"

clean-all: clean ## Full cleanup including CLI
	@rm -rf cli-real
	@cd nx-sandbox && go clean

## Help

help: ## Show this help
	@echo "DevX Terraform Sandbox"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
