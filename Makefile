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

test-e2e: ## Run end-to-end tests
	@echo "🔄 Running E2E tests..."
	@./tests/e2e_test.sh

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
