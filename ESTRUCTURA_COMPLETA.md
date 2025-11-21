# 📁 ESTRUCTURA FINAL DEL PROYECTO

```
ProyectoFinalMatSeguros/
│
├── 📄 DOCUMENTACIÓN PRINCIPAL
│   ├── PROYECTO_FINAL.md                          # Especificaciones oficiales del proyecto
│   ├── README.md                                  # Guía de estructura y funcionamiento
│   ├── GUIA_RAPIDA.md                             # ⭐ START HERE - Checklist y resumen
│   ├── CONFIGURACION_GRUPO.md                     # Tu configuración específica (Origen=2, M)
│   ├── TABLA_REFERENCIA_INVALIDEZ_2014.md        # Cómo obtener tabla de referencia
│   └── VALIDACION_INICIAL.R                       # ⭐ Script para verificar datos
│
├── 📂 01_construccion_tabla_mortalidad/            # MÓDULO 1 (60% ponderación)
│   ├── 01_carga_y_exploracion.R
│   │   ├── Carga Base_act.RData
│   │   ├── Filtra: Origen=2, TM_SEXO="M"
│   │   └── → data/datos_seleccionados.RData
│   │
│   ├── 02_periodo_analisis.R
│   │   ├── Filtra período: 01/01/2000 - 31/12/2012
│   │   ├── Genera cuadro descriptivo
│   │   └── → resultados/cuadro_descriptivo.csv
│   │
│   ├── 03_graduacion.R
│   │   ├── Método 1: Spline Cúbica
│   │   ├── Método 2: Gompertz
│   │   ├── Método 3: Polinomio Grado 3
│   │   └── → resultados/tasas_graduadas.csv
│   │
│   ├── 04_bondad_ajuste.R
│   │   ├── Test 1: Chi-Cuadrado (χ²)
│   │   ├── Test 2: Kolmogorov-Smirnov (KS)
│   │   ├── Test 3: Rachas
│   │   ├── Test 4: Signos
│   │   ├── → resultados/resumen_bondad_ajuste.csv
│   │   └── → resultados/comparacion_metodos.png
│   │
│   └── 05_extrapolacion_tabla_completa.R
│       ├── Cabeza: Edades 10 a X
│       ├── Núcleo: Datos graduados
│       ├── Cola: Edades X a 109
│       ├── Tabla vida: l(x), d(x), e(x)
│       ├── Radix: 10.000.000
│       └── → resultados/tabla_vida_completa.csv
│
├── 📂 02_valores_conmutacion/                      # MÓDULO 2 (10% ponderación)
│   └── 01_conmutaciones.R
│       ├── Calcula D(x), N(x), C(x), M(x), R(x)
│       ├── Tasa técnica: 5%
│       └── → resultados/tabla_conmutaciones.csv
│
├── 📂 03_valores_actuales/                         # MÓDULO 3 (30% ponderación)
│   └── 01_rentas_seguros.R
│       ├── Renta 1: Dotal Puro (Edad 70)
│       │   → resultados/dotal_puro.csv
│       ├── Renta 2: Vitalicia Vencida
│       │   → resultados/renta_vitalicia_vencida.csv
│       ├── Renta 3: Diferida Anticipada (desde 75)
│       │   → resultados/renta_diferida_anticipada.csv
│       ├── Renta 4: Temporal Vencida (hasta 80)
│       │   → resultados/renta_temporal_vencida.csv
│       └── Renta 5: Temporal Diferida Anticipada (hasta 70)
│           → resultados/renta_temporal_diferida_anticipada.csv
│
├── 📂 data/                                        # CARPETA DE DATOS
│   ├── Base_act.RData                             # ⭐ COPIAR AQUÍ tu archivo
│   ├── datos_seleccionados.RData                  # Generado por script 01
│   ├── datos_periodo_analisis.RData               # Generado por script 02
│   ├── modelos_graduacion.RData                   # Generado por script 03
│   ├── tabla_vida_completa.RData                  # Generado por script 05
│   └── tabla_conmutaciones.RData                  # Generado por script conmutaciones
│
└── 📂 resultados/                                  # CARPETA DE OUTPUTS
    ├── 📋 TABLAS DESCRIPTIVAS
    │   ├── cuadro_descriptivo.csv                 # Registros/muertes original vs análisis
    │   ├── tabla_edad.csv                         # Distribución por edad
    │   ├── resumen_tabla_vida.csv                 # Resumen ejecutivo
    │
    ├── 📋 GRADUACIÓN Y AJUSTE
    │   ├── tasas_graduadas.csv                    # Tasas: bruto, spline, gompertz, poly
    │   ├── resumen_bondad_ajuste.csv              # Tests: Chi², KS, Rachas, Signos
    │   └── comparacion_metodos.png                # Gráfico visual de métodos
    │
    ├── 📋 TABLA DE VIDA (PRINCIPAL)
    │   └── tabla_vida_completa.csv                # ⭐ ENTREGABLE CLAVE
    │       Columnas: edad, qx, px, lx, dx, Lx, Tx, ex
    │
    ├── 📋 CONMUTACIONES
    │   └── tabla_conmutaciones.csv                # ⭐ D(x), N(x), C(x), M(x), R(x)
    │
    └── 📋 VALORES ACTUALES (COMPARATIVOS)
        ├── dotal_puro.csv                         # Edad final = 70
        ├── renta_vitalicia_vencida.csv            # Pago vencido
        ├── renta_diferida_anticipada.csv          # Desde edad 75, anticipada
        ├── renta_temporal_vencida.csv             # Hasta edad 80, vencida
        ├── renta_temporal_diferida_anticipada.csv # Hasta edad 70, anticipada
        └── tabla_referencia_invalidez_2014_m.csv  # ⭐ Descargar y completar
            (Crear después de obtener tabla oficial)
```

---

## 🎯 PUNTOS DE PARTIDA

### PRIMERO (5 minutos)
Leer: **GUIA_RAPIDA.md**

### SEGUNDO (10 minutos)
Revisar: **CONFIGURACION_GRUPO.md**

### TERCERO (necesario)
Copiar: `Base_act.RData` a carpeta `data/`

### CUARTO (diagnóstico)
Ejecutar: `source("VALIDACION_INICIAL.R")`

### QUINTO (producción)
Ejecutar scripts en orden:
1. `01_construccion_tabla_mortalidad/01_carga_y_exploracion.R`
2. `01_construccion_tabla_mortalidad/02_periodo_analisis.R`
3. `01_construccion_tabla_mortalidad/03_graduacion.R`
4. `01_construccion_tabla_mortalidad/04_bondad_ajuste.R`
5. `01_construccion_tabla_mortalidad/05_extrapolacion_tabla_completa.R`
6. `02_valores_conmutacion/01_conmutaciones.R`
7. `03_valores_actuales/01_rentas_seguros.R`

---

## 📊 OUTPUTS ESPERADOS

### Tablas CSV (7 principales)

| Nombre | Descripción | Filas aprox. | Columnas |
|--------|-------------|------------|----------|
| `cuadro_descriptivo.csv` | Stats registros/muertes | 8 | 2 |
| `tasas_graduadas.csv` | Tasas por método | 50-80 | 6 |
| `resumen_bondad_ajuste.csv` | Tests de ajuste | 3 | 9 |
| `tabla_vida_completa.csv` | ⭐ Tabla final | 100 | 8 |
| `tabla_conmutaciones.csv` | ⭐ Conmutaciones | 100 | 8 |
| `dotal_puro.csv` | Comparativo renta 1 | 3 | 4 |
| `renta_vitalicia_vencida.csv` | Comparativo renta 2 | 3 | 4 |
| `renta_diferida_anticipada.csv` | Comparativo renta 3 | 3 | 4 |
| `renta_temporal_vencida.csv` | Comparativo renta 4 | 3 | 4 |
| `renta_temporal_diferida_anticipada.csv` | Comparativo renta 5 | 3 | 4 |

### Gráficos (1)
- `comparacion_metodos.png` - Visual de 3 métodos de graduación

### Archivos RData (6)
Para trabajo interno entre scripts

---

## 📄 TU ASIGNACIÓN (RESUMEN)

```
═══════════════════════════════════════════════════════════════
GRUPO: Matemáticas Actuariales - EYP2605
SEMESTRE: 2025-01 (Noviembre 2025)

CRITERIOS:
  ✓ Base de datos: Base_act.RData
  ✓ Origen: 2
  ✓ TM_SEXO: M (Masculino)
  ✓ Tabla Referencia: INVALIDEZ 2014 - Masculino
  
PERÍODO ANÁLISIS:
  ✓ Desde: 01/01/2000
  ✓ Hasta: 31/12/2012
  ✓ Duración: 13 años
  
PARÁMETROS TÉCNICOS:
  ✓ Tasa de interés: 5% anual
  ✓ Radix (l(x) inicial): 10.000.000
  ✓ Rango de edades tabla: 10 a 109 años
  
PONDERACIÓN:
  ✓ Módulo 1 (Tabla): 60%
  ✓ Módulo 2 (Conmutaciones): 10%
  ✓ Módulo 3 (Valores Actuales): 30%
  
ENTREGA:
  ✓ Fecha: Lunes 08 de diciembre
  ✓ Hora: Antes de las 22:00 hrs
═══════════════════════════════════════════════════════════════
```

---

## 🔍 VERIFICACIÓN RÁPIDA

Antes de entregar, verifica que existan estos archivos en `resultados/`:

```
resultados/
├── cuadro_descriptivo.csv                    ✓ (MÓDULO 1)
├── tasas_graduadas.csv                       ✓ (MÓDULO 1)
├── resumen_bondad_ajuste.csv                 ✓ (MÓDULO 1)
├── tabla_vida_completa.csv                   ✓ (MÓDULO 1)
├── comparacion_metodos.png                   ✓ (MÓDULO 1)
├── tabla_conmutaciones.csv                   ✓ (MÓDULO 2)
├── dotal_puro.csv                            ✓ (MÓDULO 3)
├── renta_vitalicia_vencida.csv               ✓ (MÓDULO 3)
├── renta_diferida_anticipada.csv             ✓ (MÓDULO 3)
├── renta_temporal_vencida.csv                ✓ (MÓDULO 3)
├── renta_temporal_diferida_anticipada.csv    ✓ (MÓDULO 3)
└── tabla_referencia_invalidez_2014_m.csv     ✓ (MÓDULO 3 - obtener)
```

Y en el **informe final** debe incluir:
- Justificación de edades límites
- Método de graduación seleccionado
- Resultados 4 tests de bondad
- Método extrapolación utilizado
- Fórmulas de cada renta
- Análisis de diferenciales

---

**Creado**: Noviembre 21, 2025  
**Para**: Tu grupo - EYP2605 Matemáticas Actuariales  
**Asignación**: Origen=2, TM_SEXO=M, INVALIDEZ 2014-M
