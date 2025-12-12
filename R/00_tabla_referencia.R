# ============================================================================
# MÓDULO 0: CÁLCULO DE TABLA DE REFERENCIA DESDE DATOS BASE
# ============================================================================
# Descripción: Calcula tabla de mortalidad de referencia desde datos originales
#              Esto simula tener SOLO la base de datos sin tablas pre-calculadas
# Input:  Base_act.RData (datos originales completos)
# Output: tabla_referencia_calculada con qx, lx, dx, ex y conmutaciones
# ============================================================================

# Cargar configuración
source("R/00_config.R")

mensaje("MÓDULO 0: CÁLCULO DE TABLA DE REFERENCIA", "titulo")

# ----------------------------------------------------------------------------
# 1. CARGAR DATOS ORIGINALES COMPLETOS (SIN FILTRAR)
# ----------------------------------------------------------------------------

mensaje("Cargando datos base completos...", "subtitulo")

if (!file.exists(ARCHIVO_BASE_DATOS)) {
  stop("ERROR: No se encuentra el archivo de datos base")
}

load(ARCHIVO_BASE_DATOS)

# Convertir a tibble
if (exists("baseR")) {
  datos_completos <- as_tibble(baseR)
  rm(baseR)
} else {
  stop("ERROR: El archivo no contiene el objeto 'baseR'")
}

cat(sprintf("✓ Datos completos cargados: %d registros\n", nrow(datos_completos)))

# ----------------------------------------------------------------------------
# 2. FILTRAR DATOS DE REFERENCIA (TODAS LAS TABLAS/ORÍGENES)
# ----------------------------------------------------------------------------

mensaje("Preparando datos para tabla de referencia...", "subtitulo")

# Procesar fechas
datos_completos <- datos_completos %>%
  mutate(
    Fecha_nacimiento = ymd(as.character(TM_FEC_NAC)),
    Fecha_fallecimiento = if_else(
      TM_FEC_FALL == 0 | is.na(TM_FEC_FALL),
      NA_Date_,
      ymd(as.character(TM_FEC_FALL))
    ),
    Muerte = if_else(is.na(Fecha_fallecimiento), 0L, 1L)
  ) %>%
  filter(!is.na(Fecha_nacimiento))

cat(sprintf("✓ Registros con fechas válidas: %d\n", nrow(datos_completos)))

# Aplicar ventana temporal
datos_referencia <- datos_completos %>%
  mutate(
    Edad_inicio = as.integer(floor(
      as.numeric(FECHA_INICIO - Fecha_nacimiento) / 365.25
    )),
    Edad_fin = if_else(
      is.na(Fecha_fallecimiento),
      as.integer(floor(as.numeric(FECHA_FIN - Fecha_nacimiento) / 365.25)),
      as.integer(floor(as.numeric(Fecha_fallecimiento - Fecha_nacimiento) / 365.25))
    ),
    Muerte_periodo = as.integer(
      Muerte == 1 & 
      !is.na(Fecha_fallecimiento) & 
      Fecha_fallecimiento >= FECHA_INICIO & 
      Fecha_fallecimiento <= FECHA_FIN
    )
  ) %>%
  filter(
    Fecha_nacimiento < FECHA_FIN,
    is.na(Fecha_fallecimiento) | Fecha_fallecimiento >= FECHA_INICIO
  )

cat(sprintf("✓ Registros en ventana de análisis: %d\n", nrow(datos_referencia)))
cat(sprintf("✓ Muertes en período: %d\n", sum(datos_referencia$Muerte_periodo)))

# ----------------------------------------------------------------------------
# 3. CALCULAR EXPOSICIÓN Y TASAS CRUDAS DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Calculando exposición y tasas crudas de referencia...", "subtitulo")

# Expandir a nivel edad-individuo
datos_expandidos_ref <- datos_referencia %>%
  mutate(
    Edad_min = pmax(0, Edad_inicio),
    Edad_max = pmin(EDAD_MAX, Edad_fin)
  ) %>%
  filter(Edad_max >= Edad_min) %>%
  rowwise() %>%
  mutate(
    Edades = list(Edad_min:Edad_max)
  ) %>%
  ungroup() %>%
  unnest(Edades) %>%
  rename(Edad = Edades) %>%
  mutate(
    # Fracción de exposición en esta edad
    Exposicion = case_when(
      Edad == Edad_inicio & Edad == Edad_fin ~ as.numeric(Edad_fin - Edad_inicio),
      Edad == Edad_inicio ~ 1 - (Edad_inicio - floor(Edad_inicio)),
      Edad == Edad_fin ~ Edad_fin - floor(Edad_fin),
      TRUE ~ 1
    ),
    # Muerte ocurrió en esta edad
    Muerte_edad = if_else(Edad == floor(Edad_fin) & Muerte_periodo == 1, 1L, 0L)
  )

cat("✓ Datos expandidos por edad\n")

# Agregar por edad
tasas_referencia <- datos_expandidos_ref %>%
  group_by(Edad) %>%
  summarise(
    exposicion = as.numeric(sum(Exposicion, na.rm = TRUE)),
    muertes = as.integer(sum(Muerte_edad, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  filter(exposicion > 0) %>%
  mutate(
    qx_ref = as.numeric(muertes / exposicion)
  ) %>%
  arrange(Edad) %>%
  as_tibble()

cat(sprintf("✓ Tasas crudas calculadas para %d edades\n", nrow(tasas_referencia)))
cat(sprintf("  Exposición total: %.2f años-persona\n", sum(tasas_referencia$exposicion)))
cat(sprintf("  Muertes totales: %d\n", sum(tasas_referencia$muertes)))

# ----------------------------------------------------------------------------
# 4. GRADUACIÓN DE REFERENCIA (WHITTAKER-HENDERSON)
# ----------------------------------------------------------------------------

mensaje("Graduando tasas de referencia...", "subtitulo")

# Filtrar rango para graduación
datos_grad_ref <- tasas_referencia %>%
  filter(
    Edad >= EDAD_MIN_GRADUACION,
    Edad <= EDAD_MAX_GRADUACION,
    muertes >= 1,
    exposicion >= 1
  ) %>%
  arrange(Edad)

cat(sprintf("✓ Graduando %d edades (%d-%d)\n", 
            nrow(datos_grad_ref), 
            min(datos_grad_ref$Edad), 
            max(datos_grad_ref$Edad)))

# Función Whittaker-Henderson
whittaker_henderson_ref <- function(y, exposiciones, lambda = 0.02, d = 2) {
  n <- length(y)
  E <- diag(n)
  for (i in 1:d) {
    E <- diff(E)
  }
  W <- diag(exposiciones)
  A <- W + lambda * t(E) %*% E
  b <- W %*% y
  z <- solve(A, b)
  return(as.numeric(z))
}

# Graduar
qx_grad_ref <- whittaker_henderson_ref(
  datos_grad_ref$qx_ref,
  datos_grad_ref$exposicion,
  lambda = LAMBDA,
  d = D_ORDER
)

datos_grad_ref <- datos_grad_ref %>%
  mutate(qx_graduado_ref = as.numeric(qx_grad_ref))

cat("✓ Graduación completada\n")

# ----------------------------------------------------------------------------
# 5. EXTRAPOLACIÓN DE REFERENCIA (HELIGMAN-POLLARD)
# ----------------------------------------------------------------------------

mensaje("Extrapolando edades faltantes de referencia...", "subtitulo")

# Ajustar HP
hp_formula <- function(x, A, B, C, D, E, F, G, H) {
  term1 <- A^((x + B)^C)
  term2 <- D * exp(-E * (log(pmax(x, 1) / F))^2)
  term3 <- G * H^x
  return(term1 + term2 + term3)
}

# Preparar datos para HP
datos_hp_ref <- tasas_referencia %>%
  filter(Edad >= 0, Edad <= 100, muertes >= 1) %>%
  select(Edad, qx = qx_ref)

# Ajustar
tryCatch({
  fit_hp_ref <- nls(
    qx ~ hp_formula(Edad, A, B, C, D, E, F, G, H),
    data = datos_hp_ref,
    start = list(A = 0.0005, B = 0.05, C = 0.1, D = 0.001, E = 10, F = 25, G = 0.0001, H = 1.1),
    control = list(maxiter = 1000, warnOnly = TRUE),
    algorithm = "port",
    lower = c(A = 0.00001, B = 0, C = 0, D = 0, E = 0, F = 1, G = 0, H = 1),
    upper = c(A = 1, B = 10, C = 2, D = 1, E = 100, F = 100, G = 1, H = 1.2)
  )
  params_hp_ref <- coef(fit_hp_ref)
  cat("✓ Ajuste HP exitoso para referencia\n")
}, error = function(e) {
  cat("⚠ Usando valores HP predeterminados\n")
  params_hp_ref <- list(A = 0.0005, B = 0.05, C = 0.1, D = 0.001, E = 10, F = 25, G = 0.0001, H = 1.1)
})

# Calcular Oppermann para 0-9
datos_opp_ref <- tibble(
  Edad = 0:9,
  qx_ref_crudo = tasas_referencia$qx_ref[1:10]
)
fit_opp_ref <- lm(qx_ref_crudo ~ Edad + I(Edad^2), data = datos_opp_ref)
qx_opp_ref <- predict(fit_opp_ref, newdata = tibble(Edad = 0:9))
qx_opp_ref <- pmax(qx_opp_ref, 0)

# HP para 10-19 y 85-109
qx_hp_cab_ref <- hp_formula(10:19, params_hp_ref["A"], params_hp_ref["B"], params_hp_ref["C"],
                             params_hp_ref["D"], params_hp_ref["E"], params_hp_ref["F"],
                             params_hp_ref["G"], params_hp_ref["H"])
qx_hp_cola_ref <- hp_formula(85:109, params_hp_ref["A"], params_hp_ref["B"], params_hp_ref["C"],
                              params_hp_ref["D"], params_hp_ref["E"], params_hp_ref["F"],
                              params_hp_ref["G"], params_hp_ref["H"])

# Factor de empalme
qx_opp_10_ref <- predict(fit_opp_ref, newdata = tibble(Edad = 10))
C_ref <- qx_hp_cab_ref[1] / qx_opp_10_ref
qx_opp_ref <- qx_opp_ref * C_ref

cat("✓ Extrapolación completada\n")

# ----------------------------------------------------------------------------
# 6. ENSAMBLAR TABLA COMPLETA DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Ensamblando tabla de referencia completa...", "subtitulo")

tabla_referencia_calculada <- tibble(Edad = 0:EDAD_MAX)

# Llenar valores
for (i in 1:nrow(tabla_referencia_calculada)) {
  edad <- tabla_referencia_calculada$Edad[i]
  
  if (edad %in% 0:9) {
    tabla_referencia_calculada$qx_ref[i] <- qx_opp_ref[edad + 1]
  } else if (edad %in% 10:19) {
    tabla_referencia_calculada$qx_ref[i] <- qx_hp_cab_ref[edad - 9]
  } else if (edad %in% RANGO_GRAD) {
    idx <- which(datos_grad_ref$Edad == edad)
    if (length(idx) > 0) {
      tabla_referencia_calculada$qx_ref[i] <- datos_grad_ref$qx_graduado_ref[idx]
    } else {
      tabla_referencia_calculada$qx_ref[i] <- NA
    }
  } else if (edad %in% 85:109) {
    tabla_referencia_calculada$qx_ref[i] <- qx_hp_cola_ref[edad - 84]
  } else {
    tabla_referencia_calculada$qx_ref[i] <- NA
  }
}

# Asegurar límites
tabla_referencia_calculada <- tabla_referencia_calculada %>%
  mutate(qx_ref = pmin(pmax(qx_ref, 0), 0.999))

cat("✓ Tabla de referencia ensamblada: 110 edades\n")

# ----------------------------------------------------------------------------
# 7. CALCULAR FUNCIONES DE VIDA DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Calculando funciones de vida de referencia...", "subtitulo")

tabla_referencia_calculada <- tabla_referencia_calculada %>%
  mutate(
    px_ref = as.numeric(1 - qx_ref),
    lx_ref = as.numeric(L0 * cumprod(c(1, head(px_ref, -1)))),
    dx_ref = as.numeric(lx_ref * qx_ref),
    Lx_ref = as.numeric(case_when(
      Edad == EDAD_MAX ~ lx_ref,
      TRUE ~ (lx_ref + lead(lx_ref, default = 0)) / 2
    ))
  ) %>%
  arrange(desc(Edad)) %>%
  mutate(Tx_ref = as.numeric(cumsum(Lx_ref))) %>%
  arrange(Edad) %>%
  mutate(ex_ref = as.numeric(Tx_ref / pmax(lx_ref, 1))) %>%
  as_tibble()

cat(sprintf("✓ l(0) referencia = %.0f\n", L0))
cat(sprintf("✓ e(0) referencia = %.2f años\n", tabla_referencia_calculada$ex_ref[1]))

# ----------------------------------------------------------------------------
# 8. CALCULAR CONMUTACIONES DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Calculando conmutaciones de referencia...", "subtitulo")

tabla_conmut_referencia_calc <- tabla_referencia_calculada %>%
  select(Edad, qx = qx_ref, px = px_ref, lx = lx_ref, dx = dx_ref) %>%
  mutate(
    Dx = as.numeric(lx * V^Edad),
    Cx = as.numeric(dx * V^(Edad + 1))
  ) %>%
  arrange(desc(Edad)) %>%
  mutate(
    Nx = as.numeric(cumsum(Dx)),
    Mx = as.numeric(cumsum(Cx))
  ) %>%
  arrange(Edad) %>%
  arrange(desc(Edad)) %>%
  mutate(Rx = as.numeric(cumsum(Nx))) %>%
  arrange(Edad) %>%
  as_tibble()

cat("✓ Conmutaciones de referencia calculadas\n")
cat(sprintf("  N0 = %.2f\n", tabla_conmut_referencia_calc$Nx[1]))
cat(sprintf("  M0 = %.2f\n", tabla_conmut_referencia_calc$Mx[1]))

# ----------------------------------------------------------------------------
# 9. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando tabla de referencia calculada...", "subtitulo")

# Guardar CSV
write_csv(
  tabla_referencia_calculada,
  file.path(DIR_RESULTADOS, "00_tabla_referencia_calculada.csv")
)
write_csv(
  tabla_conmut_referencia_calc,
  file.path(DIR_RESULTADOS, "00_conmutacion_referencia_calculada.csv")
)

cat("✓ Guardado: 00_tabla_referencia_calculada.csv\n")
cat("✓ Guardado: 00_conmutacion_referencia_calculada.csv\n")

# Guardar RData
save(
  tabla_referencia_calculada,
  tabla_conmut_referencia_calc,
  tasas_referencia,
  file = file.path(DIR_DATA, "referencia_calculada.RData")
)

cat("✓ Datos guardados en data/referencia_calculada.RData\n")

# ----------------------------------------------------------------------------
# 10. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 0 COMPLETADO", "titulo")
cat("Tabla de referencia calculada desde datos base\n")
cat(sprintf("Registros procesados:     %d\n", nrow(datos_completos)))
cat(sprintf("Exposición total:         %.2f años-persona\n", sum(tasas_referencia$exposicion)))
cat(sprintf("Muertes totales:          %d\n", sum(tasas_referencia$muertes)))
cat(sprintf("Esperanza vida e(0):      %.2f años\n", tabla_referencia_calculada$ex_ref[1]))
cat(sprintf("Esperanza vida e(65):     %.2f años\n", tabla_referencia_calculada$ex_ref[66]))

cat("\nTabla de referencia lista para comparación ✓\n")
mensaje("", "titulo")

# Limpiar objetos temporales
rm(datos_completos, datos_referencia, datos_expandidos_ref, datos_grad_ref, datos_hp_ref)
gc()
