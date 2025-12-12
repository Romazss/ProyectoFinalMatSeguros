# 🔄 Sistema de Análisis Multi-Escenario

## 📖 Descripción

Sistema avanzado para ejecutar múltiples configuraciones del análisis de mortalidad y comparar resultados automáticamente.

## 🎯 ¿Qué es un Escenario?

Un **escenario** es una configuración específica de parámetros que permite probar diferentes:
- Rangos de edad para graduación
- Niveles de suavizado (parámetro k del GAM)
- Criterios de filtrado (mínimo de muertes/exposición)

Esto permite **comparar** diferentes métodos y **validar** la robustez de los resultados.

---

## 🚀 Uso Rápido

### Opción 1: Ejecutar Todos los Escenarios

```r
source("R/main_escenarios.R")
# Cambiar MODO = 1 en el script
```

Esto ejecutará 5 escenarios predefinidos y generará comparaciones automáticas.

### Opción 2: Ejecutar un Escenario Específico

```r
source("R/00_gestor_escenarios.R")
ejecutar_escenario("base")
```

### Opción 3: Comparar Escenarios Existentes

```r
source("R/07_comparacion_escenarios.R")
```

---

## 📊 Escenarios Predefinidos

### 1. **Base** (Configuración por defecto)
- Edades: 20-84 años
- GAM k: 10
- Mín. muertes: 1
- Mín. exposición: 1

### 2. **Suavizado** (Mayor suavidad)
- Edades: 20-84 años
- GAM k: **15** ← Mayor suavizado
- Mín. muertes: 1
- Mín. exposición: 1

### 3. **Detallado** (Menos suavizado)
- Edades: 20-84 años
- GAM k: **8** ← Menor suavizado, más detalle
- Mín. muertes: 1
- Mín. exposición: 1

### 4. **Rango Reducido** (Más conservador)
- Edades: **25-80** años ← Rango más estrecho
- GAM k: 10
- Mín. muertes: **2** ← Más restrictivo
- Mín. exposición: **5** ← Más restrictivo

### 5. **Rango Ampliado** (Más datos)
- Edades: **18-90** años ← Rango más amplio
- GAM k: **12**
- Mín. muertes: 1
- Mín. exposición: 1

---

## 📁 Estructura de Resultados

```
resultados/
├── escenario_Base/
│   ├── 02_tasas_crudas.csv
│   ├── 03_tests_bondad_ajuste.csv
│   ├── 04_tabla_mortalidad_completa.csv
│   ├── 05_conmutacion_obtenida.csv
│   ├── 06_resumen_valores_actuales.csv
│   ├── graficos/
│   └── data/
├── escenario_Suavizado/
│   └── (misma estructura)
├── escenario_Detallado/
│   └── (misma estructura)
├── 07_comparacion_qx_todos.png          ← Compara todas las curvas qx
├── 07_comparacion_qx_bandas.png         ← Rango min-max de qx
├── 07_comparacion_ex_todos.png          ← Compara esperanzas de vida
├── 07_comparacion_tests_bondad.csv      ← Tests para todos
├── 07_comparacion_valores_actuales.csv  ← Valores actuales comparados
├── 07_evaluacion_escenarios.csv         ← ★ RANKING DE ESCENARIOS
└── 07_resumen_diferencias.csv           ← Diferencias entre pares
```

---

## 📈 Archivos Clave de Comparación

### 🏆 07_evaluacion_escenarios.csv
Ranking de escenarios según bondad de ajuste.

**Columnas:**
- `Escenario` - Nombre del escenario
- `n_tests_buenos` - Cuántos tests pasan (de 4)
- `valor_p_promedio` - P-valor promedio
- Ordenado por mejor ajuste

### 📊 07_comparacion_qx_todos.png
Gráfico con todas las curvas qx superpuestas.
- Permite ver diferencias visuales entre configuraciones
- Identifica si hay patrones consistentes

### 📉 07_comparacion_qx_bandas.png
Banda de confianza entre todos los escenarios.
- Área sombreada: rango mín-máx
- Línea: promedio
- Útil para ver sensibilidad

### 💰 07_comparacion_valores_actuales.csv
Compara rentas y seguros entre escenarios.
- Mismo formato que valores actuales individuales
- Una columna por escenario
- Identifica diferencias en productos actuariales

---

## 🎮 Modos de Ejecución (main_escenarios.R)

### MODO = 1: Ejecutar Todos los Escenarios
```r
MODO <- 1
source("R/main_escenarios.R")
```
- Ejecuta los 5 escenarios predefinidos
- Genera todas las comparaciones
- **Tiempo estimado:** 5-15 minutos

### MODO = 2: Solo Escenario Base
```r
MODO <- 2
source("R/main_escenarios.R")
```
- Ejecuta solo configuración base
- Equivalente al `main.R` original
- **Tiempo estimado:** 1-3 minutos

### MODO = 3: Escenarios Seleccionados
```r
MODO <- 3
# Editar ESCENARIOS_A_EJECUTAR en el script
source("R/main_escenarios.R")
```
- Define cuáles escenarios ejecutar
- Útil para probar solo algunos

### MODO = 4: Solo Comparar Existentes
```r
MODO <- 4
source("R/main_escenarios.R")
```
- No ejecuta análisis, solo compara
- Requiere que ya existan resultados
- **Tiempo estimado:** < 1 minuto

---

## 🔧 Crear Escenario Personalizado

Editar `R/00_gestor_escenarios.R`:

```r
ESCENARIOS <- list(
  # ... escenarios existentes ...
  
  mi_escenario = list(
    nombre = "Mi_Escenario",
    descripcion = "Descripción de mi configuración",
    EDAD_MIN_GRADUACION = 22,
    EDAD_MAX_GRADUACION = 82,
    GAM_K = 11,
    MIN_MUERTES = 1,
    MIN_EXPOSICION = 2
  )
)
```

Luego ejecutar:
```r
source("R/00_gestor_escenarios.R")
ejecutar_escenario("mi_escenario")
```

---

## 📊 Interpretación de Comparaciones

### ¿Qué buscar en los gráficos?

1. **Curvas muy diferentes** → Alta sensibilidad a parámetros
2. **Curvas similares** → Resultados robustos
3. **Banda estrecha** → Poca variación entre métodos
4. **Banda ancha** → Mayor incertidumbre

### ¿Cómo elegir el mejor escenario?

1. **Tests de bondad:** Mayor número de tests con p > 0.05
2. **Valores actuales:** Comparar con tabla de referencia
3. **Visual:** Curvas suaves sin irregularidades
4. **Rango:** Suficientes edades pero sin ruido

---

## 🔍 Ejemplo de Workflow Completo

```r
# 1. Ejecutar todos los escenarios
source("R/main_escenarios.R")  # con MODO = 1

# 2. Revisar ranking
ranking <- read.csv("resultados/07_evaluacion_escenarios.csv")
print(ranking)

# 3. Ver comparación visual
# Abrir: imagenes/07_comparacion_qx_todos.png

# 4. Seleccionar mejor escenario (ejemplo: "Suavizado")
mejor <- "Suavizado"

# 5. Revisar resultados detallados del mejor
tabla_final <- read.csv(
  paste0("resultados/escenario_", mejor, "/04_tabla_mortalidad_completa.csv")
)

# 6. Usar esa tabla para el informe final
```

---

## 🎯 Casos de Uso

### Caso 1: Validar Robustez
**Objetivo:** ¿Los resultados son sensibles a los parámetros?

```r
# Ejecutar varios escenarios
source("R/main_escenarios.R")  # MODO = 1

# Revisar diferencias
dif <- read.csv("resultados/07_resumen_diferencias.csv")
print(dif)

# Si diferencias < 5%, los resultados son robustos
```

### Caso 2: Optimizar Configuración
**Objetivo:** Encontrar la mejor combinación de parámetros

```r
# Ejecutar todos
source("R/main_escenarios.R")  # MODO = 1

# Ver evaluación
eval <- read.csv("resultados/07_evaluacion_escenarios.csv")
print(eval[1, ])  # Mejor escenario
```

### Caso 3: Análisis de Sensibilidad
**Objetivo:** ¿Cómo afecta k a los resultados?

```r
# Comparar: base (k=10), suave (k=15), detallado (k=8)
source("R/00_gestor_escenarios.R")
ejecutar_escenario("base")
ejecutar_escenario("suave")
ejecutar_escenario("detallado")

source("R/07_comparacion_escenarios.R")
# Ver: imagenes/07_comparacion_qx_todos.png
```

---

## ⚠️ Consideraciones

### Tiempo de Ejecución
- **1 escenario:** ~2-3 minutos
- **5 escenarios:** ~10-15 minutos
- **Solo comparar:** ~30 segundos

### Espacio en Disco
Cada escenario genera ~5-10 MB de resultados.

### Memoria RAM
Todos los escenarios pueden ejecutarse con 4 GB de RAM.

---

## 🐛 Troubleshooting

### Error: "Escenario no encontrado"
**Solución:** Verificar nombre exacto en `ESCENARIOS` list

### Error: "No se encontraron carpetas de escenarios"
**Solución:** Ejecutar al menos un escenario antes de comparar

### Gráficos vacíos
**Solución:** Verificar que los escenarios tengan datos en edades comunes

---

## 📚 Archivos del Sistema

```
R/
├── 00_gestor_escenarios.R      # ⚙️ Definición y ejecución de escenarios
├── 07_comparacion_escenarios.R # 📊 Análisis comparativo
├── main_escenarios.R           # 🎯 Script maestro multi-escenario
└── ESCENARIOS_README.md        # 📖 Esta documentación
```

---

## 🎓 Para el Informe

### Sección Recomendada: "Análisis de Sensibilidad"

Incluir:
1. Tabla con configuraciones probadas
2. Gráfico comparativo de qx
3. Tabla de tests de bondad por escenario
4. Justificación del escenario seleccionado

### Elementos a Incluir:
- `07_comparacion_qx_todos.png` → Figura comparativa
- `07_evaluacion_escenarios.csv` → Tabla de evaluación
- Resultados del escenario elegido → Tablas principales

---

## 💡 Tips Avanzados

### Comparar solo 2 escenarios
```r
# Editar main_escenarios.R
MODO <- 3
ESCENARIOS_A_EJECUTAR <- c("base", "suave")
```

### Exportar comparación a Excel
```r
library(openxlsx)
wb <- createWorkbook()
addWorksheet(wb, "Evaluacion")
writeData(wb, "Evaluacion", 
          read.csv("resultados/07_evaluacion_escenarios.csv"))
saveWorkbook(wb, "Comparacion_Escenarios.xlsx", overwrite = TRUE)
```

### Graficar diferencias específicas
```r
# Cargar dos tablas
t1 <- read.csv("resultados/escenario_Base/04_tabla_mortalidad_completa.csv")
t2 <- read.csv("resultados/escenario_Suavizado/04_tabla_mortalidad_completa.csv")

# Calcular diferencia
dif <- (t2$qx - t1$qx) / t1$qx * 100

# Graficar
plot(t1$Edad, dif, type = "l", 
     main = "Diferencia % entre Base y Suavizado",
     xlab = "Edad", ylab = "Diferencia %")
abline(h = 0, col = "red", lty = 2)
```

---

**¡Sistema de multi-escenario listo para análisis comparativos! 🚀**
