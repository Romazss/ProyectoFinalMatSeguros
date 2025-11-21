# ProyectoFinalMatSeguros - Estructura Modularizada

> **⭐ PERSONALIZADO PARA: Origen=2, TM_SEXO=M (INVALIDEZ 2014 - Masculino)**

## 📖 Documentación Disponible

| Documento | Propósito |
|-----------|-----------|
| **GUIA_RAPIDA.md** | ⭐ START HERE - Checklist y resumen ejecutivo |
| **CONFIGURACION_GRUPO.md** | Tu configuración específica paso a paso |
| **ESTRUCTURA_COMPLETA.md** | Mapa visual completo del proyecto |
| **TABLA_REFERENCIA_INVALIDEZ_2014.md** | Cómo obtener tabla de referencia oficial |
| **PROYECTO_FINAL.md** | Especificaciones oficiales del proyecto |
| **VALIDACION_INICIAL.R** | Script para verificar datos antes de empezar |

## 📁 Estructura del Proyecto

```
ProyectoFinalMatSeguros/
│
├── PROYECTO_FINAL.md                          # Especificaciones del proyecto
├── README.md                                  # Este archivo
│
├── 01_construccion_tabla_mortalidad/          # MÓDULO 1: Construcción Tabla (60%)
│   ├── 01_carga_y_exploracion.R               # Carga datos Base_act.RData
│   ├── 02_periodo_analisis.R                  # Análisis período 2000-2012
│   ├── 03_graduacion.R                        # Métodos: Spline, Gompertz, Polinomio
│   └── 04_bondad_ajuste.R                     # Tests: Chi², KS, Rachas, Signos
│   └── 05_extrapolacion_tabla_completa.R      # Cabeza, núcleo, cola + tabla vida
│
├── 02_valores_conmutacion/                    # MÓDULO 2: Conmutaciones (10%)
│   └── 01_conmutaciones.R                     # D(x), N(x), C(x), M(x), R(x) @ 5%
│
├── 03_valores_actuales/                       # MÓDULO 3: Valores Actuales (30%)
│   └── 01_rentas_seguros.R                    # Cálculo de 5 tipos de rentas
│
├── data/                                      # Carpeta de datos
│   ├── Base_act.RData                         # Datos originales (copiar aquí)
│   ├── datos_seleccionados.RData              # Subset según asignación
│   ├── datos_periodo_analisis.RData           # Datos filtrados 2000-2012
│   ├── modelos_graduacion.RData               # Modelos ajustados
│   ├── tabla_vida_completa.RData              # Tabla final con l(x), d(x), e(x)
│   └── tabla_conmutaciones.RData              # Conmutaciones para rentas
│
└── resultados/                                # Carpeta de outputs
    ├── cuadro_descriptivo.csv                 # Registros y muertes
    ├── tabla_edad.csv                         # Distribución por edad
    ├── tasas_graduadas.csv                    # Tasas brutas y graduadas
    ├── resumen_bondad_ajuste.csv              # Tests de ajuste
    ├── comparacion_metodos.png                # Gráfico métodos
    ├── tabla_vida_completa.csv                # Tabla vida final
    ├── resumen_tabla_vida.csv                 # Resumen ejecutivo
    ├── tabla_conmutaciones.csv                # D, N, C, M, R valores
    ├── dotal_puro.csv                         # Resultado renta 3.1
    ├── renta_vitalicia_vencida.csv            # Resultado renta 3.2
    ├── renta_diferida_anticipada.csv          # Resultado renta 3.3
    ├── renta_temporal_vencida.csv             # Resultado renta 3.4
    └── renta_temporal_diferida_anticipada.csv # Resultado renta 3.5
```

---

## 🚀 Cómo Ejecutar los Scripts

### Preparación Inicial

1. **Copiar datos**: Asegúrate que `Base_act.RData` esté en la carpeta `data/`

2. **Ajustar parámetros**: 
   - Abre `01_construccion_tabla_mortalidad/01_carga_y_exploracion.R`
   - Modifica los criterios de filtrado según tu asignación (Origen, TM_SEXO, Tabla)
   - Actualiza nombres de columnas si es necesario

### Ejecución por Módulos

#### MÓDULO 1: Construcción de Tabla de Mortalidad (60%)

**Paso 1**: Carga y exploración
```r
# Archivo: 01_construccion_tabla_mortalidad/01_carga_y_exploracion.R
# Revisa estructura datos, identifica columnas de fecha, edad, muerte
```

**Paso 2**: Análisis período 2000-2012
```r
# Archivo: 01_construccion_tabla_mortalidad/02_periodo_analisis.R
# Genera: cuadro_descriptivo.csv y tabla_edad.csv
```

**Paso 3**: Graduación con 3 métodos
```r
# Archivo: 01_construccion_tabla_mortalidad/03_graduacion.R
# Genera: tasas_graduadas.csv con Spline, Gompertz y Polinomio
```

**Paso 4**: Evaluar bondad de ajuste
```r
# Archivo: 01_construccion_tabla_mortalidad/04_bondad_ajuste.R
# Ejecuta tests: Chi², KS, Rachas, Signos
# Genera: resumen_bondad_ajuste.csv y comparacion_metodos.png
```

**Paso 5**: Extrapolación y tabla completa
```r
# Archivo: 01_construccion_tabla_mortalidad/05_extrapolacion_tabla_completa.R
# Construye tabla de vida con edades 10-109 y l(x)=10.000.000
# Genera: tabla_vida_completa.csv
```

#### MÓDULO 2: Valores de Conmutación (10%)

```r
# Archivo: 02_valores_conmutacion/01_conmutaciones.R
# Calcula D(x), N(x), C(x), M(x), R(x) con tasa=5%
# Genera: tabla_conmutaciones.csv
```

#### MÓDULO 3: Cálculo de Valores Actuales (30%)

```r
# Archivo: 03_valores_actuales/01_rentas_seguros.R
# Calcula 5 tipos de rentas usando conmutaciones
# Completa tablas comparativas con diferencial %
# Genera: 5 archivos CSV con resultados
```

---

## 📊 Productos a Entregar

Según especificaciones del proyecto:

### 1. Construcción de Tabla de Mortalidad (60%)

- ✅ Cuadro descriptivo de registros y muertes (original vs análisis)
- ✅ Edades límites justificadas
- ✅ Parámetros de graduación y script R usado
- ✅ Resultados 4 tests: Chi², KS, Rachas, Signos (valor + valor-p)
- ✅ Método extrapolación explícitamente indicado
- ✅ Tabla completa (10-109 años) con l(x)=10.000.000 y e(x)

### 2. Valores de Conmutación (10%)

- ✅ Conmutaciones D(x), N(x), C(x), M(x), R(x)
- ✅ Tasa de interés técnico: 5%

### 3. Cálculo de Valores Actuales (30%)

- ✅ 5 cuadros comparativos (tabla referencia vs tabla obtenida)
- ✅ Fórmulas mostradas para cada cálculo
- ✅ Diferencial porcentual calculado
- ✅ Comentarios sobre resultados

---

## 📝 Fórmulas Utilizadas

### Tabla de Vida
- **l(x)**: Número de sobrevivientes a edad x
- **d(x)**: l(x) × q(x)
- **L(x)**: Años persona vividos durante el año
- **T(x)**: Suma de años persona desde edad x
- **e(x)**: T(x) / l(x) (Esperanza de vida)

### Conmutaciones (i=5%)
- **v**: Factor de descuento = 1/(1+i)
- **D(x)**: l(x) × v^x
- **N(x)**: Σ D(k) para k ≥ x
- **C(x)**: d(x) × v^(x+1)
- **M(x)**: Σ C(k) para k ≥ x
- **R(x)**: Σ N(k) para k ≥ x

### Rentas

1. **Dotal Puro**: $_xE_n = \frac{D_n}{D_x}$

2. **Renta Vitalicia Vencida**: $_x a = \frac{N_{x+1}}{D_x}$

3. **Renta Diferida Anticipada**: $_m/_x \ddot{a} = \frac{N_{x+m}}{D_x}$

4. **Renta Temporal Vencida**: $_x a_{\overline{n|}} = \frac{N_{x+1} - N_{x+n+1}}{D_x}$

5. **Renta Temporal Diferida Anticipada**: $_m/_x \ddot{a}_{\overline{n|}} = \frac{N_{x+m} - N_{x+n+1}}{D_x}$

---

## 🔧 Requisitos R

Librerías necesarias:
- `tidyverse` - Manipulación de datos
- `lubridate` - Manejo de fechas
- `MortalityLaws` - Modelos de mortalidad
- `splines` - Suavizamiento
- `DescTools` - Tests estadísticos

Instalar:
```r
install.packages(c("tidyverse", "lubridate", "splines", "DescTools"))
# MortalityLaws - si está disponible en CRAN
```

---

## ⚠️ Notas Importantes

1. **Columnas de datos**: Los nombres de columnas en los scripts son ejemplos. 
   **AJUSTAR según tu base de datos** (edad, muerte, fecha_inicio, etc.)

2. **Criterios de asignación**: Modifica filtros en `01_carga_y_exploracion.R` según:
   - Origen (2 o 3)
   - TM_SEXO (F o M)
   - Tabla (1, 2, 4)

3. **Método de graduación**: Seleccionar el que pase mejor los tests de bondad

4. **Tabla de referencia**: 
   - Obtener de sitio web oficial asignado
   - Completar columna `Tabla_Referencia` en los resultados

5. **Tasa de interés**: Verificar si es 5% o ajustar según asignación

---

## 📧 Contacto y Duda

- Revisar documentación de funciones R
- Consultar PROYECTO_FINAL.md para especificaciones exactas
- Fecha de entrega: **08 de diciembre antes de las 22:00 hrs**

---

**Última actualización**: Noviembre 2025
