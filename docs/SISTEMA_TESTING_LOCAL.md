# 🔧 DevX Sandbox - Sistema Completo de Testing Local

## 📋 Resumen del Sistema

Has creado un ambiente de desarrollo completo para probar comandos DevX sin afectar repositorios reales.

## 🛠️ Herramientas Disponibles

### 1. **Selector de Artifacts Local**
```bash
./artifact-selector.sh
```
- Menú interactivo para seleccionar artifacts del sandbox
- Lista artifacts disponibles en inventory y environments
- Permite ejecutar tests y preparar artifacts para testing

### 2. **Test del Comando `/review-artifact`**
```bash
./test-review-artifact.sh --artifact <nombre-artifact>
```
- Simula el comando DevX interno
- Analiza artifacts con datos reales del sandbox
- Genera reportes de estado de salud

### 3. **Clonador de Repositorios Reales**
```bash
./clone-artifact-from-github.sh <org> <artifact>
```
- Clona repos reales de GitHub para testing local
- Prepara artifacts con archivos de inventory
- Permite modificar y probar sin afectar repos reales

## 🎯 Flujo de Trabajo Recomendado

### Opción A: Testing con Artifacts Existentes
```bash
# 1. Seleccionar artifact del sandbox
./artifact-selector.sh

# 2. Ejecutar review-artifact
./test-review-artifact.sh --artifact web-offer-seat

# 3. Modificar y probar código
# 4. Iterar hasta que funcione
```

### Opción B: Testing con Repos Reales
```bash
# 1. Clonar repo real
./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator

# 2. Entrar al directorio clonado
cd local-artifacts/nx-tc-order-creator

# 3. Probar modificaciones del CLI
# 4. Usar review-artifact con el artifact clonado

# 5. Volver a clonar cuando necesites estado limpio
git clean -fdx  # Limpiar cambios
```

## 🔧 Comandos DevX Disponibles para Testing

### `/review-artifact`
- **Status**: ✅ Funcional
- **Uso**: Análisis rápido para soporte
- **Flags**: `--artifact`, `--environment`, `--depth`
- **Test**: `./test-review-artifact.sh --artifact web-offer-seat`

### `/debug-artifact`
- **Status**: 🚧 Disponible para implementar
- **Descripción**: Diagnóstico completo (30+ checks)
- **Flags**: `--artifact`, `--environment`, `--mode`, `--depth`

## 📁 Estructura del Sandbox

```
DevX-Terraform-Sandbox/
├── repos/                          # Repos simulados
│   ├── nx-artifacts-inventory/     # Artifacts inventory
│   └── nx-bolt-environment-*/      # Environments simulados
├── local-artifacts/                # Repos clonados de GitHub
├── test-artifacts/                 # Preparados para testing
└── *.sh                           # Herramientas de testing
```

## 🚀 Beneficios del Sistema

1. **Desarrollo Seguro**: Modificar y probar sin afectar repos reales
2. **Iteración Rápida**: Testing local inmediato
3. **Datos Reales**: Usar estructura y archivos reales
4. **Comandos DevX**: Probar herramientas internas
5. **Múltiples Scenarios**: Probar diferentes artifacts y environments

## 📝 Próximos Pasos

1. **Probar el sistema**: Ejecuta `./artifact-selector.sh`
2. **Clonar un repo real**: `./clone-artifact-from-github.sh BritishAirways-Nexus nx-tc-order-creator`
3. **Implementar `/debug-artifact`**: Basado en el script original
4. **Agregar más comandos**: Integrar otros comandos DevX al CLI

## ✅ Estado Actual

- **Sandbox Setup**: ✅ Completo
- **Artifact Selector**: ✅ Funcional  
- **Review-Artifact Test**: ✅ Funcional
- **GitHub Cloner**: ✅ Funcional
- **Development Environment**: ✅ Listo para usar

¡Ya puedes desarrollar y probar comandos DevX de forma local sin riesgos!