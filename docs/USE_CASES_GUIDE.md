# Use Cases Guide - Step by Step

## Case 1: "I want to create a NEW command"

### Situation
You need to add `/create-s3` to the CLI but don't know if it will work.

### Steps
```bash
# 1. Go to your CLI
cd /path/to/nx-terraform-builder

# 2. Write the new command
vim cmd/s3.go
# ... command code ...

# 3. Connect sandbox with your CLI
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make setup-local-cli CLI_PATH=/path/to/nx-terraform-builder

# 4. Quick test
make dev-test

# 5. If it fails → fix → repeat step 4
# If it passes → continue

# 6. Complete test before commit
make validate

# 7. Commit with confidence
cd /path/to/nx-terraform-builder
git add .
git commit -m "feat: add s3 command"
git push
```

**Total time**: 5-10 minutes
**Confidence**: 100% tested

---

## Case 2: "I fixed a bug in an existing command"

### Situation
The `/add-redis` command has a bug. You fixed it and want to validate.

### Steps
```bash
# 1. Already made the fix in your CLI
cd /path/to/nx-terraform-builder
# ... fix applied ...

# 2. Test against real CLI
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make test-real-cli

# 3. See what happened
# If PASS → continue
# If FAIL → see logs and fix

# 4. Pre-commit validation
make validate

# 5. Commit
git commit -m "fix: redis command bug"
```

**Time**: 3-5 minutes
**Confidence**: Bug won't return

---

## Case 3: "First time using the sandbox"

### Situation
New to the team, never used this.

### Steps
```bash
# 1. Go to sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 2. Read quick help
cat README_TESTING.md

# 3. Initial setup
make setup

# 4. Explore what's available
./artifact-selector.sh

# 5. Try example command
./test-review-artifact.sh --artifact web-offer-seat

# 6. See available tests
make help

# 7. Run tests
make test-unit
```

**Time**: 10 minutes
**Result**: You understand the system

---

## Case 4: "Fast iterative development"

### Situation
You're developing and need immediate feedback.

### Steps
```bash
# Terminal 1: Sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# Terminal 2: Your CLI
cd /path/to/nx-terraform-builder

# Development loop:
# 1. Edit code in Terminal 2
vim cmd/mycommand.go

# 2. Test in Terminal 1
make dev-test  # Only 30 seconds

# 3. Repeat until it passes

# 4. Final validation
make validate
```

**Time per iteration**: 30 seconds
**Speed**: Maximum

---

## Case 5: "Validate code security"

### Situation
You want to ensure your command has no vulnerabilities.

### Steps
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# Security test
make test-security

# See what was validated:
# ✓ Path traversal
# ✓ Command injection
# ✓ Input validation
# ✓ Secrets in logs
# ✓ File permissions
```

**Time**: 10 seconds
**Result**: Secure code

---

## Case 6: "Test with real GitHub data"

### Situation
Simulated data isn't enough, you need real artifact.

### Steps
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 1. Clone real artifact
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 2. Verify clone
ls local-artifacts/nx-tc-order-creator/

# 3. Test with real artifact
./test-review-artifact.sh --artifact order-creator

# 4. See structure
cd local-artifacts/nx-tc-order-creator
tree
```

**Time**: 2-3 minutes
**Benefit**: 100% real data

---

## Case 7: "The test failed, now what?"

### Situation
You ran `make test-all` and something failed.

### Steps
```bash
# 1. See summary
# Output will show what failed

# 2. See detailed logs
cat /tmp/cli-real-test-*/test-real-cli.log

# 3. Identify problem
grep "FAIL" /tmp/cli-real-test-*/test-real-cli.log

# 4. Specific test for debug
./tests/test-with-real-cli.sh

# 5. Fix code

# 6. Re-test only what failed
make test-real-cli

# 7. When it passes → complete test
make validate
```

**Result**: Bug identified and fixed

---

## Case 8: "Before creating a PR"

### Situation
Code ready, you want to create PR with confidence.

### Steps
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 1. Complete validation
make validate

# 2. If it passes → commit
cd /path/to/nx-terraform-builder
git add .
git commit -m "feat: my change"

# 3. Push
git push origin feature/my-branch

# 4. CI/CD automatically:
#    - Runs tests
#    - Validates security
#    - Reports result

# 5. If CI passes → merge approved
```

**Time**: 2 minutes
**Result**: PR without surprises

---

## Case 9: "Clean everything and start fresh"

### Situation
Something broke, you need a reset.

### Steps
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# Complete cleanup
make clean-all

# Re-setup from scratch
make setup

# Validate
make test-unit
```

**Time**: 2-3 minutes
**Result**: Clean state

---

## Case 10: "See test coverage"

### Situation
You want to know what % of code is covered by tests.

### Steps
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox/nx-sandbox

# Detailed coverage
go test -cover ./...

# Coverage with HTML
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# See what's missing coverage
```

**Result**: Know where to add tests

---

## Case 11: "Train new team member"

### Situation
Onboarding new developer.

### Quick guide
```bash
# 1. Clone sandbox
git clone <repo> DevX-Terraform-Sandbox
cd DevX-Terraform-Sandbox

# 2. Read this
cat docs/USE_CASES_GUIDE.md

# 3. Setup
make setup

# 4. First test
make test-unit

# 5. Explore
./artifact-selector.sh

# 6. Practice
make dev-test
```

**Onboarding time**: 15 minutes
**Result**: Productive developer

---

## Case 12: "Debug a specific test"

### Situation
Specific unit test fails.

### Steps
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox/nx-sandbox

# Specific test with verbose
go test -v -run TestListArtifacts ./internal/sandbox/

# With more detail
go test -v -run TestListArtifacts ./internal/sandbox/ -args -test.v

# Debug with prints
# Add fmt.Printf in the code
go test -v -run TestListArtifacts ./internal/sandbox/
```

**Result**: Bug found

---

## Case 13: "CI/CD failed on GitHub"

### Situation
Your PR has red tests on GitHub Actions.

### Steps
```bash
# 1. See logs on GitHub
# Actions → Your workflow → See logs

# 2. Reproduce locally
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make test-all

# 3. If local passes but CI fails:
#    - Verify dependencies
#    - Verify environment variables
#    - Verify paths

# 4. If local also fails:
#    - Fix
#    - make validate
#    - git push

# 5. CI runs automatically again
```

**Result**: Green CI

---

## Most Used Commands Summary

```bash
# Initial setup (once)
make setup-local-cli CLI_PATH=/path/to/cli

# Daily development
make dev-test              # Fast (30s)

# Before commit
make validate              # Critical (2min)

# Complete test
make test-all              # Everything (3min)

# Specific tests
make test-unit             # Go tests (5s)
make test-real-cli         # Real CLI (30s)
make test-security         # Security (10s)

# Cleanup
make clean                 # Artifacts
make clean-all             # Everything

# Help
make help                  # See all commands
```

---

## Golden Rules

1. **ALWAYS** `make validate` before commit
2. **NEVER** commit if tests fail
3. **USE** `make dev-test` during development
4. **TRUST** the tests, if they pass → code works
5. **CLEAN** with `make clean` regularly

---

## Need Help?

```bash
# See Make help
make help

# See complete testing guide
cat docs/TESTING_GUIDE.md

# See quick reference
cat README_TESTING.md

# See technical implementation
cat docs/IMPLEMENTATION_STATUS.md
```

---

**With these use cases you can do ANYTHING in the sandbox!**
