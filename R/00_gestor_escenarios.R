# ============================================================================
# GESTOR DE ESCENARIOS - Análisis Comparativos
# ============================================================================
# Descripción: Permite ejecutar múltiples configuraciones y compararlas
# Autor: Esteban Román
# ============================================================================

# ----------------------------------------------------------------------------
# 1. DEFINIR ESCENARIOS
# ----------------------------------------------------------------------------

# Cada escenario es una lista con parámetros específicos
ESCENARIOS <- list(
  
  # Escenario Base (configuración actual)
  base = list(
    nombre = "Base",
    descripcion = "Configuración base: GAM k=10, edades 20-84",
    EDAD_MIN_GRADUACION = 20,
    EDAD_MAX_GRADUACION = 84,
    GAM_K = 10,
    MIN_MUERTES = 1,
    MIN_EXPOSICION = 1
  ),
  
  # Escenario con más suavizado
  suave = list(
    nombre = "Suavizado",
    descripcion = "Mayor suavizado: GAM k=15",
    EDAD_MIN_GRADUACION = 20,
    EDAD_MAX_GRADUACION = 84,
    GAM_K = 15,
    MIN_MUERTES = 1,
    MIN_EXPOSICION = 1
  ),
  
  # Escenario con menos suavizado
  detallado = list(
    nombre = "Detallado",
    descripcion = "Menor suavizado: GAM k=8",
    EDAD_MIN_GRADUACION = 20,
    EDAD_MAX_GRADUACION = 84,
    GAM_K = 8,
    MIN_MUERTES = 1,
    MIN_EXPOSICION = 1
  ),
  
  # Escenario con rango reducido
  rango_reducido = list(
    nombre = "Rango_Reducido",
    descripcion = "Rango reducido: edades 25-80",
    EDAD_MIN_GRADUACION = 25,
    EDAD_MAX_GRADUACION = 80,
    GAM_K = 10,
    MIN_MUERTES = 2,
    MIN_EXPOSICION = 5
  ),
  
  # Escenario con rango ampliado
  rango_ampliado = list(
    nombre = "Rango_Ampliado",
    descripcion = "Rango ampliado: edades 18-90",
    EDAD_MIN_GRADUACION = 18,
    EDAD_MAX_GRADUACION = 90,
    GAM_K = 12,
    MIN_MUERTES = 1,
    MIN_EXPOSICION = 1
  )
)

# ----------------------------------------------------------------------------
# 2. FUNCIONES DE GESTIÓN
# ----------------------------------------------------------------------------

# Crear carpeta para un escenario
crear_carpeta_escenario <- function(nombre_escenario) {
  carpeta <- file.path("resultados", paste0("escenario_", nombre_escenario))
  if (!dir.exists(carpeta)) {
    dir.create(carpeta, recursive = TRUE)
  }
  return(carpeta)
}

# Configurar entorno para un escenario
configurar_escenario <- function(escenario) {
  # Actualizar variables globales
  EDAD_MIN_GRADUACION <<- escenario$EDAD_MIN_GRADUACION
  EDAD_MAX_GRADUACION <<- escenario$EDAD_MAX_GRADUACION
  GAM_K <<- escenario$GAM_K
  MIN_MUERTES <<- escenario$MIN_MUERTES
  MIN_EXPOSICION <<- escenario$MIN_EXPOSICION
  
  # Crear carpetas específicas para este escenario
  DIR_RESULTADOS_ESCENARIO <<- crear_carpeta_escenario(escenario$nombre)
  DIR_GRAFICOS_ESCENARIO <<- file.path(DIR_RESULTADOS_ESCENARIO, "graficos")
  DIR_DATA_ESCENARIO <<- file.path(DIR_RESULTADOS_ESCENARIO, "data")
  
  dir.create(DIR_GRAFICOS_ESCENARIO, showWarnings = FALSE, recursive = TRUE)
  dir.create(DIR_DATA_ESCENARIO, showWarnings = FALSE, recursive = TRUE)
  
  cat(sprintf("\n✓ Configurado escenario: %s\n", escenario$nombre))
  cat(sprintf("  Descripción: %s\n", escenario$descripcion))
  cat(sprintf("  Edades: %d-%d\n", escenario$EDAD_MIN_GRADUACION, escenario$EDAD_MAX_GRADUACION))
  cat(sprintf("  GAM k: %d\n", escenario$GAM_K))
  cat(sprintf("  Resultados en: %s\n", DIR_RESULTADOS_ESCENARIO))
}

# Guardar resultado de escenario
guardar_resultado_escenario <- function(objeto, nombre_archivo, formato = "csv") {
  ruta_completa <- file.path(DIR_RESULTADOS_ESCENARIO, nombre_archivo)
  
  if (formato == "csv") {
    write.csv(objeto, ruta_completa, row.names = FALSE)
  } else if (formato == "rdata") {
    save(objeto, file = ruta_completa)
  }
  
  cat(sprintf("✓ Guardado: %s\n", nombre_archivo))
}

# Guardar gráfico de escenario
guardar_grafico_escenario <- function(plot, nombre_archivo, width = 10, height = 6) {
  ruta_completa <- file.path(DIR_GRAFICOS_ESCENARIO, nombre_archivo)
  ggsave(
    filename = ruta_completa,
    plot = plot,
    width = width,
    height = height,
    dpi = 300
  )
  cat(sprintf("✓ Gráfico guardado: %s\n", nombre_archivo))
}

# ----------------------------------------------------------------------------
# 3. EJECUTAR ESCENARIO COMPLETO
# ----------------------------------------------------------------------------

ejecutar_escenario <- function(nombre_escenario, cargar_config = TRUE) {
  
  escenario <- ESCENARIOS[[nombre_escenario]]
  
  if (is.null(escenario)) {
    stop(sprintf("Escenario '%s' no encontrado", nombre_escenario))
  }
  
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat(sprintf("║  EJECUTANDO ESCENARIO: %-45s║\n", toupper(escenario$nombre)))
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  cat("\n")
  
  tiempo_inicio <- Sys.time()
  
  # Cargar configuración base
  if (cargar_config) {
    source("R/00_config.R", encoding = "UTF-8")
  }
  
  # Configurar este escenario
  configurar_escenario(escenario)
  
  # Ejecutar módulos (asumiendo que ya se cargaron datos en módulo 1)
  tryCatch({
    # Módulo 2: Tasas crudas (reutilizar datos cargados)
    if (exists("datos_periodo")) {
      cat("\n→ Calculando tasas crudas...\n")
      source("R/02_tasas_crudas.R", encoding = "UTF-8")
    }
    
    # Módulo 3: Graduación
    cat("\n→ Graduando tasas...\n")
    source("R/03_graduacion.R", encoding = "UTF-8")
    
    # Módulo 4: Tabla completa
    cat("\n→ Construyendo tabla completa...\n")
    source("R/04_tabla_completa.R", encoding = "UTF-8")
    
    # Módulo 5: Conmutación
    cat("\n→ Calculando conmutaciones...\n")
    source("R/05_conmutacion.R", encoding = "UTF-8")
    
    # Módulo 6: Valores actuales
    cat("\n→ Calculando valores actuales...\n")
    source("R/06_valores_actuales.R", encoding = "UTF-8")
    
    tiempo_total <- as.numeric(difftime(Sys.time(), tiempo_inicio, units = "secs"))
    
    cat("\n")
    cat("╔══════════════════════════════════════════════════════════════════════╗\n")
    cat(sprintf("║  ESCENARIO COMPLETADO: %-43s║\n", escenario$nombre))
    cat(sprintf("║  Tiempo: %.1f segundos                                            ║\n", tiempo_total))
    cat("╚══════════════════════════════════════════════════════════════════════╝\n")
    cat("\n")
    
    # Guardar resumen del escenario
    resumen_escenario <- list(
      escenario = escenario,
      tiempo_ejecucion = tiempo_total,
      fecha_ejecucion = Sys.time()
    )
    
    save(resumen_escenario, 
         file = file.path(DIR_DATA_ESCENARIO, "resumen_escenario.RData"))
    
    return(TRUE)
    
  }, error = function(e) {
    cat(sprintf("\n✗ ERROR en escenario %s: %s\n", escenario$nombre, e$message))
    return(FALSE)
  })
}

# ----------------------------------------------------------------------------
# 4. EJECUTAR TODOS LOS ESCENARIOS
# ----------------------------------------------------------------------------

ejecutar_todos_escenarios <- function() {
  
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  EJECUTAR TODOS LOS ESCENARIOS                                       ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  # Cargar configuración y datos base UNA VEZ
  source("R/00_config.R", encoding = "UTF-8")
  cargar_librerias()
  
  # Ejecutar módulo 1 solo una vez (los datos son los mismos para todos)
  if (!exists("datos_periodo")) {
    cat("\n→ Cargando datos base (una sola vez)...\n")
    source("R/01_carga_datos.R", encoding = "UTF-8")
  }
  
  tiempo_inicio_total <- Sys.time()
  resultados <- list()
  
  # Ejecutar cada escenario
  for (nombre in names(ESCENARIOS)) {
    resultado <- ejecutar_escenario(nombre, cargar_config = FALSE)
    resultados[[nombre]] <- resultado
    
    if (!resultado) {
      cat(sprintf("\n⚠ Escenario %s falló, continuando con el siguiente...\n", nombre))
    }
  }
  
  tiempo_total <- as.numeric(difftime(Sys.time(), tiempo_inicio_total, units = "secs"))
  
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  TODOS LOS ESCENARIOS COMPLETADOS                                    ║\n")
  cat(sprintf("║  Tiempo total: %.1f segundos (%.2f minutos)                       ║\n", 
              tiempo_total, tiempo_total/60))
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  
  cat("\nResumen de ejecución:\n")
  for (nombre in names(resultados)) {
    estado <- if (resultados[[nombre]]) "✓ Exitoso" else "✗ Fallido"
    cat(sprintf("  %s: %s\n", nombre, estado))
  }
  
  return(resultados)
}

# ----------------------------------------------------------------------------
# 5. MENSAJE DE AYUDA
# ----------------------------------------------------------------------------

mostrar_ayuda_escenarios <- function() {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════════════╗\n")
  cat("║  GESTOR DE ESCENARIOS - AYUDA                                        ║\n")
  cat("╚══════════════════════════════════════════════════════════════════════╝\n")
  cat("\n")
  cat("ESCENARIOS DISPONIBLES:\n")
  cat("═══════════════════════════════════════════════════════════════════════\n")
  
  for (nombre in names(ESCENARIOS)) {
    esc <- ESCENARIOS[[nombre]]
    cat(sprintf("\n%s:\n", nombre))
    cat(sprintf("  Nombre: %s\n", esc$nombre))
    cat(sprintf("  Descripción: %s\n", esc$descripcion))
    cat(sprintf("  Edades: %d-%d | GAM k=%d | Min muertes=%d | Min exp=%d\n",
                esc$EDAD_MIN_GRADUACION, esc$EDAD_MAX_GRADUACION,
                esc$GAM_K, esc$MIN_MUERTES, esc$MIN_EXPOSICION))
  }
  
  cat("\n")
  cat("USO:\n")
  cat("═══════════════════════════════════════════════════════════════════════\n")
  cat("\n1. Ejecutar un escenario específico:\n")
  cat("   source('R/00_gestor_escenarios.R')\n")
  cat("   ejecutar_escenario('base')\n")
  cat("\n2. Ejecutar todos los escenarios:\n")
  cat("   source('R/00_gestor_escenarios.R')\n")
  cat("   ejecutar_todos_escenarios()\n")
  cat("\n3. Comparar resultados:\n")
  cat("   source('R/07_comparacion_escenarios.R')\n")
  cat("\n")
}

# Mostrar ayuda al cargar
mostrar_ayuda_escenarios()
