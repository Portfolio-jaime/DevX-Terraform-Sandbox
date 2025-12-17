# DevX Sandbox - Complete Local Testing System

## Overview

You've created a complete development environment to test DevX commands without affecting real repositories.

## Available Tools

### 1. Local Artifact Selector
```bash
./artifact-selector.sh
```
- Interactive menu to select artifacts from sandbox
- Lists available artifacts in inventory and environments
- Allows running tests and preparing artifacts for testing

### 2. `/review-artifact` Command Test
```bash
./test-review-artifact.sh --artifact <artifact-name>
```
- Simulates the internal DevX command
- Analyzes artifacts with real sandbox data
- Generates health status reports

### 3. Real Repository Cloner
```bash
./clone-artifact-from-github.sh <org> <artifact>
```
- Clones real repositories from GitHub for local testing
- Prepares artifacts with inventory files
- Allows modifications and testing without affecting real repositories

## Recommended Workflows

### Option A: Testing with Existing Artifacts
```bash
# 1. Select artifact from sandbox
./artifact-selector.sh

# 2. Run review-artifact
./test-review-artifact.sh --artifact web-offer-seat

# 3. Modify and test code
# 4. Iterate until it works
```

### Option B: Testing with Real Repositories
```bash
# 1. Clone real repository
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 2. Enter cloned directory
cd local-artifacts/nx-tc-order-creator

# 3. Test CLI modifications
# 4. Use review-artifact with the cloned artifact

# 5. Re-clone when you need a clean state
git clean -fdx  # Clean changes
```

## Available DevX Commands for Testing

### `/review-artifact`
- **Status**: Functional
- **Usage**: Quick analysis for support
- **Flags**: `--artifact`, `--environment`, `--depth`
- **Test**: `./test-review-artifact.sh --artifact web-offer-seat`

### `/debug-artifact`
- **Status**: Available for implementation
- **Description**: Complete diagnostics (30+ checks)
- **Flags**: `--artifact`, `--environment`, `--mode`, `--depth`

## Sandbox Structure

```
DevX-Terraform-Sandbox/
├── repos/                          # Simulated repositories
│   ├── nx-artifacts-inventory/     # Artifacts inventory
│   └── nx-bolt-environment-*/      # Simulated environments
├── local-artifacts/                # Repositories cloned from GitHub
├── test-artifacts/                 # Prepared for testing
└── *.sh                           # Testing tools
```

## System Benefits

1. **Safe Development**: Modify and test without affecting real repositories
2. **Rapid Iteration**: Immediate local testing
3. **Real Data**: Use real structure and files
4. **DevX Commands**: Test internal tools
5. **Multiple Scenarios**: Test different artifacts and environments

## Next Steps

1. **Test the system**: Run `./artifact-selector.sh`
2. **Clone a real repo**: `./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator`
3. **Implement `/debug-artifact`**: Based on the original script
4. **Add more commands**: Integrate other DevX commands into the CLI

## Current Status

- **Sandbox Setup**: Complete
- **Artifact Selector**: Functional
- **Review-Artifact Test**: Functional
- **GitHub Cloner**: Functional
- **Development Environment**: Ready to use

You can now develop and test DevX commands locally without risks!
