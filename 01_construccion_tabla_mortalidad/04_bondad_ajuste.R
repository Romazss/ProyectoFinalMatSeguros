# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 1: Construcción de Tabla de Mortalidad
# Script 04: Tests de Bondad de Ajuste
# ============================================================================

library(tidyverse)
library(DescTools)

# ============================================================================
# 1. CARGAR DATOS Y MODELOS
# ============================================================================

load("../data/datos_periodo_analisis.RData")
load("../data/modelos_graduacion.RData")

# Cargar tasas graduadas
tabla_grad <- read.csv("../resultados/tasas_graduadas.csv")

# ============================================================================
# 2. FUNCIÓN PARA TESTS DE BONDAD DE AJUSTE
# ============================================================================

bondad_ajuste <- function(qx_observado, qx_esperado, nombre_metodo) {
  
  cat("\n" %+% "="^80 %+% "\n")
  cat("PRUEBAS DE BONDAD DE AJUSTE -", nombre_metodo, "\n")
  cat("="^80 %+% "\n")
  
  # Preparar datos
  obs <- qx_observado[!is.na(qx_observado) & !is.na(qx_esperado)]
  esp <- qx_esperado[!is.na(qx_observado) & !is.na(qx_esperado)]
  
  resultados <- list()
  
  # TEST 1: CHI-CUADRADO
  # ----------
  cat("\n1. TEST CHI-CUADRADO (χ²)\n")
  cat("---\n")
  
  # Transformar a frecuencias observadas y esperadas
  # Usar muertes observadas vs muertes esperadas
  n <- 10000000  # Radix para tabla de vida
  
  # Asumir que tenemos muertes observadas
  muertes_obs <- tabla_grad$muertes
  muertes_esp <- tabla_grad$expuestos * esp
  
  chi2_stat <- sum((muertes_obs - muertes_esp)^2 / pmax(muertes_esp, 1))
  df <- length(obs) - 1
  chi2_pvalue <- 1 - pchisq(chi2_stat, df)
  
  cat("Estadístico χ²:", round(chi2_stat, 4), "\n")
  cat("Grados de libertad:", df, "\n")
  cat("Valor-p:", round(chi2_pvalue, 6), "\n")
  cat("Conclusión:", ifelse(chi2_pvalue > 0.05, "✓ ACEPTA ajuste", "✗ RECHAZA ajuste"), 
      "(α = 0.05)\n")
  
  resultados$chi2_stat <- chi2_stat
  resultados$chi2_pvalue <- chi2_pvalue
  
  # TEST 2: KOLMOGOROV-SMIRNOV
  # ----------
  cat("\n2. TEST KOLMOGOROV-SMIRNOV (KS)\n")
  cat("---\n")
  
  # Estandarizar los datos
  obs_std <- (obs - mean(obs)) / sd(obs)
  esp_std <- (esp - mean(esp)) / sd(esp)
  
  # Test KS
  ks_test <- ks.test(obs_std, esp_std)
  
  cat("Estadístico KS:", round(ks_test$statistic, 4), "\n")
  cat("Valor-p:", round(ks_test$p.value, 6), "\n")
  cat("Conclusión:", ifelse(ks_test$p.value > 0.05, "✓ ACEPTA ajuste", "✗ RECHAZA ajuste"), 
      "(α = 0.05)\n")
  
  resultados$ks_stat <- ks_test$statistic
  resultados$ks_pvalue <- ks_test$p.value
  
  # TEST 3: RACHAS (Runs Test)
  # ----------
  cat("\n3. TEST DE RACHAS\n")
  cat("---\n")
  
  # Calcular residuos
  residuos <- obs - esp
  
  # Clasificar como arriba/abajo de la mediana
  mediana_residuos <- median(residuos, na.rm = TRUE)
  clasificacion <- ifelse(residuos > mediana_residuos, 1, 0)
  clasificacion <- clasificacion[!is.na(clasificacion)]
  
  # Runs test
  runs_test <- RunsTest(clasificacion, alternative = "two.sided")
  
  cat("Número de rachas observado:", runs_test$Obs.Runs, "\n")
  cat("Número de rachas esperado:", round(runs_test$Exp.Runs, 2), "\n")
  cat("Estadístico Z:", round(runs_test$Z, 4), "\n")
  cat("Valor-p:", round(runs_test$p.value, 6), "\n")
  cat("Conclusión:", ifelse(runs_test$p.value > 0.05, "✓ ACEPTA ajuste", "✗ RECHAZA ajuste"), 
      "(α = 0.05)\n")
  
  resultados$runs_stat <- runs_test$Z
  resultados$runs_pvalue <- runs_test$p.value
  
  # TEST 4: SIGNOS
  # ----------
  cat("\n4. TEST DE SIGNOS\n")
  cat("---\n")
  
  # Contar signos positivos y negativos
  diff <- residuos[residuos != 0]
  signos_pos <- sum(diff > 0)
  signos_neg <- sum(diff < 0)
  total_signos <- signos_pos + signos_neg
  
  # Bajo H0, esperar igual número de + y -
  # Usar test binomial
  signos_test <- binom.test(signos_pos, total_signos, 0.5, alternative = "two.sided")
  
  cat("Signos positivos:", signos_pos, "\n")
  cat("Signos negativos:", signos_neg, "\n")
  cat("Total:", total_signos, "\n")
  cat("Proporción esperada: 0.5\n")
  cat("Valor-p:", round(signos_test$p.value, 6), "\n")
  cat("Conclusión:", ifelse(signos_test$p.value > 0.05, "✓ ACEPTA ajuste", "✗ RECHAZA ajuste"), 
      "(α = 0.05)\n")
  
  resultados$signos_stat <- signos_pos / total_signos
  resultados$signos_pvalue <- signos_test$p.value
  
  return(resultados)
}

# ============================================================================
# 3. APLICAR TESTS A CADA MÉTODO
# ============================================================================

resultados_tests <- list()

# Método 1: Spline
resultados_tests$spline <- bondad_ajuste(
  tabla_grad$qx_bruto,
  tabla_grad$qx_graduada_spline,
  "SPLINE CÚBICA"
)

# Método 2: Gompertz
resultados_tests$gompertz <- bondad_ajuste(
  tabla_grad$qx_bruto,
  tabla_grad$qx_graduada_gompertz,
  "MODELO GOMPERTZ"
)

# Método 3: Polinomio
resultados_tests$poly <- bondad_ajuste(
  tabla_grad$qx_bruto,
  tabla_grad$qx_graduada_poly,
  "POLINOMIO GRADO 3"
)

# ============================================================================
# 4. RESUMEN COMPARATIVO
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("RESUMEN COMPARATIVO DE MÉTODOS\n")
cat("="^80 %+% "\n\n")

resumen <- data.frame(
  Método = c("Spline", "Gompertz", "Polinomio"),
  Chi2 = c(
    round(resultados_tests$spline$chi2_stat, 4),
    round(resultados_tests$gompertz$chi2_stat, 4),
    round(resultados_tests$poly$chi2_stat, 4)
  ),
  Chi2_p = c(
    round(resultados_tests$spline$chi2_pvalue, 6),
    round(resultados_tests$gompertz$chi2_pvalue, 6),
    round(resultados_tests$poly$chi2_pvalue, 6)
  ),
  KS = c(
    round(resultados_tests$spline$ks_stat, 4),
    round(resultados_tests$gompertz$ks_stat, 4),
    round(resultados_tests$poly$ks_stat, 4)
  ),
  KS_p = c(
    round(resultados_tests$spline$ks_pvalue, 6),
    round(resultados_tests$gompertz$ks_pvalue, 6),
    round(resultados_tests$poly$ks_pvalue, 6)
  ),
  Rachas = c(
    round(resultados_tests$spline$runs_stat, 4),
    round(resultados_tests$gompertz$runs_stat, 4),
    round(resultados_tests$poly$runs_stat, 4)
  ),
  Rachas_p = c(
    round(resultados_tests$spline$runs_pvalue, 6),
    round(resultados_tests$gompertz$runs_pvalue, 6),
    round(resultados_tests$poly$runs_pvalue, 6)
  ),
  Signos = c(
    round(resultados_tests$spline$signos_stat, 4),
    round(resultados_tests$gompertz$signos_stat, 4),
    round(resultados_tests$poly$signos_stat, 4)
  ),
  Signos_p = c(
    round(resultados_tests$spline$signos_pvalue, 6),
    round(resultados_tests$gompertz$signos_pvalue, 6),
    round(resultados_tests$poly$signos_pvalue, 6)
  )
)

print(resumen)

# Guardar tabla de resumen
write.csv(resumen, "../resultados/resumen_bondad_ajuste.csv", row.names = FALSE)

# ============================================================================
# 5. VISUALIZACIONES
# ============================================================================

# Gráfico comparativo
png("../resultados/comparacion_metodos.png", width = 1200, height = 600)

par(mfrow = c(1, 2))

# Gráfico 1: Tasas
plot(tabla_grad$edad, tabla_grad$qx_bruto, 
     main = "Comparación de Métodos de Graduación",
     xlab = "Edad", ylab = "qx",
     type = "p", pch = 1, col = "black", cex = 0.6)
lines(tabla_grad$edad, tabla_grad$qx_graduada_spline, col = "red", lwd = 2, lty = 1)
lines(tabla_grad$edad, tabla_grad$qx_graduada_gompertz, col = "blue", lwd = 2, lty = 2)
lines(tabla_grad$edad, tabla_grad$qx_graduada_poly, col = "green", lwd = 2, lty = 3)
legend("topleft", 
       legend = c("Observado", "Spline", "Gompertz", "Polinomio"),
       col = c("black", "red", "blue", "green"),
       lty = c(0, 1, 2, 3),
       pch = c(1, NA, NA, NA))

# Gráfico 2: Residuos
plot(tabla_grad$edad, tabla_grad$qx_bruto - tabla_grad$qx_graduada_spline,
     main = "Residuos - Spline",
     xlab = "Edad", ylab = "Residuos",
     type = "l", col = "red")
abline(h = 0, col = "black", lty = 2)

dev.off()

cat("\nGráficos guardados en resultados/comparacion_metodos.png\n")

# ============================================================================
# 6. SELECCIONAR MEJOR MÉTODO
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("RECOMENDACIÓN: Basarse en\n")
cat("1. Valores-p > 0.05 en los 4 tests\n")
cat("2. Valor del estadístico más bajo\n")
cat("3. Suavidad visual del ajuste\n")
cat("="^80 %+% "\n")

cat("\nREVISAR gráficos en resultados/comparacion_metodos.png\n")
