# 🧪 Testing Guide - DevX Sandbox

## Overview

El sandbox ahora soporta testing completo de comandos **ANTES** de merge a producción.

## 🎯 Testing de Comandos Nuevos

### Workflow: Desarrollo → Test → Merge

```bash
# 1. Desarrollar comando nuevo en nx-terraform-builder
cd /path/to/nx-terraform-builder
# ... escribir código ...

# 2. Configurar sandbox con tu CLI local
cd /path/to/DevX-Terraform-Sandbox
make setup-local-cli CLI_PATH=/path/to/nx-terraform-builder

# 3. Ejecutar tests
make test-real-cli

# 4. Si pasa → hacer commit
git commit -m "feat: nuevo comando"

# 5. CI/CD ejecutará tests automáticamente
```

## 📋 Tipos de Tests

### 1. Tests Unitarios (Go)

**Ubicación**: `nx-sandbox/internal/sandbox/manager_test.go`

```bash
# Ejecutar tests unitarios
make test-unit

# Con coverage
cd nx-sandbox
go test -cover ./...

# Benchmarks
make benchmark
```

**Qué cubren:**
- ✅ `SandboxManager.ListArtifacts()`
- ✅ `SandboxManager.GetStatus()`
- ✅ `SandboxManager.GetArtifactInfo()`
- ✅ `SandboxManager.Clean()`
- ✅ Filtros por layer, environment, source

### 2. Tests de CLI Real

**Ubicación**: `tests/test-with-real-cli.sh`

```bash
# Ejecutar con CLI real
make test-real-cli
```

**Qué valida:**
- ✅ Comandos de ayuda (`--help`, `version`)
- ✅ Creación de artifacts
- ✅ Comandos de infraestructura (Redis, ECR, DynamoDB)
- ✅ Manejo de errores
- ✅ Output esperado

### 3. Tests de Seguridad

**Ubicación**: `tests/security_test.sh`

```bash
# Ejecutar security tests
make test-security
```

**Qué valida:**
- ✅ Path traversal prevention
- ✅ Command injection prevention
- ✅ Input validation
- ✅ Secret exposure
- ✅ File permissions

### 4. Tests de Integración

**Ubicación**: `tests/test-integration.sh`

```bash
# Ejecutar E2E tests
make test-integration
```

**Qué valida:**
- ✅ Ciclo completo de artifact
- ✅ Integración con Terraform
- ✅ Integración con AWS (LocalStack)
- ✅ Error recovery

## 🔄 CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test-sandbox.yml
name: Sandbox Tests

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Sandbox
        run: |
          git clone https://github.com/BritishAirways-Nexus/DevX-Terraform-Sandbox.git
          cd DevX-Terraform-Sandbox
          make setup-local-cli CLI_PATH=${{ github.workspace }}

      - name: Run Tests
        run: |
          cd DevX-Terraform-Sandbox
          make test-all

      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: DevX-Terraform-Sandbox/test-artifacts/
```

## 📊 Test Results

### Interpretar Resultados

```bash
# Ejemplo de output exitoso:
╔════════════════════════════════════════╗
║         TEST RESULTS SUMMARY          ║
╚════════════════════════════════════════╝

Total tests: 15
Passed: 15
Failed: 0

✓ All tests passed!
CLI is working correctly
```

### Logs de Tests

```bash
# Revisar logs detallados
cat /tmp/cli-real-test-*/test-real-cli.log

# Buscar fallos específicos
grep "FAIL" /tmp/cli-real-test-*/test-real-cli.log
```

## 🐛 Debugging Tests Fallidos

### Test Unitario Falla

```bash
# Ejecutar con verbose
cd nx-sandbox
go test -v ./internal/sandbox/

# Test específico
go test -v -run TestListArtifacts ./internal/sandbox/
```

### Test CLI Real Falla

```bash
# Ejecutar con debug
CLI_DEBUG=1 ./tests/test-with-real-cli.sh

# Verificar CLI existe
ls -la tf_nx

# Rebuild CLI
./tests/setup-real-cli.sh
```

### Test Seguridad Falla

```bash
# Ejecutar con trace
bash -x ./tests/security_test.sh

# Verificar permisos
find . -name "*.sh" -ls
```

## 📈 Coverage Goals

| Tipo | Coverage Actual | Target |
|------|----------------|--------|
| Unit Tests (Go) | **NEW** | 80%+ |
| CLI Commands | **NEW** | 100% |
| Security | **NEW** | 100% |
| Integration | 60% | 80%+ |

## 🔧 Agregar Nuevos Tests

### Test Unitario Nuevo

```go
// nx-sandbox/internal/sandbox/manager_test.go
func TestNewFeature(t *testing.T) {
    baseDir := setupTestEnv(t)
    manager := NewSandboxManager(baseDir)

    result, err := manager.NewFeature()

    if err != nil {
        t.Fatalf("NewFeature failed: %v", err)
    }

    if result != expected {
        t.Errorf("Expected %v, got %v", expected, result)
    }
}
```

### Test CLI Nuevo

```bash
# tests/test-with-real-cli.sh
test_new_command() {
    echo -e "\n${YELLOW}🆕 Testing New Command${NC}"

    run_test "New Command Test" \
        "$CLI_BIN new-command --flag=value" \
        "expected output"
}

# Agregar a main()
main() {
    ...
    test_new_command
}
```

## ✅ Pre-Commit Checklist

Antes de hacer commit:

```bash
# 1. Ejecutar validación completa
make validate

# 2. Verificar coverage
cd nx-sandbox && go test -cover ./...

# 3. Lint código
make lint

# 4. Build exitoso
make build-cli

# 5. Tests pasan
make test-all
```

## 🎯 Best Practices

1. **Siempre usa CLI real** - No confíes en mocks para validación final
2. **Test en artifacts reales** - Clona repos reales cuando sea posible
3. **Valida outputs** - No solo exit codes, también contenido
4. **Cleanup automático** - Tests deben limpiar después
5. **Logs detallados** - Guarda logs para debugging
6. **Fast feedback** - Tests unitarios < 5s, integración < 30s

## 📞 Troubleshooting

### "CLI not found"
```bash
./tests/setup-real-cli.sh
```

### "Go tests fail"
```bash
cd nx-sandbox
go mod tidy
go test ./...
```

### "Permission denied"
```bash
chmod +x tests/*.sh *.sh
```

### "LocalStack not running"
```bash
docker-compose -f config/docker-compose.yml up -d localstack
```

---

**Actualizado**: 2025-01-13
**Versión**: 2.0 (con CLI real integration)
