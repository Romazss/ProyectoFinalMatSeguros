# 📁 Carpeta R/ - Scripts Organizados del Proyecto

## 📖 Descripción

Esta carpeta contiene todos los scripts de R organizados de forma modular y limpia para regenerar todos los resultados del Proyecto Final de Matemáticas Actuariales desde cero.

**Asignación:** Origen = 2, TM_SEXO = M (INVALIDEZ 2014 - Masculino)

---

## 🚀 Inicio Rápido

### Opción 1: Ejecución Completa (Recomendada)

```r
# Desde la raíz del proyecto
source("R/main.R")
```

Este script ejecuta automáticamente todos los módulos en orden y genera todos los resultados.

### Opción 2: Ejecución Modular

Ejecutar módulos individuales en orden:

```r
source("R/00_config.R")         # Cargar configuración
source("R/01_carga_datos.R")    # Cargar datos
source("R/02_tasas_crudas.R")   # Calcular tasas
source("R/03_graduacion.R")     # Graduar tasas
source("R/04_tabla_completa.R") # Construir tabla
source("R/05_conmutacion.R")    # Conmutaciones
source("R/06_valores_actuales.R") # Valores actuales
```

---

## 📂 Estructura de Scripts

```
R/
├── 00_config.R              # ⚙️ Configuración global y parámetros
├── 01_carga_datos.R         # 📥 Carga y preparación de datos
├── 02_tasas_crudas.R        # 📊 Cálculo de exposición y tasas brutas
├── 03_graduacion.R          # 📈 Graduación GAM y tests de bondad
├── 04_tabla_completa.R      # 📋 Extrapolación y tabla de vida completa
├── 05_conmutacion.R         # 🔢 Valores de conmutación (Dx, Nx, Cx, Mx)
├── 06_valores_actuales.R    # 💰 Cálculo de rentas y seguros
├── main.R                   # 🎯 Script maestro (ejecuta todo)
└── README.md                # 📖 Esta documentación
```

---

## 📝 Descripción de Cada Módulo

### 00_config.R - Configuración Global

**Función:** Define todos los parámetros, constantes y funciones auxiliares globales.

**Parámetros principales:**
- `ORIGEN = 2` - Filtro para datos
- `SEXO = "M"` - Sexo masculino
- `FECHA_INICIO = 2000-01-01` - Inicio del período
- `FECHA_FIN = 2012-12-31` - Fin del período
- `L0 = 10,000,000` - Radix para tabla de vida
- `I_TEC = 0.05` - Tasa de interés técnico (5%)
- `EDAD_MIN_GRADUACION = 20` - Edad mínima para graduación
- `EDAD_MAX_GRADUACION = 84` - Edad máxima para graduación
- `TABLA_REFERENCIA_QX` - Vector con tasas MI-2014

**No genera archivos** - Solo carga configuración en memoria.

---

### 01_carga_datos.R - Carga y Preparación de Datos

**Input:**
- `data/base_act.RData` (debe existir previamente)

**Proceso:**
1. Verifica existencia del archivo de datos
2. Carga y filtra por Origen=2 y Sexo=M
3. Procesa fechas de nacimiento y fallecimiento
4. Aplica ventana temporal de análisis (2000-2012)
5. Genera estadísticas descriptivas

**Output:**
- `resultados/01_cuadro_descriptivo.csv` - Resumen de registros y muertes
- `data/datos_procesados.RData` - Datos procesados en memoria

**Variables en memoria:**
- `datos_periodo` - Datos filtrados para análisis

---

### 02_tasas_crudas.R - Cálculo de Tasas Crudas

**Input:**
- `data/datos_procesados.RData` (del módulo anterior)

**Proceso:**
1. Calcula exposición al riesgo por edad
2. Expande datos a nivel edad-individuo
3. Calcula fracción de exposición en cada edad
4. Agrega muertes y exposición por edad
5. Calcula tasas crudas qx = muertes / exposición

**Output:**
- `resultados/02_tasas_crudas.csv` - Tasas por edad
- `imagenes/02_tasas_crudas.png` - Gráfico de tasas
- `data/tasas_crudas.RData` - Tasas en memoria

**Variables en memoria:**
- `tasas_crudas` - Tibble con Edad, exposicion, muertes, qx_crudo

---

### 03_graduacion.R - Graduación y Tests de Bondad

**Input:**
- `data/tasas_crudas.RData`

**Proceso:**
1. Filtra edades con suficientes datos (muertes ≥ 1, exposición ≥ 1)
2. Ajusta modelo GAM (Generalized Additive Model) con P-splines
3. Predice tasas graduadas
4. Ejecuta 4 tests de bondad de ajuste:
   - Chi-cuadrado
   - Kolmogorov-Smirnov
   - Test de Signos
   - Test de Rachas

**Output:**
- `resultados/03_datos_graduacion.csv` - Tasas crudas y graduadas
- `resultados/03_tests_bondad_ajuste.csv` - Resultados de tests
- `imagenes/03_tasas_graduadas.png` - Comparación crudas vs graduadas
- `imagenes/03_residuos_graduacion.png` - Análisis de residuos
- `data/graduacion.RData` - Datos graduados en memoria

**Variables en memoria:**
- `datos_graduacion` - Tasas con qx_graduado
- `tests_ajuste` - Resultados de tests
- `modelo_gam` - Modelo ajustado

---

### 04_tabla_completa.R - Construcción de Tabla Completa

**Input:**
- `data/graduacion.RData`

**Proceso:**
1. Ajusta modelo Gompertz-Makeham para extrapolación
2. Construye tabla de qx completa (0-109 años):
   - Edades 0-19: Tabla de referencia MI-2014
   - Edades 20-84: Valores graduados
   - Edades 85-109: Extrapolación Gompertz-Makeham
3. Calcula funciones de vida: lx, dx, px
4. Calcula esperanza de vida ex
5. Compara con tabla de referencia

**Output:**
- `resultados/04_tabla_mortalidad_completa.csv` - Tabla principal
- `resultados/04_tabla_referencia_MI2014.csv` - Tabla de referencia
- `resultados/04_comparacion_tablas.csv` - Comparación
- `imagenes/04_curva_sobrevivencia.png` - Curva lx
- `imagenes/04_tasas_completas.png` - Tasas qx
- `imagenes/04_esperanza_vida.png` - Curva ex
- `data/tabla_completa.RData` - Tabla completa en memoria

**Variables en memoria:**
- `tabla_mortalidad` - Tabla completa con qx, lx, dx, ex
- `tabla_referencia` - Tabla MI-2014 para comparación

---

### 05_conmutacion.R - Valores de Conmutación

**Input:**
- `data/tabla_completa.RData`

**Proceso:**
1. Calcula funciones de conmutación con i=5%:
   - Dx = lx × v^x
   - Nx = Σ Dk (k≥x)
   - Cx = dx × v^(x+1)
   - Mx = Σ Ck (k≥x)
   - Rx = Σ Nk (k≥x)
2. Calcula para ambas tablas (obtenida y referencia)
3. Compara resultados

**Output:**
- `resultados/05_conmutacion_obtenida.csv` - Conmutaciones tabla obtenida
- `resultados/05_conmutacion_referencia.csv` - Conmutaciones tabla referencia
- `resultados/05_comparacion_conmutacion.csv` - Comparación
- `imagenes/05_conmutacion_Dx.png` - Gráfico Dx
- `imagenes/05_conmutacion_Nx.png` - Gráfico Nx
- `imagenes/05_conmutacion_Mx.png` - Gráfico Mx
- `data/conmutacion.RData` - Conmutaciones en memoria

**Variables en memoria:**
- `tabla_conmut_obtenida` - Conmutaciones tabla obtenida
- `tabla_conmut_referencia` - Conmutaciones tabla referencia

---

### 06_valores_actuales.R - Cálculo de Valores Actuales

**Input:**
- `data/conmutacion.RData`

**Proceso:**
Calcula 5 tipos de valores actuales especificados en el proyecto:
1. **Dotal puro** (edad final 70): nEx = D(x+n) / Dx
2. **Renta vitalicia vencida**: äx = Nx+1 / Dx
3. **Renta diferida anticipada** (desde 75): m|äx = Nx+m / Dx
4. **Renta temporal vencida** (final 80): äx:n| = (Nx+1 - Nx+n+1) / Dx
5. **Renta temporal diferida anticipada** (final 70): m|äx:n| = (Nx+m - Nx+m+n) / Dx

Calcula para ambas tablas y compara resultados.

**Output:**
- `resultados/06_dotal_puro.csv`
- `resultados/06_renta_vitalicia_vencida.csv`
- `resultados/06_renta_diferida_anticipada.csv`
- `resultados/06_renta_temporal_vencida.csv`
- `resultados/06_renta_temporal_diferida_anticipada.csv`
- `resultados/06_resumen_valores_actuales.csv` - Tabla consolidada
- `data/valores_actuales.RData` - Valores en memoria

**Variables en memoria:**
- `resultados_*_obt` - Valores para tabla obtenida
- `resultados_*_ref` - Valores para tabla referencia
- `tabla_resumen` - Resumen consolidado

---

### main.R - Script Maestro

**Función:** Ejecuta todos los módulos en orden secuencial.

**Características:**
- Control de errores (detiene si falla algún módulo)
- Medición de tiempos de ejecución
- Resumen final con lista de archivos generados
- Genera log de ejecución
- Interfaz visual con mensajes formateados

**Uso:**
```r
source("R/main.R")
```

**Output adicional:**
- `resultados/log_ejecucion_YYYYMMDD_HHMMSS.txt` - Log de ejecución

---

## 📦 Requisitos Previos

### Paquetes de R Necesarios

```r
install.packages(c(
  "tidyverse",      # Manipulación de datos y gráficos
  "data.table",     # Procesamiento eficiente
  "mgcv",           # Modelos GAM
  "MortalityTables" # Opcional: para métodos alternativos
))
```

El script `00_config.R` puede instalarlos automáticamente.

### Archivo de Datos

Debe existir el archivo:
```
data/base_act.RData
```

Si no existe, copiar `Base_act.RData` a la carpeta `data/`.

---

## 📊 Archivos Generados

### Carpeta `data/` (archivos intermedios)
- `datos_procesados.RData` - Datos filtrados y preparados
- `tasas_crudas.RData` - Tasas brutas por edad
- `graduacion.RData` - Tasas graduadas y modelo
- `tabla_completa.RData` - Tabla de mortalidad completa
- `conmutacion.RData` - Funciones de conmutación
- `valores_actuales.RData` - Valores actuales calculados

### Carpeta `resultados/` (archivos CSV para informe)
- `01_cuadro_descriptivo.csv` - **Incluir en informe**
- `02_tasas_crudas.csv`
- `03_datos_graduacion.csv`
- `03_tests_bondad_ajuste.csv` - **Incluir en informe**
- `04_tabla_mortalidad_completa.csv` - **PRINCIPAL**
- `04_tabla_referencia_MI2014.csv`
- `04_comparacion_tablas.csv`
- `05_conmutacion_obtenida.csv` - **PRINCIPAL**
- `05_conmutacion_referencia.csv`
- `05_comparacion_conmutacion.csv`
- `06_resumen_valores_actuales.csv` - **PRINCIPAL**
- `log_ejecucion_*.txt`

### Carpeta `imagenes/` (gráficos para informe)
- `02_tasas_crudas.png`
- `03_tasas_graduadas.png` - **Incluir en informe**
- `03_residuos_graduacion.png`
- `04_curva_sobrevivencia.png` - **Incluir en informe**
- `04_tasas_completas.png` - **Incluir en informe**
- `04_esperanza_vida.png`
- `05_conmutacion_Dx.png`
- `05_conmutacion_Nx.png`
- `05_conmutacion_Mx.png`

---

## ⚙️ Configuración Personalizada

Para cambiar parámetros, editar `R/00_config.R`:

```r
# Cambiar filtros de datos
ORIGEN <- 2
SEXO <- "M"

# Cambiar período
FECHA_INICIO <- as.Date("2000-01-01")
FECHA_FIN <- as.Date("2012-12-31")

# Cambiar parámetros actuariales
L0 <- 10000000
I_TEC <- 0.05

# Cambiar rango de graduación
EDAD_MIN_GRADUACION <- 20
EDAD_MAX_GRADUACION <- 84

# Cambiar criterios de filtrado
MIN_MUERTES <- 1
MIN_EXPOSICION <- 1

# Cambiar parámetros GAM
GAM_K <- 10
```

---

## 🐛 Solución de Problemas

### Error: "No se encuentra base_act.RData"
**Solución:** Copiar el archivo `Base_act.RData` a la carpeta `data/`

### Error: "Paquete 'xxx' no encontrado"
**Solución:** Instalar paquetes faltantes:
```r
install.packages("nombre_paquete")
```

### Error: "Insuficientes edades para graduación"
**Solución:** Ajustar `MIN_MUERTES` y `MIN_EXPOSICION` en `00_config.R`

### Advertencia: "Ajustando k a X debido a cantidad de datos"
**Información:** Normal cuando hay pocas edades. El script ajusta automáticamente.

---

## 📈 Flujo de Datos

```
Base_act.RData
    ↓
[01_carga_datos]
    ↓
datos_periodo → [02_tasas_crudas]
    ↓
tasas_crudas → [03_graduacion]
    ↓
datos_graduacion → [04_tabla_completa]
    ↓
tabla_mortalidad → [05_conmutacion]
    ↓
tabla_conmut_obtenida → [06_valores_actuales]
    ↓
valores_actuales (resultados finales)
```

---

## 📚 Referencias Metodológicas

### Graduación
- **Método:** GAM (Generalized Additive Models) con P-splines
- **Familia:** Poisson con link logarítmico
- **Suavidad:** Controlada por parámetro k

### Extrapolación
- **Método:** Gompertz-Makeham
- **Fórmula:** μ(x) = A + B·c^x
- **Fallback:** Gompertz simple si Makeham falla (A=0)

### Tests de Bondad
- **Chi-cuadrado:** Compara frecuencias observadas vs esperadas
- **Kolmogorov-Smirnov:** Compara distribuciones acumuladas
- **Signos:** Distribución de desviaciones positivas/negativas
- **Rachas:** Aleatoriedad de secuencia de desviaciones

---

## 👥 Autores

- **Esteban Román**
- **Juan Pablo Cuevas**

---

## 📅 Última Actualización

Diciembre 2025

---

## 📞 Contacto

Para preguntas sobre estos scripts, revisar:
1. Comentarios dentro de cada archivo .R
2. GUIA_RAPIDA.md en la raíz del proyecto
3. ESTRUCTURA_COMPLETA.md para visión general

---

**¡Éxito con el proyecto! 🎓**
