# 🚀 Guía Paso a Paso - DevX Sandbox System

## 📋 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Instalación y Configuración](#instalación-y-configuración)
3. [Flujo de Trabajo Completo](#flujo-de-trabajo-completo)
4. [Casos de Uso Específicos](#casos-de-uso-específicos)
5. [Comandos y Sintaxis](#comandos-y-sintaxis)
6. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## 🎯 Introducción

El DevX Sandbox es un ambiente de desarrollo local que te permite:
- **Probar comandos DevX** sin afectar repositorios reales
- **Clonar repositorios reales** de GitHub para testing local
- **Iterar rápidamente** en el desarrollo de herramientas
- **Validar funcionalidades** antes de desplegar

---

## 🛠️ Instalación y Configuración

### Requisitos Previos
```bash
# Verificar que tienes git instalado
git --version

# Verificar que tienes bash
bash --version
```

### Configuración Inicial
```bash
# 1. Ir al directorio del sandbox
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox

# 2. Verificar que los scripts son ejecutables
chmod +x *.sh

# 3. Verificar la estructura del sandbox
ls -la
```

**✅ Resultado Esperado:**
```
artifact-selector.sh
clone-artifact-from-github.sh  
test-review-artifact.sh
repos/
```

---

## 🔄 Flujo de Trabajo Completo

### Paso 1: Elegir el Enfoque de Testing

```bash
# Ejecutar el selector de artifacts para ver opciones
./artifact-selector.sh
```

**Opciones disponibles:**
- **Opción A**: Usar artifacts existentes en el sandbox
- **Opción B**: Clonar un repositorio real desde GitHub

### Paso 2A: Testing con Artifacts Existentes

#### 2.1 Seleccionar Artifact
```bash
./artifact-selector.sh
# Elegir opción 1: "List all available artifacts"
```

#### 2.2 Analizar Artifact Seleccionado
```bash
# Número de artifact (ej: 1 para nx-bff-web-offer-seat-dev1)
# Elegir opción 2: "Run /review-artifact test with specific artifact"
```

#### 2.3 Ejecutar Review Command
```bash
# Automáticamente ejecutará:
./test-review-artifact.sh --artifact web-offer-seat
```

**✅ Ejemplo de Salida:**
```
🔍 Starting artifact review...
Artifact: web-offer-seat
Environment: all
Depth: standard
============================================
🔍 DevX Artifact Review Tool - Sandbox Test
============================================
📦 Gathering artifact information...
Layer: bff
Inventory Directory: repos/nx-artifacts-inventory/nx-artifacts/bff
Artifact Directory: repos/nx-artifacts-inventory/nx-artifacts/bff/nx-bff-web-offer-seat-prod1

🌍 Checking environments...
Found        1 environment(s):
  - bff-web-offer-seat

📊 Analyzing inventory files...
Found inventory files:
  📄 nx-ch-web-checkout-dev1
     Environment: "dev1"
     Artifact: "nx-ch-web-checkout-dev1"
     Enabled components: 0
     Deployed components: 0

⏳ Checking pending actions...
Total pending actions: 0

🏥 Checking artifact health...
Health score: 80%
Status: ⚠️ Degraded

============================================
🎉 Artifact review complete!
```

### Paso 2B: Testing con Repositorios Reales

#### 2.1 Validar Repositorio en GitHub
```bash
# Verificar que el repositorio existe
git ls-remote --heads https://github.com/BritishAirways-Nexus/nx-tc-order-creator.git
```

#### 2.2 Clonar Repositorio
```bash
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator
```

**✅ Ejemplo de Salida:**
```
🔧 GitHub Artifact Cloner - DevX Sandbox
========================================

✅ Git is available

🔍 Validating repository...
✅ Repository exists: https://github.com/BritishAirways-Nexus/nx-tc-order-creator

🔄 Cloning artifact repository...
Organization: BritishAirways-Nexus
Artifact: nx-tc-order-creator
Target directory: local-artifacts/nx-tc-order-creator

✅ Successfully cloned nx-tc-order-creator

📁 Repository contents:
total 8
drwxr-xr-x  3 jaime.henao  staff  96 Nov 17 15:40 .
drwxr-xr-x  7 jaime.henao  staff  416 Nov 17 15:40 ..
-rw-r--r-- 1 jaime.henao  staff  802 Nov 17 15:40 Chart.yaml
-rw-r--r-- 1 jaime.henao  staff  1024 Nov 17 15:40 values.yaml
-rw-r--r-- 1 jaime.henao  staff  2048 Nov 17 15:40 README.md

🏗️  Found Helm chart:
   Chart.yaml exists
   values.yaml exists
   README.md exists

🧪 Preparing artifact for testing...
✅ Copied Chart.yaml
✅ Copied values.yaml
✅ Copied README.md

📝 Creating test inventory file...
✅ Created test inventory file
   Service: nx-tc-order-creator
   Layer: tc
   From GitHub: Yes

🎯 Artifact prepared for testing in: test-artifacts/nx-tc-order-creator

🔧 Available commands for testing:

1. Review artifact:
   ./test-review-artifact.sh --artifact order-creator

2. Test CLI with artifact:
   cd local-artifacts/nx-tc-order-creator
   # Test your CLI modifications here

3. Manual testing:
   cd test-artifacts/nx-tc-order-creator
   # Modify files and test changes

🎉 Artifact ready for local testing!
```

#### 2.3 Probar con el Artifact Clonado
```bash
# Usar el artifact clonado para testing
./test-review-artifact.sh --artifact order-creator
```

---

## 🎯 Casos de Uso Específicos

### Caso de Uso 1: Desarrollo de Nuevo Comando DevX

**Situación**: Quieres desarrollar el comando `/debug-artifact`

```bash
# 1. Clonar un artifact para tener datos reales
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 2. Entrar al directorio del artifact clonado
cd local-artifacts/nx-tc-order-creator

# 3. Desarrollar y probar tu comando
# Editar archivos, modificar lógica, etc.

# 4. Volver al sandbox y probar con el artifact
cd /Users/jaime.henao/arheanja/DevX-Terraform-Sandbox
./test-review-artifact.sh --artifact order-creator

# 5. Iterar hasta que funcione correctamente
```

### Caso de Uso 2: Modificación de Comandos Existentes

**Situación**: Quieres mejorar `/review-artifact`

```bash
# 1. Probar el comando actual
./test-review-artifact.sh --artifact web-offer-seat

# 2. Analizar resultados y identificar mejoras
# (Revisar la salida del comando anterior)

# 3. Modificar el script test-review-artifact.sh
# (Editar directamente en el sandbox)

# 4. Volver a probar
./test-review-artifact.sh --artifact web-offer-seat

# 5. Comparar resultados y repetir hasta满意
```

### Caso de Uso 3: Testing con Múltiples Artifacts

**Situación**: Quieres probar con varios artifacts diferentes

```bash
# 1. Probar con artifact del sandbox
./test-review-artifact.sh --artifact web-offer-seat

# 2. Clonar y probar con artifact real
./clone-artifact-from-github.sh BritishAirways-Nexus nx-ch-web-checkout
./test-review-artifact.sh --artifact web-checkout

# 3. Probar con otro artifact real
./clone-artifact-from-github.sh BritishAirways-Nexus nx-al-user-service
./test-review-artifact.sh --artifact user-service

# 4. Comparar resultados entre diferentes artifacts
```

---

## 🔧 Comandos y Sintaxis

### artifact-selector.sh
```bash
# Ejecutar selector interactivo
./artifact-selector.sh

# Opciones del menú:
# [1] List all available artifacts
# [2] Run /review-artifact test with specific artifact  
# [3] Clone artifact for local testing
# [4] Exit
```

### clone-artifact-from-github.sh
```bash
# Sintaxis básica
./clone-artifact-from-github.sh <organization> <artifact-name>

# Ejemplos
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator
./clone-artifact-from-github.sh BritishAirways-Nexus nx-ch-web-checkout
./clone-artifact-from-github.sh BritishAirways-Nexus nx-al-user-service

# Organizaciones disponibles:
# - BritishAirways-Nexus
# - BritishAirways-Nexus-Internal
```

### test-review-artifact.sh
```bash
# Sintaxis básica
./test-review-artifact.sh --artifact <name>

# Con parámetros opcionales
./test-review-artifact.sh --artifact <name> --environment <env> --depth <level>

# Ejemplos
./test-review-artifact.sh --artifact web-offer-seat
./test-review-artifact.sh --artifact order-creator --environment dev1 --depth deep
```

---

## 📝 Ejemplos Prácticos

### Ejemplo 1: Primera Vez Usando el Sandbox

```bash
# 1. Explorar artifacts disponibles
./artifact-selector.sh
# Seleccionar opción 1 para ver lista completa

# 2. Probar con un artifact existente
# Seleccionar opción 2, luego elegir artifact #1

# 3. Analizar resultados y entender el formato
```

### Ejemplo 2: Probar Comando Mejorado

```bash
# 1. Hacer backup del comando original
cp test-review-artifact.sh test-review-artifact.sh.backup

# 2. Modificar el comando (ejemplo: cambiar health score)
# Editar la función get_health_status()

# 3. Probar la modificación
./test-review-artifact.sh --artifact web-offer-seat

# 4. Comparar con la versión original si es necesario
./test-review-artifact.sh.backup --artifact web-offer-seat

# 5. Iterar hasta estar satisfecho
```

### Ejemplo 3: Simular Error y Debugging

```bash
# 1. Ejecutar comando y capturar error
./test-review-artifact.sh --artifact non-existent-artifact

# 2. Verificar manejo de errores
# (El comando debería mostrar mensaje apropiado)

# 3. Probar con artifact válido
./test-review-artifact.sh --artifact web-offer-seat

# 4. Verificar que todo funciona correctamente
```

### Ejemplo 4: Limpiar y Resetear

```bash
# 1. Limpiar artifacts clocados localmente
rm -rf local-artifacts/

# 2. Limpiar artifacts de testing
rm -rf test-artifacts/

# 3. Restaurar sandbox a estado limpio
# (Los repos simulados en repos/ quedan intactos)

# 4. Empezar de nuevo
./artifact-selector.sh
```

---

## ✅ Checklist de Validación

Antes de considerar que tu testing está completo:

- [ ] **Artifact encontrado**: El comando identifica correctamente el artifact
- [ ] **Datos analizados**: Se procesan todos los archivos relevantes
- [ ] **Estado calculado**: Health score y status son calculados correctamente
- [ ] **Reportes generados**: La salida es clara y útil
- [ ] **Errores manejados**: El comando maneja casos edge apropiadamente
- [ ] **Performance aceptable**: El comando ejecuta en tiempo razonable
- [ ] **Resultados reproducibles**: Mismo input produce mismo output

---

## 🎉 Próximos Pasos

Después de completar tus pruebas en el sandbox:

1. **Validar cambios**: Asegúrate de que todas las funcionalidades trabajen como esperado
2. **Documentar modificaciones**: Actualiza la documentación de comandos
3. **Push a repositorio real**: Cuando estés satisfecho, aplica cambios a repos reales
4. **Continuar iterando**: El sandbox sigue disponible para futuras mejoras

**¡El DevX Sandbox está diseñado para hacer el desarrollo rápido, seguro y eficiente!**