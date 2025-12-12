# ============================================================================
# MÓDULO 0: CARGAR TABLA DE REFERENCIA DESDE EXCEL
# ============================================================================
# Descripción: Carga tabla de referencia desde TablaRef.xlsx y calcula
#              todas las funciones de vida y conmutación necesarias
# Input:  Tarea Final/TablaRef.xlsx
# Output: referencia_calculada.RData con tabla_referencia_calculada y 
#         tabla_conmut_referencia_calc
# ============================================================================

# Cargar configuración
source("R/00_config.R")

mensaje("MÓDULO 0: CARGA TABLA DE REFERENCIA DESDE EXCEL", "titulo")

# ----------------------------------------------------------------------------
# 1. CARGAR TABLA DE REFERENCIA DESDE EXCEL
# ----------------------------------------------------------------------------

mensaje("Cargando tabla de referencia desde Excel...", "subtitulo")

# Verificar que existe el archivo
archivo_ref <- "Tarea Final/TablaRef.xlsx"
if (!file.exists(archivo_ref)) {
  stop(sprintf("ERROR: No se encuentra el archivo %s", archivo_ref))
}

# Cargar datos
library(readxl)
tabla_ref_excel <- read_excel(archivo_ref) %>%
  as_tibble()

cat(sprintf("✓ Tabla cargada: %d registros\n", nrow(tabla_ref_excel)))
cat(sprintf("  Columnas: %s\n", paste(colnames(tabla_ref_excel), collapse = ", ")))

# Verificar estructura
if (!"Edad" %in% colnames(tabla_ref_excel) || !"qx" %in% colnames(tabla_ref_excel)) {
  stop("ERROR: El archivo debe contener columnas 'Edad' y 'qx'")
}

# ----------------------------------------------------------------------------
# 2. CALCULAR FUNCIONES DE VIDA
# ----------------------------------------------------------------------------

mensaje("Calculando funciones de vida...", "subtitulo")

tabla_referencia_calculada <- tabla_ref_excel %>%
  select(Edad, qx) %>%
  mutate(
    Edad = as.integer(Edad),
    qx = as.numeric(qx),
    px = as.numeric(1 - qx)
  ) %>%
  arrange(Edad)

# Calcular lx
tabla_referencia_calculada$lx <- numeric(nrow(tabla_referencia_calculada))
tabla_referencia_calculada$lx[1] <- L0

for (i in 2:nrow(tabla_referencia_calculada)) {
  tabla_referencia_calculada$lx[i] <- as.numeric(
    tabla_referencia_calculada$lx[i-1] * tabla_referencia_calculada$px[i-1]
  )
}

# Calcular dx
tabla_referencia_calculada <- tabla_referencia_calculada %>%
  mutate(
    dx = as.numeric(lx * qx)
  )

# Calcular Lx
tabla_referencia_calculada$Lx <- numeric(nrow(tabla_referencia_calculada))
for (i in 1:(nrow(tabla_referencia_calculada) - 1)) {
  tabla_referencia_calculada$Lx[i] <- as.numeric(
    (tabla_referencia_calculada$lx[i] + tabla_referencia_calculada$lx[i+1]) / 2
  )
}
# Última edad: Lx_omega = lx_omega / qx_omega
ultima_fila <- nrow(tabla_referencia_calculada)
tabla_referencia_calculada$Lx[ultima_fila] <- as.numeric(
  tabla_referencia_calculada$lx[ultima_fila] / 
  pmax(tabla_referencia_calculada$qx[ultima_fila], 0.0001)
)

# Calcular Tx (hacia atrás)
tabla_referencia_calculada$Tx <- numeric(nrow(tabla_referencia_calculada))
tabla_referencia_calculada$Tx[ultima_fila] <- tabla_referencia_calculada$Lx[ultima_fila]

for (i in (ultima_fila - 1):1) {
  tabla_referencia_calculada$Tx[i] <- as.numeric(
    tabla_referencia_calculada$Lx[i] + tabla_referencia_calculada$Tx[i+1]
  )
}

# Calcular ex
tabla_referencia_calculada <- tabla_referencia_calculada %>%
  mutate(
    ex = as.numeric(Tx / pmax(lx, 1))
  ) %>%
  as_tibble()

cat(sprintf("✓ l(0) = %.0f\n", tabla_referencia_calculada$lx[1]))
cat(sprintf("✓ e(0) = %.2f años\n", tabla_referencia_calculada$ex[1]))
edad_65_idx <- which(tabla_referencia_calculada$Edad == 65)
if (length(edad_65_idx) > 0) {
  cat(sprintf("✓ e(65) = %.2f años\n", tabla_referencia_calculada$ex[edad_65_idx]))
}

# ----------------------------------------------------------------------------
# 3. CALCULAR CONMUTACIONES DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Calculando conmutaciones de referencia...", "subtitulo")

tabla_conmut_referencia_calc <- tabla_referencia_calculada %>%
  select(Edad, qx, lx, dx) %>%
  mutate(
    # Dx = lx * v^x
    Dx = as.numeric(lx * V^Edad),
    # Cx = dx * v^(x+1)
    Cx = as.numeric(dx * V^(Edad + 1))
  ) %>%
  # Calcular Nx, Mx, Rx (sumas acumuladas hacia atrás)
  arrange(desc(Edad)) %>%
  mutate(
    Nx = as.numeric(cumsum(Dx)),
    Mx = as.numeric(cumsum(Cx))
  ) %>%
  arrange(Edad) %>%
  arrange(desc(Edad)) %>%
  mutate(
    Rx = as.numeric(cumsum(Nx))
  ) %>%
  arrange(Edad) %>%
  as_tibble()

cat(sprintf("✓ Conmutaciones calculadas\n"))
cat(sprintf("  D0 = %.2f\n", tabla_conmut_referencia_calc$Dx[1]))
cat(sprintf("  N0 = %.2f\n", tabla_conmut_referencia_calc$Nx[1]))
cat(sprintf("  C0 = %.2f\n", tabla_conmut_referencia_calc$Cx[1]))
cat(sprintf("  M0 = %.2f\n", tabla_conmut_referencia_calc$Mx[1]))

# ----------------------------------------------------------------------------
# 4. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando tabla de referencia...", "subtitulo")

# Guardar CSV
write_csv(
  tabla_referencia_calculada,
  "00_tabla_referencia_calculada.csv"
)
cat("✓ Guardado: 00_tabla_referencia_calculada.csv\n")

write_csv(
  tabla_conmut_referencia_calc,
  "00_conmutacion_referencia_calculada.csv"
)
cat("✓ Guardado: 00_conmutacion_referencia_calculada.csv\n")

# Guardar RData
save(
  tabla_referencia_calculada,
  tabla_conmut_referencia_calc,
  file = file.path(DIR_DATA, "referencia_calculada.RData")
)
cat("✓ Datos guardados en data/referencia_calculada.RData\n")

# ----------------------------------------------------------------------------
# RESUMEN
# ----------------------------------------------------------------------------

cat("\n")
mensaje("RESUMEN - MÓDULO 0 COMPLETADO", "titulo")
cat("Tabla de referencia cargada desde Excel\n")
cat(sprintf("Edades:               %d (de %d a %d)\n", 
            nrow(tabla_referencia_calculada),
            min(tabla_referencia_calculada$Edad),
            max(tabla_referencia_calculada$Edad)))
cat(sprintf("Esperanza vida e(0):  %.2f años\n", tabla_referencia_calculada$ex[1]))
if (length(edad_65_idx) > 0) {
  cat(sprintf("Esperanza vida e(65): %.2f años\n", tabla_referencia_calculada$ex[edad_65_idx]))
}
cat("\nTabla de referencia lista para comparación ✓\n")
mensaje("", "titulo")
cat("\n")
