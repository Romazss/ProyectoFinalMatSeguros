# ============================================================================
# MÓDULO 1: CARGA Y PREPARACIÓN DE DATOS
# ============================================================================
# Descripción: Carga Base_act.RData y filtra según criterios de asignación
# Input:  data/base_act.RData
# Output: datos_originales, datos_filtrados (en memoria)
# ============================================================================

# Cargar configuración global
source("R/00_config.R")

mensaje("MÓDULO 1: CARGA Y PREPARACIÓN DE DATOS", "titulo")

# ----------------------------------------------------------------------------
# 1. VERIFICAR EXISTENCIA DE ARCHIVO
# ----------------------------------------------------------------------------

mensaje("Verificando archivo de datos...", "subtitulo")

if (!file.exists(ARCHIVO_BASE_DATOS)) {
  stop(sprintf("ERROR: No se encuentra el archivo %s\nPor favor, copia Base_act.RData a la carpeta data/", 
               ARCHIVO_BASE_DATOS))
}

cat(sprintf("✓ Archivo encontrado: %s\n", ARCHIVO_BASE_DATOS))

# ----------------------------------------------------------------------------
# 2. CARGAR DATOS ORIGINALES
# ----------------------------------------------------------------------------

mensaje("Cargando datos originales...", "subtitulo")

load(ARCHIVO_BASE_DATOS)

# El archivo carga un objeto llamado 'baseR'
if (!exists("baseR")) {
  stop("ERROR: El archivo no contiene el objeto 'baseR'")
}

# Convertir inmediatamente a tibble para mejor manejo
datos_originales <- as_tibble(baseR)
rm(baseR)  # Limpiar objeto temporal

cat(sprintf("✓ Registros cargados: %s\n", format(nrow(datos_originales), big.mark = ".")))
cat(sprintf("✓ Variables: %d\n", ncol(datos_originales)))

# Mostrar estructura
mensaje("Estructura de los datos:", "subtitulo")
str(datos_originales, give.attr = FALSE)

# ----------------------------------------------------------------------------
# 3. EXPLORACIÓN INICIAL
# ----------------------------------------------------------------------------

mensaje("Análisis exploratorio...", "subtitulo")

# Verificar columnas clave
columnas_necesarias <- c("Origen", "TM_SEXO", "TM_FEC_NAC", "TM_FEC_FALL")
columnas_faltantes <- setdiff(columnas_necesarias, names(datos_originales))

if (length(columnas_faltantes) > 0) {
  stop(sprintf("ERROR: Faltan columnas necesarias: %s", 
               paste(columnas_faltantes, collapse = ", ")))
}

cat("✓ Todas las columnas necesarias están presentes\n\n")

# Resumen de origen y sexo
cat("Distribución por Origen:\n")
print(table(datos_originales$Origen))

cat("\nDistribución por Sexo:\n")
print(table(datos_originales$TM_SEXO))

cat("\nDistribución por Origen y Sexo:\n")
print(table(datos_originales$Origen, datos_originales$TM_SEXO))

# ----------------------------------------------------------------------------
# 4. FILTRAR SEGÚN ASIGNACIÓN
# ----------------------------------------------------------------------------

mensaje("Filtrando según asignación...", "subtitulo")
cat(sprintf("Filtros: Origen = %d, TM_SEXO = %s\n", ORIGEN, SEXO))

datos_filtrados <- datos_originales %>%
  filter(Origen == ORIGEN, TM_SEXO == SEXO) %>%
  as_tibble()

cat(sprintf("✓ Registros después de filtrar: %s\n", 
            format(nrow(datos_filtrados), big.mark = ".")))

if (nrow(datos_filtrados) == 0) {
  stop("ERROR: No hay registros que cumplan con los criterios de filtrado")
}

# ----------------------------------------------------------------------------
# 5. PROCESAMIENTO DE FECHAS
# ----------------------------------------------------------------------------

mensaje("Procesando fechas...", "subtitulo")

datos_filtrados <- datos_filtrados %>%
  mutate(
    # Convertir fechas desde formato YYYYMMDD
    Fecha_nacimiento = as.Date(
      ifelse(TM_FEC_NAC == 0 | is.na(TM_FEC_NAC), NA, as.character(TM_FEC_NAC)), 
      format = "%Y%m%d"
    ),
    Fecha_fallecimiento = as.Date(
      ifelse(TM_FEC_FALL == 0 | is.na(TM_FEC_FALL), NA, as.character(TM_FEC_FALL)), 
      format = "%Y%m%d"
    ),
    # Indicador de muerte
    Muerte = as.integer(TM_FEC_FALL != 0 & !is.na(TM_FEC_FALL))
  )

# Verificar conversión de fechas
cat(sprintf("✓ Fechas de nacimiento válidas: %s\n", 
            format(sum(!is.na(datos_filtrados$Fecha_nacimiento)), big.mark = ".")))
cat(sprintf("✓ Registros con fallecimiento: %s\n", 
            format(sum(datos_filtrados$Muerte), big.mark = ".")))

# Eliminar registros sin fecha de nacimiento o con fechas inválidas
datos_filtrados <- datos_filtrados %>%
  filter(
    !is.na(Fecha_nacimiento),
    Fecha_nacimiento < FECHA_FIN,
    Fecha_nacimiento <= Sys.Date()  # No puede nacer en el futuro
  )



cat(sprintf("✓ Registros válidos después de limpieza: %s\n", 
            format(nrow(datos_filtrados), big.mark = ".")))

# ----------------------------------------------------------------------------
# 6. FILTRAR POR PERÍODO DE ANÁLISIS
# ----------------------------------------------------------------------------

mensaje("Aplicando ventana temporal de análisis...", "subtitulo")
cat(sprintf("Período: %s a %s\n", FECHA_INICIO, FECHA_FIN))

datos_periodo <- datos_filtrados %>%
  mutate(
    # Muerte dentro del período
    Muerte_periodo = as.integer(
      Muerte == 1 & 
      !is.na(Fecha_fallecimiento) & 
      Fecha_fallecimiento >= FECHA_INICIO & 
      Fecha_fallecimiento <= FECHA_FIN
    )
    ) %>%
  as_tibble()

cat(sprintf("✓ Registros en ventana de análisis: %s\n", 
            format(nrow(datos_periodo), big.mark = ".")))
cat(sprintf("✓ Muertes en ventana de análisis: %s\n", 
            format(sum(datos_periodo$Muerte_periodo), big.mark = ".")))

# ----------------------------------------------------------------------------
# 7. ESTADÍSTICAS DESCRIPTIVAS
# ----------------------------------------------------------------------------

mensaje("Estadísticas descriptivas:", "subtitulo")

# Edad al inicio del período
datos_periodo <- datos_periodo %>%
  mutate(
    Edad_inicio = floor(fecha_a_anios(FECHA_INICIO, Fecha_nacimiento))
  ) %>%
  # Filtrar solo registros con edad válida (sin NA, permitir todas las edades)
  # NOTA: Se incluyen nacidos durante el período (edad negativa al inicio)
  # Su exposición se calculará desde su fecha de nacimiento
  filter(
    !is.na(Edad_inicio),
    Edad_inicio <= 110  # Solo excluir edades biológicamente imposibles
  )

cat("\nDistribución de edad al inicio del período:\n")
cat(sprintf("  NOTA: Se incluyen %d nacidos durante el período (edad < 0 al inicio)\n",
            sum(datos_periodo$Edad_inicio < 0, na.rm = TRUE)))
cat(sprintf("  Mínima: %d años\n", min(datos_periodo$Edad_inicio, na.rm = TRUE)))
cat(sprintf("  Media: %.1f años\n", mean(datos_periodo$Edad_inicio, na.rm = TRUE)))
cat(sprintf("  Mediana: %d años\n", median(datos_periodo$Edad_inicio, na.rm = TRUE)))
cat(sprintf("  Máxima: %d años\n", max(datos_periodo$Edad_inicio, na.rm = TRUE)))

# Tabla resumen por grupos de edad
tabla_edad <- datos_periodo %>%
  mutate(Grupo_edad = cut(Edad_inicio, 
                          breaks = c(0, 20, 30, 40, 50, 60, 70, 80, 90, 150),
                          labels = c("0-19", "20-29", "30-39", "40-49", 
                                   "50-59", "60-69", "70-79", "80-89", "90+"),
                          right = FALSE,
                          include.lowest = TRUE)) %>%
  group_by(Grupo_edad, .drop = FALSE) %>%
  summarise(
    Registros = n(),
    Muertes = sum(Muerte_periodo),
    .groups = "drop"
  ) %>%
  filter(Registros > 0)  # Solo mostrar grupos con datos

cat("\nDistribución por grupos de edad:\n")
print(tabla_edad)

# ----------------------------------------------------------------------------
# 8. CUADRO DESCRIPTIVO REQUERIDO PARA EL PROYECTO
# ----------------------------------------------------------------------------

mensaje("Generando cuadro descriptivo para el informe...", "subtitulo")

cuadro_descriptivo <- tibble(
  Concepto = c(
    "Registros originales (Origen=2, Sexo=M)",
    "Muertes totales en datos originales",
    "Registros en período de análisis (2000-2012)",
    "Muertes en período de análisis (2000-2012)"
  ),
  Valor = c(
    nrow(datos_filtrados),
    sum(datos_filtrados$Muerte),
    nrow(datos_periodo),
    sum(datos_periodo$Muerte_periodo)
  )
)

print(cuadro_descriptivo)

# Guardar para el informe
guardar_resultado(cuadro_descriptivo, "01_cuadro_descriptivo.csv")

# ----------------------------------------------------------------------------
# 9. GUARDAR DATOS PROCESADOS
# ----------------------------------------------------------------------------

mensaje("Guardando datos procesados...", "subtitulo")

# Guardar en RData para uso en siguientes módulos
save(datos_originales, datos_filtrados, datos_periodo, 
     file = file.path(DIR_DATA, "datos_procesados.RData"))

cat("✓ Datos guardados en: data/datos_procesados.RData\n")

# ----------------------------------------------------------------------------
# 10. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 1 COMPLETADO", "titulo")
cat(sprintf("Registros originales:     %s\n", format(nrow(datos_originales), big.mark = ".")))
cat(sprintf("Registros filtrados:      %s\n", format(nrow(datos_filtrados), big.mark = ".")))
cat(sprintf("Registros en análisis:    %s\n", format(nrow(datos_periodo), big.mark = ".")))
cat(sprintf("Muertes en período:       %s\n", format(sum(datos_periodo$Muerte_periodo), big.mark = ".")))
cat(sprintf("\nDatos listos para análisis ✓\n"))
mensaje("", "titulo")

# Limpiar variables intermedias (opcional)
rm(datos_originales, datos_filtrados, tabla_edad, columnas_necesarias, columnas_faltantes)
