# ❓ Troubleshooting & FAQ - DevX Sandbox System

## 📋 Tabla de Contenidos
1. [Problemas Comunes](#problemas-comunes)
2. [FAQ - Preguntas Frecuentes](#faq---preguntas-frecuentes)
3. [Soluciones Paso a Paso](#soluciones-paso-a-paso)
4. [Herramientas de Diagnóstico](#herramientas-de-diagnóstico)
5. [Contacto y Soporte](#contacto-y-soporte)

---

## 🐛 Problemas Comunes

### ❌ Error: "Repository not found"
**Síntomas:**
```bash
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator
# Output: ❌ Repository not found: https://github.com/BritishAirways-Nexus/nx-tc-order-creator
```

**Causas:**
- Repositorio no existe en la organización especificada
- Nombre del artifact incorrecto
- Organización incorrecta
- Repositorio privado sin permisos

**Solución:**
```bash
# 1. Verificar que el repositorio existe
git ls-remote --heads https://github.com/BritishAirways-Nexus/nx-tc-order-creator.git

# 2. Verificar organizaciones disponibles
# BritishAirways-Nexus
# BritishAirways-Nexus-Internal

# 3. Usar nombre exacto del repositorio
# ✅ Correcto: nx-tc-order-creator
# ❌ Incorrecto: nx-tc-orderCreator
```

### ❌ Error: "Permission denied"
**Síntomas:**
```bash
./artifact-selector.sh
# Output: Permission denied
```

**Causas:**
- Script no tiene permisos de ejecución
- Propietario incorrecto de archivos

**Solución:**
```bash
# 1. Hacer scripts ejecutables
chmod +x *.sh

# 2. Verificar permisos
ls -la *.sh
# Debe mostrar: -rwxr-xr-x

# 3. Cambiar propietario si es necesario
sudo chown jaime:jaime *.sh
```

### ❌ Error: "Git is not installed"
**Síntomas:**
```bash
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator
# Output: ❌ Git is not installed. Please install Git first.
```

**Solución:**
```bash
# Instalar Git (macOS)
brew install git

# Verificar instalación
git --version
```

### ❌ Error: "No inventory files found"
**Síntomas:**
```bash
./test-review-artifact.sh --artifact bc-test-service
# Output: ⚠️ No inventory files found for artifact: bc-test-service
```

**Causas:**
- Artifact existe solo en environments, no en inventory
- Nombre del artifact no coincide exactamente

**Solución:**
```bash
# 1. Usar artifact selector para ver disponibles
./artifact-selector.sh

# 2. Probar con artifact que tiene inventory
./test-review-artifact.sh --artifact web-offer-seat

# 3. Verificar estructura del artifact
find repos/ -name "*bc-test*" -type d
```

### ❌ Error: "Permission denied while executing scripts"
**Síntomas:**
```bash
bash ./artifact-selector.sh
# Output: Permission denied
```

**Solución:**
```bash
# Solución 1: Usar chmod
chmod +x artifact-selector.sh
./artifact-selector.sh

# Solución 2: Ejecutar con bash explícitamente
bash artifact-selector.sh
```

---

## ❓ FAQ - Preguntas Frecuentes

### ¿Qué diferencia hay entre artifacts del sandbox y repositorios reales?

**Artifacts del Sandbox:**
- ✅ Acceso inmediato (no requiere red)
- ✅ Datos simulados pero reales
- ✅ Útiles para testing básico
- ❌ Limitados a los artifacts disponibles

**Repositorios Reales:**
- ✅ Datos completamente reales
- ✅ Testing con casos de uso reales
- ✅ Actualizaciones desde GitHub
- ❌ Requiere conexión a internet
- ❌ Puede tener límites de rate limiting

### ¿Puedo modificar los repositorios clonados?

**¡Sí, completamente!** El propósito del sandbox es permitir modificaciones seguras:

```bash
# Clonar repositorio
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# Modificar archivos
cd local-artifacts/nx-tc-order-creator
vim Chart.yaml
# Hacer todos los cambios necesarios

# Probar cambios
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
./test-review-artifact.sh --artifact order-creator

# Cuando estés satisfecho, puedes:
# 1. Aplicar cambios al repo real
git push origin main
# 2. O mantener solo para testing local
```

### ¿Cómo limpio el sandbox y empiezo de nuevo?

```bash
# 1. Limpiar repositorios clonados
rm -rf local-artifacts/

# 2. Limpiar artifacts de testing
rm -rf test-artifacts/

# 3. Restaurar scripts originales si los modificó
git checkout HEAD -- *.sh

# 4. Verificar estado limpio
ls -la
./artifact-selector.sh
```

### ¿Puedo usar el sandbox sin conexión a internet?

**Parcialmente:**

```bash
# ✅ Funciona sin internet:
./artifact-selector.sh                              # Artifacts locales
./test-review-artifact.sh --artifact web-offer-seat # Datos simulados

# ❌ Requiere internet:
./clone-artifact-from-github.sh                    # Clonar repos
```

### ¿Qué organizaciones de GitHub están soportadas?

**Oficiales:**
- `BritishAirways-Nexus`
- `BritishAirways-Nexus-Internal`

**Para agregar nuevas organizaciones:**
```bash
# Editar el script clone-artifact-from-github.sh
# En la función validate_repository(), agregar:
if [[ "$org" == "tu-org" ]]; then
    echo "✅ Organization recognized"
else
    echo "⚠️ Unknown organization: $org"
fi
```

### ¿Cómo sé si un comando DevX está implementado?

```bash
# Verificar comandos disponibles
./test-review-artifact.sh --help  # Si existe

# Verificar scripts en el directorio
ls -la *.sh

# Verificar documentación
grep -r "Status:" .
```

### ¿Puedo ejecutar múltiples comandos a la vez?

```bash
# Sí, crear un script de testing combinado
cat > test-suite.sh << 'EOF'
#!/bin/bash
echo "🧪 Running DevX Sandbox Test Suite"
echo "=================================="

# Test 1: Artifacts locales
echo "Test 1: Local artifacts"
./test-review-artifact.sh --artifact web-offer-seat

echo ""
echo "Test 2: Multiple artifacts"
./test-review-artifact.sh --artifact web-payment

echo ""
echo "Test 3: Health check"
./test-review-artifact.sh --artifact web-offer-seat --depth deep

echo ""
echo "✅ Test suite complete!"
EOF

chmod +x test-suite.sh
./test-suite.sh
```

---

## 🔧 Soluciones Paso a Paso

### Solución 1: Problema de Permisos

```bash
# Diagnóstico
ls -la *.sh
# Debe mostrar algo como: -rw-r--r-- 1 jaime jaime 1000 script.sh

# Solución paso a paso
echo "Solucionando permisos..."

# 1. Dar permisos de ejecución
chmod +x *.sh

# 2. Verificar
ls -la *.sh
# Debe mostrar: -rwxr-xr-x 1 jaime jaime 1000 script.sh

# 3. Probar
./artifact-selector.sh
```

### Solución 2: Repositorio No Encontrado

```bash
# Diagnóstico
echo "Verificando repositorio..."

# 1. Verificar estructura del nombre
echo "Artifact name: nx-tc-order-creator"
echo "Expected layers: nx-[layer]-[service]-[env]"

# 2. Listar artifacts disponibles
./artifact-selector.sh

# 3. Verificar organización
echo "Organization: BritishAirways-Nexus"
echo "Available repos can be listed at:"
echo "https://github.com/BritishAirways-Nexus?tab=repositories"

# 4. Probar con artifact conocido
./test-review-artifact.sh --artifact web-offer-seat
```

### Solución 3: Script No Encuentra Artifact

```bash
# Diagnóstico detallado
echo "🔍 Diagnosticando artifact..."

# 1. Verificar estructura de directorios
find repos/ -name "*artifact-name*" -type d

# 2. Buscar en inventory
find repos/nx-artifacts-inventory/ -name "*artifact*" -name "*.yaml"

# 3. Buscar en environments
find repos/nx-bolt-environment-*/ -name "*artifact*" -type d

# 4. Usar selector para encontrar artifact correcto
./artifact-selector.sh
# Buscar artifact en la lista

# 5. Usar nombre exacto del selector
./test-review-artifact.sh --artifact exact-name-from-selector
```

---

## 🔍 Herramientas de Diagnóstico

### Script de Diagnóstico Rápido

```bash
cat > diagnostic.sh << 'EOF'
#!/bin/bash
echo "🔍 DevX Sandbox Diagnostic Tool"
echo "==============================="

echo ""
echo "📁 Directory Structure:"
ls -la | grep -E "\.sh$|repos/"

echo ""
echo "🔧 Scripts Status:"
for script in *.sh; do
    if [[ -x "$script" ]]; then
        echo "✅ $script (executable)"
    else
        echo "❌ $script (not executable)"
    fi
done

echo ""
echo "📦 Available Artifacts:"
find repos/ -name "*.yaml" | wc -l | xargs echo "Inventory files:"

echo ""
echo "🌐 Network Test:"
if curl -s --head https://github.com > /dev/null; then
    echo "✅ GitHub accessible"
else
    echo "❌ GitHub not accessible"
fi

echo ""
echo "🧪 Quick Test:"
if [[ -f "test-review-artifact.sh" ]] && [[ -x "test-review-artifact.sh" ]]; then
    echo "Running quick test..."
    ./test-review-artifact.sh --artifact web-offer-seat | head -5
else
    echo "❌ test-review-artifact.sh not available"
fi
EOF

chmod +x diagnostic.sh
./diagnostic.sh
```

### Verificación de Integridad

```bash
cat > verify-sandbox.sh << 'EOF'
#!/bin/bash
echo "🔍 Verificando integridad del sandbox..."

# 1. Verificar archivos esenciales
essential_files=(
    "artifact-selector.sh"
    "clone-artifact-from-github.sh"
    "test-review-artifact.sh"
    "repos/nx-artifacts-inventory"
)

echo "📁 Verificando archivos esenciales:"
for file in "${essential_files[@]}"; do
    if [[ -e "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ $file - MISSING"
    fi
done

# 2. Verificar permisos
echo ""
echo "🔐 Verificando permisos:"
for script in *.sh; do
    if [[ -x "$script" ]]; then
        echo "✅ $script (executable)"
    else
        echo "❌ $script (not executable)"
    fi
done

# 3. Verificar conectividad
echo ""
echo "🌐 Verificando conectividad:"
if command -v curl >/dev/null 2>&1; then
    if curl -s --head https://github.com | head -1 | grep -q "200 OK"; then
        echo "✅ GitHub accessible"
    else
        echo "❌ GitHub not accessible"
    fi
else
    echo "❓ curl not available"
fi

# 4. Test rápido
echo ""
echo "🧪 Ejecutando test rápido:"
./test-review-artifact.sh --artifact web-offer-seat | grep -E "Artifact|Health score|Status" | head -3

echo ""
echo "✅ Diagnóstico completo"
EOF

chmod +x verify-sandbox.sh
./verify-sandbox.sh
```

---

## 🆘 Contacto y Soporte

### Antes de Contactar Soporte

1. **Ejecuta el diagnóstico:**
   ```bash
   ./verify-sandbox.sh
   ./diagnostic.sh
   ```

2. **Documenta el problema:**
   - Comando exacto que ejecutaste
   - Mensaje de error completo
   - Pasos para reproducir el problema

3. **Verifica la configuración:**
   ```bash
   git --version
   bash --version
   ls -la
   ```

### Comandos de Auto-Servicio

```bash
# Limpiar y empezar de nuevo
rm -rf local-artifacts/ test-artifacts/
./artifact-selector.sh

# Reinstalar permisos
chmod +x *.sh

# Test completo
./verify-sandbox.sh && ./test-review-artifact.sh --artifact web-offer-seat
```

### Información de Debug

**Cuando contactes soporte, incluye:**
```bash
# Versiones del sistema
echo "=== SYSTEM INFO ===" > debug-info.txt
git --version >> debug-info.txt
bash --version >> debug-info.txt
uname -a >> debug-info.txt

# Estado del sandbox
echo -e "\n=== SANDBOX STATUS ===" >> debug-info.txt
ls -la *.sh >> debug-info.txt
ls -la repos/ >> debug-info.txt

# Test results
echo -e "\n=== TEST RESULTS ===" >> debug-info.txt
./verify-sandbox.sh >> debug-info.txt 2>&1

# Error details
echo -e "\n=== ERROR DETAILS ===" >> debug-info.txt
# Reproducir el error aquí y copiar la salida
```

**Este documento debería resolver la mayoría de los problemas comunes. Si encuentras un problema no documentado, considera agregarlo a esta guía.**