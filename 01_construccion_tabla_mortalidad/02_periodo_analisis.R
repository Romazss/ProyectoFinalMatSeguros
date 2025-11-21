# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 1: Construcción de Tabla de Mortalidad
# Script 02: Análisis Descriptivo y Período de Análisis
# ============================================================================

library(tidyverse)
library(lubridate)

# ============================================================================
# PARÁMETROS ESPECÍFICOS DEL GRUPO
# ============================================================================
# Asignación: Origen = 2, TM_SEXO = M
# Tabla de Referencia: INVALIDEZ 2014 - Masculino

# ============================================================================
# 1. CARGAR DATOS
# ============================================================================

load("../data/datos_seleccionados.RData")

# ============================================================================
# 2. DEFINIR PERÍODO DE ANÁLISIS
# ============================================================================

# Período: 01/01/2000 - 31/12/2012
fecha_inicio <- as.Date("2000-01-01")
fecha_fin <- as.Date("2012-12-31")

cat("PERÍODO DE ANÁLISIS\n")
cat("Inicio:", as.character(fecha_inicio), "\n")
cat("Fin:", as.character(fecha_fin), "\n")

# ============================================================================
# 3. EXPLORACIÓN DE FECHAS EN LOS DATOS
# ============================================================================

# NOTA: Ajustar nombres de columnas según tu base de datos
# Columnas probables: fecha_inicio_vigencia, fecha_termino, fecha_muerte, etc.

# Ver columnas con "fecha"
fecha_cols <- names(datos_analisis)[grep("fecha|date", names(datos_analisis), ignore.case = TRUE)]
cat("\nColumnas de fecha encontradas:\n")
print(fecha_cols)

# ============================================================================
# 4. FILTRAR DATOS POR PERÍODO DE ANÁLISIS
# ============================================================================

# NOTA: Ajustar según las columnas reales de tu base de datos
# Ejemplo suponiendo columnas: fecha_inicio_vigencia y fecha_muerte

datos_periodo <- datos_analisis %>%
  # Filtrar registros con exposición dentro del período
  # Ajustar la condición según tus columnas reales
  filter(
    # Registro debe haber iniciado antes del fin del período
    # registro_inicio <= fecha_fin,
    # Registro debe haber estado vigente durante el período (cuando aplique)
  )

# ============================================================================
# 5. CUADRO DESCRIPTIVO
# ============================================================================

# Calcular estadísticas originales
registros_originales <- nrow(datos_analisis)
muertes_originales <- sum(datos_analisis$muerte, na.rm = TRUE)  # Ajustar nombre de columna

# Calcular estadísticas después del filtrado
registros_analisis <- nrow(datos_periodo)
muertes_analisis <- sum(datos_periodo$muerte, na.rm = TRUE)  # Ajustar nombre de columna

# Crear cuadro resumen
cuadro_descriptivo <- data.frame(
  Concepto = c(
    "Registros Originales",
    "Muertes Originales",
    "Registros en Análisis",
    "Muertes en Análisis",
    "Registros Excluidos",
    "Muertes Excluidas",
    "% Registros Mantenidos",
    "% Muertes Mantenidas"
  ),
  Valor = c(
    registros_originales,
    muertes_originales,
    registros_analisis,
    muertes_analisis,
    registros_originales - registros_analisis,
    muertes_originales - muertes_analisis,
    round(100 * registros_analisis / registros_originales, 2),
    round(100 * muertes_analisis / muertes_originales, 2)
  )
)

cat("\n" %+% "="^80 %+% "\n")
cat("CUADRO DESCRIPTIVO - PERÍODO DE ANÁLISIS\n")
cat("="^80 %+% "\n")
print(cuadro_descriptivo, row.names = FALSE)

# ============================================================================
# 6. ANÁLISIS POR EDAD
# ============================================================================

# NOTA: Ajustar nombre de la columna de edad
cat("\n" %+% "="^80 %+% "\n")
cat("DISTRIBUCIÓN POR EDAD\n")
cat("="^80 %+% "\n")

# Crear tabla por edad con registros y muertes
# (Ajustar nombre de columna: edad, Edad, AGE, age, etc.)
tabla_edad <- datos_periodo %>%
  group_by(edad) %>%  # Cambiar 'edad' por el nombre real de tu columna
  summarise(
    registros = n(),
    muertes = sum(muerte, na.rm = TRUE),
    tasa_mortalidad = round(muertes / registros, 6),
    .groups = 'drop'
  ) %>%
  arrange(edad)

print(head(tabla_edad, 20))
print(tail(tabla_edad, 20))

# ============================================================================
# 7. GUARDAR DATOS PROCESADOS
# ============================================================================

save(datos_periodo, file = "../data/datos_periodo_analisis.RData")
write.csv(cuadro_descriptivo, "../resultados/cuadro_descriptivo.csv", row.names = FALSE)
write.csv(tabla_edad, "../resultados/tabla_edad.csv", row.names = FALSE)

cat("\nAnálisis completado y datos guardados.\n")
