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

datos_periodo <- datos_analisis %>%
  filter(
    # Debe haber nacido antes del fin del periodo
    fecha_nacimiento <= fecha_fin,
    # Si falleció, debe ser después del inicio del periodo
    (is.na(fecha_fallecimiento) | fecha_fallecimiento >= fecha_inicio)
  ) %>%
  mutate(
    # Calcular edad al inicio del periodo (o al nacimiento si nació después)
    fecha_referencia_edad = pmax(fecha_inicio, fecha_nacimiento),
    edad = floor(as.numeric(difftime(fecha_referencia_edad, fecha_nacimiento, units = "days")) / 365.25)
  )

# ============================================================================
# 5. CUADRO DESCRIPTIVO
# ============================================================================

# Calcular estadísticas originales
registros_originales <- nrow(datos_analisis)
muertes_originales <- sum(datos_analisis$es_fallecido, na.rm = TRUE)

# Calcular estadísticas después del filtrado
registros_analisis <- nrow(datos_periodo)
# Contar muertes solo si ocurrieron DENTRO del periodo de análisis
muertes_analisis <- sum(datos_periodo$es_fallecido & 
                        !is.na(datos_periodo$fecha_fallecimiento) &
                        datos_periodo$fecha_fallecimiento <= fecha_fin & 
                        datos_periodo$fecha_fallecimiento >= fecha_inicio, na.rm = TRUE)

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

cat("\n" %+% "="^80 %+% "\n")
cat("DISTRIBUCIÓN POR EDAD\n")
cat("="^80 %+% "\n")

# Crear tabla por edad con registros y muertes
tabla_edad <- datos_periodo %>%
  group_by(edad) %>%
  summarise(
    registros = n(),
    muertes = sum(es_fallecido & 
                  !is.na(fecha_fallecimiento) &
                  fecha_fallecimiento <= fecha_fin & 
                  fecha_fallecimiento >= fecha_inicio, na.rm = TRUE),
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
