# ============================================================================
# SCRIPT MAESTRO - PROYECTO FINAL MATEMÁTICAS ACTUARIALES
# ============================================================================
# Descripción: Ejecuta todos los módulos en orden para generar resultados
# Autor: Esteban Román
# Asignación: Origen=2, TM_SEXO=M (INVALIDEZ 2014 - Masculino)
# Fecha: Diciembre 2025
# ============================================================================

# Limpiar entorno
rm(list = ls())
gc()

# Establecer directorio de trabajo
setwd("c:/Users/esteb/GitHub/ProyectoFinalMatSeguros")

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════════╗\n")
cat("║  PROYECTO FINAL - EYP2605 MATEMÁTICAS ACTUARIALES                   ║\n")
cat("║  Construcción de Tabla de Mortalidad                                ║\n")
cat("║  Asignación: INVALIDEZ 2014 - Masculino                             ║\n")
cat("╚══════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# ----------------------------------------------------------------------------
# CONFIGURACIÓN INICIAL
# ----------------------------------------------------------------------------

cat("Preparando entorno...\n")

# Cargar configuración global
source("R/00_config.R")

# Instalar paquetes si es necesario
cat("\nVerificando librerías...\n")
instalar_paquetes()
cargar_librerias()

cat("\n")
mensaje("INICIO DE EJECUCIÓN", "titulo")
cat(sprintf("Fecha y hora: %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
mensaje("", "titulo")

# Control de tiempo
tiempo_inicio <- Sys.time()

# Variable para controlar ejecución
EJECUTAR_TODO <- TRUE  # Cambiar a FALSE para ejecutar módulos individuales

# ----------------------------------------------------------------------------
# MÓDULO 0: CARGAR TABLA DE REFERENCIA DESDE EXCEL
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 0: CARGAR TABLA DE REFERENCIA DESDE EXCEL                   ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod0 <- Sys.time()
  
  tryCatch({
    source("R/00_cargar_tabla_referencia_excel.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 0 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod0, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 0: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 0")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 1: CARGA Y PREPARACIÓN DE DATOS
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 1: CARGA Y PREPARACIÓN DE DATOS                             ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod1 <- Sys.time()
  
  tryCatch({
    source("R/01_carga_datos.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 1 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod1, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 1: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 1")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 2: CÁLCULO DE TASAS CRUDAS
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 2: CÁLCULO DE TASAS CRUDAS                                  ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod2 <- Sys.time()
  
  tryCatch({
    source("R/02_tasas_crudas.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 2 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod2, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 2: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 2")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 3: GRADUACIÓN Y TESTS DE BONDAD
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 3: GRADUACIÓN Y TESTS DE BONDAD DE AJUSTE                   ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod3 <- Sys.time()
  
  tryCatch({
    source("R/03_graduacion.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 3 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod3, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 3: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 3")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 4: CONSTRUCCIÓN DE TABLA COMPLETA
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 4: CONSTRUCCIÓN DE TABLA COMPLETA                           ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod4 <- Sys.time()
  
  tryCatch({
    source("R/04_tabla_completa.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 4 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod4, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 4: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 4")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 5: VALORES DE CONMUTACIÓN
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 5: VALORES DE CONMUTACIÓN                                   ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod5 <- Sys.time()
  
  tryCatch({
    source("R/05_conmutacion.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 5 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod5, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 5: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 5")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 6: CÁLCULO DE VALORES ACTUALES
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO || TRUE) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  MÓDULO 6: VALORES ACTUALES (RENTAS Y SEGUROS)                      ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  tiempo_mod6 <- Sys.time()
  
  tryCatch({
    source("R/06_valores_actuales.R", encoding = "UTF-8")
    cat(sprintf("\n✓ Módulo 6 completado en %.1f segundos\n", 
                as.numeric(difftime(Sys.time(), tiempo_mod6, units = "secs"))))
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en Módulo 6: %s\n", e$message))
    stop("Ejecución detenida por error en Módulo 6")
  })
}

# ----------------------------------------------------------------------------
# MÓDULO 8: ESTADÍSTICOS DESCRIPTIVOS
# ----------------------------------------------------------------------------

if (EJECUTAR_TODO) {
  tryCatch({
    mensaje("Ejecutando Módulo 8: Estadísticos Descriptivos...", "modulo")
    source("R/08_estadisticos_descriptivos.R", encoding = "UTF-8")
    cat("✓ Módulo 8 completado\n\n")
  }, error = function(e) {
    cat("❌ Error en Módulo 8:\n")
    print(e)
    stop("Ejecución detenida por error en Módulo 8")
  })
}

# ----------------------------------------------------------------------------
# RESUMEN FINAL DE EJECUCIÓN
# ----------------------------------------------------------------------------

tiempo_total <- as.numeric(difftime(Sys.time(), tiempo_inicio, units = "secs"))

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════════╗\n")
cat("║  EJECUCIÓN COMPLETADA EXITOSAMENTE                                   ║\n")
cat("╚══════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

cat("RESUMEN DE EJECUCIÓN:\n")
cat("════════════════════════════════════════════════════════════════════════\n")
cat(sprintf("Hora inicio:              %s\n", format(tiempo_inicio, "%H:%M:%S")))
cat(sprintf("Hora fin:                 %s\n", format(Sys.time(), "%H:%M:%S")))
cat(sprintf("Tiempo total:             %.1f segundos (%.2f minutos)\n", 
            tiempo_total, tiempo_total/60))
cat("════════════════════════════════════════════════════════════════════════\n")

cat("\nARCHIVOS GENERADOS:\n")
cat("────────────────────────────────────────────────────────────────────────\n")

cat("\nDatos procesados (data/):\n")
archivos_data <- list.files(DIR_DATA, pattern = "\\.RData$")
for (archivo in archivos_data) {
  cat(sprintf("  ✓ %s\n", archivo))
}

cat("\nResultados (resultados/):\n")
archivos_resultados <- list.files(DIR_RESULTADOS, pattern = "\\.csv$")
for (archivo in archivos_resultados) {
  cat(sprintf("  ✓ %s\n", archivo))
}

cat("\nGráficos (imagenes/):\n")
archivos_graficos <- list.files(DIR_GRAFICOS, pattern = "\\.(png|pdf)$")
for (archivo in archivos_graficos) {
  cat(sprintf("  ✓ %s\n", archivo))
}

cat("\n════════════════════════════════════════════════════════════════════════\n")
cat("\nARCHIVOS PRINCIPALES PARA EL INFORME:\n")
cat("────────────────────────────────────────────────────────────────────────\n")
cat("  📊 01_cuadro_descriptivo.csv - Resumen de datos\n")
cat("  📊 03_tests_bondad_ajuste.csv - Tests estadísticos\n")
cat("  📊 04_tabla_mortalidad_completa.csv - Tabla principal\n")
cat("  📊 05_conmutacion_obtenida.csv - Funciones de conmutación\n")
cat("  📊 06_resumen_valores_actuales.csv - Valores actuales\n")
cat("\n  📈 Todos los gráficos en imagenes/\n")
cat("════════════════════════════════════════════════════════════════════════\n")

cat("\n✨ ¡PROYECTO COMPLETADO! ✨\n\n")

cat("Próximos pasos:\n")
cat("  1. Revisar archivos CSV en resultados/\n")
cat("  2. Revisar gráficos en imagenes/\n")
cat("  3. Usar datos para completar el informe\n")
cat("  4. Verificar comparación con tabla de referencia MI-2014\n\n")

# Crear archivo de log
log_file <- file.path(DIR_RESULTADOS, sprintf("log_ejecucion_%s.txt", 
                                               format(Sys.time(), "%Y%m%d_%H%M%S")))

sink(log_file)
cat("PROYECTO FINAL - MATEMÁTICAS ACTUARIALES\n")
cat("========================================\n\n")
cat(sprintf("Asignación: Origen=%d, TM_SEXO=%s\n", ORIGEN, SEXO))
cat(sprintf("Período análisis: %s a %s\n", FECHA_INICIO, FECHA_FIN))
cat(sprintf("Ejecutado: %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("Tiempo total: %.1f segundos\n", tiempo_total))
cat("\nMódulos ejecutados:\n")
cat("  ✓ Módulo 1: Carga y preparación de datos\n")
cat("  ✓ Módulo 2: Cálculo de tasas crudas\n")
cat("  ✓ Módulo 3: Graduación y tests de bondad\n")
cat("  ✓ Módulo 4: Construcción de tabla completa\n")
cat("  ✓ Módulo 5: Valores de conmutación\n")
cat("  ✓ Módulo 6: Valores actuales\n")
cat("  ✓ Módulo 8: Estadísticos descriptivos\n")
sink()

cat(sprintf("Log guardado en: %s\n\n", log_file))
