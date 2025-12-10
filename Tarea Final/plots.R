###############################################
# CÓDIGO COMPLETO PARA ANÁLISIS FALTANTES    #
# Proyecto Final - Matemática de Seguros     #
###############################################

# ══════════════════════════════════════════════
# 0. LIBRERÍAS Y CONFIGURACIÓN
# ══════════════════════════════════════════════

library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(readxl)
library(openxlsx)

# Test bondad de ajuste
library(BSDA)         # SIGN.test
library(tseries)      # runs.test

# Suavizamiento y extrapolación
library(WH)
library(MortalityTables)
library(MortalityLaws)

# Configuración
options(scipen = 999)

# Crear carpetas de salida
if (!dir.exists("graficos")) dir.create("graficos")
if (!dir.exists("resultados")) dir.create("resultados")
# ══════════════════════════════════════════════
# 1. PARÁMETROS DE GRADUACIÓN (Sección 2)
# ══════════════════════════════════════════════

# Parámetros del método Whittaker-Henderson
parametros_graduacion <- list(
  edad_min = 20,           # Edad mínima de graduación
  edad_max = 84,           # Edad máxima de graduación
  metodo = "Whittaker-Henderson",
  lambda = 1/50,           # λ = 0.02
  orden_diferencias = 2,   # d = 2
  script = "C_Optimizadosycompletos.R"
)

# Justificación de edades límite
justificacion_edades <- "
Las edades 20-84 años fueron seleccionadas porque:
1. Edades < 20: Exposición insuficiente en la muestra (rentistas)
2. Edades > 84: Alta volatilidad por bajo número de observaciones
3. Rango 20-84: Datos estables con exposición significativa
"

# Justificación de parámetros
justificacion_parametros <- "
Los parámetros λ=0.02 y d=2 fueron seleccionados porque:
1. λ pequeño (0.02): Mayor suavizamiento, reduce ruido
2. d=2: Penaliza diferencias de segundo orden (suavidad en curvatura)
3. Balance entre ajuste a datos y suavidad de la curva
"

cat("=== PARÁMETROS DE GRADUACIÓN ===")
print(parametros_graduacion)
cat(justificacion_edades)
cat(justificacion_parametros)



# ══════════════════════════════════════════════
# 2. TESTS DE BONDAD DE AJUSTE CON INTERPRETACIÓN
# ══════════════════════════════════════════════

# Función para interpretar tests
interpretar_test <- function(nombre, p_valor, alpha = 0.05) {
  decision <- ifelse(p_valor > alpha, "NO se rechaza H0", "Se rechaza H0")
  conclusion <- ifelse(p_valor > alpha, 
                       "El ajuste es adecuado", 
                       "El ajuste presenta deficiencias")
  cat(sprintf("\n--- %s ---\n", nombre))
  cat(sprintf("p-valor: %.4f\n", p_valor))
  cat(sprintf("Decisión (α=%.2f): %s\n", alpha, decision))
  cat(sprintf("Conclusión: %s\n", conclusion))
  return(list(test = nombre, p_valor = p_valor, decision = decision))
}

# Asumiendo que base2, TasasEsperadas.2 y MuertesEsperadas.2 ya existen
# del código original...

# 2.1 Test de Kolmogorov-Smirnov (indicativo)
ks_res <- ks.test(base2$Muertes, MuertesEsperadas.2)
interpretar_test("Kolmogorov-Smirnov", ks_res$p.value)
cat("Nota: KS compara distribuciones; es indicativo, no definitivo para graduación.\n")

# 2.2 Test del Signo
signo <- base2$Muertes - MuertesEsperadas.2
sign_res <- SIGN.test(signo, md = 0, alternative = "two.sided")
interpretar_test("Test del Signo", sign_res$p.value)
cat("Interpretación: Evalúa si hay sesgo sistemático (sobre/subestimación).\n")

# 2.3 Chi-cuadrado de Pearson
chi_val <- sum((base2$Muertes - MuertesEsperadas.2)^2 / 
                 pmax(MuertesEsperadas.2, .Machine$double.eps))
gl <- nrow(base2) - 1
p_chi <- 1 - pchisq(chi_val, df = gl)
interpretar_test("Chi-cuadrado de Pearson", p_chi)
cat(sprintf("Estadístico χ²: %.2f con %d g.l.\n", chi_val, gl))
cat("Interpretación: Mide discrepancia global entre observados y esperados.\n")

# 2.4 Test de Rachas
runs_res <- tseries::runs.test(as.factor(
  ifelse(base2$Muertes > MuertesEsperadas.2, 1, 0)))
interpretar_test("Test de Rachas", runs_res$p.value)
cat("Interpretación: Detecta patrones sistemáticos en los residuos.\n")

# Resumen consolidado
cat("\n=== RESUMEN DE TESTS ===")
cat("\nSi la mayoría de tests NO rechazan H0, la graduación es aceptable.")


# ══════════════════════════════════════════════
# 3. FUNCIONES DE CONMUTACIÓN Y GRÁFICOS
# ══════════════════════════════════════════════

# Cargar tabla graduada y tabla de referencia MI2014
tabla_graduada <- tabla_completa
mi2014 <- TablaRef

# Parámetros
i <- 0.03  # Tasa de interés técnico
v <- 1 / (1 + i)

# Función para calcular valores de conmutación
calcular_conmutacion <- function(qx, edades, i = 0.03) {
  n <- length(qx)
  v <- 1 / (1 + i)
  
  # lx: supervivientes (partiendo de l_0 = 100000)
  lx <- numeric(n)
  lx[1] <- 100000
  for (x in 2:n) {
    lx[x] <- lx[x-1] * (1 - qx[x-1])
  }
  
  # dx: fallecidos
  dx <- c(lx[-n] - lx[-1], lx[n] * qx[n])
  
  # Dx: valor presente de supervivientes
  Dx <- lx * v^edades
  
  # Cx: valor presente de fallecidos
  Cx <- dx * v^(edades + 0.5)
  
  # Nx: suma acumulada reversa de Dx
  Nx <- rev(cumsum(rev(Dx)))
  
  # Mx: suma acumulada reversa de Cx
  Mx <- rev(cumsum(rev(Cx)))
  
  return(data.frame(
    edad = edades,
    lx = lx,
    dx = dx,
    qx = qx,
    Dx = Dx,
    Cx = Cx,
    Nx = Nx,
    Mx = Mx
  ))
}

# Calcular para tabla propia y MI2014
conmut_propia <- calcular_conmutacion(tabla_graduada$qx_final, tabla_graduada$edad)
conmut_mi2014 <- calcular_conmutacion(mi2014$qx, mi2014$Edad)

# ══════════════════════════════════════════════
# GRÁFICO: Comparación Dx
# ══════════════════════════════════════════════
png("graficos/comparacion_Dx.png", width = 800, height = 500)
plot(conmut_propia$edad, conmut_propia$Dx, 
     type = "l", lwd = 2, col = "steelblue",
     xlab = "Edad", ylab = expression(D[x]),
     main = "Comparación de Función Dx")
lines(conmut_mi2014$edad, conmut_mi2014$Dx, 
      lwd = 2, col = "firebrick", lty = 2)
legend("topright", 
       legend = c("Tabla Propia", "MI2014"),
       col = c("steelblue", "firebrick"),
       lwd = 2, lty = c(1, 2))
dev.off()

# ══════════════════════════════════════════════
# GRÁFICO: Comparación Nx
# ══════════════════════════════════════════════
png("graficos/comparacion_Nx.png", width = 800, height = 500)
plot(conmut_propia$edad, conmut_propia$Nx, 
     type = "l", lwd = 2, col = "steelblue",
     xlab = "Edad", ylab = expression(N[x]),
     main = "Comparación de Función Nx")
lines(conmut_mi2014$edad, conmut_mi2014$Nx, 
      lwd = 2, col = "firebrick", lty = 2)
legend("topright", 
       legend = c("Tabla Propia", "MI2014"),
       col = c("steelblue", "firebrick"),
       lwd = 2, lty = c(1, 2))
dev.off()

cat("\nGráficos de Dx y Nx guardados en carpeta 'graficos/'")


# ══════════════════════════════════════════════
# 4. COMPARACIÓN DE ESPERANZAS DE VIDA
# ══════════════════════════════════════════════

# Calcular esperanza de vida completa
calcular_ex <- function(lx) {
  n <- length(lx)
  ex <- numeric(n)
  for (x in 1:n) {
    if (lx[x] > 0) {
      # Suma de supervivientes futuros / supervivientes actuales
      ex[x] <- sum(lx[(x+1):min(n, x+100)], na.rm = TRUE) / lx[x]
    }
  }
  return(ex)
}

conmut_propia$ex <- calcular_ex(conmut_propia$lx)
conmut_mi2014$ex <- calcular_ex(conmut_mi2014$lx)

# Comparación en edades clave
edades_clave <- c(20, 30, 40, 50, 60, 65, 70, 80)

comparacion_ex <- data.frame(
  Edad = edades_clave,
  ex_Propia = conmut_propia$ex[conmut_propia$edad %in% edades_clave],
  ex_MI2014 = conmut_mi2014$ex[conmut_mi2014$edad %in% edades_clave]
) %>%
  mutate(
    Diferencia = ex_Propia - ex_MI2014,
    Dif_Pct = round(100 * Diferencia / ex_MI2014, 2)
  )

print(comparacion_ex)

cat("\n=== INTERPRETACIÓN ===")
cat("\nDiferencias positivas: Tabla propia predice mayor longevidad que MI2014")
cat("\nDiferencias negativas: Tabla propia predice menor longevidad que MI2014")
cat("\n\nPosibles explicaciones:")
cat("\n1. Población de rentistas vs. población general")
cat("\n2. Efecto de selección adversa en rentas vitalicias")
cat("\n3. Período de observación diferente")
cat("\n4. Tendencias de mortalidad mejorada en cohortes recientes")


# ══════════════════════════════════════════════
# 5. GRÁFICOS DE VALORES ACTUALES POR PRODUCTO
# ══════════════════════════════════════════════

# Función para calcular valores actuales básicos
calcular_valores_actuales <- function(conmut, n_años = 10) {
  df <- conmut %>%
    filter(edad <= 100 - n_años) %>%
    mutate(
      # Renta vitalicia inmediata
      ax = Nx / Dx,
      # Renta vitalicia diferida n años
      n_ax = lead(Nx, n_años) / Dx,
      # Seguro de vida entera
      Ax = Mx / Dx,
      # Dotal puro n años
      nEx = lead(Dx, n_años) / Dx
    )
  return(df)
}

va_propia <- calcular_valores_actuales(conmut_propia)
va_mi2014 <- calcular_valores_actuales(conmut_mi2014)

# Combinar para comparación
comparacion_va <- va_propia %>%
  select(edad, ax_propia = ax, Ax_propia = Ax) %>%
  left_join(
    va_mi2014 %>% select(edad, ax_mi2014 = ax, Ax_mi2014 = Ax),
    by = "edad"
  ) %>%
  mutate(
    dif_ax = ax_propia - ax_mi2014,
    dif_Ax = Ax_propia - Ax_mi2014,
    dif_ax_pct = 100 * dif_ax / ax_mi2014,
    dif_Ax_pct = 100 * dif_Ax / Ax_mi2014
  )

# ══════════════════════════════════════════════
# GRÁFICO: Diferencias por producto
# ══════════════════════════════════════════════
png("graficos/diferencias_productos.png", width = 900, height = 600)
par(mfrow = c(2, 2))

# Panel 1: Renta vitalicia
plot(comparacion_va$edad, comparacion_va$ax_propia,
     type = "l", lwd = 2, col = "steelblue",
     xlab = "Edad", ylab = expression(a[x]),
     main = "Renta Vitalicia Inmediata")
lines(comparacion_va$edad, comparacion_va$ax_mi2014, 
      lwd = 2, col = "firebrick", lty = 2)
legend("topright", c("Propia", "MI2014"), 
       col = c("steelblue", "firebrick"), lwd = 2, lty = c(1,2), cex = 0.8)

# Panel 2: Seguro de vida
plot(comparacion_va$edad, comparacion_va$Ax_propia,
     type = "l", lwd = 2, col = "steelblue",
     xlab = "Edad", ylab = expression(A[x]),
     main = "Seguro de Vida Entera")
lines(comparacion_va$edad, comparacion_va$Ax_mi2014, 
      lwd = 2, col = "firebrick", lty = 2)
legend("topleft", c("Propia", "MI2014"), 
       col = c("steelblue", "firebrick"), lwd = 2, lty = c(1,2), cex = 0.8)

# Panel 3: Diferencia % en renta
plot(comparacion_va$edad, comparacion_va$dif_ax_pct,
     type = "l", lwd = 2, col = "darkgreen",
     xlab = "Edad", ylab = "Diferencia (%)",
     main = "Diferencia % en Renta Vitalicia")
abline(h = 0, lty = 3, col = "gray50")

# Panel 4: Diferencia % en seguro
plot(comparacion_va$edad, comparacion_va$dif_Ax_pct,
     type = "l", lwd = 2, col = "darkorange",
     xlab = "Edad", ylab = "Diferencia (%)",
     main = "Diferencia % en Seguro de Vida")
abline(h = 0, lty = 3, col = "gray50")

par(mfrow = c(1, 1))
dev.off()

cat("\nGráfico de diferencias por producto guardado en 'graficos/'")