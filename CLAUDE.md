# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🎯 Project Overview

**DevX Terraform Sandbox** is a local development and testing environment for the British Airways Nexus Team's self-service infrastructure commands. It enables safe, isolated testing of DevX CLI commands without affecting production repositories.

**Key Purpose**: Test, debug, and validate infrastructure commands locally using either simulated data or real GitHub repositories before deploying to production.

## 🏗️ Architecture

### Core Components

1. **Simulated Repositories** (`repos/`)
   - `nx-artifacts-inventory/`: Artifact registry with YAML definitions organized by layer (al, bal, bb, bc, bff, ch, tc, xp)
   - `nx-bolt-environment-{dev1,sit1,uat1,prod1}/`: Environment-specific configurations with Helm charts
   - `nexus-infrastructure/`: Terraform infrastructure components

2. **Testing Tools** (root directory)
   - `artifact-selector.sh`: Interactive browser for available artifacts
   - `clone-artifact-from-github.sh`: Clones real GitHub repositories into `local-artifacts/`
   - `test-review-artifact.sh`: Tests the `/review-artifact` command functionality

3. **Nx Sandbox CLI** (`nx-sandbox/`)
   - Go-based CLI tool with commands: `list`, `status`, `clean`, `clone`
   - Provides programmatic access to sandbox operations
   - Uses Cobra framework for command structure

4. **Working Directories**
   - `local-artifacts/`: Real repositories cloned from GitHub
   - `test-artifacts/`: Prepared artifacts with generated test inventories
   - `logs/`: Script execution logs

### Artifact Inventory Schema

All artifacts follow the `app-inventory-schema.yaml` structure:
- `artifact_metadata`: name, layer, domain, service, owner
- `infrastructure`: enabled, deployed, component, environment
- `components`: service_account, redis, dynamo, rds, ecr (each with enabled flag)

**Supported Layers**: al, bal, bb, bc, bff, ch, dev, lib, sdk, tc, xp

**Supported Environments**: dev1, sit1, uat1, prod1

## 🔧 Development Commands

### Setup & Build
```bash
# Initial setup - builds real CLI
make setup

# Or use local CLI path
make setup-local-cli CLI_PATH=/path/to/nx-terraform-builder

# Build nx-sandbox
make build-cli
```

### Testing Workflow
```bash
# Complete test suite (unit + real CLI + security + integration)
make test-all

# Individual test suites
make test-unit          # Go unit tests
make test-real-cli      # Test with real nx-terraform-builder CLI
make test-security      # Security validation
make test-integration   # E2E integration tests

# Development cycle
make dev-test           # Quick unit + real CLI tests

# Pre-commit validation
make validate           # Run before git commit
```

### Quick Testing
```bash
# Interactive artifact selection and testing
./artifact-selector.sh

# Test with specific artifact from simulated inventory
./test-review-artifact.sh --artifact web-offer-seat --environment dev1 --depth standard

# Clone real repository for testing
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator
./test-review-artifact.sh --artifact order-creator
```

### Nx Sandbox CLI (Go-based)
```bash
cd nx-sandbox

# Build the CLI
go build -o nx-sandbox

# List artifacts with filters
./nx-sandbox list --layer bff --environment dev1
./nx-sandbox list --from-inventory
./nx-sandbox list --from-environments

# Check sandbox health
./nx-sandbox status

# Clean old artifacts
./nx-sandbox clean

# Clone from GitHub
./nx-sandbox clone BritishAirways-Nexus nx-artifact-name --prepare-testing
```

### Makefile Commands
```bash
# Setup complete sandbox environment
make setup

# Run all tests
make test-all

# Run specific test suites
make test-cli          # Test CLI commands
make test-workflows    # Test workflow simulations
make test-integration  # Test end-to-end scenarios
make test-terraform    # Test Terraform validation

# Cleanup
make clean             # Clean sandbox
make clean-aws         # Clean AWS mock environment
```

### Manual Testing Workflow
```bash
# Setup
chmod +x *.sh

# Option A: Use simulated data
./artifact-selector.sh
# Choose artifact → Run test

# Option B: Use real GitHub repository
./clone-artifact-from-github.sh <org> <repo>
cd local-artifacts/<repo>
# Make changes
cd ../..
./test-review-artifact.sh --artifact <repo-name>
```

## 📁 Key File Patterns

### Finding Artifacts
- Inventory artifacts: `repos/nx-artifacts-inventory/nx-artifacts/{layer}/nx-{layer}-{service}-{env}/nx-app-inventory.yaml`
- Environment services: `repos/nx-bolt-environment-{env}/{layer}/nx-{layer}-{service}/Chart.yaml`
- Cloned artifacts: `local-artifacts/{artifact-name}/`

### Script Locations
- Testing tools: Root directory `*.sh`
- Setup scripts: `scripts/setup-*.sh`
- Test suites: `tests/test-*.sh`
- Command tests: `tests/commands/test-*.sh`

### Workflow Simulations
- GitHub Actions workflows: `github-simulator/workflows/{command}/{command}.yml`

## 🎯 DevX Commands Implementation Status

### ✅ Implemented
- `/review-artifact`: Full implementation with layer detection, environment scanning, inventory analysis, health scoring

### 🚧 Planned
- `/debug-artifact`: Comprehensive diagnostics (30+ checks)
- `/delete-artifact`: Artifact deletion workflow
- `/check-artifact`: Artifact validation

## 🔍 Testing Patterns

### Testing New Command Implementation
1. Create script in root: `test-{command}.sh`
2. Test with simulated data from `repos/`
3. Test with real GitHub repository via `clone-artifact-from-github.sh`
4. Iterate until working correctly
5. Document in `docs/`

### Artifact Selection Logic
The `artifact-selector.sh` and `test-review-artifact.sh` both:
1. Search across all layer directories (al, bal, bb, bc, bff, ch, dev, lib, sdk, tc, xp)
2. Look in both inventory and environment repositories
3. Match artifact names flexibly (partial matching supported)
4. Detect available environments automatically

### GitHub Clone Workflow
1. Validate repository exists via Git
2. Clone to `local-artifacts/{artifact-name}/`
3. Generate `nx-app-inventory.yaml` for testing
4. Copy relevant files (Chart.yaml, values.yaml, etc.)
5. Prepare for test execution

## 🚨 Important Conventions

### Artifact Naming
- Full name format: `nx-{layer}-{service}-{environment}`
- Short name for testing: Extract service name (e.g., "web-offer-seat" from "nx-bff-web-offer-seat-dev1")
- Layer prefixes are standardized and lowercase

### Script Behavior
- All scripts use `set -e` for fail-fast behavior
- Scripts accept `--artifact`, `--environment`, `--depth` flags
- Default environment is "all" if not specified
- Default depth is "standard" if not specified

### Directory Safety
- Never modify files in `repos/` directory (treated as immutable simulated data)
- Use `local-artifacts/` for cloned repositories that can be modified
- Use `test-artifacts/` for prepared test data with generated inventories

## 🧪 Testing Strategy

### Validation Approach
1. **Layer Detection**: Search all layer directories to identify artifact location
2. **Environment Discovery**: Find all environment variants (dev1, sit1, uat1, prod1)
3. **Inventory Analysis**: Parse YAML files for component configuration
4. **Health Scoring**: Calculate based on enabled components and deployment status

### Common Testing Scenarios
- Single artifact across all environments
- Multiple artifacts in same layer
- Performance testing with many artifacts
- Error recovery and validation
- Integration with real GitHub repositories

## 📚 Documentation Structure

- `README.md`: Main entry point, quick start, architecture overview
- `docs/QUICK_START_GUIDE.md`: Step-by-step tutorial for new users
- `docs/TECHNICAL_ARCHITECTURE.md`: Detailed technical documentation
- `docs/PRACTICAL_USE_CASES.md`: 6 real-world usage scenarios
- `docs/TROUBLESHOOTING.md`: FAQ and problem solutions
- `docs/DESARROLLO_GUIDE.md`: Development guide in Spanish
- `nx-sandbox/README.md`: Go CLI tool documentation

## 🔗 External Dependencies

- **GitHub**: BritishAirways-Nexus organization for real repository cloning
- **Docker** (optional): LocalStack for AWS mocking via `make setup-aws`
- **Git**: Required for repository cloning functionality
- **Bash**: Shell scripting environment
- **Go 1.19+**: For nx-sandbox CLI development

## 💡 Development Tips

- The sandbox is designed for rapid iteration without fear of breaking production
- Use `artifact-selector.sh` to quickly explore available test data
- Clone real repositories when you need actual production configurations
- Test commands should be idempotent and safe to run multiple times
- Output formatting uses markdown for readability in test reports
- Artifact matching is flexible - partial names work (e.g., "offer-seat" matches "nx-bff-web-offer-seat-dev1")
