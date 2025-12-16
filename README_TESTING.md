# 🧪 Testing System - Quick Reference

## ⚡ Quick Start

```bash
# Setup sandbox con CLI real
make setup

# Ejecutar TODOS los tests
make test-all

# Solo críticos (unit + security)
make validate
```

## 📊 Test Suites Disponibles

| Comando | Descripción | Tiempo | Crítico |
|---------|-------------|--------|---------|
| `make test-unit` | Tests unitarios Go | ~5s | ✅ Sí |
| `make test-real-cli` | Tests con CLI GO real | ~30s | ✅ Sí |
| `make test-security` | Validación seguridad | ~10s | ✅ Sí |
| `make test-integration` | Tests E2E integración | ~45s | ⚠️ Recomendado |
| `make test-e2e` | Ciclo completo artifacts | ~60s | ⚠️ Recomendado |
| `make test-terraform` | Validación Terraform | ~30s | 📝 Opcional |

## 🎯 Workflows por Caso de Uso

### Desarrollo de Comando Nuevo

```bash
# 1. Conectar tu CLI local
export LOCAL_CLI_PATH=/path/to/nx-terraform-builder
make setup-local-cli

# 2. Desarrollo iterativo
# ... editar código en nx-terraform-builder ...

# 3. Test rápido
make dev-test

# 4. Test completo antes de commit
make validate
```

### Mejora de Comando Existente

```bash
# 1. Setup
make setup

# 2. Hacer cambios
# ... editar código ...

# 3. Test específico
./tests/test-with-real-cli.sh

# 4. Validar no rompiste nada
make test-all
```

### Pre-Commit

```bash
# Ejecutar SIEMPRE antes de commit
make validate

# Si pasa → commit seguro
git commit -m "feat: nuevo comando"
```

### CI/CD

```bash
# En GitHub Actions se ejecuta automáticamente:
# - Unit tests
# - Integration tests
# - Security tests
# Ver: .github/workflows/test-sandbox.yml
```

## 🔍 Interpretar Resultados

### ✅ Éxito Total
```
Total tests: 25
Passed: 25
Failed: 0

✓ All tests passed!
```
→ **Safe to merge** ✅

### ⚠️ Algunos Fallos
```
Total tests: 25
Passed: 20
Failed: 5

✗ Some tests failed
Check logs: /tmp/cli-real-test-12345/test-real-cli.log
```
→ **Revisar logs** → **Arreglar** → **Re-test**

### ❌ Setup Falla
```
✗ CLI not found. Run: ./tests/setup-real-cli.sh
```
→ **Ejecutar setup primero**

## 🐛 Troubleshooting Rápido

| Error | Solución |
|-------|----------|
| CLI not found | `make setup` o `./tests/setup-real-cli.sh` |
| Permission denied | `chmod +x tests/*.sh *.sh` |
| Go tests fail | `cd nx-sandbox && go mod tidy && go test ./...` |
| Port 4566 in use | `docker-compose -f config/docker-compose.yml down` |
| GitHub clone fails | Verificar acceso/token o usar artifacts simulados |

## 📈 Coverage Actual

```bash
# Ver coverage Go
cd nx-sandbox
go test -cover ./...

# Target: 80%+ coverage
```

## 🎓 Aprender Más

- **Guía completa**: `docs/TESTING_GUIDE.md`
- **Arquitectura técnica**: `docs/TECHNICAL_ARCHITECTURE.md`
- **Troubleshooting**: `docs/TROUBLESHOOTING.md`

## 🚀 Próximos Pasos

Después de implementar tests:

1. ✅ **Commit** con tests pasando
2. ✅ **Push** (CI/CD ejecutará tests)
3. ✅ **PR** (revisión + tests automáticos)
4. ✅ **Merge** cuando tests pasen

---

**Pro Tip**: Usa `make dev-test` durante desarrollo para feedback rápido (unit + real CLI en ~30s)
