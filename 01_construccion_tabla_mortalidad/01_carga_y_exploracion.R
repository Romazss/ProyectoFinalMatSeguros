# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 1: Construcción de Tabla de Mortalidad
# Script 01: Carga y Exploración de Datos
# ============================================================================

# Librerías
library(tidyverse)
library(readxl)

# ============================================================================
# 1. CARGA DE DATOS
# ============================================================================

# Cargar el archivo RData
load("/Users/estebanroman/Documents/GitHub/ProyectoFinalMatSeguros/data/base_act.RData")

# Verificar qué objetos se cargaron
ls()

# ============================================================================
# 2. EXPLORACIÓN INICIAL DE DATOS
# ============================================================================

# Ver estructura general
head(base_act, 10)
str(base_act)
dim(base_act)

# Ver nombres de columnas
names(base_act)

# Resumen estadístico
summary(base_act)

# ============================================================================
# 3. IDENTIFICAR CRITERIOS DE ASIGNACIÓN
# ============================================================================

# Ver valores únicos de Origen
cat("\n--- Valores de 'Origen' ---\n")
table(base_act$Origen)

# Ver valores únicos de TM_SEXO
cat("\n--- Valores de 'TM_SEXO' ---\n")
table(base_act$TM_SEXO)

# Ver valores únicos de Tabla
cat("\n--- Valores de 'Tabla' ---\n")
table(base_act$Tabla)

# Cruces entre variables
cat("\n--- Crosstab: Origen vs TM_SEXO ---\n")
table(base_act$Origen, base_act$TM_SEXO)

cat("\n--- Crosstab: Tabla vs TM_SEXO ---\n")
table(base_act$Tabla, base_act$TM_SEXO)

# ============================================================================
# 4. PROCESAMIENTO DE FECHAS Y VARIABLES
# ============================================================================

cat("\n--- Procesando fechas y variables ---\n")

# Función para convertir entero AAAAMMDD a Date
convertir_fecha_int <- function(x) {
  # Convertir 0 a NA
  x_char <- as.character(x)
  # Manejar casos donde x es 0 o NA
  is_invalid <- x == 0 | is.na(x) | x_char == "0"
  
  fechas <- rep(as.Date(NA), length(x))
  fechas[!is_invalid] <- as.Date(x_char[!is_invalid], format = "%Y%m%d")
  
  return(fechas)
}

# Aplicar transformaciones según definición de datos
base_act <- base_act %>%
  mutate(
    # Asegurar tipos de datos
    ID = as.integer(ID),
    Origen = as.integer(Origen),
    Tabla = as.integer(Tabla),
    TM_SEXO = as.character(TM_SEXO),
    
    # Convertir fechas
    fecha_nacimiento = convertir_fecha_int(TM_FEC_NAC),
    fecha_fallecimiento = convertir_fecha_int(TM_FEC_FALL),
    
    # Indicador de fallecimiento
    es_fallecido = !is.na(fecha_fallecimiento)
  )

# Verificar conversión
cat("\n--- Resumen de Fechas ---\n")
summary(base_act$fecha_nacimiento)
summary(base_act$fecha_fallecimiento)

cat("\n--- Conteo de Fallecidos ---\n")
table(base_act$es_fallecido)

# ============================================================================
# 5. CREAR SUBSET PARA ANÁLISIS
# ============================================================================

# ASIGNACIÓN DEL GRUPO:
# Origen = 2 y TM_SEXO = M (INVALIDEZ 2014 - Mas)
# Tabla de Referencia: INVALIDEZ 2014 - Masculino

datos_analisis <- base_act %>%
  filter(Origen == 2 & TM_SEXO == "M")

cat("\n--- Dimensiones del subset para análisis ---\n")
cat("Registros:", nrow(datos_analisis), "\n")
cat("Columnas:", ncol(datos_analisis), "\n")

# ============================================================================
# 6. GUARDAR DATOS PROCESADOS
# ============================================================================

# Guardar el subset para uso en otros scripts
save(datos_analisis, file = "/Users/estebanroman/Documents/GitHub/ProyectoFinalMatSeguros/data/datos_seleccionados.RData")

cat("\nDatos cargados, procesados y explorados exitosamente.\n")
