# 🏗️ Diseño CLI DevX - Migración desde Scripts Bash

## 📋 Estructura de Comandos Propuesta

```
tf_nx
├── artifact          (ya existe)
│   ├── env-var       (ya existe)
│   ├── resource      (ya existe)
│   └── review        (NUEVO) - Review artifact command
├── devx              (NUEVO) - DevX Internal Tools
│   ├── review        (NUEVO) - /review-artifact
│   ├── debug         (NUEVO) - /debug-artifact
│   └── clone         (NUEVO) - Clone from GitHub
└── inventory         (ya existe)

nx-sandbox           (CLI SEPARADO) - Sandbox Management
├── list             - Listar artifacts disponibles
├── status           - Estado del sandbox
├── clean            - Limpiar archivos temporales
└── clone            - Clonar repos para testing
```

## 🎯 Comandos Nuevos a Implementar

### 1. `tf_nx devx review`
**Propósito**: Review artifact para soporte y troubleshooting

```bash
tf_nx devx review --artifact <name> [--environment <env>] [--depth <level>] [--output <file>]
```

**Flags**:
- `--artifact, -a`: Nombre del artifact (requerido)
- `--environment, -e`: Ambiente específico (opcional, default: all)
- `--depth, -d`: Profundidad del análisis (standard|deep, default: standard)
- `--output, -o`: Archivo de salida (opcional, default: stdout)

### 2. `tf_nx devx debug`
**Propósito**: Debug completo para troubleshooting avanzado

```bash
tf_nx devx debug --artifact <name> [--environment <env>] [--mode <mode>] [--depth <level>]
```

**Flags**:
- `--artifact, -a`: Nombre del artifact (requerido)
- `--environment, -e`: Ambiente específico (opcional)
- `--mode, -m`: Modo de debug (quick|full|comprehensive, default: full)
- `--depth, -d`: Profundidad del análisis

### 3. `tf_nx devx clone`
**Propósito**: Clonar repositorios reales de GitHub para testing

```bash
tf_nx devx clone <organization> <repository> [--target-dir <dir>] [--prepare-testing]
```

**Flags**:
- `<organization>`: Organización de GitHub (positional arg)
- `<repository>`: Nombre del repositorio (positional arg)
- `--target-dir, -t`: Directorio destino (opcional)
- `--prepare-testing, -p`: Preparar automáticamente para testing

### 4. `nx-sandbox` (CLI Separado)
**Propósito**: Gestión completa del ambiente sandbox como herramienta independiente

```bash
nx-sandbox list [--from-inventory|--from-environments]  # Listar artifacts disponibles
nx-sandbox status                                       # Estado del sandbox
nx-sandbox clean                                        # Limpiar archivos temporales
nx-sandbox clone <org> <repo> [--prepare-testing]       # Clonar repos para testing
```

## 🏗️ Estructura de Archivos Propuesta

### CLI DevX (tf_nx devx)
```
cli-tester/
├── cmd/
│   ├── devx/                    (NUEVO)
│   │   ├── devx.go             (comando raíz de devx)
│   │   ├── review.go           (comando review-artifact)
│   │   ├── debug.go            (comando debug-artifact)
│   │   └── clone.go            (comando clone-artifact)
│   ├── artifact/
│   │   └── review.go           (subcomando de artifact review)
│   └── utils/
│       ├── devx/               (utilidades de devx)
│       │   ├── artifact.go     (análisis de artifacts)
│       │   ├── github.go       (clonación de repos)
│       │   └── inventory.go    (procesamiento de inventory)
│       └── yaml/               (procesamiento de YAML)
└── interfaces/
    ├── devx/                   (interfaces de devx)
    │   ├── artifact.go         (interface para artifacts)
    │   └── github.go           (interface para GitHub)
```

### CLI Sandbox Independiente (nx-sandbox)
```
nx-sandbox/                     (PROYECTO SEPARADO)
├── main.go
├── cmd/
│   ├── root.go                 (comando raíz)
│   ├── list.go                 (comando list)
│   ├── status.go               (comando status)
│   ├── clean.go                (comando clean)
│   └── clone.go                (comando clone)
├── internal/
│   ├── sandbox/
│   │   ├── manager.go          (lógica de gestión)
│   │   ├── lister.go           (lógica de listado)
│   │   ├── cleaner.go          (lógica de limpieza)
│   │   └── cloner.go           (lógica de clonación)
│   └── models/
│       ├── artifact.go         (estructuras de datos)
│       └── environment.go      (modelos de ambiente)
├── go.mod
└── go.sum
```

## 🔧 Funcionalidades por Comando

### Review Artifact
```go
// Funcionalidades implementadas:
- Identificación de artifacts por layer
- Detección de ambientes disponibles
- Análisis de archivos de inventory
- Verificación de estado de componentes
- Cálculo de health score
- Generación de reportes detallados
- Manejo de errores y casos edge
```

### Debug Artifact
```go
// Funcionalidades planificadas:
- Diagnóstico completo (30+ checks)
- Análisis de infraestructura
- Verificación de dependencias
- Generación de logs detallados
- Recomendaciones de troubleshooting
```

### Clone Repository
```go
// Funcionalidades:
- Validación de repositorios en GitHub
- Clonación segura con rate limiting
- Generación automática de inventory de testing
- Preparación de archivos relevantes
- Manejo de errores de red
```

### Sandbox Management
```go
// Funcionalidades:
- Listado interactivo de artifacts
- Búsqueda en inventory y environments
- Gestión de estado del sandbox
- Limpieza automática
- Diagnóstico del ambiente
```

## 📊 Migración de Funcionalidades Bash

### Funcionalidades a Migrar:
1. **test-review-artifact.sh** → `tf_nx devx review`
2. **artifact-selector.sh** → `nx-sandbox list`
3. **clone-artifact-from-github.sh** → `nx-sandbox clone`
4. **Verificar y diagnosticar** → `nx-sandbox status`

### Ventajas de la Migración a Go:
- ✅ **Type Safety**: Tipos definidos vs strings en bash
- ✅ **Error Handling**: Manejo robusto de errores
- ✅ **Testing**: Tests unitarios automatizados
- ✅ **Performance**: Go es mucho más rápido que bash
- ✅ **Cross-platform**: Compilación para múltiples OS
- ✅ **Maintenability**: Código más fácil de mantener
- ✅ **API Integration**: Mejor integración con GitHub API
- ✅ **Concurrency**: Soporte nativo para concurrencia

## 🚀 Plan de Implementación

### Fase 1: CLI DevX (tf_nx devx)
1. Crear estructura de directorio `cmd/devx/`
2. Implementar comando `tf_nx devx`
3. Implementar `tf_nx devx review` (migrar test-review-artifact.sh)
4. Crear utilidades base en `utils/devx/`

### Fase 2: CLI Sandbox Independiente (nx-sandbox)
1. Crear proyecto Go separado `nx-sandbox/`
2. Implementar comandos base: `list`, `status`, `clean`
3. Implementar `clone` con integración GitHub
4. Crear interfaces y modelos de datos
5. Migrar funcionalidades de `artifact-selector.sh`

### Fase 3: Funcionalidades Avanzadas
1. Implementar `tf_nx devx debug` y `tf_nx devx clone`
2. Añadir tests unitarios para ambos CLIs
3. Optimización y performance
4. Documentación completa

Esta migración nos dará dos CLIs robustos, escalables y fáciles de mantener:

- **`tf_nx devx`**: Herramientas DevX para soporte y troubleshooting
- **`nx-sandbox`**: Gestión independiente del ambiente sandbox para desarrollo local

Ambos aprovechando las ventajas de Go: type safety, testing automatizado, performance y cross-platform.