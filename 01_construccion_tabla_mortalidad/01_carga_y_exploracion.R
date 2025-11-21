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
load("../data/Base_act.RData")

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
# 4. EXPLORACIÓN DE FECHAS
# ============================================================================

# Verificar formato de fechas
cat("\n--- Información de Fechas ---\n")
head(base_act[, grep("fecha|date|Date", names(base_act), ignore.case = TRUE)])

# Convertir a formato fecha si es necesario
# MODIFICAR según el nombre real de la columna de fecha
# base_act$fecha <- as.Date(base_act$fecha_columna)

# ============================================================================
# 5. EXPLORACIÓN DE MUERTES Y EXPOSICIÓN
# ============================================================================

# Verificar columnas relacionadas con muertes
cat("\n--- Columnas de Muertes ---\n")
head(base_act[, grep("muerte|death|Death|MUERTE", names(base_act), ignore.case = TRUE)])

# Verificar columnas de edad
cat("\n--- Columnas de Edad ---\n")
head(base_act[, grep("edad|age|Age|EDAD", names(base_act), ignore.case = TRUE)])

# ============================================================================
# 6. CREAR SUBSET PARA ANÁLISIS
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
# 7. GUARDAR DATOS PROCESADOS
# ============================================================================

# Guardar el subset para uso en otros scripts
save(datos_analisis, file = "../data/datos_seleccionados.RData")

cat("\nDatos cargados y explorados exitosamente.\n")
