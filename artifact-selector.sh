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
    
    COUNTER=1
    declare -A ARTIFACTS
    
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
                    
                    ARTIFACTS[$COUNTER]="$ARTIFACT_NAME|$LAYER|$artifact_dir"
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
                                
                                ARTIFACTS[$COUNTER]="$SERVICE_NAME|$LAYER|$service_dir|$ENV_NAME"
                                ((COUNTER++))
                            fi
                        fi
                    done
                fi
            done
        fi
    done
}

clone_artifact_for_testing() {
    local choice=$1
    IFS='|' read -r ARTIFACT_NAME LAYER ARTIFACT_PATH ENV_NAME <<< "${ARTIFACTS[$choice]}"
    
    echo ""
    echo "🔄 Preparing artifact for local testing..."
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
    IFS='|' read -r ARTIFACT_NAME LAYER ARTIFACT_PATH ENV_NAME <<< "${ARTIFACTS[$choice]}"
    
    echo ""
    echo "🧪 Running test with artifact: $(basename "$ARTIFACT_NAME")"
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

declare -A ARTIFACTS

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
            if [[ -n "${ARTIFACTS[$test_choice]}" ]]; then
                run_test_with_artifact $test_choice
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
            if [[ -n "${ARTIFACTS[$clone_choice]}" ]]; then
                clone_artifact_for_testing $clone_choice
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
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please enter 1-4."
            echo ""
            read -p "Press Enter to continue..."
            ;;
    esac
done