# Nx Sandbox

Nx Sandbox is a CLI tool for managing local testing environments for Nexus artifacts. It provides functionality to list, clone, and manage artifacts for development and testing purposes.

## Features

- 🔍 **List Artifacts**: Scan and list available artifacts from inventory and environment repositories
- 📊 **Status Monitoring**: Check sandbox health, disk usage, and artifact counts
- 🧹 **Automated Cleanup**: Remove old test artifacts to optimize space
- 🔄 **GitHub Cloning**: Clone real artifact repositories for local testing
- 🎯 **Smart Filtering**: Filter artifacts by source, layer, or environment

## Installation

### From Source

```bash
git clone <repository-url>
cd nx-sandbox
go build -o nx-sandbox
```

### Direct Download

Download the latest binary from the releases page and add it to your PATH.

## Usage

### List Available Artifacts

```bash
# List all artifacts
nx-sandbox list

# List only inventory artifacts
nx-sandbox list --from-inventory

# List only environment artifacts
nx-sandbox list --from-environments

# Filter by layer
nx-sandbox list --layer bff

# Filter by environment
nx-sandbox list --environment dev1
```

### Check Sandbox Status

```bash
nx-sandbox status
```

Shows:
- Overall health status
- Directory locations
- Artifact counts
- Disk usage
- Last cleanup time
- Issues and recommendations

### Clean Sandbox

```bash
nx-sandbox clean
```

Automatically removes:
- Test artifacts older than 7 days
- Local artifacts older than 30 days

### Clone Artifact from GitHub

```bash
# Basic clone
nx-sandbox clone BritishAirways-Nexus nx-tc-order-creator

# Clone and prepare for testing
nx-sandbox clone BritishAirways-Nexus nx-ch-web-checkout --prepare-testing
```

## Architecture

### Project Structure

```
nx-sandbox/
├── main.go                    # Application entry point
├── cmd/                       # CLI commands
│   ├── root.go               # Root command
│   ├── list.go               # List command
│   ├── status.go             # Status command
│   ├── clean.go              # Clean command
│   └── clone.go              # Clone command
├── internal/
│   ├── sandbox/              # Core business logic
│   │   ├── interfaces.go     # Interface definitions
│   │   └── manager.go        # Main implementation
│   └── models/               # Data structures
│       ├── artifact.go       # Artifact models
│       └── environment.go    # Environment models
├── go.mod
├── go.sum
└── README.md
```

### Key Interfaces

- `SandboxManager`: Main interface for sandbox operations
- `ArtifactLister`: Interface for listing and filtering artifacts
- `SandboxCleaner`: Interface for cleanup operations

### Data Models

- `SandboxArtifact`: Represents an artifact with metadata
- `SandboxEnvironment`: Represents sandbox environment state
- `ArtifactFilter`: Filtering options for artifact queries

## Development

### Prerequisites

- Go 1.19 or later
- Access to Nexus repositories

### Building

```bash
go build -o nx-sandbox
```

### Testing

```bash
go test ./...
```

### Adding New Commands

1. Create a new file in `cmd/` (e.g., `newcmd.go`)
2. Implement the command logic
3. Add the init function to `cmd/root.go`
4. Update this README

## Examples

### Development Workflow

```bash
# Check current status
nx-sandbox status

# List available artifacts
nx-sandbox list --layer bff

# Clone an artifact for testing
nx-sandbox clone BritishAirways-Nexus nx-bff-web-offer-seat

# Work on the artifact...
cd local-artifacts/nx-bff-web-offer-seat

# Clean up when done
nx-sandbox clean
```

### CI/CD Integration

```bash
# List artifacts for automation
nx-sandbox list --from-inventory --layer tc --json

# Check if cleanup is needed
nx-sandbox status
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the DevX team
- Check the troubleshooting guide

---

**Built with ❤️ by the DevX Team**