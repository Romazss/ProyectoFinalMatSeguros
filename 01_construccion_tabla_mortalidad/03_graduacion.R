# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 1: Construcción de Tabla de Mortalidad
# Script 03: Graduación y Ajuste de Tasas
# ASIGNACIÓN: Origen=2, TM_SEXO=M (INVALIDEZ 2014 - Masculino)
# ============================================================================

library(tidyverse)
library(splines)        # Para suavizamiento

# ============================================================================
# 1. CARGAR DATOS
# ============================================================================

load("../data/datos_periodo_analisis.RData")

# ============================================================================
# 2. CALCULAR TASAS BRUTAS DE MORTALIDAD
# ============================================================================

# Crear tabla de tasas crudas por edad
# (Ajustar nombre de columnas según tu base de datos)

tasas_brutas <- datos_periodo %>%
  group_by(edad) %>%
  summarise(
    expuestos = n(),
    muertes = sum(muerte, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    qx_bruto = muertes / expuestos,
    qx_bruto = pmax(qx_bruto, 0),
    qx_bruto = pmin(qx_bruto, 1)
  ) %>%
  arrange(edad)

cat("Tasas brutas de mortalidad por edad:\n")
print(head(tasas_brutas, 20))

# ============================================================================
# 3. DEFINIR EDADES LÍMITES
# ============================================================================

# IMPORTANTE: Definir edades límites para graduación
# Generalmente se excluyen edades muy jóvenes y muy viejas con pocos datos

# Análisis: Buscar edades con suficiente exposición
edades_info <- tasas_brutas %>%
  arrange(edad) %>%
  mutate(
    datos_suficientes = case_when(
      expuestos >= 30 & muertes >= 5 ~ TRUE,
      TRUE ~ FALSE
    )
  )

cat("\n" %+% "="^80 %+% "\n")
cat("ANÁLISIS DE EDADES LÍMITES\n")
cat("="^80 %+% "\n")

edad_minima_valida <- min(edades_info$edad[edades_info$datos_suficientes])
edad_maxima_valida <- max(edades_info$edad[edades_info$datos_suficientes])

cat("Edad mínima con datos suficientes:", edad_minima_valida, "\n")
cat("Edad máxima con datos suficientes:", edad_maxima_valida, "\n")

print(edades_info)

# ============================================================================
# 4. SELECCIONAR RANGO PARA GRADUACIÓN
# ============================================================================

# NOTA: Ajustar estas edades según el análisis anterior
edad_inicio_grad <- edad_minima_valida
edad_fin_grad <- edad_maxima_valida

cat("\nRango seleccionado para graduación: ", edad_inicio_grad, " - ", edad_fin_grad, "\n")

tasas_para_graduar <- tasas_brutas %>%
  filter(edad >= edad_inicio_grad & edad <= edad_fin_grad)

# ============================================================================
# 5. MÉTODOS DE GRADUACIÓN
# ============================================================================

# MÉTODO 1: Spline cúbica (recomendado para este tipo de datos)
# --------

cat("\n" %+% "="^80 %+% "\n")
cat("MÉTODO 1: SPLINE CÚBICA\n")
cat("="^80 %+% "\n")

# Ajustar spline cúbica
spline_grad <- smooth.spline(
  x = tasas_para_graduar$edad,
  y = tasas_para_graduar$qx_bruto,
  df = length(unique(tasas_para_graduar$edad)) / 3,  # Parámetro de suavidad
  cv = FALSE
)

# Predecir para todas las edades en el rango
qx_spline <- predict(spline_grad, x = tasas_para_graduar$edad)
tasas_para_graduar$qx_graduada_spline <- pmax(pmin(qx_spline$y, 1), 0)

cat("Spline ajustada. Parámetro de suavidad (df):", spline_grad$df, "\n")

# MÉTODO 2: Gompertz
# --------

cat("\nMÉTODO 2: MODELO GOMPERTZ\n")

# Ajustar modelo Gompertz: qx = A * exp(B * edad)
datos_gompertz <- tasas_para_graduar %>%
  filter(qx_bruto > 0)

fit_gompertz <- nls(
  qx_bruto ~ A * exp(B * edad),
  data = datos_gompertz,
  start = list(A = 0.0001, B = 0.1),
  control = nls.control(maxiter = 1000),
  trace = TRUE
)

tasas_para_graduar$qx_graduada_gompertz <- 
  predict(fit_gompertz, newdata = tasas_para_graduar)

cat("Modelo Gompertz ajustado.\n")
print(summary(fit_gompertz))

# MÉTODO 3: Polinomio (log de tasas)
# --------

cat("\nMÉTODO 3: POLINOMIO DE GRADO 3\n")

# Ajustar polinomio a log(qx)
datos_poly <- tasas_para_graduar %>%
  filter(qx_bruto > 0) %>%
  mutate(log_qx = log(qx_bruto))

fit_poly <- lm(log_qx ~ poly(edad, 3), data = datos_poly)

tasas_para_graduar$log_qx_poly <- 
  predict(fit_poly, newdata = tasas_para_graduar)
tasas_para_graduar$qx_graduada_poly <- exp(tasas_para_graduar$log_qx_poly)

cat("Polinomio ajustado.\n")
print(summary(fit_poly))

# ============================================================================
# 6. GUARDAR TASAS GRADUADAS
# ============================================================================

tabla_graduacion <- tasas_para_graduar %>%
  select(edad, expuestos, muertes, qx_bruto, qx_graduada_spline, 
         qx_graduada_gompertz, qx_graduada_poly)

write.csv(tabla_graduacion, "../resultados/tasas_graduadas.csv", row.names = FALSE)

cat("\nTasas graduadas guardadas en resultados/tasas_graduadas.csv\n")
cat("Seleccionar el método más apropiado basado en el análisis de bondad de ajuste.\n")

# ============================================================================
# 7. GUARDAR MODELOS
# ============================================================================

save(spline_grad, fit_gompertz, fit_poly, 
     file = "../data/modelos_graduacion.RData")

cat("\nModelos guardados.\n")
