# ============================================================================
# SCRIPT MAESTRO CON ESCENARIOS - PROYECTO FINAL
# ============================================================================
# Descripción: Ejecuta múltiples escenarios y genera comparaciones
# Autor: Esteban Román
# ============================================================================

# Limpiar entorno
rm(list = ls())
gc()

# Establecer directorio de trabajo
setwd("c:/Users/esteb/GitHub/ProyectoFinalMatSeguros")

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════════╗\n")
cat("║  PROYECTO FINAL - ANÁLISIS MULTI-ESCENARIO                           ║\n")
cat("║  Construcción de Tabla de Mortalidad                                ║\n")
cat("║  Con comparación de diferentes configuraciones                       ║\n")
cat("╚══════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# ----------------------------------------------------------------------------
# OPCIONES DE EJECUCIÓN
# ----------------------------------------------------------------------------

cat("OPCIONES DE EJECUCIÓN:\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("1. Ejecutar todos los escenarios y comparar\n")
cat("2. Ejecutar solo escenario base\n")
cat("3. Ejecutar escenarios seleccionados\n")
cat("4. Solo comparar escenarios existentes\n")
cat("═══════════════════════════════════════════════════════════════════════\n")

# CAMBIAR ESTA VARIABLE PARA SELECCIONAR MODO
MODO <- 1  # 1, 2, 3 o 4

tiempo_inicio_global <- Sys.time()

# ----------------------------------------------------------------------------
# MODO 1: EJECUTAR TODOS LOS ESCENARIOS
# ----------------------------------------------------------------------------

if (MODO == 1) {
  cat("\n→ Modo seleccionado: EJECUTAR TODOS LOS ESCENARIOS\n\n")
  
  # Cargar gestor de escenarios
  source("R/00_gestor_escenarios.R", encoding = "UTF-8")
  
  # Ejecutar todos
  resultados <- ejecutar_todos_escenarios()
  
  # Comparar resultados
  cat("\n→ Comparando resultados entre escenarios...\n")
  source("R/07_comparacion_escenarios.R", encoding = "UTF-8")
}

# ----------------------------------------------------------------------------
# MODO 2: SOLO ESCENARIO BASE
# ----------------------------------------------------------------------------

if (MODO == 2) {
  cat("\n→ Modo seleccionado: SOLO ESCENARIO BASE\n\n")
  
  # Ejecutar script normal
  source("R/main.R", encoding = "UTF-8")
}

# ----------------------------------------------------------------------------
# MODO 3: ESCENARIOS SELECCIONADOS
# ----------------------------------------------------------------------------

if (MODO == 3) {
  cat("\n→ Modo seleccionado: ESCENARIOS SELECCIONADOS\n\n")
  
  # Definir escenarios a ejecutar
  ESCENARIOS_A_EJECUTAR <- c("base", "suave", "detallado")
  
  # Cargar gestor
  source("R/00_gestor_escenarios.R", encoding = "UTF-8")
  
  # Cargar configuración y datos base
  source("R/00_config.R", encoding = "UTF-8")
  cargar_librerias()
  
  # Cargar datos una vez
  if (!exists("datos_periodo")) {
    cat("\n→ Cargando datos base...\n")
    source("R/01_carga_datos.R", encoding = "UTF-8")
  }
  
  # Ejecutar escenarios seleccionados
  for (nombre in ESCENARIOS_A_EJECUTAR) {
    ejecutar_escenario(nombre, cargar_config = FALSE)
  }
  
  # Comparar
  cat("\n→ Comparando resultados...\n")
  source("R/07_comparacion_escenarios.R", encoding = "UTF-8")
}

# ----------------------------------------------------------------------------
# MODO 4: SOLO COMPARAR EXISTENTES
# ----------------------------------------------------------------------------

if (MODO == 4) {
  cat("\n→ Modo seleccionado: COMPARAR ESCENARIOS EXISTENTES\n\n")
  
  source("R/00_config.R", encoding = "UTF-8")
  cargar_librerias()
  
  source("R/07_comparacion_escenarios.R", encoding = "UTF-8")
}

# ----------------------------------------------------------------------------
# RESUMEN FINAL
# ----------------------------------------------------------------------------

tiempo_total_global <- as.numeric(difftime(Sys.time(), tiempo_inicio_global, units = "secs"))

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════════╗\n")
cat("║  ANÁLISIS MULTI-ESCENARIO COMPLETADO                                 ║\n")
cat("╚══════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

cat(sprintf("Tiempo total: %.1f segundos (%.2f minutos)\n", 
            tiempo_total_global, tiempo_total_global/60))

cat("\nUBICACIÓN DE RESULTADOS:\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("\nPor escenario:\n")
carpetas_esc <- list.dirs("resultados", full.names = FALSE, recursive = FALSE)
carpetas_esc <- carpetas_esc[grepl("^escenario_", carpetas_esc)]

for (carpeta in carpetas_esc) {
  cat(sprintf("  📁 resultados/%s/\n", carpeta))
}

cat("\nComparativos generales:\n")
cat("  📊 resultados/07_*.csv\n")
cat("  📈 imagenes/07_*.png\n")

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("PRÓXIMOS PASOS:\n")
cat("═══════════════════════════════════════════════════════════════════════\n")
cat("\n1. Revisar gráficos comparativos en imagenes/\n")
cat("2. Analizar 07_evaluacion_escenarios.csv para ver mejor modelo\n")
cat("3. Comparar 07_comparacion_tests_bondad.csv\n")
cat("4. Revisar resultados detallados en cada carpeta de escenario\n")
cat("5. Seleccionar escenario óptimo para el informe final\n\n")

cat("✨ ¡ANÁLISIS COMPARATIVO COMPLETADO! ✨\n\n")

# Crear resumen consolidado
resumen_consolidado <- sprintf(
  "ANÁLISIS MULTI-ESCENARIO
Fecha: %s
Tiempo: %.2f minutos
Escenarios ejecutados: %d
Modo: %d

Para ver resultados:
- Comparativos: imagenes/07_*.png
- Evaluación: resultados/07_evaluacion_escenarios.csv
- Por escenario: resultados/escenario_*/
",
  format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
  tiempo_total_global/60,
  length(carpetas_esc),
  MODO
)

writeLines(resumen_consolidado, "resultados/RESUMEN_MULTI_ESCENARIO.txt")
cat("Resumen guardado en: resultados/RESUMEN_MULTI_ESCENARIO.txt\n\n")
