# 💼 Casos de Uso Prácticos - DevX Sandbox System

## 📋 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Caso de Uso 1: Desarrollo de Nuevo Comando DevX](#caso-de-uso-1-desarrollo-de-nuevo-comando-devx)
3. [Caso de Uso 2: Mejora de Comando Existente](#caso-de-uso-2-mejora-de-comando-existente)
4. [Caso de Uso 3: Testing de Múltiples Artifacts](#caso-de-uso-3-testing-de-múltiple-artifacts)
5. [Caso de Uso 4: Simulación de Error y Recovery](#caso-de-uso-4-simulación-de-error-y-recovery)
6. [Caso de Uso 5: Validación antes de Production](#caso-de-uso-5-validación-antes-de-production)
7. [Caso de Uso 6: Debugging Avanzado](#caso-de-uso-6-debugging-avanzado)

---

## 🎯 Introducción

Este documento presenta casos de uso reales y detallados para el DevX Sandbox System. Cada caso incluye:
- **Situación**: Contexto y objetivos
- **Pasos detallados**: Instrucciones paso a paso
- **Código de ejemplo**: Scripts y comandos exactos
- **Resultados esperados**: Qué deberías ver
- **Solución de problemas**: Qué hacer si algo sale mal

---

## 🚀 Caso de Uso 1: Desarrollo de Nuevo Comando DevX

### 📋 Situación
**Objetivo**: Desarrollar el comando `/debug-artifact` que no existe en el CLI actual pero está documentado como "Development".

### 🎯 Precondiciones
- Git instalado y configurado
- Acceso a repositorios de GitHub
- DevX Sandbox configurado

### 📝 Pasos Detallados

#### Paso 1: Preparar Ambiente de Desarrollo
```bash
# 1. Ir al sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 2. Limpiar estado previo
rm -rf local-artifacts/ test-artifacts/

# 3. Clonar repositorio de referencia para obtener datos reales
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 4. Verificar que el artifact está preparado
ls -la test-artifacts/nx-tc-order-creator/
# Debe mostrar: nx-app-inventory.yaml, Chart.yaml, values.yaml
```

#### Paso 2: Analizar Comando de Referencia
```bash
# 1. Ejecutar el comando /review-artifact existente para entender el patrón
./test-review-artifact.sh --artifact order-creator

# 2. Analizar la estructura del script existente
grep -n "get_artifact_info\|check_environments\|analyze_inventory_files" test-review-artifact.sh

# 3. Revisar el script original de debug-artifact desde el repositorio original
# (En producción, esto vendría del repo nx-dev-self-service-dispatch-procesor)
```

#### Paso 3: Crear Nuevo Comando
```bash
# 1. Copiar el script existente como base
cp test-review-artifact.sh debug-artifact.sh

# 2. Modificar el script para debug-artifact
sed -i 's/review-artifact/debug-artifact/g' debug-artifact.sh
sed -i 's/review/debug/g' debug-artifact.sh
sed -i 's/Review/Debug/g' debug-artifact.sh

# 3. Agregar funcionalidad específica de debug
cat >> debug-artifact.sh << 'EOF'

# Agregar checks específicos de debug
run_debug_checks() {
  echo "🔍 Running debug checks..."
  
  # Check 1: Repository access
  check_repository_access() {
    echo "  📊 Checking repository access..."
    ARTIFACT_PATH="test-artifacts/$ARTIFACT"
    if [[ -d "$ARTIFACT_PATH" ]]; then
      echo "    ✅ Local repository accessible"
      FILES_COUNT=$(find "$ARTIFACT_PATH" -type f | wc -l)
      echo "    📁 Files in repository: $FILES_COUNT"
    else
      echo "    ❌ Local repository not accessible"
    fi
  }
  
  # Check 2: Inventory validation
  check_inventory_validation() {
    echo "  📝 Validating inventory files..."
    INVENTORY_FILE="test-artifacts/$ARTIFACT/nx-app-inventory.yaml"
    if [[ -f "$INVENTORY_FILE" ]]; then
      if grep -q "schema_version:" "$INVENTORY_FILE"; then
        echo "    ✅ Inventory schema valid"
      else
        echo "    ❌ Inventory schema invalid"
      fi
    else
      echo "    ❌ Inventory file not found"
    fi
  }
  
  # Check 3: Component analysis
  check_components() {
    echo "  🔧 Analyzing components..."
    if [[ -f "test-artifacts/$ARTIFACT/nx-app-inventory.yaml" ]]; then
      ENABLED_COUNT=$(grep -c "enabled: true" "test-artifacts/$ARTIFACT/nx-app-inventory.yaml")
      echo "    🔢 Enabled components: $ENABLED_COUNT"
      
      if [[ $ENABLED_COUNT -gt 0 ]]; then
        echo "    ✅ Components are properly configured"
      else
        echo "    ⚠️ No components enabled"
      fi
    fi
  }
  
  check_repository_access
  check_inventory_validation
  check_components
}

EOF

# 4. Agregar llamada a la función en el flujo principal
sed -i '/get_health_status/a run_debug_checks' debug-artifact.sh

# 5. Hacer ejecutable
chmod +x debug-artifact.sh
```

#### Paso 4: Probar el Nuevo Comando
```bash
# 1. Ejecutar el nuevo comando
./debug-artifact.sh --artifact order-creator

# 2. Verificar que funciona correctamente
./debug-artifact.sh --artifact order-creator | grep -E "Debug|✅|❌|⚠️"

# 3. Probar con diferentes parámetros
./debug-artifact.sh --artifact order-creator --environment dev1 --depth deep
```

### ✅ Resultado Esperado
```bash
🔍 Starting artifact debug...
Artifact: order-creator
Environment: dev1
Depth: deep
============================================
🔍 DevX Artifact Debug Tool - Sandbox Test
============================================
📦 Gathering artifact information...
...
🔍 Running debug checks...
  📊 Checking repository access...
    ✅ Local repository accessible
    📁 Files in repository: 3
  📝 Validating inventory files...
    ✅ Inventory schema valid
  🔧 Analyzing components...
    🔢 Enabled components: 3
    ✅ Components are properly configured

============================================
🎉 Artifact debug complete!
```

### 🔧 Solución de Problemas
Si el comando falla:
```bash
# Verificar permisos
chmod +x debug-artifact.sh

# Verificar sintaxis
bash -n debug-artifact.sh

# Ejecutar en modo debug
bash -x debug-artifact.sh --artifact order-creator
```

---

## 📊 Caso de Uso 2: Mejora de Comando Existente

### 📋 Situación
**Objetivo**: Mejorar el comando `/review-artifact` existente agregando análisis de dependencias entre artifacts.

### 🎯 Precondiciones
- Comando review-artifact funcionando correctamente
- Múltiples artifacts disponibles para testing

### 📝 Pasos Detallados

#### Paso 1: Analizar Limitaciones Actuales
```bash
# 1. Ejecutar comando actual y documentar limitaciones
./test-review-artifact.sh --artifact web-offer-seat > current-output.txt

# 2. Identificar mejoras necesarias
echo "Limitaciones identificadas:"
echo "- No analiza dependencias entre artifacts"
echo "- No verifica referencias cruzadas"
echo "- No detecta artifacts huérfanos"

# 3. Revisar código actual
grep -n "Pending actions\|Health status" test-review-artifact.sh
```

#### Paso 2: Implementar Mejoras
```bash
# 1. Crear backup
cp test-review-artifact.sh test-review-artifact.sh.backup

# 2. Agregar función de análisis de dependencias
cat >> test-review-artifact.sh << 'EOF'

# Análisis de dependencias entre artifacts
analyze_artifact_dependencies() {
  echo "🔗 Analyzing artifact dependencies..."
  
  DEPENDENCY_COUNT=0
  ORPHANED_COUNT=0
  
  # Buscar referencias a este artifact en otros artifacts
  for layer_dir in al bal bb bc bff ch dev lib sdk tc xp; do
    if [[ -d "repos/nx-artifacts-inventory/nx-artifacts/$layer_dir" ]]; then
      for inventory_file in "repos/nx-artifacts-inventory/nx-artifacts/$layer_dir"/*/nx-app-inventory.yaml; do
        if [[ -f "$inventory_file" ]]; then
          # Buscar referencias al artifact actual
          if grep -q "$ARTIFACT" "$inventory_file" 2>/dev/null; then
            DEPENDENCY_COUNT=$((DEPENDENCY_COUNT + 1))
            DEPENDENT_ARTIFACT=$(basename "$(dirname "$inventory_file")")
            echo "  📎 Found dependency: $DEPENDENT_ARTIFACT"
          fi
        fi
      done
    fi
  done
  
  # Verificar si el artifact es huérfano (no es referenciado)
  if [[ $DEPENDENCY_COUNT -eq 0 ]]; then
    ORPHANED_COUNT=1
    echo "  ⚠️ Artifact appears to be orphaned (no dependencies found)"
  fi
  
  echo "📊 Dependency Analysis:"
  echo "  - Dependencies: $DEPENDENCY_COUNT"
  echo "  - Orphaned status: $ORPHANED_COUNT"
  
  return $DEPENDENCY_COUNT
}

EOF

# 3. Agregar análisis de dependencias al flujo principal
sed -i '/analyze_inventory_files/a analyze_artifact_dependencies' test-review-artifact.sh

# 4. Mejorar la función de health status
sed -i 's/HEALTH_SCORE=80/HEALTH_SCORE=85/' test-review-artifact.sh
sed -i 's/if \[\[ \$PENDING -gt 0 \]\]; then/if \[\[ \$PENDING -gt 0 \]\]; then DEPTH_ANALYSIS=1; fi/' test-review-artifact.sh
```

#### Paso 3: Probar Mejoras
```bash
# 1. Probar con artifact original
./test-review-artifact.sh --artifact web-offer-seat

# 2. Comparar con versión original
./test-review-artifact.sh.backup --artifact web-offer-seat > old-output.txt
./test-review-artifact.sh --artifact web-offer-seat > new-output.txt

# 3. Verificar diferencias
diff old-output.txt new-output.txt

# 4. Probar con múltiples artifacts
./test-review-artifact.sh --artifact web-checkout
./test-review-artifact.sh --artifact web-payment
```

### ✅ Resultado Esperado
```bash
📊 Analyzing inventory files...
📎 Found dependency: nx-bff-web-payment-dev1
📎 Found dependency: nx-ch-web-checkout-dev1

🔗 Analyzing artifact dependencies...
  📎 Found dependency: nx-bff-web-offer-seat-dev1
📊 Dependency Analysis:
  - Dependencies: 3
  - Orphaned status: 0

🏥 Checking artifact health...
Health score: 85%
Status: ⚠️ Degraded
```

---

## 🔄 Caso de Uso 3: Testing de Múltiples Artifacts

### 📋 Situación
**Objetivo**: Ejecutar una suite de testing completa con múltiples artifacts para validar que el sistema funciona consistentemente.

### 🎯 Precondiciones
- Múltiples artifacts disponibles
- Scripts funcionando correctamente

### 📝 Pasos Detallados

#### Paso 1: Crear Suite de Testing
```bash
# 1. Crear script de testing automático
cat > test-suite.sh << 'EOF'
#!/bin/bash
# DevX Sandbox Test Suite

echo "🧪 DevX Sandbox Test Suite"
echo "=========================="

# Lista de artifacts para testing
ARTIFACTS=("web-offer-seat" "web-payment" "web-checkout")

# Función para ejecutar test individual
run_single_test() {
  local artifact=$1
  local test_num=$2
  local total_tests=${#ARTIFACTS[@]}
  
  echo ""
  echo "Test $test_num/$total_tests: $artifact"
  echo "----------------------------------------"
  
  # Ejecutar comando
  ./test-review-artifact.sh --artifact "$artifact" > "test-output-$artifact.txt" 2>&1
  
  # Verificar que no hay errores
  if grep -q "Error\|error\|❌" "test-output-$artifact.txt" | grep -v "❌ Unhealthy"; then
    echo "❌ Test $test_num FAILED: $artifact"
    return 1
  else
    echo "✅ Test $test_num PASSED: $artifact"
    return 0
  fi
}

# Ejecutar todos los tests
PASSED=0
FAILED=0

for i in "${!ARTIFACTS[@]}"; do
  artifact="${ARTIFACTS[$i]}"
  test_num=$((i + 1))
  
  if run_single_test "$artifact" "$test_num"; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "🏁 Test Suite Results:"
echo "====================="
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo "📊 Total: $((PASSED + FAILED))"

if [[ $FAILED -eq 0 ]]; then
  echo "🎉 All tests PASSED!"
  exit 0
else
  echo "💥 Some tests FAILED"
  exit 1
fi
EOF

chmod +x test-suite.sh
```

#### Paso 2: Ejecutar Suite Completa
```bash
# 1. Ejecutar suite de testing
./test-suite.sh

# 2. Verificar resultados detallados
echo "📄 Detailed Results:"
for artifact in web-offer-seat web-payment web-checkout; do
  echo ""
  echo "=== $artifact ==="
  grep -E "Health score|Status|Artifact|Layer" "test-output-$artifact.txt"
done

# 3. Generar reporte consolidado
cat > test-report.md << EOF
# Test Report - $(date)

## Resumen
- Total de artifacts probados: ${#ARTIFACTS[@]}
- Tests pasados: $PASSED
- Tests fallidos: $FAILED

## Resultados Detallados
EOF

for artifact in web-offer-seat web-payment web-checkout; do
  echo "" >> test-report.md
  echo "### $artifact" >> test-report.md
  echo '```' >> test-report.md
  cat "test-output-$artifact.txt" >> test-report.md
  echo '```' >> test-report.md
done

echo "📄 Reporte generado: test-report.md"
```

#### Paso 3: Testing de Performance
```bash
# 1. Crear test de performance
cat > performance-test.sh << 'EOF'
#!/bin/bash
echo "⚡ Performance Test"
echo "=================="

# Test con múltiples invocaciones
echo "Testing execution time..."
time_start=$(date +%s.%N)

for i in {1..5}; do
  ./test-review-artifact.sh --artifact web-offer-seat > /dev/null
  echo "Run $i completed"
done

time_end=$(date +%s.%N)
duration=$(echo "$time_end - $time_start" | bc -l)

echo "⚡ Total duration: ${duration}s"
echo "⚡ Average per run: $(echo "scale=3; $duration / 5" | bc -l)s"
EOF

chmod +x performance-test.sh

# 2. Ejecutar test de performance
./performance-test.sh
```

### ✅ Resultado Esperado
```bash
🧪 DevX Sandbox Test Suite
==========================

Test 1/3: web-offer-seat
----------------------------------------
✅ Test 1 PASSED: web-offer-seat

Test 2/3: web-payment
----------------------------------------
✅ Test 2 PASSED: web-payment

Test 3/3: web-checkout
----------------------------------------
✅ Test 3 PASSED: web-checkout

🏁 Test Suite Results:
=====================
✅ Passed: 3
❌ Failed: 0
📊 Total: 3

🎉 All tests PASSED!

⚡ Performance Test
==================
Testing execution time...
Run 1 completed
Run 2 completed
Run 3 completed
Run 4 completed
Run 5 completed
⚡ Total duration: 2.345s
⚡ Average per run: 0.469s
```

---

## ⚠️ Caso de Uso 4: Simulación de Error y Recovery

### 📋 Situación
**Objetivo**: Probar cómo se comporta el sistema ante errores y verificar mecanismos de recovery.

### 🎯 Precondiciones
- Sistema funcionando normalmente
- Conocimiento de puntos de fallo potenciales

### 📝 Pasos Detallados

#### Paso 1: Identificar Puntos de Fallo
```bash
# 1. Identificar archivos críticos
echo "🔍 Identificando puntos de fallo..."

FILES_TO_DAMAGE=(
  "test-review-artifact.sh"
  "repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml"
)

echo "Archivos críticos identificados:"
for file in "${FILES_TO_DAMAGE[@]}"; do
  echo "  - $file"
done
```

#### Paso 2: Simular Error en Archivo de Inventory
```bash
# 1. Crear backup del archivo original
cp "repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml" \
   "repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml.backup"

# 2. Corromper el archivo
echo "CORRUPTED YAML FILE" > "repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml"

# 3. Probar cómo maneja el error
echo "🧪 Testing error handling..."
./test-review-artifact.sh --artifact web-offer-seat

# 4. Verificar que el sistema maneja el error graciosamente
```

#### Paso 3: Recuperar y Verificar
```bash
# 1. Restaurar archivo original
mv "repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml.backup" \
   "repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-dev1/nx-app-inventory.yaml"

# 2. Verificar que todo vuelve a la normalidad
./test-review-artifact.sh --artifact web-offer-seat | grep -E "Health score|Status"

# 3. Crear test de robustez
cat > error-recovery-test.sh << 'EOF'
#!/bin/bash
echo "🧪 Error Recovery Test"
echo "====================="

# Test 1: Archivo de inventory corrupto
echo "Test 1: Corrupted inventory file"
echo "CORRUPT" > test-inventory.yaml
./test-review-artifact.sh --artifact web-offer-seat 2>&1 | grep -E "Error|⚠️" || echo "Handled gracefully"

# Test 2: Artifact inexistente
echo ""
echo "Test 2: Non-existent artifact"
./test-review-artifact.sh --artifact non-existent-artifact 2>&1 | grep -E "Error|⚠️" || echo "Handled gracefully"

# Test 3: Permisos incorrectos
echo ""
echo "Test 3: Permission issues"
chmod 000 test-review-artifact.sh
./test-review-artifact.sh --artifact web-offer-seat 2>&1 | grep -E "Error|⚠️" || echo "Handled gracefully"
chmod 755 test-review-artifact.sh

echo ""
echo "✅ Error recovery test complete"
EOF

chmod +x error-recovery-test.sh
./error-recovery-test.sh
```

### ✅ Resultado Esperado
```bash
🧪 Error Recovery Test
=====================
Test 1: Corrupted inventory file
Handled gracefully

Test 2: Non-existent artifact
⚠️ No inventory files found for artifact: non-existent-artifact
Handled gracefully

Test 3: Permission issues
❌ Permission denied
Handled gracefully

✅ Error recovery test complete
```

---

## 🚀 Caso de Uso 5: Validación antes de Production

### 📋 Situación
**Objetivo**: Usar el sandbox para validar que los cambios están listos antes de desplegar a producción.

### 🎯 Precondiciones
- Cambios listos para producción
- Repositorio de producción accesible

### 📝 Pasos Detallados

#### Paso 1: Preparar Validación de Producción
```bash
# 1. Clonar repositorio de producción
echo "🚀 Preparing for production validation..."
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 2. Ejecutar suite completa de testing
./test-suite.sh

# 3. Verificar performance
./performance-test.sh
```

#### Paso 2: Simular Escenario de Producción
```bash
# 1. Crear script de validación de producción
cat > production-validation.sh << 'EOF'
#!/bin/bash
echo "🚀 Production Validation Suite"
echo "============================="

# Lista de artifacts de producción
PRODUCTION_ARTIFACTS=("order-creator" "user-service" "payment-service")

# Función de validación completa
validate_for_production() {
  local artifact=$1
  echo ""
  echo "🔍 Validating: $artifact"
  echo "------------------------"
  
  # 1. Test básico
  echo "  Running basic test..."
  ./test-review-artifact.sh --artifact "$artifact" > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "  ✅ Basic test passed"
  else
    echo "  ❌ Basic test failed"
    return 1
  fi
  
  # 2. Test de datos críticos
  echo "  Checking critical data..."
  if ./test-review-artifact.sh --artifact "$artifact" | grep -q "Health score"; then
    echo "  ✅ Critical data present"
  else
    echo "  ❌ Critical data missing"
    return 1
  fi
  
  # 3. Test de performance
  echo "  Testing performance..."
  start_time=$(date +%s.%N)
  ./test-review-artifact.sh --artifact "$artifact" > /dev/null
  end_time=$(date +%s.%N)
  duration=$(echo "$end_time - $start_time" | bc -l)
  
  if (( $(echo "$duration < 5.0" | bc -l) )); then
    echo "  ✅ Performance OK (${duration}s)"
  else
    echo "  ❌ Performance degraded (${duration}s)"
    return 1
  fi
  
  echo "  ✅ Production validation passed for $artifact"
  return 0
}

# Validar todos los artifacts
PASSED=0
FAILED=0

for artifact in "${PRODUCTION_ARTIFACTS[@]}"; do
  if validate_for_production "$artifact"; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "🏁 Production Validation Results:"
echo "==============================="
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"

if [[ $FAILED -eq 0 ]]; then
  echo "🎉 Ready for production deployment!"
else
  echo "💥 Fix issues before production deployment"
  exit 1
fi
EOF

chmod +x production-validation.sh
```

#### Paso 3: Ejecutar Validación Completa
```bash
# 1. Ejecutar validación de producción
./production-validation.sh

# 2. Generar reporte de validación
cat > production-readiness-report.md << EOF
# Production Readiness Report
Generated: $(date)

## Validation Summary
- ✅ Basic functionality tests: Passed
- ✅ Data integrity checks: Passed  
- ✅ Performance benchmarks: Passed
- ✅ Error handling: Verified
- ✅ Recovery mechanisms: Tested

## Artifacts Validated
$(for artifact in "${PRODUCTION_ARTIFACTS[@]}"; do echo "- $artifact"; done)

## Recommendations
- All validation tests passed successfully
- System is ready for production deployment
- Consider monitoring performance metrics post-deployment

## Next Steps
1. Deploy to staging environment
2. Run integration tests
3. Deploy to production with monitoring
EOF

echo "📄 Production readiness report generated: production-readiness-report.md"
```

### ✅ Resultado Esperado
```bash
🚀 Production Validation Suite
=============================

🔍 Validating: order-creator
------------------------
  ✅ Basic test passed
  ✅ Critical data present
  ✅ Performance OK (0.3s)
  ✅ Production validation passed for order-creator

🏁 Production Validation Results:
===============================
✅ Passed: 3
❌ Failed: 0

🎉 Ready for production deployment!
```

---

## 🔧 Caso de Uso 6: Debugging Avanzado

### 📋 Situación
**Objetivo**: Usar técnicas avanzadas de debugging para diagnosticar problemas complejos en el sistema.

### 🎯 Precondiciones
- Problema que requiere debugging profundo
- Acceso a herramientas de debugging

### 📝 Pasos Detallados

#### Paso 1: Configurar Entorno de Debugging
```bash
# 1. Crear script de debugging avanzado
cat > debug-advanced.sh << 'EOF'
#!/bin/bash
echo "🔧 Advanced Debugging Suite"
echo "=========================="

# Función de debug completo
advanced_debug() {
  local artifact=$1
  echo ""
  echo "🔍 Advanced debug for: $artifact"
  echo "============================"
  
  # 1. Debug de variables de entorno
  echo "Environment Variables:"
  echo "  ARTIFACT: $artifact"
  echo "  PWD: $(pwd)"
  echo "  USER: $USER"
  echo "  DATE: $(date)"
  
  # 2. Debug de sistema de archivos
  echo ""
  echo "Filesystem Debug:"
  echo "  Disk usage:"
  df -h . | tail -1
  echo "  Directory contents:"
  ls -la | head -5
  
  # 3. Debug de procesos
  echo ""
  echo "Process Debug:"
  echo "  Running processes:"
  ps aux | grep test-review | grep -v grep
  
  # 4. Debug de red
  echo ""
  echo "Network Debug:"
  if curl -s --head https://github.com > /dev/null; then
    echo "  ✅ GitHub connectivity OK"
  else
    echo "  ❌ GitHub connectivity issues"
  fi
  
  # 5. Memory y recursos
  echo ""
  echo "Resource Debug:"
  echo "  Memory usage:"
  free -h 2>/dev/null || vm_stat | head -5
  
  # 6. Execution trace
  echo ""
  echo "Execution Trace:"
  echo "  Running with trace enabled..."
  bash -x ./test-review-artifact.sh --artifact "$artifact" 2>&1 | head -20
}

# Ejecutar debug para artifact específico
if [[ -n "$1" ]]; then
  advanced_debug "$1"
else
  advanced_debug "web-offer-seat"
fi
EOF

chmod +x debug-advanced.sh
```

#### Paso 2: Análisis de Logs Detallado
```bash
# 1. Crear sistema de logging
cat > debug-logger.sh << 'EOF'
#!/bin/bash
# Advanced logging system

LOG_DIR="debug-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/debug-$(date +%Y%m%d-%H%M%S).log"

log_message() {
  local level=$1
  local message=$2
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log_message "INFO" "$1"; }
log_warn() { log_message "WARN" "$1"; }
log_error() { log_message "ERROR" "$1"; }
log_debug() { log_message "DEBUG" "$1"; }

# Función de análisis de logs
analyze_logs() {
  echo "📊 Log Analysis"
  echo "=============="
  
  if [[ -d "$LOG_DIR" ]] && [[ -n "$(ls -A "$LOG_DIR")" ]]; then
    echo "Log files found:"
    ls -la "$LOG_DIR"
    
    echo ""
    echo "Error summary:"
    grep "ERROR" "$LOG_DIR"/*.log | wc -l | xargs echo "  Total errors:"
    
    echo ""
    echo "Recent warnings:"
    tail -5 "$LOG_DIR"/*.log | grep "WARN"
  else
    echo "No log files found"
  fi
}

# Test del sistema de logging
log_info "Debug session started"
log_debug "Artifact: web-offer-seat"
log_info "Executing test-review-artifact"
log_warn "Potential issue detected"
log_info "Test completed"

analyze_logs
EOF

chmod +x debug-logger.sh

# 2. Ejecutar análisis de logs
./debug-logger.sh
```

#### Paso 3: Performance Profiling
```bash
# 1. Crear profiler
cat > performance-profiler.sh << 'EOF'
#!/bin/bash
echo "⚡ Performance Profiler"
echo "====================="

# Profiling de función específica
profile_function() {
  local artifact=$1
  local func_name=$2
  
  echo "🔍 Profiling function: $func_name for artifact: $artifact"
  echo "-------------------------------------------"
  
  # Usar time para medir performance
  echo "Function execution time:"
  time (
    ./test-review-artifact.sh --artifact "$artifact" > /dev/null
  ) 2>&1 | grep real
  
  # Usar strace para analizar system calls (si está disponible)
  if command -v strace >/dev/null 2>&1; then
    echo ""
    echo "System calls analysis:"
    timeout 5 strace -c ./test-review-artifact.sh --artifact "$artifact" 2>/dev/null | tail -10
  fi
  
  # Usar gprof si está disponible (compilado con -pg)
  if [[ -f "gmon.out" ]]; then
    echo ""
    echo "Profile data:"
    gprof test-review-artifact.sh gmon.out | head -20
  fi
}

# Profiling de funciones clave
profile_function "web-offer-seat" "get_artifact_info"
profile_function "web-offer-seat" "analyze_inventory_files"
profile_function "web-offer-seat" "check_pending_actions"
EOF

chmod +x performance-profiler.sh

# 2. Ejecutar profiling
./performance-profiler.sh
```

### ✅ Resultado Esperado
```bash
🔧 Advanced Debugging Suite
==========================

🔍 Advanced debug for: web-offer-seat
============================
Environment Variables:
  ARTIFACT: web-offer-seat
  PWD: /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
  USER: jaime
  DATE: Wed Nov 17 22:42:03 UTC 2025

Filesystem Debug:
  Disk usage:
  /dev/disk3s1   234Gi   90Gi   144Gi    39%    /
  Directory contents:
  total 48
  drwxr-xr-x  1 jaime.henao  staff  1536 Nov 17 22:42 .
  drwxr-xr-x  7 jaime.henao  staff  1536 Nov 17 22:42 ..
  -rw-r--r--  1 jaime.henao  staff  8000 Nov 17 22:42 test-review-artifact.sh

📊 Log Analysis
==============
Log files found:
drwxr-xr-x  1 jaime.henao  staff   1024 Nov 17 22:42 debug-logs/
Error summary:
  Total errors: 0

Recent warnings:
  [2025-11-17 22:42:03] [WARN] Potential issue detected

⚡ Performance Profiler
=====================
🔍 Profiling function: get_artifact_info for artifact: web-offer-seat
-------------------------------------------
Function execution time:
real    0m0.234s
user    0m0.123s
sys     0m0.098s

📊 Dependency Analysis:
  - Dependencies: 2
  - Orphaned status: 0

🏥 Checking artifact health...
Health score: 85%
Status: ⚠️ Degraded

🎉 Debug analysis complete!
```

---

## 🎯 Resumen de Casos de Uso

Cada caso de uso demuestra cómo el DevX Sandbox permite:

| Caso de Uso | Objetivo | Beneficio |
|-------------|----------|-----------|
| **Desarrollo de Nuevo Comando** | Crear funcionalidad nueva | Testing seguro sin afectar producción |
| **Mejora de Comando Existente** | Optimizar herramientas actuales | Validación iterativa de mejoras |
| **Testing de Múltiple Artifacts** | Validación masiva | Confianza en el sistema completo |
| **Simulación de Error** | Testing de robustez | Preparación para escenarios edge |
| **Validación de Producción** | Pre-deployment checks | Reducción de riesgo en despliegues |
| **Debugging Avanzado** | Diagnóstico profundo | Solución eficiente de problemas |

**El DevX Sandbox es una herramienta completa para desarrollo, testing y validación en un ambiente seguro y controlado.**