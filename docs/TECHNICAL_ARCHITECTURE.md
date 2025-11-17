# 🏗️ Documentación Técnica - DevX Sandbox System

## 📐 Diagrama de Arquitectura del Sistema

```mermaid
graph TB
    subgraph "DevX Sandbox Environment"
        subgraph "Local Filesystem"
            SANDBOX[DevX-Terraform-Sandbox/]
            LOCAL[local-artifacts/]
            TEST[test-artifacts/]
            REPOS[repos/]
        end
        
        subgraph "Tools & Scripts"
            SELECTOR[artifact-selector.sh]
            CLONER[clone-artifact-from-github.sh]
            TESTER[test-review-artifact.sh]
        end
        
        subgraph "Source Repositories"
            GITHUB[GitHub Repositories]
            INVENTORY[nx-artifacts-inventory]
            ENVIRON[nx-bolt-environment-*]
        end
    end
    
    subgraph "External Systems"
        GITHUB_API[GitHub API]
        USER[DevX Developer]
    end
    
    USER -->|1. Select/Clone| SANDBOX
    USER -->|2. Clone from GitHub| GITHUB
    GITHUB -->|3. Download| GITHUB_API
    
    SELECTOR -->|Analyze| INVENTORY
    SELECTOR -->|Analyze| ENVIRON
    
    CLONER -->|Clone repo| GITHUB
    CLONER -->|Copy to| LOCAL
    CLONER -->|Generate| TEST
    
    TESTER -->|Review artifacts| LOCAL
    TESTER -->|Review artifacts| TEST
    
    SANDBOX <-->|Simulate| INVENTORY
    SANDBOX <-->|Simulate| ENVIRON
    
    style SANDBOX fill:#e1f5fe
    style LOCAL fill:#f3e5f5
    style TEST fill:#fff3e0
    style SELECTOR fill:#e8f5e8
    style CLONER fill:#e8f5e8
    style TESTER fill:#e8f5e8
```

## 🔄 Diagrama de Flujo de Trabajo

```mermaid
graph LR
    START([Start Development]) --> CHOOSE{Choose Approach}
    
    CHOOSE -->|Option A| EXISTING[Use Existing Artifacts]
    CHOOSE -->|Option B| CLONE_REAL[Clone Real Repository]
    
    EXISTING --> SELECT[Run artifact-selector.sh]
    SELECT --> TEST1[Run test-review-artifact.sh]
    TEST1 --> ITERATE1[Iterate & Modify]
    ITERATE1 --> REVIEW1{Working?}
    
    CLONE_REAL --> VALIDATE[Validate Repository]
    VALIDATE --> CLONE[Run clone-artifact-from-github.sh]
    CLONE --> PREPARE[Prepare for Testing]
    PREPARE --> TEST2[Run test-review-artifact.sh]
    TEST2 --> ITERATE2[Iterate & Modify]
    ITERATE2 --> REVIEW2{Working?}
    
    REVIEW1 -->|Yes| CLEANUP1[Clean Changes]
    REVIEW1 -->|No| ITERATE1
    REVIEW2 -->|Yes| CLEANUP2[Push to Real Repo]
    REVIEW2 -->|No| ITERATE2
    
    CLEANUP1 --> COMPLETE([Testing Complete])
    CLEANUP2 --> COMPLETE
    
    style START fill:#4caf50,color:#fff
    style COMPLETE fill:#4caf50,color:#fff
    style CHOOSE fill:#ff9800,color:#fff
    style VALIDATE fill:#2196f3,color:#fff
```

## 📁 Estructura Detallada del Sandbox

```
DevX-Terraform-Sandbox/
├── 📂 repos/                              # Simulated Repositories
│   ├── 📂 nx-artifacts-inventory/         # Artifact Registry
│   │   └── 📂 nx-artifacts/              # Real Artifact Definitions
│   │       ├── 📂 bff/                   # BFF Layer Artifacts
│   │       │   ├── 📂 nx-bff-web-offer-seat-dev1/
│   │       │   │   └── 📄 nx-app-inventory.yaml
│   │       │   ├── 📂 nx-bff-web-offer-seat-prod1/
│   │       │   ├── 📂 nx-bff-web-offer-seat-sit1/
│   │       │   ├── 📂 nx-bff-web-offer-seat-uat1/
│   │       │   └── 📂 nx-bff-web-payment-dev1/
│   │       ├── 📂 ch/                    # CH Layer Artifacts
│   │       ├── 📂 tc/                    # TC Layer Artifacts
│   │       └── 📂 al/                    # AL Layer Artifacts
│   └── 📂 nx-bolt-environment-*/          # Environment Simulations
│       ├── 📂 nx-bolt-environment-dev1/
│       │   ├── 📂 bc/
│       │   │   └── 📂 nx-bc-test-service/
│       │   │       ├── 📄 Chart.yaml
│       │   │       └── 📄 values.yaml
│       │   └── 📂 bff/
│       └── 📂 nx-bolt-environment-prod1/
│
├── 📂 local-artifacts/                    # Cloned Real Repositories
│   ├── 📂 nx-tc-order-creator/           # Real artifact repository
│   │   ├── 📄 Chart.yaml
│   │   ├── 📄 values.yaml
│   │   └── 📄 README.md
│   └── 📂 nx-ch-web-checkout/
│
├── 📂 test-artifacts/                     # Prepared for Testing
│   ├── 📂 nx-tc-order-creator/
│   │   ├── 📄 nx-app-inventory.yaml      # Generated test inventory
│   │   ├── 📄 Chart.yaml
│   │   └── 📄 values.yaml
│   └── 📂 nx-bff-web-offer-seat/         # Existing artifact copy
│
└── 🔧 Scripts/
    ├── 🔄 artifact-selector.sh            # Interactive artifact browser
    ├── 📦 clone-artifact-from-github.sh   # GitHub repository cloner
    ├── 🧪 test-review-artifact.sh         # Review artifact command test
    └── 📚 Documentation/
        ├── 📖 README.md
        ├── 🔧 QUICK_START.md
        ├── 📚 TECHNICAL_REFERENCE.md
        └── ❓ TROUBLESHOOTING.md
```

## 🎯 Comandos DevX Soportados

### `/review-artifact` ✅ Implementado
```bash
./test-review-artifact.sh --artifact <name> --environment <env> --depth <level>
```

**Funcionalidades:**
- ✅ Identificación de artifacts por layer
- ✅ Detección de ambientes disponibles  
- ✅ Análisis de archivos de inventory
- ✅ Verificación de estado de componentes
- ✅ Cálculo de health score
- ✅ Generación de reportes detallados

### `/debug-artifact` 🚧 Disponible para Implementar
```bash
# Planned functionality based on original script
./debug-artifact.sh --artifact <name> --environment <env> --mode <mode> --depth <level>
```

**Funcionalidades Planificadas:**
- 🚧 Diagnóstico completo (30+ checks)
- 🚧 Análisis de infraestructura
- 🚧 Verificación de dependencias
- 🚧 Generación de logs detallados
- 🚧 Recomendaciones de troubleshooting

## 🔧 Herramientas de Desarrollo

### 1. Artifact Selector
```bash
./artifact-selector.sh
```
**Características:**
- 📋 Lista interactiva de artifacts disponibles
- 🔍 Búsqueda en inventory y environments
- 🧪 Opción de ejecutar tests directamente
- 📁 Preparación de artifacts para testing local

### 2. GitHub Repository Cloner
```bash
./clone-artifact-from-github.sh <organization> <artifact-name>
```
**Características:**
- 🔄 Clonación segura desde GitHub
- ✅ Validación de repositorios
- 📝 Generación automática de inventory de testing
- 🗂️ Preparación de archivos relevantes

### 3. Review Artifact Tester
```bash
./test-review-artifact.sh --artifact <artifact-name>
```
**Características:**
- 🔍 Análisis completo de artifacts
- 📊 Reportes de salud y estado
- ⚠️ Detección de problemas pendientes
- 💡 Recomendaciones automáticas

## 🔄 Workflows de Testing

### Workflow A: Testing con Artifacts Existentes
```mermaid
graph TD
    A[Start] --> B[Run artifact-selector.sh]
    B --> C[Choose artifact from list]
    C --> D[Review artifact details]
    D --> E[Test review-artifact command]
    E --> F[Analyze results]
    F --> G{Issues found?}
    G -->|Yes| H[Modify CLI code]
    H --> E
    G -->|No| I[Continue to next test]
    I --> J[Complete testing]
```

### Workflow B: Testing con Repositorios Reales
```mermaid
graph TD
    A[Start] --> B[Validate GitHub repository]
    B --> C[Run clone-artifact-from-github.sh]
    C --> D[Repository cloned to local-artifacts/]
    D --> E[Generate test inventory]
    E --> F[Run test-review-artifact.sh]
    F --> G[Iterate development]
    G --> H{Working correctly?}
    H -->|No| I[Modify and retest]
    H -->|Yes| J[Push changes to real repo]
    J --> K[Complete testing]
```

Esta documentación técnica proporciona la base arquitectónica completa del sistema DevX Sandbox.