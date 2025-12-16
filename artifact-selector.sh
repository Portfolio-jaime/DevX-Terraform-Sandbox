#!/bin/bash
# ============================================================================
# Artifact Selector - DevX Sandbox Test Tool
# ============================================================================
# Description: Interactive menu to select and clone artifacts for local testing
# Usage: ./artifact-selector.sh
# ============================================================================

set -e

# ============================================================================
# Functions
# ============================================================================

show_banner() {
    echo "🔧 DevX Artifact Selector - Sandbox Test"
    echo "=========================================="
    echo ""
}

list_available_artifacts() {
    echo "📦 Available Artifacts in Sandbox:"
    echo ""
    
    # Create a temporary file to store artifacts data
    ARTIFACTS_FILE="/tmp/artifact_selector_$$.tmp"
    > "$ARTIFACTS_FILE"
    
    COUNTER=1
    
    # Search in nx-artifacts-inventory
    for layer_dir in al bal bb bc bff ch dev lib sdk tc xp; do
        if [[ -d "repos/nx-artifacts-inventory/nx-artifacts/$layer_dir" ]]; then
            for artifact_dir in "repos/nx-artifacts-inventory/nx-artifacts/$layer_dir"/*; do
                if [[ -d "$artifact_dir" ]]; then
                    ARTIFACT_NAME=$(basename "$artifact_dir")
                    LAYER=$(basename "$(dirname "$artifact_dir")")
                    
                    # Count environments
                    ENV_COUNT=$(ls "$artifact_dir" 2>/dev/null | grep -c "\.yaml$" || echo "0")
                    
                    echo "[$COUNTER] $ARTIFACT_NAME"
                    echo "    Layer: $LAYER | Environments: $ENV_COUNT | Path: $artifact_dir"
                    echo ""
                    
                    # Store in temporary file
                    echo "$COUNTER|$ARTIFACT_NAME|$LAYER|$artifact_dir|unknown" >> "$ARTIFACTS_FILE"
                    ((COUNTER++))
                fi
            done
        fi
    done
    
    # Search in nx-bolt-environment repos (for artifacts not in inventory)
    echo "🏗️  Available in Environment Repos:"
    echo ""
    
    for env_repo in repos/nx-bolt-environment-*; do
        if [[ -d "$env_repo" ]]; then
            ENV_NAME=$(basename "$env_repo" | sed 's/nx-bolt-environment-//')
            
            for layer_dir in "$env_repo"/*; do
                if [[ -d "$layer_dir" ]]; then
                    LAYER=$(basename "$layer_dir")
                    
                    for service_dir in "$layer_dir"/*; do
                        if [[ -d "$service_dir" ]]; then
                            SERVICE_NAME=$(basename "$service_dir")
                            
                            if [[ -f "$service_dir/Chart.yaml" ]]; then
                                echo "[$COUNTER] $SERVICE_NAME"
                                echo "    Layer: $LAYER | Environment: $ENV_NAME | Path: $service_dir"
                                echo ""
                                
                                # Store in temporary file
                                echo "$COUNTER|$SERVICE_NAME|$LAYER|$service_dir|$ENV_NAME" >> "$ARTIFACTS_FILE"
                                ((COUNTER++))
                            fi
                        fi
                    done
                fi
            done
        fi
    done
    
    # Export the file path for other functions
    export ARTIFACTS_FILE
}

get_artifact_info() {
    local choice=$1
    
    if [[ ! -f "$ARTIFACTS_FILE" ]]; then
        echo "❌ No artifacts data found. Please run list_available_artifacts first."
        return 1
    fi
    
    # Extract artifact info from temporary file
    IFS='|' read -r NUMBER ARTIFACT_NAME LAYER ARTIFACT_PATH ENV_NAME < <(grep "^$choice|" "$ARTIFACTS_FILE" | head -1)
    
    if [[ -z "$ARTIFACT_NAME" ]]; then
        echo "❌ Invalid choice. Please try again."
        return 1
    fi
    
    # Return the artifact info
    echo "$ARTIFACT_NAME|$LAYER|$ARTIFACT_PATH|$ENV_NAME"
}

clone_artifact_for_testing() {
    local choice=$1
    
    echo ""
    echo "🔄 Preparing artifact for local testing..."
    
    ARTIFACT_INFO=$(get_artifact_info "$choice")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    IFS='|' read -r ARTIFACT_NAME LAYER ARTIFACT_PATH ENV_NAME <<< "$ARTIFACT_INFO"
    
    echo "Artifact: $ARTIFACT_NAME"
    echo "Layer: $LAYER"
    echo "Path: $ARTIFACT_PATH"
    
    # Create test directory
    TEST_DIR="test-artifacts/$(basename "$ARTIFACT_NAME")"
    mkdir -p "$TEST_DIR"
    
    # Copy relevant files for testing
    if [[ -f "$ARTIFACT_PATH/nx-app-inventory.yaml" ]]; then
        cp "$ARTIFACT_PATH/nx-app-inventory.yaml" "$TEST_DIR/"
        echo "✅ Copied inventory file"
    fi
    
    if [[ -f "$ARTIFACT_PATH/Chart.yaml" ]]; then
        cp "$ARTIFACT_PATH/Chart.yaml" "$TEST_DIR/"
        echo "✅ Copied Helm chart"
    fi
    
    if [[ -f "$ARTIFACT_PATH/values.yaml" ]]; then
        cp "$ARTIFACT_PATH/values.yaml" "$TEST_DIR/"
        echo "✅ Copied values file"
    fi
    
    echo ""
    echo "🎯 Artifact prepared for testing in: $TEST_DIR"
    echo ""
    echo "Now you can run:"
    echo "  ./test-review-artifact.sh --artifact $(basename "$ARTIFACT_NAME")"
    echo ""
}

run_test_with_artifact() {
    local choice=$1
    
    echo ""
    echo "🧪 Running test with artifact..."
    
    ARTIFACT_INFO=$(get_artifact_info "$choice")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    IFS='|' read -r ARTIFACT_NAME LAYER ARTIFACT_PATH ENV_NAME <<< "$ARTIFACT_INFO"
    
    echo "Artifact: $ARTIFACT_NAME"
    echo "Layer: $LAYER"
    echo ""
    
    # Extract the service name for artifact search
    if [[ "$LAYER" == "unknown" ]]; then
        # This is from environment repo
        SERVICE_NAME=$(basename "$ARTIFACT_NAME")
    else
        # This is from inventory repo
        SERVICE_NAME=$(echo "$ARTIFACT_NAME" | sed 's/nx-[^-]*-//' | sed 's/-[^-]*$//')
    fi
    
    ./test-review-artifact.sh --artifact "$SERVICE_NAME"
}

show_menu() {
    echo "Choose an option:"
    echo "[1] List all available artifacts"
    echo "[2] Run /review-artifact test with specific artifact"
    echo "[3] Clone artifact for local testing"
    echo "[4] Exit"
    echo ""
    read -p "Enter your choice (1-4): " choice
    echo ""
}

# ============================================================================
# Main Menu Loop
# ============================================================================

# Initialize variables
ARTIFACTS_FILE=""
choice=""

while true; do
    clear
    show_banner
    show_menu
    
    case $choice in
        1)
            list_available_artifacts
            echo ""
            read -p "Press Enter to continue..."
            ;;
        2)
            list_available_artifacts
            echo ""
            read -p "Enter artifact number to test: " test_choice
            if [[ -n "$test_choice" ]] && [[ -f "$ARTIFACTS_FILE" ]] && grep -q "^$test_choice|" "$ARTIFACTS_FILE" 2>/dev/null; then
                run_test_with_artifact "$test_choice"
                echo ""
                echo "✅ Test completed! Review the results above."
                echo ""
                read -p "Press Enter to continue..."
            else
                echo "❌ Invalid choice. Please try again."
                echo ""
                read -p "Press Enter to continue..."
            fi
            ;;
        3)
            list_available_artifacts
            echo ""
            read -p "Enter artifact number to clone: " clone_choice
            if [[ -n "$clone_choice" ]] && [[ -f "$ARTIFACTS_FILE" ]] && grep -q "^$clone_choice|" "$ARTIFACTS_FILE" 2>/dev/null; then
                clone_artifact_for_testing "$clone_choice"
                echo ""
                read -p "Press Enter to continue..."
            else
                echo "❌ Invalid choice. Please try again."
                echo ""
                read -p "Press Enter to continue..."
            fi
            ;;
        4)
            echo "👋 Goodbye!"
            # Clean up temporary file
            [[ -f "$ARTIFACTS_FILE" ]] && rm -f "$ARTIFACTS_FILE"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please enter 1-4."
            echo ""
            read -p "Press Enter to continue..."
            ;;
    esac
    
    # Clean up temporary file after each iteration
    [[ -f "$ARTIFACTS_FILE" ]] && rm -f "$ARTIFACTS_FILE"
done