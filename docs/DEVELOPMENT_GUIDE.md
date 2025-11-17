# CLI Command Development Guide

## 🎯 Overview

This guide helps you create new commands for the British Airways Terraform Nexus Builder CLI (`tf_nx`) using the sandbox as your development platform.

## 🚀 Quick Start for New Commands

### Step 1: Create Command Structure

```bash
# Go to CLI directory
cd cli-tester

# Create new command directory
mkdir -p cmd/yourcommand

# Create command file
cat > cmd/yourcommand/yourcommand.go << 'EOF'
package yourcommand

import (
    "fmt"
    "terraform_nexus_builder/cmd"
    "terraform_nexus_builder/tf_infra_components/yourcomponent"
    "terraform_nexus_builder/utils"

    "github.com/fatih/color"
    "github.com/spf13/cobra"
)

var yourCmd = &cobra.Command{
    Use:   "yourcommand [action] [flags]",
    Short: color.YellowString("Your command description"),
    Long:  color.BlueString("Detailed description of your command"),
    Args:  cobra.ExactArgs(1),
    Run:   runYourCommand,
}

func init() {
    utils.SetGlobalDefaultFlags(yourCmd)
    cmd.RootCmd.AddCommand(yourCmd)
}

func runYourCommand(cmd *cobra.Command, args []string) {
    action := args[0]
    
    settings := interfaces.TerraformBuilderSettings{
        ArtifactName: artifactName,
        Environment:  environment,
        Individual:   individual,
        Debug:        debug,
    }

    component := yourcomponent.New(settings)
    
    switch action {
    case "create":
        fmt.Println(color.GreenString("Creating your component..."))
        component.Create()
    case "delete":
        fmt.Println(color.GreenString("Deleting your component..."))
        component.Delete()
    default:
        fmt.Println(color.RedString("Unknown action: %s", action))
    }
}
EOF
```

### Step 2: Create Infrastructure Component

```bash
# Create infrastructure component
mkdir -p tf_infra_components/yourcomponent

# Create component file
cat > tf_infra_components/yourcomponent/yourcomponent.go << 'EOF'
package yourcomponent

import (
    "fmt"
    "terraform_nexus_builder/interfaces"
    "terraform_nexus_builder/utils"
)

type YourComponentConfig struct {
    editor       *utils.TfEditor
    artifactName string
    settings     interfaces.TerraformBuilderSettings
}

func New(settings interfaces.TerraformBuilderSettings) YourComponentConfig {
    editor, err := utils.NewTfEditor(settings.ArtifactName, settings.Environment)
    if err != nil {
        panic(err)
    }

    return YourComponentConfig{
        editor:       editor,
        artifactName: settings.ArtifactName,
        settings:     settings,
    }
}

func (c *YourComponentConfig) Create() {
    fmt.Printf("Creating your component for artifact: %s\n", c.artifactName)
    
    // Add your Terraform configuration logic here
    // Use the editor to modify files
    // Example:
    // c.editor.AddResource("your_resource_type", "your_resource_name", map[string]interface{}{...})
}

func (c *YourComponentConfig) Delete() {
    fmt.Printf("Deleting your component for artifact: %s\n", c.artifactName)
    
    // Add your deletion logic here
}
EOF
```

### Step 3: Register Command in main.go

```bash
# Edit main.go to register your command
sed -i '' 's/_ "terraform_nexus_builder\/cmd\/service_account"/&\
\t_ "terraform_nexus_builder\/cmd\/yourcommand"/' cli-tester/main.go
```

### Step 4: Test Your Command

```bash
# Build CLI with new command
cd cli-tester && make build

# Test the new command
make test-cli COMMAND=yourcommand

# Test specific action
ARTIFACT_NAME=nx-bff-test ENVIRONMENT=dev1 cli-tester/tf_nx yourcommand create -a nx-bff-test -e dev1
```

## 📋 Command Development Checklist

### Command Structure
- [ ] Command directory created in `cli-tester/cmd/yourcommand/`
- [ ] Command file follows naming convention: `yourcommand.go`
- [ ] Command registered in `main.go`
- [ ] Uses proper Cobra command structure
- [ ] Includes help text and descriptions

### Infrastructure Component
- [ ] Component directory created in `cli-tester/tf_infra_components/yourcomponent/`
- [ ] Component implements required interface
- [ ] Create and Delete methods implemented
- [ ] Uses utils.TfEditor for file operations
- [ ] Proper error handling

### Testing Requirements
- [ ] Command builds successfully
- [ ] Help command works: `tf_nx yourcommand --help`
- [ ] Create action works: `tf_nx yourcommand create -a test -e dev1`
- [ ] Delete action works: `tf_nx yourcommand delete -a test -e dev1`
- [ ] Error handling tested
- [ ] Validation tested

### Integration Testing
- [ ] Works with all environments (dev1, sit1, uat1, prod1)
- [ ] Individual architecture tested
- [ ] Inventory updates correctly
- [ ] Terraform generation works
- [ ] GitHub workflow integration works

## 🧪 Testing Your New Command

### Unit Testing
```bash
# Test basic functionality
make test-cli COMMAND=yourcommand

# Test with different environments
for env in dev1 sit1 uat1 prod1; do
    make test-cli COMMAND=yourcommand ENV=$env
done

# Test individual architecture
make test-cli COMMAND=yourcommand INDIVIDUAL=true
```

### Error Testing
```bash
# Test invalid artifact name
make test-cli COMMAND=yourcommand ARTIFACT="invalid-name"

# Test invalid environment
make test-cli COMMAND=yourcommand ENV="invalid-env"

# Test missing required flags
make test-cli COMMAND=yourcommand
```

### Integration Testing
```bash
# Test full workflow
make test-integration COMMAND=yourcommand

# Test with real CLI build
cd cli-tester && go build -o tf_nx_test
./tf_nx_test yourcommand create -a nx-bff-test -e dev1
```

## 🛠️ Development Tools

### Template Generator
```bash
# Use template to generate new command
./scripts/generate-command.sh mynewcommand

# This creates:
# - cli-tester/cmd/mynewcommand/mynewcommand.go
# - cli-tester/tf_infra_components/mynewcomponent/mynewcomponent.go
# - Test files
```

### Validation Tools
```bash
# Check command structure
./scripts/validate-command.sh yourcommand

# Check Terraform generation
./scripts/check-tf-generation.sh yourcommand

# Check integration
./scripts/check-integration.sh yourcommand
```

### Debug Tools
```bash
# Enable debug mode
make dev-cli DEBUG=1

# Verbose output
export DEBUG=1
export LOG_LEVEL=debug
make test-cli COMMAND=yourcommand

# Trace execution
bash -x ./tests/test-cli-command.sh yourcommand
```

## 📝 Common Patterns

### Command Structure Pattern
```go
package yourcommand

import (
    "fmt"
    "terraform_nexus_builder/cmd"
    "terraform_nexus_builder/tf_infra_components/yourcomponent"
    "terraform_nexus_builder/utils"

    "github.com/fatih/color"
    "github.com/spf13/cobra"
)

var yourCmd = &cobra.Command{
    Use:   "yourcommand [action] [flags]",
    Short: color.YellowString("Description"),
    Long:  color.BlueString("Detailed description"),
    Args:  cobra.ExactArgs(1),
    Run:   runYourCommand,
}

func init() {
    utils.SetGlobalDefaultFlags(yourCmd)
    cmd.RootCmd.AddCommand(yourCmd)
}

func runYourCommand(cmd *cobra.Command, args []string) {
    // Command implementation
}
```

### Infrastructure Component Pattern
```go
package yourcomponent

import (
    "fmt"
    "terraform_nexus_builder/interfaces"
    "terraform_nexus_builder/utils"
)

type YourComponentConfig struct {
    editor       *utils.TfEditor
    artifactName string
    settings     interfaces.TerraformBuilderSettings
}

func New(settings interfaces.TerraformBuilderSettings) YourComponentConfig {
    editor, err := utils.NewTfEditor(settings.ArtifactName, settings.Environment)
    if err != nil {
        panic(err)
    }

    return YourComponentConfig{
        editor:       editor,
        artifactName: settings.ArtifactName,
        settings:     settings,
    }
}

func (c *YourComponentConfig) Create() {
    // Create implementation
}

func (c *YourComponentConfig) Delete() {
    // Delete implementation
}
```

### Terraform Template Pattern
```hcl
# your-component.tf
resource "your_resource_type" "your_resource_name" {
  name        = "${var.artifact_name}-${var.environment}"
  environment = var.environment
  
  # Add your resource configuration
  
  tags = {
    ArtifactName = var.artifact_name
    Environment  = var.environment
    Component    = "yourcomponent"
  }
}

# Output your resource outputs
output "your_output_name" {
  value = your_resource_type.your_resource_name.output_attribute
}
```

## 🔧 Troubleshooting

### Common Issues

**1. Command Not Found**
```bash
# Check if registered in main.go
grep "yourcommand" cli-tester/main.go

# Rebuild CLI
cd cli-tester && make build
```

**2. Import Errors**
```bash
# Check Go modules
cd cli-tester && go mod tidy

# Verify package paths
go list ./...
```

**3. Terraform Generation Issues**
```bash
# Check component interface implementation
go vet ./tf_infra_components/yourcomponent/

# Test Terraform syntax
cd cli-tester/tf_infra_components/yourcomponent/
terraform init
terraform validate
```

### Debug Commands
```bash
# Check command registration
cli-tester/tf_nx --help | grep yourcommand

# Test command parsing
cli-tester/tf_nx yourcommand --help

# Check component loading
DEBUG=1 cli-tester/tf_nx yourcommand create -a test -e dev1
```

## 📊 Pre-Production Checklist

Before submitting to production repositories:

### Code Quality
- [ ] Code follows Go conventions
- [ ] Proper error handling implemented
- [ ] Logging and debug support
- [ ] Help text and documentation complete

### Testing
- [ ] All tests pass: `make test-cli COMMAND=yourcommand`
- [ ] Error scenarios tested: `make test-errors`
- [ ] Integration tests pass: `make test-integration`
- [ ] Performance acceptable

### Documentation
- [ ] Command help text implemented
- [ ] README updated with new command
- [ ] Examples provided
- [ ] Troubleshooting guide updated

### Production Readiness
- [ ] No debug statements in production code
- [ ] Proper resource cleanup on deletion
- [ ] Inventory integration working
- [ ] GitHub workflow integration working
- [ ] Cost estimation updated if applicable

## 🆘 Getting Help

1. **Check Examples**: Look at existing commands in `cli-tester/cmd/`
2. **Review Templates**: Use `cli-tester/cmd/redis/` as template
3. **Run Diagnostics**: `make diagnostics`
4. **Check Logs**: `make logs`
5. **Ask Team**: Contact DevX team for support

---

**Version**: 1.0.0  
**Purpose**: CLI Command Development  
**Last Updated**: November 2025