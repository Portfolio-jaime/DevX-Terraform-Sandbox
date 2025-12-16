#!/bin/bash
# Setup Real CLI - Builds nx-terraform-builder for testing
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SANDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_REAL_DIR="$SANDBOX_ROOT/cli-real"
CLI_BIN="$SANDBOX_ROOT/tf_nx"

# Configuración del repo CLI
CLI_REPO="${CLI_REPO:-https://github.com/BritishAirways-Nexus/nx-terraform-builder.git}"
CLI_BRANCH="${CLI_BRANCH:-main}"

echo -e "${BLUE}🔧 Setup Real CLI for Testing${NC}"

# Opción 1: Usar CLI local si existe
if [ -n "$LOCAL_CLI_PATH" ] && [ -d "$LOCAL_CLI_PATH" ]; then
    echo -e "${GREEN}✓${NC} Using local CLI: $LOCAL_CLI_PATH"
    cd "$LOCAL_CLI_PATH"
    go build -o "$CLI_BIN" .
    echo -e "${GREEN}✓${NC} CLI built: $CLI_BIN"
    exit 0
fi

# Opción 2: Clonar y compilar
if [ ! -d "$CLI_REAL_DIR" ]; then
    echo "📦 Cloning CLI repository..."
    git clone -b "$CLI_BRANCH" "$CLI_REPO" "$CLI_REAL_DIR"
else
    echo "🔄 Updating CLI repository..."
    cd "$CLI_REAL_DIR"
    git pull origin "$CLI_BRANCH"
fi

cd "$CLI_REAL_DIR"

# Verificar dependencias Go
if ! command -v go &> /dev/null; then
    echo -e "${RED}✗${NC} Go not found. Install Go 1.19+"
    exit 1
fi

# Build CLI
echo "🔨 Building CLI..."
go mod download
go build -o "$CLI_BIN" .

if [ -f "$CLI_BIN" ]; then
    echo -e "${GREEN}✓${NC} CLI ready: $CLI_BIN"
    "$CLI_BIN" --version || echo -e "${BLUE}Version: latest${NC}"
else
    echo -e "${RED}✗${NC} Build failed"
    exit 1
fi
