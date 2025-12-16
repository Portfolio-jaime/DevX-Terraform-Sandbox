# 🎯 Guía de Casos de Uso - Para Dummies

## 🚀 Caso 1: "Quiero crear un comando NUEVO"

### Situación
Necesitas agregar `/create-s3` a la CLI pero no sabes si funcionará.

### Pasos
```bash
# 1. Ir a tu CLI
cd /path/to/nx-terraform-builder

# 2. Escribir el nuevo comando
vim cmd/s3.go
# ... código del comando ...

# 3. Conectar sandbox con tu CLI
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make setup-local-cli CLI_PATH=/path/to/nx-terraform-builder

# 4. Test rápido
make dev-test

# 5. Si falla → arreglar → repetir paso 4
# Si pasa → continuar

# 6. Test completo antes de commit
make validate

# 7. Commit con confianza
cd /path/to/nx-terraform-builder
git add .
git commit -m "feat: add s3 command"
git push
```

**Tiempo total**: 5-10 minutos
**Confianza**: ✅ 100% probado

---

## 🔧 Caso 2: "Arreglé un bug en comando existente"

### Situación
El comando `/add-redis` tiene un bug. Lo arreglaste y quieres validar.

### Pasos
```bash
# 1. Ya hiciste el fix en tu CLI
cd /path/to/nx-terraform-builder
# ... fix aplicado ...

# 2. Test contra CLI real
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make test-real-cli

# 3. Ver qué pasó
# Si PASS → continuar
# Si FAIL → ver logs y arreglar

# 4. Pre-commit validation
make validate

# 5. Commit
git commit -m "fix: redis command bug"
```

**Tiempo**: 3-5 minutos
**Confianza**: ✅ Bug no volverá

---

## 🧪 Caso 3: "Primera vez usando el sandbox"

### Situación
Nuevo en el equipo, nunca usaste esto.

### Pasos
```bash
# 1. Ir al sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 2. Leer ayuda rápida
cat README_TESTING.md

# 3. Setup inicial
make setup

# 4. Explorar qué hay
./artifact-selector.sh

# 5. Probar comando de ejemplo
./test-review-artifact.sh --artifact web-offer-seat

# 6. Ver qué tests hay
make help

# 7. Ejecutar tests
make test-unit
```

**Tiempo**: 10 minutos
**Resultado**: ✅ Entiendes el sistema

---

## ⚡ Caso 4: "Desarrollo iterativo rápido"

### Situación
Estás desarrollando y necesitas feedback inmediato.

### Pasos
```bash
# Terminal 1: Sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# Terminal 2: Tu CLI
cd /path/to/nx-terraform-builder

# Loop de desarrollo:
# 1. Editar código en Terminal 2
vim cmd/mycommand.go

# 2. Test en Terminal 1
make dev-test  # Solo 30 segundos

# 3. Repetir hasta que pase

# 4. Final validation
make validate
```

**Tiempo por iteración**: 30 segundos
**Velocidad**: ⚡ Máxima

---

## 🔒 Caso 5: "Validar seguridad del código"

### Situación
Quieres asegurarte que tu comando no tiene vulnerabilidades.

### Pasos
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# Test de seguridad
make test-security

# Ver qué se validó:
# ✓ Path traversal
# ✓ Command injection
# ✓ Input validation
# ✓ Secrets en logs
# ✓ Permisos de archivos
```

**Tiempo**: 10 segundos
**Resultado**: ✅ Código seguro

---

## 📦 Caso 6: "Probar con datos reales de GitHub"

### Situación
Los datos simulados no son suficientes, necesitas artifact real.

### Pasos
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 1. Clonar artifact real
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 2. Verificar clonación
ls local-artifacts/nx-tc-order-creator/

# 3. Test con artifact real
./test-review-artifact.sh --artifact order-creator

# 4. Ver estructura
cd local-artifacts/nx-tc-order-creator
tree
```

**Tiempo**: 2-3 minutos
**Beneficio**: 📊 Datos 100% reales

---

## 🚨 Caso 7: "El test falló, ¿ahora qué?"

### Situación
Ejecutaste `make test-all` y algo falló.

### Pasos
```bash
# 1. Ver resumen
# Output mostrará qué falló

# 2. Ver logs detallados
cat /tmp/cli-real-test-*/test-real-cli.log

# 3. Identificar problema
grep "FAIL" /tmp/cli-real-test-*/test-real-cli.log

# 4. Test específico para debug
./tests/test-with-real-cli.sh

# 5. Arreglar código

# 6. Re-test solo lo que falló
make test-real-cli

# 7. Cuando pase → test completo
make validate
```

**Resultado**: ✅ Bug identificado y arreglado

---

## 🔄 Caso 8: "Antes de hacer PR"

### Situación
Código listo, quieres hacer PR con confianza.

### Pasos
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 1. Validation completa
make validate

# 2. Si pasa → commit
cd /path/to/nx-terraform-builder
git add .
git commit -m "feat: mi cambio"

# 3. Push
git push origin feature/mi-branch

# 4. CI/CD automáticamente:
#    - Ejecuta tests
#    - Valida seguridad
#    - Reporta resultado

# 5. Si CI pasa → merge aprobado
```

**Tiempo**: 2 minutos
**Resultado**: ✅ PR sin sorpresas

---

## 🧹 Caso 9: "Limpiar todo y empezar de nuevo"

### Situación
Algo se rompió, necesitas reset.

### Pasos
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# Limpieza completa
make clean-all

# Re-setup desde cero
make setup

# Validar
make test-unit
```

**Tiempo**: 2-3 minutos
**Resultado**: ✅ Estado limpio

---

## 📊 Caso 10: "Ver coverage de tests"

### Situación
Quieres saber qué % de código está cubierto por tests.

### Pasos
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox/nx-sandbox

# Coverage detallado
go test -cover ./...

# Coverage con HTML
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Ver qué falta cubrir
```

**Resultado**: 📈 Saber dónde agregar tests

---

## 🎓 Caso 11: "Enseñar a nuevo miembro"

### Situación
Onboarding de nuevo developer.

### Guía rápida
```bash
# 1. Clonar sandbox
git clone <repo> DevX-Terraform-Sandbox
cd DevX-Terraform-Sandbox

# 2. Leer esto
cat GUIA_CASOS_USO.md

# 3. Setup
make setup

# 4. Primer test
make test-unit

# 5. Explorar
./artifact-selector.sh

# 6. Práctica
make dev-test
```

**Tiempo onboarding**: 15 minutos
**Resultado**: ✅ Developer productivo

---

## 🐛 Caso 12: "Debug de un test específico"

### Situación
Test unitario específico falla.

### Pasos
```bash
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox/nx-sandbox

# Test específico con verbose
go test -v -run TestListArtifacts ./internal/sandbox/

# Con más detalle
go test -v -run TestListArtifacts ./internal/sandbox/ -args -test.v

# Debug con prints
# Agregar fmt.Printf en el código
go test -v -run TestListArtifacts ./internal/sandbox/
```

**Resultado**: 🔍 Bug encontrado

---

## ⚙️ Caso 13: "CI/CD falló en GitHub"

### Situación
Tu PR tiene tests rojos en GitHub Actions.

### Pasos
```bash
# 1. Ver logs en GitHub
# Actions → Tu workflow → Ver logs

# 2. Reproducir localmente
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
make test-all

# 3. Si local pasa pero CI falla:
#    - Verificar dependencias
#    - Verificar environment variables
#    - Verificar paths

# 4. Si local también falla:
#    - Arreglar
#    - make validate
#    - git push

# 5. CI se ejecuta automáticamente de nuevo
```

**Resultado**: ✅ CI verde

---

## 📝 Resumen de Comandos Más Usados

```bash
# Setup inicial (una vez)
make setup-local-cli CLI_PATH=/path/to/cli

# Desarrollo diario
make dev-test              # Rápido (30s)

# Antes de commit
make validate              # Crítico (2min)

# Test completo
make test-all              # Todo (3min)

# Tests específicos
make test-unit             # Go tests (5s)
make test-real-cli         # CLI real (30s)
make test-security         # Seguridad (10s)

# Limpieza
make clean                 # Artifacts
make clean-all             # Todo

# Ayuda
make help                  # Ver todos los comandos
```

---

## 🎯 Reglas de Oro

1. **SIEMPRE** `make validate` antes de commit
2. **NUNCA** hacer commit si tests fallan
3. **USAR** `make dev-test` durante desarrollo
4. **CONFIAR** en los tests, si pasan → código funciona
5. **LIMPIAR** con `make clean` regularmente

---

## 📞 ¿Necesitas Ayuda?

```bash
# Ver ayuda de Make
make help

# Ver guía de testing completa
cat docs/TESTING_GUIDE.md

# Ver quick reference
cat README_TESTING.md

# Ver implementación técnica
cat IMPLEMENTATION_STATUS.md
```

---

**¡Con estos casos de uso puedes hacer CUALQUIER cosa en el sandbox!** 🚀
