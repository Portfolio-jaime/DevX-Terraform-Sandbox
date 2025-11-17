# 🏗️ British Airways DevX Terraform Sandbox - Comprehensive Guide

## 📖 Overview

This comprehensive guide provides everything you need to use the British Airways DevX Terraform Sandbox for developing, testing, and deploying new CLI commands. The sandbox enables **100% local development** without touching production repositories or incurring AWS costs.

## 🎯 What This Guide Covers

1. **Complete Setup and Installation**
2. **Creating New CLI Commands**
3. **Testing Framework Usage**
4. **Error Detection and Debugging**
5. **Pre-Production Validation**
6. **GitHub Repository Integration**
7. **Troubleshooting and Best Practices**

---

## 🚀 Quick Start

### Prerequisites
- macOS, Linux, or Windows with WSL
- Docker and Docker Compose
- Make utility
- Git
- Bash shell

### Initial Setup

```bash
# 1. Navigate to sandbox directory
cd /Users/jaime.henao/arheanja/Sandbox-Project

# 2. Run complete setup
make setup

# 3. Verify setup
make test-all

# 4. View interactive demo
./scripts/demo-local-testing.sh
```

---

## 🛠️ Creating New CLI Commands

### Step 1: Generate Command Structure

Use the command generator to create a new CLI command:

```bash
# Generate a new command called 'databases'
./scripts/generate-command.sh databases database-service

# This creates:
# - cli-tester/cmd/databases/databases.go
# - cli-tester/tf_infra_components/database-service/database-service.go
# - tests/commands/test-databases.sh
# - cli-tester/cmd/databases/README.md
```

### Step 2: Implement Command Logic

#### Edit the Command File
```bash
# Open the generated command file
vi cli-tester/cmd/databases/databases.go
```

The generated file looks like this:

```go
package databases

import (
	"fmt"
	"terraform_nexus_builder/cmd"
	"terraform_nexus_builder/tf_infra_components/database-service"
	"terraform_nexus_builder/utils"

	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var databasesCmd = &cobra.Command{
	Use:   "databases [action] [flags]",
	Short: color.YellowString("databases command for managing database-service components"),
	Long:  color.BlueString("Comprehensive databases command for creating, managing, and deleting database-service infrastructure components"),
	Args:  cobra.ExactArgs(1),
	Run:   runDatabasesCommand,
}

func init() {
	utils.SetGlobalDefaultFlags(databasesCmd)
	cmd.RootCmd.AddCommand(databasesCmd)
}

func runDatabasesCommand(cmd *cobra.Command, args []string) {
	action := args[0]
	
	settings := interfaces.TerraformBuilderSettings{
		ArtifactName: artifactName,
		Environment:  environment,
		Individual:   individual,
		Debug:        debug,
	}

	component := database_service.New(settings)
	
	switch action {
	case "create":
		fmt.Println(color.GreenString("Creating database-service for artifact: %s in environment: %s"), settings.ArtifactName, settings.Environment)
		component.Create()
	case "delete":
		fmt.Println(color.GreenString("Deleting database-service for artifact: %s in environment: %s"), settings.ArtifactName, settings.Environment)
		component.Delete()
	case "update":
		fmt.Println(color.GreenString("Updating database-service for artifact: %s in environment: %s"), settings.ArtifactName, settings.Environment)
		component.Update()
	default:
		fmt.Println(color.RedString("Unknown action: %s. Available actions: create, delete, update"), action)
		fmt.Println(color.BlueString("Use --help for more information"))
	}
}
```

#### Edit the Infrastructure Component
```bash
# Open the component file
vi cli-tester/tf_infra_components/database-service/database-service.go
```

Add your Terraform logic:

```go
func (c *DatabaseServiceConfig) Create() {
	fmt.Printf("Creating database service for artifact: %s\n", c.artifactName)
	
	// Add your Terraform configuration logic here
	// Example: Create RDS instance
	c.editor.AddResource("aws_db_instance", c.artifactName+"-db", map[string]interface{}{
		"engine":               "postgres",
		"engine_version":       "13.7",
		"instance_class":       "db.t3.micro",
		"allocated_storage":    20,
		"db_name":              c.artifactName + "_db",
		"username":             "admin",
		"password":             "password123", // Use proper secrets management
		"parameter_group_name": "default.postgres13",
		"skip_final_snapshot":  true,
		"tags": map[string]interface{}{
			"ArtifactName": c.artifactName,
			"Environment":  c.settings.Environment,
			"Component":    "database-service",
		},
	})
	
	// Add security group
	c.editor.AddResource("aws_security_group", c.artifactName+"-db-sg", map[string]interface{}{
		"name":        c.artifactName + "-db-sg",
		"description": "Security group for database service",
		"vpc_id":      "vpc-12345678", // Use proper VPC reference
		"ingress": []map[string]interface{}{
			{
				"from_port":   5432,
				"to_port":     5432,
				"protocol":    "tcp",
				"cidr_blocks": []string{"10.0.0.0/16"},
			},
		},
		"tags": map[string]interface{}{
			"ArtifactName": c.artifactName,
			"Environment":  c.settings.Environment,
		},
	})
}
```

### Step 3: Build and Test

```bash
# Build the CLI with your changes
cd cli-tester && make build

# Test the new command
make test-cli COMMAND=databases

# Test with specific parameters
ARTIFACT_NAME=nx-bff-myapp ENVIRONMENT=dev1 cli-tester/tf_nx databases create -a nx-bff-myapp -e dev1
```

---

## 🧪 Testing Framework

### Basic Command Testing

```bash
# Test all CLI commands
make test-cli

# Test specific command
make test-cli COMMAND=databases

# Test with different environments
for env in dev1 sit1 uat1 prod1; do
    make test-cli COMMAND=databases ENV=$env
done
```

### Error Scenario Testing

```bash
# Test error scenarios
make test-errors

# Test invalid inputs
make test-cli COMMAND=databases ARTIFACT="invalid-name"

# Test missing permissions
make test-cli COMMAND=databases ENV="invalid-env"
```

### Integration Testing

```bash
# Test end-to-end workflows
make test-integration

# Test Terraform validation
make test-terraform

# Test GitHub workflow simulation
make test-workflows
```

### Custom Test Creation

Create custom tests in `tests/commands/`:

```bash
# Create custom test file
cat > tests/commands/test-databases.sh << 'EOF'
#!/bin/bash
# Custom test for databases command

set -e

# Test database creation
ARTIFACT_NAME=nx-bff-test ENVIRONMENT=dev1 cli-tester/tf_nx databases create -a nx-bff-test -e dev1

# Verify Terraform files were created
if [ -f "repos/nexus-infrastructure/components/tool/databases.tf" ]; then
    echo "✅ Database Terraform configuration created"
else
    echo "❌ Database Terraform configuration missing"
    exit 1
fi

echo "✅ All database tests passed"
EOF

chmod +x tests/commands/test-databases.sh
```

---

## 🔍 Validation and Debugging

### Command Validation

```bash
# Validate command structure
./scripts/validate-command.sh databases

# This checks:
# ✅ Go syntax and imports
# ✅ Component interface compliance
# ✅ Test file existence
# ✅ Documentation completeness
# ✅ Build success
```

### Debugging Tools

```bash
# Enable debug mode
DEBUG=1 make test-cli COMMAND=databases

# View detailed logs
make logs

# Check Terraform generation
make test-terraform

# Test AWS mock services
make shell-aws
aws --endpoint-url=http://localhost:4566 rds describe-db-instances
```

### Common Issues and Solutions

#### Issue: Command not found
```bash
# Check if command is registered in main.go
grep "databases" cli-tester/main.go

# Rebuild CLI
cd cli-tester && make build
```

#### Issue: Terraform syntax errors
```bash
# Validate Terraform files
cd cli-tester/tf_infra_components/database-service/
terraform init
terraform validate

# Check generated files
ls -la repos/nexus-infrastructure/components/tool/
```

#### Issue: Test failures
```bash
# Run specific test with verbose output
bash -x tests/commands/test-databases.sh

# Check test logs
cat logs/cli-test-results.log
```

---

## ✅ Pre-Production Validation

### Validation Checklist

Before submitting to production repositories:

- [ ] **Code Quality**
  - [ ] Go syntax validation passes
  - [ ] No TODO comments in production code
  - [ ] Proper error handling implemented
  - [ ] Code follows BA standards

- [ ] **Testing**
  - [ ] All unit tests pass: `make test-cli COMMAND=databases`
  - [ ] Error scenarios tested: `make test-errors`
  - [ ] Integration tests pass: `make test-integration`
  - [ ] Multi-environment testing: dev1, sit1, uat1, prod1

- [ ] **Infrastructure**
  - [ ] Terraform validation passes: `make test-terraform`
  - [ ] Cost estimation reviewed
  - [ ] Resource dependencies verified
  - [ ] Security groups and networking configured

- [ ] **Documentation**
  - [ ] Command help text implemented
  - [ ] README updated with new command
  - [ ] Usage examples provided
  - [ ] Troubleshooting guide updated

### Final Validation

```bash
# Run complete pre-production check
make pre-production-check

# This executes:
# ✅ Full test suite
# ✅ Terraform validation
# ✅ Error scenario testing
# ✅ Code quality checks
# ✅ Documentation validation
```

---

## 🚀 GitHub Repository Integration

### Step 1: Prepare Changes

Once all tests pass and validation is complete:

```bash
# Ensure all changes are committed locally
cd cli-tester
git add .
git commit -m "feat: Add databases command for database service management

- Add databases CLI command
- Implement database-service infrastructure component
- Add comprehensive testing
- Update documentation

Closes: #ISSUE-NUMBER"

# Create feature branch
git checkout -b feature/databases-command
```

### Step 2: Push to GitHub

```bash
# Push to your fork
git push origin feature/databases-command

# Or push directly to main repo (if you have permissions)
git push upstream feature/databases-command
```

### Step 3: Create Pull Request

1. **Go to GitHub**: Navigate to the British Airways nx-terraform-builder repository
2. **Create PR**: Click "New Pull Request"
3. **Select Branch**: Choose your `feature/databases-command` branch
4. **Fill PR Details**:
   - **Title**: `feat: Add databases command for database service management`
   - **Description**:
     ```
     ## Overview
     Adds a new `databases` command to manage database services in the British Airways infrastructure.

     ## Changes
     - New CLI command: `tf_nx databases [create|delete|update]`
     - Infrastructure component for database service management
     - Comprehensive testing suite
     - Updated documentation

     ## Testing
     - ✅ All tests pass locally
     - ✅ Pre-production validation completed
     - ✅ Multi-environment testing verified
     - ✅ Error scenarios covered

     ## Usage
     ```bash
     tf_nx databases create -a nx-bff-myapp -e dev1
     tf_nx databases delete -a nx-bff-myapp -e dev1
     ```

     Closes: #ISSUE-NUMBER
     ```
5. **Add Labels**: Add appropriate labels (e.g., `enhancement`, `cli`, `testing`)
6. **Request Review**: Assign reviewers from the DevX team

### Step 4: CI/CD Pipeline

The repository will automatically run:

1. **Code Quality Checks**: Go linting, formatting
2. **Unit Tests**: All CLI command tests
3. **Integration Tests**: End-to-end workflow tests
4. **Terraform Validation**: Infrastructure code validation
5. **Security Scans**: Vulnerability checks

### Step 5: Merge and Deploy

Once approved:

1. **Merge PR**: Squash and merge the changes
2. **Automatic Release**: CI/CD will create a new release
3. **Documentation Update**: Auto-update command documentation
4. **Team Notification**: Notify DevX team of new command availability

---

## 📋 Complete Example: Creating and Testing a New Command

### Scenario: Create a "queues" command for SQS management

#### 1. Generate the command
```bash
./scripts/generate-command.sh queues queue-service
```

#### 2. Implement the logic
```bash
# Edit command file
vi cli-tester/cmd/queues/queues.go

# Add SQS creation logic
func (c *QueueServiceConfig) Create() {
	c.editor.AddResource("aws_sqs_queue", c.artifactName+"-queue", map[string]interface{}{
		"name":                      c.artifactName + "-queue.fifo",
		"fifo_queue":                true,
		"content_based_deduplication": true,
		"delay_seconds":             0,
		"max_message_size":          262144,
		"message_retention_seconds": 345600,
		"receive_wait_time_seconds": 0,
		"tags": map[string]interface{}{
			"ArtifactName": c.artifactName,
			"Environment":  c.settings.Environment,
			"Component":    "queue-service",
		},
	})
}
```

#### 3. Test the command
```bash
# Build and test
cd cli-tester && make build
make test-cli COMMAND=queues

# Test with real parameters
ARTIFACT_NAME=nx-bff-myapp ENVIRONMENT=dev1 cli-tester/tf_nx queues create -a nx-bff-myapp -e dev1
```

#### 4. Validate and debug
```bash
# Run validation
./scripts/validate-command.sh queues

# Check generated Terraform
cat repos/nexus-infrastructure/components/tool/queues.tf

# Test with AWS mock
make shell-aws
aws --endpoint-url=http://localhost:4566 sqs list-queues
```

#### 5. Run comprehensive tests
```bash
# Full test suite
make test-all

# Integration testing
make test-integration

# Pre-production check
make pre-production-check
```

#### 6. Submit to GitHub
```bash
# Commit changes
cd cli-tester
git add .
git commit -m "feat: Add queues command for SQS management

- Add queues CLI command for SQS queue management
- Implement queue-service infrastructure component
- Add FIFO queue support with proper configuration
- Comprehensive testing and validation

Closes: #123"

# Push to GitHub
git push origin feature/queues-command

# Create PR with detailed description
```

---

## 🛠️ Advanced Usage

### Custom Terraform Templates

Create custom templates for complex infrastructure:

```bash
# Create custom template
cat > cli-tester/tf_infra_components/queues/templates/queue.tf.tpl << 'EOF'
# Custom SQS Queue Template
resource "aws_sqs_queue" "{{.ArtifactName}}-queue" {
  name                      = "{{.ArtifactName}}-queue.fifo"
  fifo_queue                = true
  content_based_deduplication = true
  
  # Custom configuration based on environment
  {{if eq .Environment "prod1"}}
  message_retention_seconds = 1209600  # 14 days for prod
  {{else}}
  message_retention_seconds = 345600   # 4 days for non-prod
  {{end}}
  
  tags = {
    ArtifactName = "{{.ArtifactName}}"
    Environment  = "{{.Environment}}"
    Component    = "queue-service"
    ManagedBy    = "tf_nx"
  }
}

# Dead letter queue
resource "aws_sqs_queue" "{{.ArtifactName}}-dlq" {
  name = "{{.ArtifactName}}-dlq.fifo"
  fifo_queue = true
  
  tags = {
    ArtifactName = "{{.ArtifactName}}"
    Environment  = "{{.Environment}}"
    Component    = "queue-service-dlq"
  }
}
EOF
```

### Environment-Specific Logic

```go
func (c *QueueServiceConfig) Create() {
	// Environment-specific configuration
	var retentionSeconds int
	switch c.settings.Environment {
	case "prod1":
		retentionSeconds = 1209600 // 14 days
	case "uat1":
		retentionSeconds = 604800  // 7 days
	default:
		retentionSeconds = 345600  // 4 days
	}
	
	// Create queue with environment-specific settings
	c.editor.AddResource("aws_sqs_queue", c.artifactName+"-queue", map[string]interface{}{
		"name":                       c.artifactName + "-queue.fifo",
		"fifo_queue":                 true,
		"message_retention_seconds":  retentionSeconds,
		"tags": map[string]interface{}{
			"ArtifactName": c.artifactName,
			"Environment":  c.settings.Environment,
		},
	})
}
```

### Custom Testing Scenarios

```bash
# Create advanced test scenarios
cat > tests/commands/test-queues-advanced.sh << 'EOF'
#!/bin/bash
# Advanced testing for queues command

set -e

# Test different environments
environments=("dev1" "sit1" "uat1" "prod1")

for env in "${environments[@]}"; do
    echo "Testing queues in $env environment..."
    
    # Create queue
    ARTIFACT_NAME=nx-bff-test ENVIRONMENT=$env cli-tester/tf_nx queues create -a nx-bff-test -e $env
    
    # Verify environment-specific configuration
    if [ "$env" = "prod1" ]; then
        grep -q "message_retention_seconds = 1209600" repos/nexus-infrastructure/components/tool/queues.tf
    else
        grep -q "message_retention_seconds = 345600" repos/nexus-infrastructure/components/tool/queues.tf
    fi
    
    echo "✅ $env environment test passed"
done

# Test error scenarios
echo "Testing error scenarios..."

# Invalid artifact name
if cli-tester/tf_nx queues create -a invalid-name -e dev1 2>/dev/null; then
    echo "❌ Should have failed with invalid artifact name"
    exit 1
fi

echo "✅ All advanced tests passed"
EOF
```

---

## 📞 Support and Resources

### Getting Help

1. **Documentation**: Check this guide and inline help (`tf_nx --help`)
2. **Logs**: Use `make logs` to view detailed execution logs
3. **Validation**: Run `./scripts/validate-command.sh <command>` for diagnostics
4. **Demo**: Run `./scripts/demo-local-testing.sh` for interactive walkthrough

### Best Practices

- **Always test locally first**: Never push untested code
- **Use the validation script**: `./scripts/validate-command.sh` before submission
- **Follow naming conventions**: Use BA artifact naming standards
- **Document your commands**: Update README and help text
- **Test all environments**: dev1, sit1, uat1, prod1
- **Handle errors gracefully**: Implement proper error handling

### Troubleshooting Checklist

- [ ] CLI builds successfully: `cd cli-tester && make build`
- [ ] Command is registered: `grep "yourcommand" cli-tester/main.go`
- [ ] Tests pass: `make test-cli COMMAND=yourcommand`
- [ ] Validation passes: `./scripts/validate-command.sh yourcommand`
- [ ] Terraform validates: `make test-terraform`
- [ ] No syntax errors: Go vet and linting pass
- [ ] Documentation updated: README and help text complete

---

## 🎯 Success Criteria

Your command is ready for production when:

✅ **All tests pass**: `make test-all`  
✅ **Validation passes**: `./scripts/validate-command.sh yourcommand`  
✅ **Pre-production check passes**: `make pre-production-check`  
✅ **PR created and reviewed**: Following the GitHub workflow above  
✅ **CI/CD pipeline passes**: All automated checks green  
✅ **Documentation complete**: Help text, README, examples  
✅ **Team approval**: DevX team review and approval  

---

**Version**: 1.0.0  
**Last Updated**: November 2025  
**Guide Author**: British Airways DevX Team</parameter>
<parameter name="line_count">467</parameter>
</xai:function_call>