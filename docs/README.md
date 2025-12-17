# Documentation Index - DevX Sandbox System

Welcome to the DevX Terraform Sandbox documentation. This directory contains comprehensive guides organized by category and audience.

## Quick Navigation

| I want to... | Read this |
|--------------|-----------|
| Get started quickly | [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) |
| See real-world examples | [USE_CASES_GUIDE.md](USE_CASES_GUIDE.md) or [PRACTICAL_USE_CASES.md](PRACTICAL_USE_CASES.md) |
| Understand the architecture | [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md) |
| Test with AWS services | [AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md) |
| Write tests | [TESTING_GUIDE.md](TESTING_GUIDE.md) |
| Develop CLI commands | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) |
| Fix a problem | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |

---

## Documentation Structure

### Getting Started

Perfect for new users and quick reference.

| Document | Description | Time to Read | Audience |
|----------|-------------|--------------|----------|
| **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** | Step-by-step guide to get up and running | 10 min | Everyone |
| **[LOCAL_TESTING_SYSTEM.md](LOCAL_TESTING_SYSTEM.md)** | Overview of the complete local testing system | 5 min | New users |
| **[SANDBOX_GUIDE.md](SANDBOX_GUIDE.md)** | Complete sandbox usage guide | 15 min | All users |
| **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** | 13 practical use cases with step-by-step instructions | 20 min | Developers |

### Architecture & Technical

Deep-dive into system design and implementation.

| Document | Description | Time to Read | Audience |
|----------|-------------|--------------|----------|
| **[TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md)** | Detailed technical architecture with diagrams | 20 min | Architects, DevOps |
| **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** | Complete implementation summary and achievements | 10 min | Technical leads |
| **[CLI_DEVX_DESIGN.md](CLI_DEVX_DESIGN.md)** | CLI design patterns and architecture | 15 min | CLI developers |

### Testing & Development

Guides for writing tests and developing new features.

| Document | Description | Time to Read | Audience |
|----------|-------------|--------------|----------|
| **[TESTING_GUIDE.md](TESTING_GUIDE.md)** | Complete testing guide (unit, integration, E2E) | 15 min | Developers |
| **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** | CLI command development guide | 20 min | CLI developers |
| **[AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md)** | LocalStack and AWS service testing | 25 min | DevOps, Testers |

### AWS & LocalStack Integration

Everything about testing with mock AWS services.

| Document | Description | Key Topics |
|----------|-------------|------------|
| **[AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md)** | Complete AWS testing with LocalStack | Setup, Services (IAM, ECR, S3, DynamoDB, Redis, RDS), E2E Tests, Troubleshooting |

**Quick AWS Commands**:
```bash
make setup-aws      # Start LocalStack
make status-aws     # Check health
make test-e2e       # Run E2E tests with AWS
make logs-aws       # View LocalStack logs
make clean-aws      # Clean up
```

### Support & Troubleshooting

Problem-solving and FAQ.

| Document | Description | Time to Read | Audience |
|----------|-------------|--------------|----------|
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | FAQ and common problem solutions | As needed | Support, All users |

---

## Recommended Learning Path

### For New Team Members

1. **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** - Get sandbox running (10 min)
2. **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** - See practical examples (20 min)
3. **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Learn testing workflow (15 min)
4. Start working with `make dev-test`

**Total onboarding time**: ~45 minutes to productivity

### For CLI Developers

1. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - CLI development patterns (20 min)
2. **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing your commands (15 min)
3. **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** - Real-world workflows (20 min)
4. **[AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md)** - AWS integration (25 min)

**Total time**: ~80 minutes to expert level

### For DevOps Engineers

1. **[TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md)** - System architecture (20 min)
2. **[AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md)** - LocalStack setup (25 min)
3. **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation details (10 min)
4. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues (as needed)

**Total time**: ~55 minutes to operational expertise

### For Architects

1. **[TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md)** - Complete architecture (20 min)
2. **[CLI_DEVX_DESIGN.md](CLI_DEVX_DESIGN.md)** - Design patterns (15 min)
3. **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation review (10 min)

**Total time**: ~45 minutes to architectural understanding

---

## Documentation by Use Case

### "I want to create a new CLI command"

1. Read: **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Command structure
2. Read: **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** - Case 1: Creating new command
3. Run: `make setup-local-cli CLI_PATH=/path/to/cli`
4. Follow: Development workflow in guides

### "I want to test with AWS services"

1. Read: **[AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md)** - Complete AWS guide
2. Run: `make setup-aws`
3. Run: `make test-e2e`
4. Reference: AWS service sections for specific testing

### "I need to fix a bug"

1. Read: **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** - Case 2: Bug fixing
2. Run: `make test-real-cli`
3. Check: **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** if tests fail
4. Run: `make validate` before commit

### "I'm onboarding a new developer"

1. Share: **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)**
2. Walk through: **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** - Case 11
3. Practice: `make setup` → `make test-unit` → `make dev-test`
4. Reference: **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for issues

### "I need to validate before PR"

1. Run: `make validate` (critical tests)
2. Reference: **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Pre-commit checklist
3. Check: **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** - Case 8: Before PR
4. Run: `make test-all` (complete validation)

---

## Documentation Statistics

| Category | Documents | Total Pages | Status |
|----------|-----------|-------------|--------|
| **Getting Started** | 4 | ~30 | Complete |
| **Architecture & Technical** | 3 | ~25 | Complete |
| **Testing & Development** | 3 | ~35 | Complete |
| **AWS Integration** | 1 | ~20 | Complete |
| **Support** | 1 | ~10 | Complete |
| **TOTAL** | **12** | **~120** | Production Ready |

---

## Quick Reference Cards

### Essential Commands

```bash
# Setup
make setup                              # Initial setup
make setup-local-cli CLI_PATH=/path    # Setup with local CLI
make setup-aws                          # Start LocalStack

# Testing
make test-unit                          # Go unit tests (5s)
make test-real-cli                      # CLI tests (30s)
make test-security                      # Security tests (10s)
make test-e2e                          # E2E with AWS (60s)
make test-all                          # Everything (3min)

# Development
make dev-test                          # Fast feedback (30s)
make validate                          # Pre-commit critical (2min)
make build-cli                         # Build CLI

# AWS/LocalStack
make status-aws                        # Check LocalStack
make logs-aws                          # View logs
make restart-aws                       # Fresh restart
make clean-aws                         # Remove all data

# Cleanup
make clean                             # Clean artifacts
make clean-all                         # Clean everything
```

### Testing Workflow

```bash
# 1. Daily development
make dev-test          # Quick feedback

# 2. Before commit
make validate          # Critical tests

# 3. Before PR
make test-all          # Complete suite

# 4. CI/CD
# Automatically runs test-all on push
```

### AWS Services Available

- **IAM**: Roles, policies, service accounts
- **ECR**: Container registries for all layers
- **S3**: Artifact storage, Terraform state
- **DynamoDB**: Application data tables
- **ElastiCache**: Redis clusters
- **RDS**: PostgreSQL and MySQL instances

See **[AWS_TESTING_GUIDE.md](AWS_TESTING_GUIDE.md)** for complete details.

---

## Additional Resources

### Scripts & Tools

Located in repository root:

- `artifact-selector.sh` - Interactive artifact browser
- `clone-artifact-from-github.sh` - Clone real repositories
- `test-review-artifact.sh` - Test review-artifact command

### External Documentation

- **Main README**: `../README.md` - Project overview
- **Testing Quick Reference**: `../README_TESTING.md` - Quick testing commands
- **Implementation Status**: `../IMPLEMENTATION_STATUS.md` - Current implementation state

### Related Files

Root directory summaries (Spanish):
- `RESUMEN_FINAL.md` - Final summary (translated to IMPLEMENTATION_SUMMARY.md)
- `GUIA_CASOS_USO.md` - Use cases guide (translated to USE_CASES_GUIDE.md)
- `RESULTADO_IMPLEMENTACION.md` - Implementation results

---

## Version Information

- **Version**: 2.0.0
- **Last Updated**: December 2025
- **Status**: Production Ready
- **Language**: English (primary), Spanish (legacy files)
- **Maintained By**: British Airways Nexus Team - DevX

---

## Contributing to Documentation

### Updating Documentation

1. Keep guides concise and practical
2. Include code examples
3. Add time estimates for reading
4. Update this index when adding new docs
5. Follow existing formatting patterns

### Documentation Standards

- Use markdown formatting
- Include table of contents for long docs
- Add code blocks with syntax highlighting
- Keep examples up to date with codebase
- Cross-reference related documents

### Need Help?

- Check **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** first
- Review **[USE_CASES_GUIDE.md](USE_CASES_GUIDE.md)** for examples
- Contact DevX team for clarifications
- Submit issues for documentation bugs

---

**Welcome to DevX Sandbox! Start with [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) and you'll be testing in minutes.**
