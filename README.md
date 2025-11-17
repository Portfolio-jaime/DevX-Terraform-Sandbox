# British Airways DevX Terraform Sandbox

🚀 **Development and Testing Platform for Terraform Nexus Builder CLI**

## 🎯 Purpose

This sandbox is designed as a **development platform** for creating, testing, and validating new CLI commands before deploying them to the British Airways production repositories.

## 🚀 Quick Start

```bash
# 1. Setup the development environment
make setup

# 2. Build and test CLI in development mode
make dev-cli

# 3. Run comprehensive test suite
make test-all
```

## 🛠️ Command Development Workflow

### 1. Create New CLI Command

```bash
# Copy existing command as template
cp cli-tester/cmd/redis/cli-tester/cmd/mycommand/
cd cli-tester/cmd/mycommand/

# Edit the command structure
vi mycommand.go
```

### 2. Add Infrastructure Component

```bash
# Create new Terraform component
mkdir cli-tester/tf_infra_components/mycomponent/
cd cli-tester/tf_infra_components/mycomponent/

# Add your component logic
vi mycomponent.go
```

### 3. Test the New Command

```bash
# Test your new command
make test-cli COMMAND=mycommand

# Run specific test
./tests/test-cli-command.sh mycommand

# Test with different environments
for env in dev1 sit1 uat1 prod1; do
    make test-cli COMMAND=mycommand ENV=$env
done
```

### 4. Validate Error Scenarios

```bash
# Test error handling
make test-errors

# Test with invalid inputs
./tests/test-error-scenarios.sh mycommand
```

## 📁 Development Structure

```
cli-tester/                          # Your main CLI development area
├── cmd/                             # All CLI commands
│   ├── mycommand/                   # Your new command
│   ├── redis/                       # Template reference
│   ├── dynamo/                      # Template reference
│   └── ...
├── tf_infra_components/             # Infrastructure components
│   ├── mycomponent/                 # Your new component
│   ├── redis_cache/                 # Template reference
│   └── ...
├── interfaces/                      # CLI interfaces
├── utils/                           # Utility functions
└── tests/                           # Testing framework
```

## 🧪 Testing Framework

### Command Testing

```bash
# Test all CLI commands
make test-cli

# Test specific command
make test-cli COMMAND=yourcommand

# Test with custom artifact
ARTIFACT_NAME=nx-my-new-command make test-cli COMMAND=yourcommand
```

### Error Detection

```bash
# Test error scenarios
make test-errors

# Test validation failures
./tests/test-validation.sh yourcommand

# Test with invalid inputs
./tests/test-invalid-inputs.sh yourcommand
```

### Integration Testing

```bash
# Test end-to-end workflows
make test-integration

# Test with actual CLI build
make build-cli
make test-with-real-cli
```

## 🏗️ Infrastructure Components Testing

### Terraform Validation

```bash
# Validate new Terraform modules
make test-terraform

# Test component generation
./tests/test-component-generation.sh mycomponent

# Validate Terraform syntax
./tests/test-tf-syntax.sh mycomponent
```

### AWS Services Testing

```bash
# Test with LocalStack
make setup-aws
make test-with-aws-mock

# Test specific AWS service
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

## 📊 Error Detection & Debugging

### Common Development Issues

**1. Command Not Found**
```bash
# Check if command is registered in main.go
grep "mycommand" cli-tester/main.go

# Build CLI with new command
cd cli-tester && make build
```

**2. Infrastructure Component Missing**
```bash
# Verify component interface
grep "MyComponent" cli-tester/interfaces/

# Check import statements
grep "tf_infra_components/mycomponent" cli-tester/cmd/mycommand/mycommand.go
```

**3. Terraform Module Errors**
```bash
# Test Terraform syntax
cd cli-tester/tf_infra_components/mycomponent/
terraform validate

# Test module template
./tests/test-template.sh mycomponent
```

### Debug Commands

```bash
# Run CLI in debug mode
make dev-cli DEBUG=1

# Enable verbose logging
export DEBUG=1
export LOG_LEVEL=debug
make test-cli COMMAND=yourcommand

# View detailed logs
make logs
tail -f logs/cli-test.log
```

## 🔄 Development Cycle

### 1. Code Development
- Edit command in `cli-tester/cmd/yourcommand/`
- Add infrastructure component in `cli-tester/tf_infra_components/yourcomponent/`
- Update interfaces if needed

### 2. Local Testing
- Build CLI: `cd cli-tester && make build`
- Test command: `make test-cli COMMAND=yourcommand`
- Test error scenarios: `make test-errors`

### 3. Validation
- Test with all environments: `make test-all-environments`
- Validate Terraform: `make test-terraform`
- Test workflows: `make test-workflows`

### 4. Pre-Production Check
```bash
# Final validation before repo submission
make pre-production-check

# This runs:
# - All CLI tests
# - Terraform validation
# - Error scenario testing
# - Integration testing
```

## 📋 Testing Checklist

Before submitting to production repos:

- [ ] **Command Functions**: `make test-cli COMMAND=yourcommand`
- [ ] **Error Handling**: `make test-errors`
- [ ] **All Environments**: `make test-all-environments`
- [ ] **Terraform Validation**: `make test-terraform`
- [ ] **Integration Tests**: `make test-integration`
- [ ] **AWS Mock Testing**: `make test-with-aws-mock`
- [ ] **Performance Check**: `make test-performance`
- [ ] **Documentation**: `make generate-docs`

## 🛠️ Development Commands

```bash
# Development
make dev-cli                    # CLI development mode
make build-cli                  # Build the CLI
make test-cli                   # Test all CLI commands
make test-cli COMMAND=mycommand # Test specific command

# Error Testing
make test-errors                # Test error scenarios
make test-validation            # Test input validation
make test-edge-cases            # Test edge cases

# Infrastructure Testing
make test-terraform             # Test Terraform modules
make test-aws-mock             # Test with AWS mock
make test-component-gen        # Test component generation

# Pre-Production
make pre-production-check      # Complete validation
make test-all                 # Full test suite
make clean-build              # Clean rebuild
```

## 📚 Documentation

- **Development Guide**: `docs/DEVELOPMENT_GUIDE.md`
- **Command Testing**: `docs/COMMAND_TESTING.md`
- **Troubleshooting**: `docs/TROUBLESHOOTING.md`
- **API Reference**: `docs/API_REFERENCE.md`

## 🆘 Need Help?

1. **Check Logs**: `make logs`
2. **Run Diagnostics**: `make diagnostics`
3. **Test Framework**: `./tests/test-framework.sh`
4. **Validate Setup**: `make validate-setup`

---

**Version**: 1.0.0  
**Purpose**: CLI Command Development Platform  
**Last Updated**: November 2025