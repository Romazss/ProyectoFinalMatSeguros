# ============================================================================
# TAREA FINAL - EYP2605 Matemáticas Actuariales
# Esteban Román
# Asignación: Origen = 2, TM_SEXO = M → INVALIDEZ 2014 - Masculino
# ============================================================================

library(tidyverse)
library(mgcv)

# ============================================================================
# PARÁMETROS GLOBALES
# ============================================================================

FECHA_INICIO <- as.Date("2000-01-01")
FECHA_FIN    <- as.Date("2012-12-31")
L0           <- 10000000
I_TEC        <- 0.05
V            <- 1 / (1 + I_TEC)

# ============================================================================
# MÓDULO 1: CARGA Y PREPARACIÓN DE DATOS
# ============================================================================

Base_act <- baseR

cargar_datos <- function(ruta) {
  load(ruta)
  return(baseR)
}

preparar_datos <- function(Base_act, origen = 2, sexo = "M") {
  datos <- Base_act %>%
    filter(Origen == origen, TM_SEXO == sexo) %>%
    mutate(
      Fecha_nacimiento = as.Date(as.character(TM_FEC_NAC), format = "%Y%m%d"),
      Fecha_fallecimiento = if_else(
        TM_FEC_FALL == 0, 
        as.Date(NA), 
        as.Date(as.character(TM_FEC_FALL), format = "%Y%m%d")
      ),
      Muerte = if_else(TM_FEC_FALL != 0, 1L, 0L)
    ) %>%
    filter(!is.na(Fecha_nacimiento))
  
  return(datos)
}

filtrar_periodo <- function(datos, fecha_ini, fecha_fin) {
  datos %>%
    mutate(
      Muerte_periodo = if_else(
        Muerte == 1 & !is.na(Fecha_fallecimiento) & 
          Fecha_fallecimiento >= fecha_ini & Fecha_fallecimiento <= fecha_fin,
        1L, 0L
      )
    ) %>%
    filter(
      Fecha_nacimiento < fecha_fin,
      is.na(Fecha_fallecimiento) | Fecha_fallecimiento >= fecha_ini
    )
}

# ============================================================================
# MÓDULO 2: CÁLCULO DE EXPOSICIÓN Y TASAS CRUDAS (CORREGIDO)
# ============================================================================

calcular_tasas_crudas <- function(datos_periodo, fecha_ini, fecha_fin) {
  datos_exp <- datos_periodo %>%
    mutate(
      # CORRECCIÓN: Edad al inicio del PERÍODO, no desde nacimiento
      Edad_inicio_exposicion = pmax(0, floor(as.numeric(fecha_ini - Fecha_nacimiento) / 365.25)),
      
      # Fecha de fin de observación individual
      Fecha_fin_individuo = pmin(
        coalesce(Fecha_fallecimiento, fecha_fin),
        fecha_fin, na.rm = TRUE
      ),
      
      # Edad al fin de observación
      Edad_fin_exposicion = floor(as.numeric(Fecha_fin_individuo - Fecha_nacimiento) / 365.25),
      
      Murio = Muerte_periodo == 1
    ) %>%
    filter(Edad_inicio_exposicion <= Edad_fin_exposicion)
  
  # Expandir a todas las edades vividas DURANTE el período
  tasas <- datos_exp %>%
    rowwise() %>%
    mutate(edades_lista = list(seq(Edad_inicio_exposicion, Edad_fin_exposicion))) %>%
    unnest(edades_lista) %>%
    rename(Edad = edades_lista) %>%
    mutate(
      # Calcular fracción de año expuesto en cada edad
      cumple_edad = Fecha_nacimiento + Edad * 365.25,
      cumple_edad_sig = Fecha_nacimiento + (Edad + 1) * 365.25,
      
      inicio_exp = pmax(cumple_edad, fecha_ini),
      fin_exp = case_when(
        Murio & Edad == Edad_fin_exposicion ~ Fecha_fin_individuo,
        TRUE ~ pmin(cumple_edad_sig, fecha_fin)
      ),
      
      Exposicion = as.numeric(fin_exp - inicio_exp) / 365.25,
      Exposicion = pmax(0, pmin(1, Exposicion)),
      
      Muerte_edad = if_else(Murio & Edad == Edad_fin_exposicion, 1L, 0L)
    ) %>%
    ungroup() %>%
    group_by(Edad) %>%
    summarise(
      exposicion = sum(Exposicion, na.rm = TRUE),
      muertes = sum(Muerte_edad, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    filter(exposicion > 0) %>%
    mutate(qx_crudo = muertes / exposicion)
  
  return(tasas)
}

# ============================================================================
# MÓDULO 3: GRADUACIÓN CON GAM
# ============================================================================

graduar_tasas <- function(tasas_crudas, min_muertes = 1, min_exposicion = 1) {
  datos_grad <- tasas_crudas %>% 
    filter(muertes >= min_muertes, exposicion >= min_exposicion)
  
  if (nrow(datos_grad) < 5) {
    warning("Menos de 5 edades con datos suficientes. Retornando tasas crudas.")
    datos_grad$qx_graduado <- datos_grad$qx_crudo
    return(datos_grad)
  }
  
  k_val <- min(10, nrow(datos_grad) - 1)
  
  fit_gam <- gam(
    muertes ~ s(Edad, bs = "ps", k = k_val),
    family = poisson(link = "log"),
    offset = log(exposicion),
    data = datos_grad,
    method = "REML"
  )
  
  datos_grad$qx_graduado <- predict(fit_gam, type = "response") / datos_grad$exposicion
  
  cat(sprintf("GAM ajustado: k=%d, edf=%.2f\n", k_val, sum(fit_gam$edf)))
  
  return(datos_grad)
}

# ============================================================================
# MÓDULO 4: TESTS DE BONDAD DE AJUSTE (CORREGIDO)
# ============================================================================

tests_bondad_ajuste <- function(datos_grad) {
  obs <- as.numeric(datos_grad$muertes)
  esp <- as.numeric(datos_grad$qx_graduado * datos_grad$exposicion)
  n <- length(obs)
  
  # Chi-cuadrado
  chi2_stat <- sum((obs - esp)^2 / pmax(esp, 0.001))
  chi2_pval <- 1 - pchisq(chi2_stat, max(1, n - 1))
  
  # Kolmogorov-Smirnov
  exp_total <- as.numeric(datos_grad$exposicion)
  F_obs <- cumsum(obs / exp_total) / sum(obs / exp_total)
  F_esp <- cumsum(esp / exp_total) / sum(esp / exp_total)
  ks_stat <- max(abs(F_obs - F_esp))
  ks_pval <- exp(-2 * n * ks_stat^2)
  
  # Test de signos
  signos_pos <- sum(obs > esp)
  signos_pval <- 2 * min(pbinom(signos_pos, n, 0.5), 1 - pbinom(signos_pos - 1, n, 0.5))
  
  # Test de rachas (CORREGIDO: forzar vector atómico)
  dif <- obs - esp
  dif_nz <- as.numeric(dif[dif != 0])
  
  if (length(dif_nz) > 2) {
    rachas <- rle(sign(dif_nz))
    n_rachas <- length(rachas$lengths)
    n_p <- sum(dif_nz > 0)
    n_n <- sum(dif_nz < 0)
    mu_r <- 1 + 2 * n_p * n_n / (n_p + n_n)
    var_r <- 2 * n_p * n_n * (2 * n_p * n_n - n_p - n_n) / ((n_p + n_n)^2 * (n_p + n_n - 1))
    z_r <- (n_rachas - mu_r) / sqrt(max(var_r, 0.001))
    rachas_pval <- 2 * pnorm(-abs(z_r))
  } else {
    n_rachas <- NA
    rachas_pval <- NA
  }
  
  tibble(
    Test = c("Chi-cuadrado", "Kolmogorov-Smirnov", "Signos", "Rachas"),
    Estadistico = round(c(chi2_stat, ks_stat, signos_pos, n_rachas), 4),
    Valor_p = round(c(chi2_pval, ks_pval, signos_pval, rachas_pval), 4)
  )
}

# ============================================================================
# MÓDULO 5: EXTRAPOLACIÓN MAKEHAM-GOMPERTZ
# ============================================================================

ajustar_makeham <- function(datos_grad) {
  mu_x <- -log(1 - pmin(datos_grad$qx_graduado, 0.99))
  edades <- datos_grad$Edad
  
  resultado <- tryCatch({
    nls_fit <- nls(
      mu ~ A + B * c^edad,
      data = data.frame(mu = mu_x, edad = edades),
      start = list(A = 0.001, B = 0.00001, c = 1.1),
      control = nls.control(maxiter = 500, warnOnly = TRUE)
    )
    list(
      A = coef(nls_fit)["A"],
      B = coef(nls_fit)["B"],
      c = coef(nls_fit)["c"],
      metodo = "Makeham"
    )
  }, error = function(e) {
    fit_g <- lm(log(pmax(mu_x, 1e-10)) ~ edades)
    list(
      A = 0,
      B = exp(coef(fit_g)[1]),
      c = exp(coef(fit_g)[2]),
      metodo = "Gompertz (fallback)"
    )
  })
  
  return(resultado)
}

construir_tabla_qx <- function(datos_grad, params, edad_max = 109) {
  edades_completas <- 0:edad_max
  
  qx_extrapolado <- sapply(edades_completas, function(x) {
    mu <- max(0, params$A) + params$B * params$c^x
    pmin(1 - exp(-mu), 0.999)
  })
  
  tabla <- tibble(Edad = edades_completas, qx = qx_extrapolado)
  
  # Reemplazar con valores graduados donde existan
  for (i in seq_len(nrow(datos_grad))) {
    idx <- which(tabla$Edad == datos_grad$Edad[i])
    if (length(idx) > 0) {
      tabla$qx[idx] <- datos_grad$qx_graduado[i]
    }
  }
  
  # Forzar qx = 1 en edad máxima
  tabla$qx[tabla$Edad == edad_max] <- 1
  
  return(tabla)
}

# ============================================================================
# MÓDULO 6: FUNCIONES DE CONMUTACIÓN Y RENTAS
# ============================================================================

calcular_conmutacion <- function(tabla_qx, l0 = 10000000, v = 1/1.05) {
  tabla_qx %>%
    mutate(
      px = 1 - qx,
      lx = l0 * cumprod(c(1, head(px, -1))),
      dx = lx * qx,
      Dx = lx * v^Edad,
      Cx = dx * v^(Edad + 1)
    ) %>%
    arrange(desc(Edad)) %>%
    mutate(Nx = cumsum(Dx), Mx = cumsum(Cx)) %>%
    arrange(Edad) %>%
    mutate(ex = Nx / Dx - 0.5)
}

dotal_puro <- function(t, x, n) {
  Dx <- t$Dx[t$Edad == x]
  Dxn <- t$Dx[t$Edad == x + n]
  if (length(Dx) == 0 || length(Dxn) == 0 || Dx == 0) return(NA)
  Dxn / Dx
}

renta_vit_venc <- function(t, x) {
  Dx <- t$Dx[t$Edad == x]
  Nx1 <- t$Nx[t$Edad == x + 1]
  if (length(Dx) == 0 || length(Nx1) == 0 || Dx == 0) return(NA)
  Nx1 / Dx
}

renta_vit_dif_ant <- function(t, x, m) {
  Dx <- t$Dx[t$Edad == x]
  Nxm <- t$Nx[t$Edad == x + m]
  if (length(Dx) == 0 || length(Nxm) == 0 || Dx == 0) return(NA)
  Nxm / Dx
}

renta_temp_venc <- function(t, x, n) {
  Dx <- t$Dx[t$Edad == x]
  Nx1 <- t$Nx[t$Edad == x + 1]
  Nxn1 <- t$Nx[t$Edad == x + n + 1]
  if (length(Dx) == 0 || length(Nx1) == 0 || length(Nxn1) == 0 || Dx == 0) return(NA)
  (Nx1 - Nxn1) / Dx
}

renta_temp_dif_ant <- function(t, x, m, n) {
  Dx <- t$Dx[t$Edad == x]
  Nxm <- t$Nx[t$Edad == x + m]
  Nxmn <- t$Nx[t$Edad == x + m + n]
  if (length(Dx) == 0 || length(Nxm) == 0 || length(Nxmn) == 0 || Dx == 0) return(NA)
  (Nxm - Nxmn) / Dx
}

# ============================================================================
# MÓDULO 7: EJECUCIÓN PRINCIPAL
# ============================================================================

# 1. Cargar datos
Base_act <- cargar_datos("C:/Users/esteb/GitHub/ProyectoFinalMatSeguros/data/base_act.RData")

# 2. Preparar y filtrar
datos <- preparar_datos(Base_act, origen = 2, sexo = "M")
datos_periodo <- filtrar_periodo(datos, FECHA_INICIO, FECHA_FIN)

# 3. Resumen de datos
cat("\n========== RESUMEN DE DATOS ==========\n")
cat(sprintf("Registros filtrados: %d\n", nrow(datos)))
cat(sprintf("Muertes totales: %d\n", sum(datos$Muerte)))
cat(sprintf("Registros en período: %d\n", nrow(datos_periodo)))
cat(sprintf("Muertes en período: %d\n", sum(datos_periodo$Muerte_periodo)))

# 4. Calcular tasas crudas
cat("\nCalculando tasas crudas...\n")
tasas_crudas <- calcular_tasas_crudas(datos_periodo, FECHA_INICIO, FECHA_FIN)
cat(sprintf("Rango de edades: %d a %d\n", min(tasas_crudas$Edad), max(tasas_crudas$Edad)))

# 5. Graduar
cat("\n========== GRADUACIÓN ==========\n")
datos_grad <- graduar_tasas(tasas_crudas)

# 6. Tests de bondad
cat("\n========== TESTS DE BONDAD ==========\n")
tests <- tests_bondad_ajuste(datos_grad)
print(tests)

# 7. Extrapolación
cat("\n========== EXTRAPOLACIÓN ==========\n")
params <- ajustar_makeham(datos_grad)
cat(sprintf("Parámetros %s: A=%.6f, B=%.2e, c=%.4f\n", 
            params$metodo, params$A, params$B, params$c))

# 8. Construir tabla completa
tabla_qx <- construir_tabla_qx(datos_grad, params)
tabla_mortalidad <- calcular_conmutacion(tabla_qx, L0, V)

# 9. Mostrar muestra
cat("\n========== TABLA DE MORTALIDAD (muestra) ==========\n")
print(tabla_mortalidad %>% 
        select(Edad, qx, lx, dx, ex) %>% 
        filter(Edad %in% c(0, 20, 40, 60, 80, 100, 109)))

# 10. Gráficos
cat("\n========== GRÁFICOS ==========\n")

# Gráfico 1: Tasas crudas
ggplot(tasas_crudas %>% filter(muertes > 0), aes(x = Edad, y = qx_crudo)) +
  geom_point(alpha = 0.6) +
  geom_line(alpha = 0.3) +
  scale_y_log10() +
  labs(title = "Tasas Crudas - Invalidez 2014 Masculino", 
       x = "Edad", y = "qx (escala log)") +
  theme_minimal()

# Gráfico 2: Crudas vs Graduadas
ggplot(datos_grad, aes(x = Edad)) +
  geom_point(aes(y = qx_crudo), alpha = 0.5, color = "gray40") +
  geom_line(aes(y = qx_graduado), color = "blue", linewidth = 1) +
  scale_y_log10() +
  labs(title = "Tasas Crudas vs Graduadas (GAM)", 
       x = "Edad", y = "qx (escala log)") +
  theme_minimal()

# 11. Tabla de referencia MI-2014 y comparación
tabla_ref <- tibble(
  Edad = 0:110,
  qx = c(0.01080429, 0.00440199, 0.00454767, 0.00471059, 0.00484162,
         0.00504765, 0.00524207, 0.00543836, 0.00563282, 0.00582620,
         0.00613027, 0.00634584, 0.00658733, 0.00686127, 0.00715908,
         0.00812627, 0.00845708, 0.00878197, 0.00909460, 0.00939622,
         0.00954636, 0.00984314, 0.01012160, 0.01037641, 0.01061386,
         0.01071761, 0.01094971, 0.01118516, 0.01142773, 0.01167715,
         0.01183078, 0.01217004, 0.01242405, 0.01260603, 0.01274172,
         0.01286990, 0.01313684, 0.01348688, 0.01392834, 0.01446344,
         0.01491453, 0.01560964, 0.01637149, 0.01718933, 0.01805512,
         0.01883983, 0.01978603, 0.02077704, 0.02181627, 0.02290607,
         0.02419355, 0.02537782, 0.02658361, 0.02778798, 0.02896646,
         0.03023407, 0.03130672, 0.03230843, 0.03323900, 0.03410416,
         0.03568219, 0.03646622, 0.03722138, 0.03796311, 0.03870763,
         0.04007493, 0.04089640, 0.04178883, 0.04278337, 0.04391568,
         0.04529994, 0.04683533, 0.04864091, 0.05076533, 0.05325630,
         0.05714919, 0.06055723, 0.06444797, 0.06883571, 0.07371979,
         0.08005169, 0.08593481, 0.09222398, 0.09885844, 0.10576601,
         0.11424258, 0.12153400, 0.12964852, 0.13990696, 0.15006501,
         0.16293381, 0.17478192, 0.18747762, 0.20106321, 0.21557974,
         0.23386842, 0.25056103, 0.26830449, 0.28712621, 0.30704706,
         0.33204660, 0.35446258, 0.37799926, 0.40263525, 0.42833402,
         0.45504205, 0.48268701, 0.51117625, 0.54039544, 0.57020773,
         1.00000000)
) %>% filter(Edad <= 109)

tabla_ref_completa <- calcular_conmutacion(tabla_ref, L0, V)

# 12. Comparación de valores actuariales
cat("\n========== COMPARACIÓN CON REFERENCIA MI-2014 ==========\n")

cat("\n--- DOTAL PURO (edad final 70) ---\n")
for (x in c(38, 54, 62)) {
  n <- 70 - x
  ref <- dotal_puro(tabla_ref_completa, x, n)
  obt <- dotal_puro(tabla_mortalidad, x, n)
  cat(sprintf("Edad %d: Ref=%.6f, Obt=%.6f, Dif=%.2f%%\n", 
              x, ref, obt, (obt - ref) / ref * 100))
}

cat("\n--- RENTA VITALICIA VENCIDA ---\n")
for (x in c(45, 60, 90)) {
  ref <- renta_vit_venc(tabla_ref_completa, x)
  obt <- renta_vit_venc(tabla_mortalidad, x)
  cat(sprintf("Edad %d: Ref=%.6f, Obt=%.6f, Dif=%.2f%%\n", 
              x, ref, obt, (obt - ref) / ref * 100))
}

cat("\n--- RENTA VITALICIA DIFERIDA ANTICIPADA (desde 75) ---\n")
for (x in c(25, 40, 70)) {
  m <- 75 - x
  ref <- renta_vit_dif_ant(tabla_ref_completa, x, m)
  obt <- renta_vit_dif_ant(tabla_mortalidad, x, m)
  cat(sprintf("Edad %d (m=%d): Ref=%.6f, Obt=%.6f, Dif=%.2f%%\n", 
              x, m, ref, obt, (obt - ref) / ref * 100))
}

cat("\n--- RENTA TEMPORAL VENCIDA (final 80) ---\n")
for (x in c(25, 50, 75)) {
  n <- 80 - x
  ref <- renta_temp_venc(tabla_ref_completa, x, n)
  obt <- renta_temp_venc(tabla_mortalidad, x, n)
  cat(sprintf("Edad %d (n=%d): Ref=%.6f, Obt=%.6f, Dif=%.2f%%\n", 
              x, n, ref, obt, (obt - ref) / ref * 100))
}

cat("\n--- RENTA TEMPORAL DIFERIDA ANTICIPADA (final 70) ---\n")
for (x in c(32, 50, 68)) {
  if (x < 65) { m <- 65 - x; n <- 5 }
  else if (x < 70) { m <- 0; n <- 70 - x }
  else next
  ref <- renta_temp_dif_ant(tabla_ref_completa, x, m, n)
  obt <- renta_temp_dif_ant(tabla_mortalidad, x, m, n)
  cat(sprintf("Edad %d (m=%d, n=%d): Ref=%.6f, Obt=%.6f, Dif=%.2f%%\n", 
              x, m, n, ref, obt, (obt - ref) / ref * 100))
}

# 13. Exportar
write.csv(tabla_mortalidad, "tabla_mortalidad_obtenida.csv", row.names = FALSE)
write.csv(tabla_ref_completa, "tabla_referencia_MI2014.csv", row.names = FALSE)
write.csv(tasas_crudas, "tasas_crudas.csv", row.names = FALSE)
write.csv(datos_grad, "datos_graduacion.csv", row.names = FALSE)

cat("\n========== ¡COMPLETO! ==========\n")
cat("Archivos exportados:\n")
cat("  - tabla_mortalidad_obtenida.csv\n")
cat("  - tabla_referencia_MI2014.csv\n")
cat("  - tasas_crudas.csv\n")
cat("  - datos_graduacion.csv\n")

