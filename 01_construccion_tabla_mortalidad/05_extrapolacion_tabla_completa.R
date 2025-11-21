# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 1: Construcción de Tabla de Mortalidad
# Script 05: Extrapolación y Tabla Completa
# ============================================================================

library(tidyverse)

# ============================================================================
# 1. CARGAR DATOS
# ============================================================================

load("../data/datos_periodo_analisis.RData")

# Cargar tasas graduadas
tabla_grad <- read.csv("../resultados/tasas_graduadas.csv")

# ============================================================================
# 2. SELECCIONAR MÉTODO DE GRADUACIÓN
# ============================================================================

# SELECCIONAR SEGÚN RESULTADOS DE BONDAD DE AJUSTE
# Opciones: qx_graduada_spline, qx_graduada_gompertz, qx_graduada_poly

metodo_seleccionado <- "qx_graduada_spline"  # Cambiar según tu análisis

cat("Método seleccionado: ", metodo_seleccionado, "\n")

tabla_grad <- tabla_grad %>%
  mutate(qx_final = !!as.name(metodo_seleccionado))

# ============================================================================
# 3. DEFINIR RANGOS PARA EXTRAPOLACIÓN
# ============================================================================

edad_minima_datos <- min(tabla_grad$edad)
edad_maxima_datos <- max(tabla_grad$edad)

edad_minima_tabla <- 10          # Cabeza: desde edad 10
edad_maxima_tabla <- 109         # Cola: hasta edad 109

cat("\n" %+% "="^80 %+% "\n")
cat("DEFINICIÓN DE RANGOS\n")
cat("="^80 %+% "\n")
cat("Rango de datos graduados:", edad_minima_datos, "-", edad_maxima_datos, "\n")
cat("Rango para tabla completa:", edad_minima_tabla, "-", edad_maxima_tabla, "\n")
cat("Cabeza (extrapolación inferior): 10 -", edad_minima_datos - 1, "\n")
cat("Núcleo (datos graduados):", edad_minima_datos, "-", edad_maxima_datos, "\n")
cat("Cola (extrapolación superior):", edad_maxima_datos + 1, "- 109\n")

# ============================================================================
# 4. MÉTODO DE EXTRAPOLACIÓN - CABEZA (Edades 10-x)
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("EXTRAPOLACIÓN INFERIOR (CABEZA)\n")
cat("="^80 %+% "\n")

# MÉTODO 1: Extensión lineal en escala log
# Ajustar recta a log(qx) en edades tempranas

datos_cabeza <- tabla_grad %>%
  filter(edad == min(edad)) %>%
  head(10)

if (nrow(datos_cabeza) > 1) {
  fit_cabeza <- lm(log(qx_final) ~ edad, data = datos_cabeza)
  
  # Extrapolación
  edades_cabeza <- 10:(edad_minima_datos - 1)
  qx_cabeza <- exp(predict(fit_cabeza, newdata = data.frame(edad = edades_cabeza)))
  qx_cabeza <- pmax(pmin(qx_cabeza, 1), 0)
  
  tabla_cabeza <- data.frame(
    edad = edades_cabeza,
    qx = qx_cabeza,
    fuente = "Extrapolación inferior"
  )
} else {
  tabla_cabeza <- data.frame(
    edad = integer(),
    qx = numeric(),
    fuente = character()
  )
}

cat("Cabeza extrapolada:", nrow(tabla_cabeza), "edades\n")

# ============================================================================
# 5. MÉTODO DE EXTRAPOLACIÓN - COLA (Edades x+1-109)
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("EXTRAPOLACIÓN SUPERIOR (COLA)\n")
cat("="^80 %+% "\n")

# MÉTODO 1: Extensión Gompertz en edades avanzadas
# Si qx_final sigue Gompertz: ln(qx) = a + b*edad

datos_cola <- tabla_grad %>%
  filter(qx_final > 0) %>%
  tail(20)

if (nrow(datos_cola) > 1) {
  fit_cola <- nls(
    qx_final ~ 1 - exp(-A * exp(B * edad)),
    data = datos_cola,
    start = list(A = 0.0001, B = 0.1),
    control = nls.control(maxiter = 1000),
    trace = FALSE
  )
  
  # Extrapolación
  edades_cola <- (edad_maxima_datos + 1):109
  qx_cola <- predict(fit_cola, newdata = data.frame(edad = edades_cola))
  qx_cola <- pmax(pmin(qx_cola, 1), 0)
  
  tabla_cola <- data.frame(
    edad = edades_cola,
    qx = qx_cola,
    fuente = "Extrapolación superior"
  )
} else {
  tabla_cola <- data.frame(
    edad = integer(),
    qx = numeric(),
    fuente = character()
  )
}

cat("Cola extrapolada:", nrow(tabla_cola), "edades\n")

# ============================================================================
# 6. CONSTRUIR TABLA COMPLETA
# ============================================================================

# Tabla central (datos graduados)
tabla_central <- tabla_grad %>%
  select(edad, qx_final) %>%
  rename(qx = qx_final) %>%
  mutate(fuente = "Datos graduados")

# Combinar cabeza, central y cola
tabla_completa_qx <- bind_rows(tabla_cabeza, tabla_central, tabla_cola) %>%
  arrange(edad) %>%
  filter(edad >= 10 & edad <= 109)

# ============================================================================
# 7. CONSTRUIR TABLA DE VIDA COMPLETA
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("CONSTRUCCIÓN TABLA DE VIDA\n")
cat("="^80 %+% "\n")

radix <- 10000000  # l(x) inicial

tabla_vida <- tabla_completa_qx %>%
  mutate(
    # l(x) - número de vivos
    lx = NA_real_,
    # d(x) - número de muertes
    dx = NA_real_,
    # p(x) - probabilidad de supervivencia
    px = 1 - qx,
    # L(x) - años persona vividos
    Lx = NA_real_,
    # T(x) - años persona total desde edad x
    Tx = NA_real_,
    # e(x) - esperanza de vida
    ex = NA_real_
  ) %>%
  select(edad, qx, px, lx, dx, Lx, Tx, ex)

# Calcular l(x)
tabla_vida$lx[1] <- radix
for (i in 2:nrow(tabla_vida)) {
  tabla_vida$lx[i] <- tabla_vida$lx[i-1] * tabla_vida$px[i-1]
}

# Calcular d(x)
tabla_vida$dx <- tabla_vida$lx * tabla_vida$qx

# Calcular L(x) (suponiendo muertes uniformes en el año)
tabla_vida$Lx <- tabla_vida$lx * tabla_vida$px + 0.5 * tabla_vida$dx

# Calcular T(x) - años persona acumulados
tabla_vida$Tx <- rev(cumsum(rev(tabla_vida$Lx)))

# Calcular e(x) - esperanza de vida
tabla_vida$ex <- tabla_vida$Tx / tabla_vida$lx

# ============================================================================
# 8. VERIFICACIONES
# ============================================================================

cat("\nVerificaciones:\n")
cat("- Rango de edades:", min(tabla_vida$edad), "a", max(tabla_vida$edad), "\n")
cat("- Registros totales:", nrow(tabla_vida), "\n")
cat("- l(0):", tabla_vida$lx[tabla_vida$edad == 10], "\n")
cat("- l(109):", tabla_vida$lx[tabla_vida$edad == 109], "\n")
cat("- e(10):", round(tabla_vida$ex[tabla_vida$edad == 10], 2), "años\n")

# Ver primeras y últimas filas
cat("\nPrimeras edades:\n")
print(head(tabla_vida, 10))

cat("\nÚltimas edades:\n")
print(tail(tabla_vida, 10))

# ============================================================================
# 9. GUARDAR RESULTADOS
# ============================================================================

write.csv(tabla_vida, "../resultados/tabla_vida_completa.csv", row.names = FALSE)
save(tabla_vida, file = "../data/tabla_vida_completa.RData")

cat("\nTabla de vida completa guardada.\n")

# ============================================================================
# 10. RESUMEN EJECUTIVO
# ============================================================================

resumen_tabla <- data.frame(
  Concepto = c(
    "Edad mínima",
    "Edad máxima",
    "l(10)",
    "l(109)",
    "Número de edades",
    "Total de muertes",
    "Esperanza de vida a los 10",
    "Esperanza de vida a los 40",
    "Esperanza de vida a los 65"
  ),
  Valor = c(
    min(tabla_vida$edad),
    max(tabla_vida$edad),
    round(tabla_vida$lx[tabla_vida$edad == 10], 0),
    round(tabla_vida$lx[tabla_vida$edad == 109], 0),
    nrow(tabla_vida),
    round(sum(tabla_vida$dx), 0),
    round(tabla_vida$ex[tabla_vida$edad == 10], 2),
    round(tabla_vida$ex[tabla_vida$edad == 40], 2),
    round(tabla_vida$ex[tabla_vida$edad == 65], 2)
  )
)

write.csv(resumen_tabla, "../resultados/resumen_tabla_vida.csv", row.names = FALSE)

cat("\n" %+% "="^80 %+% "\n")
cat(resumen_tabla$Concepto, "\n")
for (i in 1:nrow(resumen_tabla)) {
  cat(resumen_tabla$Concepto[i], ":", resumen_tabla$Valor[i], "\n")
}
