# ============================================================================
# CONFIGURACIÓN GLOBAL - Proyecto Final Matemáticas Actuariales
# ============================================================================
# Autor: Esteban Román
# Asignación: Origen = 2, TM_SEXO = M (INVALIDEZ 2014 - Masculino)
# Fecha: Diciembre 2025
# ============================================================================

# ----------------------------------------------------------------------------
# 1. PARÁMETROS DE LA ASIGNACIÓN
# ----------------------------------------------------------------------------

# Criterios de filtrado para los datos
ORIGEN <- 2                  # Origen de invalidez
SEXO <- "M"                  # Sexo masculino

# Período de análisis
FECHA_INICIO <- as.Date("2000-01-01")
FECHA_FIN    <- as.Date("2012-12-31")

# ----------------------------------------------------------------------------
# 2. PARÁMETROS ACTUARIALES
# ----------------------------------------------------------------------------

# Radix para construcción de tabla de vida
L0 <- 10000000              # l(0) = 10.000.000 vidas

# Tasa de interés técnico
I_TEC <- 0.05               # 5% anual
V     <- 1 / (1 + I_TEC)    # Factor de descuento

# Edad máxima (omega)
EDAD_MAX <- 109

# ----------------------------------------------------------------------------
# 3. PARÁMETROS DE GRADUACIÓN
# ----------------------------------------------------------------------------

# Edades para graduación (núcleo de la tabla)
EDAD_MIN_GRADUACION <- 20   # Edad mínima con datos observados
EDAD_MAX_GRADUACION <- 84   # Edad máxima con datos observados
RANGO_GRAD <- 20:84         # Rango completo de graduación

# Fundamentación del rango 20-84:
#   - Mayor estabilidad en tasas brutas qx
#   - Mayor concentración de exposición al riesgo
#   - Coherencia con tabla de referencia MI2014
#   - Suficiente volumen de datos

# Parámetros Whittaker-Henderson
LAMBDA     <- 1/50          # Parámetro de suavidad (1/50 = 0.02 estándar)
D_ORDER    <- 2             # Orden de diferencias (2 = segunda diferencia)
LAMBDA_MIN <- 1/100         # Lambda mínimo para búsqueda automática
LAMBDA_MAX <- 1/3           # Lambda máximo para búsqueda automática
USAR_LAMBDA_AUTO <- FALSE   # TRUE = selección automática, FALSE = usar LAMBDA fijo

# Criterios de filtrado para graduación
MIN_MUERTES    <- 1         # Mínimo de muertes por edad
MIN_EXPOSICION <- 1         # Mínima exposición por edad

# ----------------------------------------------------------------------------
# 3B. PARÁMETROS DE EXTRAPOLACIÓN
# ----------------------------------------------------------------------------

# Estructura de métodos por rango de edad:
# | Rango   | Edades    | Método           |
# |---------|-----------|------------------|
# | Cabeza  | 0-9       | Oppermann        |
# | Cabeza  | 10-19     | Heligman-Pollard |
# | Grad.   | 20-84     | Whittaker-Hend.  |
# | Cola    | 85-109    | Heligman-Pollard |

RANGO_OPPERMANN <- 0:9            # Cabeza: Oppermann
RANGO_HP_CABEZA <- 10:19          # Cabeza: Heligman-Pollard
RANGO_HP_COLA   <- 85:109         # Cola: Heligman-Pollard
EDAD_EMPALME    <- 10             # Edad de transición cabeza

# Factor de empalme: C = qx_HP(10) / qx_Oppermann(10)
# Asegura continuidad en edad de transición
calcular_factor_empalme <- function(qx_hp_10, qx_opp_10) {
  C <- qx_hp_10 / qx_opp_10
  return(C)
}

# ----------------------------------------------------------------------------
# 4. ESTRUCTURA DE CARPETAS
# ----------------------------------------------------------------------------

# Rutas relativas al directorio raíz del proyecto
DIR_RAIZ       <- "c:/Users/esteb/GitHub/ProyectoFinalMatSeguros"
DIR_DATA       <- file.path(DIR_RAIZ, "data")
DIR_RESULTADOS <- file.path(DIR_RAIZ, "resultados")
DIR_GRAFICOS   <- file.path(DIR_RAIZ, "imagenes")

# Crear carpetas si no existen
if (!dir.exists(DIR_DATA))       dir.create(DIR_DATA, recursive = TRUE)
if (!dir.exists(DIR_RESULTADOS)) dir.create(DIR_RESULTADOS, recursive = TRUE)
if (!dir.exists(DIR_GRAFICOS))   dir.create(DIR_GRAFICOS, recursive = TRUE)

# Archivos específicos
ARCHIVO_BASE_DATOS <- file.path(DIR_DATA, "base_act.RData")

# ----------------------------------------------------------------------------
# 5. TABLA DE REFERENCIA MI-2014 MASCULINO
# ----------------------------------------------------------------------------

# Tasas de mortalidad oficiales para comparación
# Fuente: INVALIDEZ 2014 - Masculino (Superintendencia de Pensiones)
TABLA_REFERENCIA_QX <- c(
  # Edades 0-9
  0.01080429, 0.00440199, 0.00454767, 0.00471059, 0.00484162,
  0.00504765, 0.00524207, 0.00543836, 0.00563282, 0.00582620,
  # Edades 10-19
  0.00613027, 0.00634584, 0.00658733, 0.00686127, 0.00715908,
  0.00812627, 0.00845708, 0.00878197, 0.00909460, 0.00939622,
  # Edades 20-29
  0.00954636, 0.00984314, 0.01012160, 0.01037641, 0.01061386,
  0.01071761, 0.01094971, 0.01118516, 0.01142773, 0.01167715,
  # Edades 30-39
  0.01183078, 0.01217004, 0.01242405, 0.01260603, 0.01274172,
  0.01286990, 0.01313684, 0.01348688, 0.01392834, 0.01446344,
  # Edades 40-49
  0.01491453, 0.01560964, 0.01637149, 0.01718933, 0.01805512,
  0.01883983, 0.01978603, 0.02077704, 0.02181627, 0.02290607,
  # Edades 50-59
  0.02419355, 0.02537782, 0.02658361, 0.02778798, 0.02896646,
  0.03023407, 0.03130672, 0.03230843, 0.03323900, 0.03410416,
  # Edades 60-69
  0.03568219, 0.03646622, 0.03722138, 0.03796311, 0.03870763,
  0.04007493, 0.04089640, 0.04178883, 0.04278337, 0.04391568,
  # Edades 70-79
  0.04529994, 0.04683533, 0.04864091, 0.05076533, 0.05325630,
  0.05714919, 0.06055723, 0.06444797, 0.06883571, 0.07371979,
  # Edades 80-89
  0.08005169, 0.08593481, 0.09222398, 0.09885844, 0.10576601,
  0.11424258, 0.12153400, 0.12964852, 0.13990696, 0.15006501,
  # Edades 90-99
  0.16293381, 0.17478192, 0.18747762, 0.20106321, 0.21557974,
  0.23386842, 0.25056103, 0.26830449, 0.28712621, 0.30704706,
  # Edades 100-110
  0.33204660, 0.35446258, 0.37799926, 0.40263525, 0.42833402,
  0.45504205, 0.48268701, 0.51117625, 0.54039544, 0.57020773,
  1.00000000  # Edad 110 (omega)
)

# ----------------------------------------------------------------------------
# 6. LIBRERÍAS REQUERIDAS
# ----------------------------------------------------------------------------

# Lista de paquetes necesarios
PAQUETES_REQUERIDOS <- c(
  "tidyverse",      # Manipulación de datos y gráficos
  "data.table",     # Procesamiento eficiente de datos
  "MortalityTables",# Tablas de mortalidad y Whittaker-Henderson
  "MortalityLaws",  # Leyes de mortalidad (Heligman-Pollard, Gompertz, etc.)
  "randtests",      # Test de rachas
  "BSDA",           # Tests estadísticos
  "tseries"         # Series de tiempo
)

# Función para instalar paquetes faltantes
instalar_paquetes <- function() {
  for (pkg in PAQUETES_REQUERIDOS) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(sprintf("Instalando paquete: %s\n", pkg))
      install.packages(pkg, dependencies = TRUE)
    }
  }
}

# Función para cargar librerías
cargar_librerias <- function() {
  for (pkg in PAQUETES_REQUERIDOS) {
    library(pkg, character.only = TRUE, quietly = TRUE)
  }
  cat("✓ Librerías cargadas correctamente\n")
}

# ----------------------------------------------------------------------------
# 7. FUNCIONES AUXILIARES GLOBALES
# ----------------------------------------------------------------------------

# Convertir diferencia de fechas a años
fecha_a_anios <- function(fecha2, fecha1) {
  as.numeric(fecha2 - fecha1) / 365.25
}

# Imprimir mensaje con formato
mensaje <- function(texto, tipo = "info") {
  separador <- paste(rep("=", 70), collapse = "")
  if (tipo == "titulo") {
    cat("\n", separador, "\n", texto, "\n", separador, "\n", sep = "")
  } else if (tipo == "subtitulo") {
    cat("\n--- ", texto, " ---\n", sep = "")
  } else {
    cat(texto, "\n")
  }
}

# Guardar resultado con timestamp
guardar_resultado <- function(objeto, nombre_archivo, formato = "csv") {
  ruta_completa <- file.path(DIR_RESULTADOS, nombre_archivo)
  
  if (formato == "csv") {
    write.csv(objeto, ruta_completa, row.names = FALSE)
  } else if (formato == "rdata") {
    save(objeto, file = ruta_completa)
  }
  
  cat(sprintf("✓ Guardado: %s\n", nombre_archivo))
}

# ----------------------------------------------------------------------------
# MENSAJE DE CONFIRMACIÓN
# ----------------------------------------------------------------------------

cat("\n")
mensaje("CONFIGURACIÓN CARGADA - Proyecto Final Mat. Actuariales", "titulo")
cat(sprintf("Asignación: Origen=%d, Sexo=%s (INVALIDEZ 2014 - Masculino)\n", ORIGEN, SEXO))
cat(sprintf("Período: %s a %s\n", FECHA_INICIO, FECHA_FIN))
cat(sprintf("Radix l(0) = %s\n", format(L0, big.mark = ".", decimal.mark = ",")))
cat(sprintf("Tasa técnica i = %.1f%%\n", I_TEC * 100))
mensaje("", "titulo")
