#!/bin/bash
# Command Generator for British Airways DevX Terraform Sandbox
# Creates new CLI commands with proper structure and templates

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

# Check if command name provided
if [ $# -eq 0 ]; then
    log_error "Usage: $0 <command-name> [component-name]"
    echo "Example: $0 myservice myservice-component"
    exit 1
fi

COMMAND_NAME=$1
COMPONENT_NAME=${2:-$1}

# Convert to lowercase for directories
COMMAND_DIR=$(echo $COMMAND_NAME | tr '[:upper:]' '[:lower:]')
COMPONENT_DIR=$(echo $COMPONENT_NAME | tr '[:upper:]' '[:lower:]')

log_info "Generating new command: $COMMAND_NAME"
log_info "Component: $COMPONENT_NAME"

# Create command directory
mkdir -p cli-tester/cmd/$COMMAND_DIR

# Generate command file
cat > cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go << EOF
package $COMMAND_DIR

import (
	"fmt"
	"terraform_nexus_builder/cmd"
	"terraform_nexus_builder/tf_infra_components/$COMPONENT_DIR"
	"terraform_nexus_builder/utils"

	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var $COMMAND_DIR\Cmd = &cobra.Command{
	Use:   "$COMMAND_DIR [action] [flags]",
	Short: color.YellowString("$COMMAND_NAME command for managing $COMPONENT_NAME components"),
	Long:  color.BlueString("Comprehensive $COMMAND_NAME command for creating, managing, and deleting $COMPONENT_NAME infrastructure components"),
	Args:  cobra.ExactArgs(1),
	Run:   run$COMMAND_DIR\Command,
}

func init() {
	utils.SetGlobalDefaultFlags($COMMAND_DIR\Cmd)
	cmd.RootCmd.AddCommand($COMMAND_DIR\Cmd)
}

func run$COMMAND_DIR\Command(cmd *cobra.Command, args []string) {
	action := args[0]
	
	settings := interfaces.TerraformBuilderSettings{
		ArtifactName: artifactName,
		Environment:  environment,
		Individual:   individual,
		Debug:        debug,
	}

	component := $COMPONENT_DIR.New(settings)
	
	switch action {
	case "create":
		fmt.Println(color.GreenString("Creating $COMPONENT_NAME for artifact: %s in environment: %s"), settings.ArtifactName, settings.Environment)
		component.Create()
	case "delete":
		fmt.Println(color.GreenString("Deleting $COMPONENT_NAME for artifact: %s in environment: %s"), settings.ArtifactName, settings.Environment)
		component.Delete()
	case "update":
		fmt.Println(color.GreenString("Updating $COMPONENT_NAME for artifact: %s in environment: %s"), settings.ArtifactName, settings.Environment)
		component.Update()
	default:
		fmt.Println(color.RedString("Unknown action: %s. Available actions: create, delete, update"), action)
		fmt.Println(color.BlueString("Use --help for more information"))
	}
}
EOF

# Create component directory
mkdir -p cli-tester/tf_infra_components/$COMPONENT_DIR

# Generate component file
cat > cli-tester/tf_infra_components/$COMPONENT_DIR/$COMPONENT_DIR.go << EOF
package $COMPONENT_DIR

import (
	"fmt"
	"terraform_nexus_builder/interfaces"
	"terraform_nexus_builder/utils"
)

type ${COMPONENT_NAME^}Config struct {
	editor       *utils.TfEditor
	artifactName string
	settings     interfaces.TerraformBuilderSettings
}

func New(settings interfaces.TerraformBuilderSettings) ${COMPONENT_NAME^}Config {
	editor, err := utils.NewTfEditor(settings.ArtifactName, settings.Environment)
	if err != nil {
		panic(err)
	}

	return ${COMPONENT_NAME^}Config{
		editor:       editor,
		artifactName: settings.ArtifactName,
		settings:     settings,
	}
}

func (c *${COMPONENT_NAME^}Config) Create() {
	fmt.Printf("Creating $COMPONENT_NAME component for artifact: %s\n", c.artifactName)
	
	// TODO: Add your Terraform configuration logic here
	// Example: Create resources, update configuration files, etc.
	
	// Example Terraform resource creation:
	// c.editor.AddResource("aws_your_resource", c.artifactName, map[string]interface{}{
	// 	"name":        c.artifactName + "-" + c.settings.Environment,
	// 	"environment": c.settings.Environment,
	// 	"tags": map[string]interface{}{
	// 		"ArtifactName": c.artifactName,
	// 		"Environment":  c.settings.Environment,
	// 		"Component":    "$COMPONENT_NAME",
	// 	},
	// })
}

func (c *${COMPONENT_NAME^}Config) Delete() {
	fmt.Printf("Deleting $COMPONENT_NAME component for artifact: %s\n", c.artifactName)
	
	// TODO: Add your deletion logic here
	// Remove resources, cleanup files, etc.
}

func (c *${COMPONENT_NAME^}Config) Update() {
	fmt.Printf("Updating $COMPONENT_NAME component for artifact: %s\n", c.artifactName)
	
	// TODO: Add your update logic here
	// Modify existing resources, update configuration, etc.
}
EOF

# Create templates directory for the component
mkdir -p cli-tester/tf_infra_components/$COMPONENT_DIR/templates

# Generate Terraform template
cat > cli-tester/tf_infra_components/$COMPONENT_DIR/templates/$COMPONENT_NAME.tpl << 'EOF'
# $COMPONENT_NAME Terraform Template
# Generated for {{.ArtifactName}} in {{.Environment}}

{{range .Resources}}
resource "{{.Type}}" "{{.Name}}" {
{{range .Attributes}}
  {{.Key}} = {{.Value}}
{{end}}
  tags = {
    ArtifactName = "{{$.ArtifactName}}"
    Environment  = "{{$.Environment}}"
    Component    = "{{$.ComponentName}}"
    ManagedBy    = "tf_nx"
  }
}
{{end}}

# Outputs
{{range .Outputs}}
output "{{.Name}}" {
  description = "{{.Description}}"
  value       = {{.Value}}
}
{{end}}
EOF

# Create test file for the command
mkdir -p tests/commands
cat > tests/commands/test-$COMMAND_DIR.sh << 'EOF'
#!/bin/bash
# Test script for $COMMAND_NAME command

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

TEST_ARTIFACT="nx-bff-$COMMAND_DIR-test"
TEST_ENV="dev1"

test_command_creation() {
    log_info "Testing $COMMAND_NAME command creation..."
    
    # Test help command
    if cli-tester/tf_nx $COMMAND_DIR --help > /dev/null 2>&1; then
        log_success "Help command works"
    else
        log_error "Help command failed"
        return 1
    fi
    
    # Test create action
    if ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx $COMMAND_DIR create -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_success "Create action works"
    else
        log_error "Create action failed"
        return 1
    fi
    
    # Test delete action
    if ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx $COMMAND_DIR delete -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_success "Delete action works"
    else
        log_error "Delete action failed"
        return 1
    fi
    
    # Test update action
    if ARTIFACT_NAME=$TEST_ARTIFACT ENVIRONMENT=$TEST_ENV cli-tester/tf_nx $COMMAND_DIR update -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_success "Update action works"
    else
        log_error "Update action failed"
        return 1
    fi
}

test_error_scenarios() {
    log_info "Testing error scenarios..."
    
    # Test invalid action
    if cli-tester/tf_nx $COMMAND_DIR invalid-action -a $TEST_ARTIFACT -e $TEST_ENV > /dev/null 2>&1; then
        log_error "Should have failed with invalid action"
        return 1
    else
        log_success "Invalid action properly rejected"
    fi
}

main() {
    echo -e "${BLUE}Testing $COMMAND_NAME Command${NC}"
    echo "================================"
    
    test_command_creation
    test_error_scenarios
    
    echo -e "${GREEN}All $COMMAND_NAME tests passed!${NC}"
}

main "$@"
EOF

chmod +x tests/commands/test-$COMMAND_DIR.sh

# Add command to main.go (if it exists)
if [ -f "cli-tester/main.go" ]; then
    log_info "Adding import to main.go..."
    
    # Check if command is already added
    if ! grep -q "\"terraform_nexus_builder/cmd/$COMMAND_DIR\"" cli-tester/main.go; then
        # Add import before the last import
        sed -i '' 's/_ "terraform_nexus_builder\/cmd\/service_account"/&\
\t_ "terraform_nexus_builder\/cmd\/'$COMMAND_DIR'"/' cli-tester/main.go
        log_success "Added import to main.go"
    else
        log_info "Command already imported in main.go"
    fi
fi

# Create README documentation for the command
cat > cli-tester/cmd/$COMMAND_DIR/README.md << EOF
# $COMMAND_NAME Command

## Overview
The \`$COMMAND_DIR\` command manages $COMPONENT_NAME components for artifacts in the British Airways infrastructure.

## Usage
\`\`\`bash
tf_nx $COMMAND_DIR <action> [flags]
\`\`\`

## Actions
- \`create\` - Create new $COMPONENT_NAME component
- \`delete\` - Delete existing $COMPONENT_NAME component  
- \`update\` - Update existing $COMPONENT_NAME component

## Examples
\`\`\`bash
# Create component
tf_nx $COMMAND_DIR create -a nx-bff-my-service -e dev1

# Delete component
tf_nx $COMMAND_DIR delete -a nx-bff-my-service -e dev1

# Update component
tf_nx $COMMAND_DIR update -a nx-bff-my-service -e dev1
\`\`\`

## Flags
- \`-a, --artifact\` - Artifact name (required)
- \`-e, --env\` - Environment (default: dev1)
- \`--individual\` - Use individual architecture
- \`--debug\` - Enable debug mode

## Testing
Run the test suite:
\`\`\`bash
./tests/commands/test-$COMMAND_DIR.sh
\`\`\`

## Development
See \`docs/DEVELOPMENT_GUIDE.md\` for detailed development instructions.
EOF

log_success "Generated new command: $COMMAND_NAME"
log_success "Command files created:"
log_success "  - cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go"
log_success "  - cli-tester/tf_infra_components/$COMPONENT_DIR/$COMPONENT_DIR.go"
log_success "  - cli-tester/tf_infra_components/$COMPONENT_DIR/templates/$COMPONENT_NAME.tpl"
log_success "  - tests/commands/test-$COMMAND_DIR.sh"
log_success "  - cli-tester/cmd/$COMMAND_DIR/README.md"

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Edit the command implementation in cli-tester/cmd/$COMMAND_DIR/$COMMAND_DIR.go"
echo "2. Add your component logic in cli-tester/tf_infra_components/$COMPONENT_DIR/$COMPONENT_DIR.go"
echo "3. Build the CLI: cd cli-tester && make build"
echo "4. Test the command: ./tests/commands/test-$COMMAND_DIR.sh"
echo "5. Test manually: cli-tester/tf_nx $COMMAND_DIR --help"