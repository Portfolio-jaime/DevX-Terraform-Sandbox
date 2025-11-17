#!/bin/bash
# ============================================================================
# GitHub Artifact Cloner - DevX Sandbox Test Tool  
# ============================================================================
# Description: Clone real artifact repositories for local testing
# Usage: ./clone-artifact-from-github.sh <github-org> <artifact-name>
# ============================================================================

set -e

# ============================================================================
# Functions
# ============================================================================

show_banner() {
    echo "🔧 GitHub Artifact Cloner - DevX Sandbox"
    echo "========================================"
    echo ""
}

check_git_installed() {
    if ! command -v git &> /dev/null; then
        echo "❌ Git is not installed. Please install Git first."
        exit 1
    fi
    echo "✅ Git is available"
}

clone_artifact_repo() {
    local org=$1
    local artifact=$2
    local clone_dir="local-artifacts/$artifact"
    
    echo "🔄 Cloning artifact repository..."
    echo "Organization: $org"
    echo "Artifact: $artifact"
    echo "Target directory: $clone_dir"
    echo ""
    
    # Create directory structure
    mkdir -p "local-artifacts"
    
    # Clone the repository
    if git clone "https://github.com/$org/$artifact.git" "$clone_dir"; then
        echo "✅ Successfully cloned $artifact"
        
        # Show repository contents
        echo ""
        echo "📁 Repository contents:"
        ls -la "$clone_dir"
        
        # Check if it's a Helm chart
        if [[ -f "$clone_dir/Chart.yaml" ]]; then
            echo ""
            echo "🏗️  Found Helm chart:"
            echo "   Chart.yaml exists"
            if [[ -f "$clone_dir/values.yaml" ]]; then
                echo "   values.yaml exists"
            fi
        fi
        
        # Check for other common files
        if [[ -f "$clone_dir/README.md" ]]; then
            echo "   README.md exists"
        fi
        
        if [[ -f "$clone_dir/.gitignore" ]]; then
            echo "   .gitignore exists"
        fi
        
        return 0
    else
        echo "❌ Failed to clone repository"
        return 1
    fi
}

prepare_artifact_for_testing() {
    local artifact=$1
    local clone_dir="local-artifacts/$artifact"
    local test_dir="test-artifacts/$artifact"
    
    echo ""
    echo "🧪 Preparing artifact for testing..."
    
    # Create test directory
    mkdir -p "$test_dir"
    
    # Copy relevant files
    if [[ -f "$clone_dir/Chart.yaml" ]]; then
        cp "$clone_dir/Chart.yaml" "$test_dir/"
        echo "✅ Copied Chart.yaml"
    fi
    
    if [[ -f "$clone_dir/values.yaml" ]]; then
        cp "$clone_dir/values.yaml" "$test_dir/"
        echo "✅ Copied values.yaml"
    fi
    
    if [[ -f "$clone_dir/README.md" ]]; then
        cp "$clone_dir/README.md" "$test_dir/"
        echo "✅ Copied README.md"
    fi
    
    # Create inventory file for testing
    create_test_inventory "$artifact" "$clone_dir" "$test_dir"
    
    echo ""
    echo "🎯 Artifact prepared for testing in: $test_dir"
}

create_test_inventory() {
    local artifact=$1
    local clone_dir=$2
    local test_dir=$3
    
    echo ""
    echo "📝 Creating test inventory file..."
    
    # Extract service info from Chart.yaml if available
    local service_name="$artifact"
    local layer="unknown"
    
    if [[ -f "$clone_dir/Chart.yaml" ]]; then
        # Try to extract name from Chart.yaml
        chart_name=$(grep -E "^name:" "$clone_dir/Chart.yaml" 2>/dev/null | awk '{print $2}' | head -1 || echo "")
        if [[ -n "$chart_name" ]]; then
            service_name="$chart_name"
        fi
        
        # Determine layer based on chart name or path
        if [[ "$service_name" =~ nx-tc- ]]; then
            layer="tc"
        elif [[ "$service_name" =~ nx-al- ]]; then
            layer="al"
        elif [[ "$service_name" =~ nx-bc- ]]; then
            layer="bc"
        elif [[ "$service_name" =~ nx-bff- ]]; then
            layer="bff"
        elif [[ "$service_name" =~ nx-ch- ]]; then
            layer="ch"
        elif [[ "$service_name" =~ nx-xp- ]]; then
            layer="xp"
        fi
    fi
    
    # Create inventory file
    cat > "$test_dir/nx-app-inventory.yaml" << EOF
schema_version: "1.0"

artifact_metadata:
  artifact_name: "$artifact"
  layer: "$layer"
  service: "$(echo $service_name | sed 's/nx-[^-]*-//')"
  description: "Test artifact for $service_name"
  owner: "devx-team"
  cloned_from_github: true

infrastructure:
  enabled: true
  deployed: false
  component: "service_account"
  environment: "sandbox"

components:
  service_account:
    name: "sa-$service_name"
    namespace: "nexus-sandbox"
    enabled: true
    
  redis:
    name: ""
    cluster_id: ""
    endpoint: ""
    enabled: false
    
  dynamo:
    table_name: ""
    partition_key: ""
    sort_key: ""
    enabled: false
    
  rds:
    instance_class: ""
    engine: ""
    enabled: true
    
  ecr:
    repository_name: "$service_name"
    image_tag: "latest"
    enabled: true
EOF
    
    echo "✅ Created test inventory file"
    echo "   Service: $service_name"
    echo "   Layer: $layer"
    echo "   From GitHub: Yes"
}

list_available_commands() {
    echo ""
    echo "🔧 Available commands for testing:"
    echo ""
    echo "1. Review artifact:"
    echo "   ./test-review-artifact.sh --artifact $(echo $artifact | sed 's/nx-[^-]*-//' | sed 's/-[^-]*$//')"
    echo ""
    echo "2. Test CLI with artifact:"
    echo "   cd $clone_dir"
    echo "   # Test your CLI modifications here"
    echo ""
    echo "3. Manual testing:"
    echo "   cd $test_dir"
    echo "   # Modify files and test changes"
    echo ""
}

# ============================================================================
# Main Script
# ============================================================================

if [[ $# -ne 2 ]]; then
    echo "❌ Usage: $0 <github-organization> <artifact-name>"
    echo ""
    echo "Examples:"
    echo "  $0 BritishAirways-Nexus nx-tc-order-creator"
    echo "  $0 BritishAirways-Nexus nx-ch-web-checkout"
    echo ""
    exit 1
fi

show_banner
check_git_installed

org=$1
artifact=$2

echo "🔍 Validating repository..."
if git ls-remote --heads "https://github.com/$org/$artifact.git" &> /dev/null; then
    echo "✅ Repository exists: https://github.com/$org/$artifact"
else
    echo "❌ Repository not found: https://github.com/$org/$artifact"
    echo "Please check the organization and artifact name."
    exit 1
fi

echo ""
if clone_artifact_repo "$org" "$artifact"; then
    prepare_artifact_for_testing "$artifact"
    list_available_commands "$artifact"
    echo ""
    echo "🎉 Artifact ready for local testing!"
    echo "You can now modify, test, and iterate without affecting the real repository."
else
    echo "❌ Failed to prepare artifact for testing."
    exit 1
fi