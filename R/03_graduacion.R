# ============================================================================
# MÓDULO 3: GRADUACIÓN CON WHITTAKER-HENDERSON Y TESTS DE BONDAD
# ============================================================================
# Descripción: Aplica graduación Whittaker-Henderson a tasas crudas y 
#              ejecuta 4 tests de bondad de ajuste
# Input:  tasas_crudas (de Módulo 2)
# Output: datos_graduacion con qx_graduado y tests de bondad
# ============================================================================

# Cargar configuración y datos
source("R/00_config.R")
load(file.path(DIR_DATA, "tasas_crudas.RData"))

mensaje("MÓDULO 3: GRADUACIÓN Y BONDAD DE AJUSTE", "titulo")

# ----------------------------------------------------------------------------
# 1. PREPARAR DATOS PARA GRADUACIÓN
# ----------------------------------------------------------------------------

mensaje("Preparando datos para graduación...", "subtitulo")

# Filtrar rango de graduación según configuración
datos_graduacion <- tasas_crudas %>%
  filter(
    Edad >= EDAD_MIN_GRADUACION,
    Edad <= EDAD_MAX_GRADUACION,
    muertes >= MIN_MUERTES,
    exposicion >= MIN_EXPOSICION
  ) %>%
  arrange(Edad) %>%
  as_tibble()

cat(sprintf("✓ Edades seleccionadas para graduación: %d\n", nrow(datos_graduacion)))
cat(sprintf("  Rango: %d a %d años\n", min(datos_graduacion$Edad), max(datos_graduacion$Edad)))
cat(sprintf("  Muertes totales: %d\n", sum(datos_graduacion$muertes)))
cat(sprintf("  Exposición total: %.2f años-persona\n", sum(datos_graduacion$exposicion)))

# ----------------------------------------------------------------------------
# 2. APLICAR GRADUACIÓN WHITTAKER-HENDERSON
# ----------------------------------------------------------------------------

mensaje("Ajustando modelo Whittaker-Henderson...", "subtitulo")

# Parámetros de graduación
cat(sprintf("Método: Whittaker-Henderson con lambda = %.4f, d = %d\n", LAMBDA, D_ORDER))

# Preparar datos en formato requerido
edades <- datos_graduacion$Edad
qx_crudo <- datos_graduacion$qx_crudo
exposiciones <- datos_graduacion$exposicion

# Crear tabla de mortalidad observada usando MortalityTables
obsTable <- mortalityTable.period(
  name = "Tabla observada Origen=2 Sexo=M",
  ages = edades,
  deathProbs = qx_crudo,
  exposures = exposiciones
)

# Aplicar Whittaker-Henderson usando MortalityTables
# Lambda como fracción (1/50 = 0.02)
lambda_frac <- LAMBDA

if (USAR_LAMBDA_AUTO) {
  cat("Buscando lambda óptimo mediante validación cruzada...\n")
  
  # Probar diferentes lambdas
  lambdas_prueba <- c(1/100, 1/80, 1/60, 1/50, 1/40, 1/30, 1/20, 1/15, 1/10, 1/8, 1/5, 1/3)
  
  errores_cv <- numeric(length(lambdas_prueba))
  
  for (i in seq_along(lambdas_prueba)) {
    lam <- lambdas_prueba[i]
    
    # Graduar con este lambda
    tabla_temp <- whittaker.mortalityTable(
      obsTable,
      lambda = lam,
      d = D_ORDER,
      name.postfix = ""
    )
    
    qx_temp <- tabla_temp@deathProbs
    muertes_esp <- qx_temp * exposiciones
    
    # Error cuadrático medio ponderado
    errores_cv[i] <- sum(exposiciones * (datos_graduacion$muertes - muertes_esp)^2) / sum(exposiciones)
  }
  
  idx_optimo <- which.min(errores_cv)
  lambda_optimo <- lambdas_prueba[idx_optimo]
  
  cat(sprintf("✓ Lambda óptimo encontrado: 1/%.0f = %.4f\n", 1/lambda_optimo, lambda_optimo))
  cat(sprintf("  Error CV mínimo: %.8f\n", min(errores_cv)))
  cat(sprintf("  Lambdas evaluados: 1/100 a 1/3\n"))
  
  lambda_frac <- lambda_optimo
} else {
  cat(sprintf("Usando lambda fijo: 1/%.0f = %.4f\n", 1/lambda_frac, lambda_frac))
}

# Aplicar graduación con lambda óptimo
obsTable_suave <- whittaker.mortalityTable(
  obsTable,
  lambda = lambda_frac,
  d = D_ORDER,
  name.postfix = sprintf(" smoothed (d=%d, lambda=1/%.0f)", D_ORDER, 1/lambda_frac)
)

qx_graduado <- obsTable_suave@deathProbs

cat(sprintf("\n✓ Graduación completada con lambda = 1/%.0f\n", 1/lambda_frac))

cat("✓ Graduación completada exitosamente\n\n")

# Agregar a los datos
datos_graduacion <- datos_graduacion %>%
  mutate(
    qx_graduado = as.numeric(qx_graduado),
    muertes_esperadas = as.numeric(qx_graduado * exposicion)
  ) %>%
  as_tibble()

cat("Resumen de tasas graduadas:\n")
cat(sprintf("  Rango qx graduado: %.8f a %.8f\n", 
            min(qx_graduado), max(qx_graduado)))
cat(sprintf("  Media qx graduado: %.8f\n", mean(qx_graduado)))

# ----------------------------------------------------------------------------
# 3. TESTS DE BONDAD DE AJUSTE
# ----------------------------------------------------------------------------

mensaje("Ejecutando tests de bondad de ajuste...", "subtitulo")

obs <- datos_graduacion$muertes
esp <- datos_graduacion$muertes_esperadas
n <- nrow(datos_graduacion)

# ---- Test 1: Chi-cuadrado ----
cat("\n1. Test Chi-cuadrado:\n")

chi2_stat <- sum((obs - esp)^2 / pmax(esp, 0.001))
chi2_gl <- max(1, n - D_ORDER - 1)  # GL = n - parámetros
chi2_pval <- 1 - pchisq(chi2_stat, df = chi2_gl)

cat(sprintf("   Estadístico χ² = %.4f\n", as.numeric(chi2_stat)))
cat(sprintf("   Grados de libertad = %.0f\n", as.numeric(chi2_gl)))
cat(sprintf("   Valor-p = %.4f\n", as.numeric(chi2_pval)))
cat(sprintf("   Decisión (α=0.05): %s\n", 
            ifelse(chi2_pval > 0.05, "No rechazar H0 (buen ajuste)", "Rechazar H0")))

# ---- Test 2: Kolmogorov-Smirnov ----
cat("\n2. Test Kolmogorov-Smirnov:\n")

exposicion_total <- datos_graduacion$exposicion
F_obs <- cumsum(obs / exposicion_total) / sum(obs / exposicion_total)
F_esp <- cumsum(esp / exposicion_total) / sum(esp / exposicion_total)
ks_stat <- max(abs(F_obs - F_esp))

# Aproximación para p-valor
ks_pval <- exp(-2 * n * ks_stat^2)

cat(sprintf("   Estadístico D = %.4f\n", ks_stat))
cat(sprintf("   Valor-p (aprox.) = %.4f\n", ks_pval))
cat(sprintf("   Decisión (α=0.05): %s\n", 
            ifelse(ks_pval > 0.05, "No rechazar H0 (buen ajuste)", "Rechazar H0")))

# ---- Test 3: Test de Signos ----
cat("\n3. Test de Signos:\n")

signos <- sign(obs - esp)
signos_pos <- sum(signos > 0)
signos_neg <- sum(signos < 0)

# Test binomial
signos_pval <- 2 * min(
  pbinom(signos_pos, n, 0.5),
  1 - pbinom(signos_pos - 1, n, 0.5)
)

cat(sprintf("   Signos positivos (obs > esp): %d\n", signos_pos))
cat(sprintf("   Signos negativos (obs < esp): %d\n", signos_neg))
cat(sprintf("   Valor-p = %.4f\n", signos_pval))
cat(sprintf("   Decisión (α=0.05): %s\n", 
            ifelse(signos_pval > 0.05, "No rechazar H0 (buen ajuste)", "Rechazar H0")))

# ---- Test 4: Test de Rachas ----
cat("\n4. Test de Rachas:\n")

rachas_seq <- rle(signos)
n_rachas <- length(rachas_seq$lengths)

# Estadístico Z (aproximación normal)
n1 <- signos_pos
n2 <- signos_neg
mu_rachas <- 2 * n1 * n2 / n + 1
sigma_rachas <- sqrt(2 * n1 * n2 * (2 * n1 * n2 - n) / (n^2 * (n - 1)))
z_rachas <- (n_rachas - mu_rachas) / pmax(sigma_rachas, 0.001)
rachas_pval <- 2 * (1 - pnorm(abs(z_rachas)))

cat(sprintf("   Número de rachas observadas: %d\n", n_rachas))
cat(sprintf("   Número esperado de rachas: %.2f\n", mu_rachas))
cat(sprintf("   Estadístico Z = %.4f\n", z_rachas))
cat(sprintf("   Valor-p = %.4f\n", rachas_pval))
cat(sprintf("   Decisión (α=0.05): %s\n", 
            ifelse(rachas_pval > 0.05, "No rechazar H0 (buen ajuste)", "Rechazar H0")))

# ---- Tabla resumen de tests ----
tests_ajuste <- tibble(
  Test = c("Chi-cuadrado", "Kolmogorov-Smirnov", "Signos", "Rachas"),
  Estadistico = as.numeric(c(chi2_stat, ks_stat, signos_pos, n_rachas)),
  Valor_p = as.numeric(c(chi2_pval, ks_pval, signos_pval, rachas_pval)),
  Resultado = c(
    ifelse(chi2_pval > 0.05, "Buen ajuste", "Mal ajuste"),
    ifelse(ks_pval > 0.05, "Buen ajuste", "Mal ajuste"),
    ifelse(signos_pval > 0.05, "Buen ajuste", "Mal ajuste"),
    ifelse(rachas_pval > 0.05, "Buen ajuste", "Mal ajuste")
  )
) %>% as_tibble()

# ----------------------------------------------------------------------------
# 4. GRÁFICOS DE DIAGNÓSTICO
# ----------------------------------------------------------------------------

mensaje("Generando gráficos de diagnóstico...", "subtitulo")

# Gráfico 1: Tasas graduadas vs crudas
p1 <- ggplot(datos_graduacion, aes(x = Edad)) +
  geom_point(aes(y = qx_crudo), alpha = 0.5, size = 2, color = "gray40") +
  geom_line(aes(y = qx_graduado), color = "blue", linewidth = 1.2) +
  geom_line(aes(y = qx_crudo), color = "gray60", linetype = "dashed", alpha = 0.5) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  labs(
    title = "Graduación Whittaker-Henderson",
    subtitle = sprintf("λ = %.2f, d = %d", LAMBDA, D_ORDER),
    x = "Edad (años)",
    y = "Tasa de mortalidad qx (escala log)",
    caption = "Puntos grises: tasas crudas | Línea azul: tasas graduadas"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "03_graduacion_whittaker.png"),
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 2: Residuos
datos_graduacion <- datos_graduacion %>%
  mutate(
    residuo = obs - esp,
    residuo_std = residuo / sqrt(pmax(esp, 1))
  )

p2 <- ggplot(datos_graduacion, aes(x = Edad, y = residuo_std)) +
  geom_hline(yintercept = c(-2, 0, 2), linetype = c(2, 1, 2), 
             color = c("red", "black", "red"), alpha = 0.5) +
  geom_point(size = 2, alpha = 0.6) +
  geom_smooth(method = "loess", se = FALSE, color = "blue") +
  labs(
    title = "Residuos Estandarizados de Graduación",
    x = "Edad (años)",
    y = "Residuo estandarizado",
    caption = "Líneas rojas: ±2 desviaciones estándar"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(DIR_GRAFICOS, "03_residuos_graduacion.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Gráficos guardados en imagenes/\n")

# ----------------------------------------------------------------------------
# 5. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando resultados...", "subtitulo")

# Determinar directorio de salida
dir_salida <- if (exists("DIR_RESULTADOS_ESCENARIO")) {
  DIR_RESULTADOS_ESCENARIO
} else {
  DIR_RESULTADOS
}

# Guardar CSV
write_csv(datos_graduacion, file.path(dir_salida, "03_datos_graduacion.csv"))
write_csv(tests_ajuste, file.path(dir_salida, "03_tests_bondad_ajuste.csv"))
cat("✓ Guardado: 03_datos_graduacion.csv\n")
cat("✓ Guardado: 03_tests_bondad_ajuste.csv\n")

# Guardar RData
save(datos_graduacion, tests_ajuste,
     file = file.path(DIR_DATA, "graduacion.RData"))
cat("✓ Resultados guardados en data/graduacion.RData\n")

# ----------------------------------------------------------------------------
# 6. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 3 COMPLETADO", "titulo")
cat(sprintf("Método de graduación:     Whittaker-Henderson (λ=%.2f, d=%d)\n", LAMBDA, D_ORDER))
cat(sprintf("Edades graduadas:         %d (de %d a %d años)\n", 
            nrow(datos_graduacion), 
            min(datos_graduacion$Edad), 
            max(datos_graduacion$Edad)))
cat(sprintf("Rango qx graduado:        %.8f a %.8f\n", 
            min(datos_graduacion$qx_graduado), 
            max(datos_graduacion$qx_graduado)))

cat("\nResultados de tests de bondad:\n")
print(tests_ajuste)

cat("\nGraduación completada exitosamente ✓\n")
mensaje("", "titulo")
