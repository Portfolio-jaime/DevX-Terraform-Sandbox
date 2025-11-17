#!/bin/bash
# ============================================================================
# Review Artifact Script - DevX Support Tool (Sandbox Test)
# ============================================================================
# Description: Quick artifact review for support tickets
# Usage: ./test-review-artifact.sh --artifact <name> --environment <env> --depth <depth>
# ============================================================================

set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --artifact)
      ARTIFACT="$2"
      shift 2
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --depth)
      DEPTH="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Defaults
ENVIRONMENT=${ENVIRONMENT:-"all"}
DEPTH=${DEPTH:-"standard"}
OUTPUT_FILE=${OUTPUT_FILE:-"/tmp/review-report.md"}

echo "🔍 Starting artifact review..."
echo "Artifact: $ARTIFACT"
echo "Environment: $ENVIRONMENT"
echo "Depth: $DEPTH"
echo "============================================"

# ============================================================================
# Functions
# ============================================================================

get_artifact_info() {
  echo "📦 Gathering artifact information..."

  # Determine layer by searching in all possible directories
  LAYER="unknown"
  INVENTORY_DIR=""
  ARTIFACT_DIR=""
  
  for layer_dir in al bal bb bc bff ch dev lib sdk tc xp; do
    if [[ -d "repos/nx-artifacts-inventory/nx-artifacts/$layer_dir" ]]; then
      # Check if artifact exists in this layer
      ARTIFACT_DIR=$(find "repos/nx-artifacts-inventory/nx-artifacts/$layer_dir" -name "*$ARTIFACT*" -type d | head -1)
      if [[ -n "$ARTIFACT_DIR" ]]; then
        LAYER="$layer_dir"
        INVENTORY_DIR="repos/nx-artifacts-inventory/nx-artifacts/$layer_dir"
        echo "Found artifact directory: $ARTIFACT_DIR"
        break
      fi
    fi
  done

  echo "Layer: $LAYER"
  echo "Inventory Directory: $INVENTORY_DIR"
  echo "Artifact Directory: $ARTIFACT_DIR"
}

check_environments() {
  echo "🌍 Checking environments..."

  if [[ -d "$INVENTORY_DIR" ]]; then
    # Find all directories matching the artifact pattern
    ENVS=$(find "$INVENTORY_DIR" -name "*$ARTIFACT*" -type d | xargs -I {} basename {} | sed 's/^nx-//' | sed 's/-[^-]*$//' | sort -u || echo "")
    ENV_COUNT=$(echo "$ENVS" | wc -l)
    
    echo "Found $ENV_COUNT environment(s):"
    echo "$ENVS" | while read env; do
      echo "  - $env"
    done
  else
    echo "⚠️ No inventory directory found"
    ENV_COUNT=0
  fi
}

analyze_inventory_files() {
  echo "📊 Analyzing inventory files..."

  # Find all nx-app-inventory.yaml files in the artifact directories
  INVENTORY_FILES=$(find "repos/nx-artifacts-inventory" -path "*/nx-bff-web-offer-seat-*/nx-app-inventory.yaml" -o -path "*/nx-ch-web-*-*/nx-app-inventory.yaml" 2>/dev/null || echo "")
  
  if [[ -n "$INVENTORY_FILES" ]]; then
    echo "Found inventory files:"
    echo "$INVENTORY_FILES" | while read file; do
      echo "  📄 $(basename "$(dirname "$file")")"
      
      # Extract environment info
      if grep -q "environment:" "$file" 2>/dev/null; then
        ENV_NAME=$(grep "environment:" "$file" | head -1 | awk '{print $2}')
        echo "     Environment: $ENV_NAME"
      fi
      
      # Extract artifact name
      if grep -q "artifact_name:" "$file" 2>/dev/null; then
        ARTIFACT_NAME=$(grep "artifact_name:" "$file" | head -1 | awk '{print $2}')
        echo "     Artifact: $ARTIFACT_NAME"
      fi
      
      # Check enabled components
      ENABLED_COUNT=$(grep -c "enabled: true" "$file" 2>/dev/null || echo "0")
      DEPLOYED_COUNT=$(grep -c "deployed: true" "$file" 2>/dev/null || echo "0")
      
      echo "     Enabled components: $ENABLED_COUNT"
      echo "     Deployed components: $DEPLOYED_COUNT"
      echo ""
    done
  else
    echo "⚠️ No inventory files found for artifact: $ARTIFACT"
  fi
}

check_pending_actions() {
  echo "⏳ Checking pending actions..."

  PENDING=0
  INVENTORY_FILES=$(find "repos/nx-artifacts-inventory" -name "*$ARTIFACT*" -name "*.yaml" 2>/dev/null || echo "")

  if [[ -n "$INVENTORY_FILES" ]]; then
    while IFS= read -r file; do
      PENDING_COMPONENTS=$(grep -c "enabled: true" "$file" 2>/dev/null || echo "0")
      DEPLOYED_COMPONENTS=$(grep -c "deployed: true" "$file" 2>/dev/null || echo "0")

      if [[ $PENDING_COMPONENTS -gt $DEPLOYED_COMPONENTS ]]; then
        ((PENDING++))
        ENV_NAME=$(basename "$(dirname "$file")")
        PENDING_COUNT=$((PENDING_COMPONENTS - DEPLOYED_COMPONENTS))
        echo "  ⚠️ $ENV_NAME: $PENDING_COUNT pending deployment(s)"
      fi
    done <<< "$INVENTORY_FILES"
  fi

  echo "Total pending actions: $PENDING"
  return $PENDING
}

get_health_status() {
  echo "🏥 Checking artifact health..."

  # Calculate health based on environment count and pending actions
  HEALTH_SCORE=80
  
  if [[ $ENV_COUNT -eq 0 ]]; then
    HEALTH_SCORE=30
  elif [[ $PENDING -gt 0 ]]; then
    HEALTH_SCORE=70
  fi

  if [[ $HEALTH_SCORE -ge 90 ]]; then
    HEALTH_STATUS="✅ Healthy"
  elif [[ $HEALTH_SCORE -ge 70 ]]; then
    HEALTH_STATUS="⚠️ Degraded"
  else
    HEALTH_STATUS="❌ Unhealthy"
  fi

  echo "Health score: $HEALTH_SCORE%"
  echo "Status: $HEALTH_STATUS"
}

# ============================================================================
# Main Execution
# ============================================================================

echo "🔍 DevX Artifact Review Tool - Sandbox Test"
echo "============================================"

get_artifact_info
echo ""
check_environments
echo ""
analyze_inventory_files
echo ""
check_pending_actions
PENDING=$?
echo ""
get_health_status

echo ""
echo "============================================"
echo "🎉 Artifact review complete!"

if [[ $PENDING -gt 0 ]]; then
  echo ""
  echo "💡 Recommendations:"
  echo "  - Review and approve pending infrastructure"
  echo "  - Check if components need to be deployed"
  echo "  - Run: /debug-artifact artifact:$ARTIFACT depth:deep"
fi