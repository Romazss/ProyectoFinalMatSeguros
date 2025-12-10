###############
# Tarea Final #
###############

library(dplyr)
# library(tidyverse); library(lubridate); library(splines)
library(purrr); library(tidyr)
# Test bondad de ajuste
library(randtests) # runs.test
library(BSDA)      # SIGN.test
library(tseries)   # test rachas
# Suavizamiento Whittaker
library(WH); library(MortalityTables)
# Extrapolacion
library(MortalityLaws)

# Origen = 2 y TM_SEXO = M
base <- baseR |>
  filter(Origen == 2, TM_SEXO == "M") |>
  select(FNAC = TM_FEC_NAC, FMUERTE = TM_FEC_FALL)

base <- base |>
  mutate(
    FNAC = na_if(FNAC, 0),
    FMUERTE = na_if(FMUERTE, 0),
    
    FNAC = as.Date(as.character(FNAC), format = "%Y%m%d"),
    FMUERTE = as.Date(as.character(FMUERTE), format = "%Y%m%d")
  )

head(base)
summary(base$FNAC)
summary(base$FMUERTE)

# Parámetros de estudio
study_start <- as.Date("2000-01-01")
study_end <- as.Date("2012-12-31")

# Ventana de observación por persona
df_obs <- base %>%
  mutate(
    # fecha de salida: muerte si cae dentro de la ventana; si no, censura al study_end
    death_in_window = !is.na(FMUERTE) & FMUERTE >= study_start & FMUERTE <= study_end,
    end_obs  = if_else(!is.na(FMUERTE) & FMUERTE <= study_end, FMUERTE, study_end),
    start_obs = pmax(FNAC, study_start)
  ) %>%
  filter(end_obs > start_obs) 

# Edades al inicio y final del estudio
to_years <- function(d2, d1) as.numeric(difftime(d2, d1, units = "days"))/365.25

df_obs <- df_obs %>%
  mutate(
    age_start = to_years(start_obs, FNAC),
    age_end   = to_years(end_obs,   FNAC),
    age_death = if_else(death_in_window, floor(to_years(FMUERTE, FNAC)), NA_integer_)
  )

# Repartir exposición por edades [x, x+1)
expo_por_edad <- function(a0, a1) {
  if (is.na(a0) || is.na(a1) || a1 <= a0) return(tibble(edad = integer(0), expos = numeric(0)))
  e0 <- floor(a0); e1 <- floor(a1)
  edades <- e0:e1
  tibble(
    edad = edades,
    expos = map_dbl(edades, function(e){
      left  <- max(e, a0)
      right <- min(e + 1, a1)
      max(0, right - left)
    })
  )
}

# Expandir persona-edad
# Utilizar vectores en el código para optimizar
datos_long <- df_obs %>%
  mutate(contrib = pmap(list(age_start, age_end), expo_por_edad)) %>%
  select(age_death, contrib) %>%
  unnest(contrib) %>%
  mutate(muerta_en_edad = as.integer(!is.na(age_death) & age_death == edad))

tabla_expo <- datos_long %>%
  group_by(edad) %>%
  summarise(
    Exposicion = sum(expos, na.rm = TRUE),
    Muertes    = sum(muerta_en_edad, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(edad) %>%
  mutate(TasaBruta = ifelse(Exposicion > 0, Muertes/Exposicion, NA_real_))

View(tabla_expo)

plot(tabla_expo$edad, tabla_expo$TasaBruta,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Tasa de Mortalidad general")

# library(openxlsx)
# write.xlsx(tabla_expo, file = "tabla_expo.xlsx")

# Número de registros y muertes originales
nrow(base); sum(1-is.na(base$FMUERTE))

# Número de registros y muertes en el análisis
nrow(df_obs); sum(df_obs$death_in_window)

# Edades limites: rango estable de edades
base2 <- tabla_expo %>% filter(edad >= 20, edad < 85)

# Suavizamiento Whittaker con WH
# mortalidad.WH <- WH(base2$Muertes, base2$Exposicion)
# TasasEsperadas <- exp(mortalidad.WH$y_hat)              # m_x suavizada
# MuertesEsperadas <- base2$Exposicion * TasasEsperadas   # E_x * m_x

# plot(base2$edad, base2$TasaBruta,
#      type = "p", pch = 19, col = "gray40",
#      xlab = "Edad", ylab = "Tasa de mortalidad",
#      main = "Tasa de Mortalidad con curva WH")
# lines(base2$edad, TasasEsperadas, lwd = 3, col = "lightblue")

# Suavizamento Whittaker con MortalityTables
obsTable = mortalityTable.period(
  name = "Tabla observada",
  ages = base2$edad,
  deathProbs = base2$TasaBruta,
  exposures = base2$Exposicion)
obsTable.suave1 = whittaker.mortalityTable(obsTable,
                                           lambda = 1/50, d = 2, name.postfix = "smoothed (d=2, lambda=1/10)")

base2$TasasEsperadas.2 <- obsTable.suave1@deathProbs
TasasEsperadas.2 <- obsTable.suave1@deathProbs
plot(base2$edad, base2$TasaBruta,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Tasa de Mortalidad con curva WH")
lines(base2$edad, TasasEsperadas.2, lwd = 3, col="red")

MuertesEsperadas.2 <- base2$Exposicion * TasasEsperadas.2   # E_x * m_x

# Test bondad de ajuste

# KS (indicativo)
ks_res <- ks.test(base2$Muertes,
                  MuertesEsperadas.2)
ks_res

# Test del signo
signo <- base2$Muertes - MuertesEsperadas.2
sign_res <- SIGN.test(signo, md = 0, alternative = "two.sided")

sign_res

# Chi-cuadrado de Pearson
chi_val <- sum((base2$Muertes - MuertesEsperadas.2)^2 /
                 pmax(MuertesEsperadas.2, .Machine$double.eps))
gl <- nrow(base2) - 1
p_chi <- 1 - pchisq(chi_val, df = gl)

p_chi

## Test de rachas
tseries::runs.test(as.factor(
  ifelse(base2$Muertes > MuertesEsperadas.2, 1, 0)))

# Extrapolación
library(readxl)
data <- read_excel("TablaRef.xlsx", sheet = 1)

# Chequear leyes de mortalidad disponibles
availableLaws()

plot(data$Edad[0:10], data$qx[0:10],
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Extrapolación Heligman–Pollard")

# base2: tabla asignada con edades 20–84 y TasaBruta = qx observada

fit_HP <- MortalityLaw(
  x  = base2$edad,
  qx = TasasEsperadas.2,
  law = "HP"
)

# predecir HP para 10–109
edad_HP_all <- 10:109
qx_HP <- predict(fit_HP, x = edad_HP_all)

tabla_HP <- data.frame(
  edad  = edad_HP_all,
  qx_HP = qx_HP
)

# Opperman
ref_0_9 <- data %>% select(edad = Edad, qx_ref = qx) %>%
  filter(edad >= 0, edad <= 9)

fit_OP <- MortalityLaw(
  x  = ref_0_9$edad,
  qx = ref_0_9$qx_ref,
  law = "opperman"
)

# Predecimos Opperman en 0–10 (10 solo para poder escalar)
edad_OP_all <- 0:10
qx_OP_all   <- predict(fit_OP, x = edad_OP_all)

# Separar qx Opperman en 0–9
edad_OP_0_9 <- 0:9
qx_OP_0_9   <- qx_OP_all[edad_OP_all <= 9]

# Valor de Opperman en 10 (para el empalme de nivel)
qx_OP_10 <- qx_OP_all[edad_OP_all == 10]

## 2) Obtener qx de HP en 10 (escala de tu población) -------------------

# Si ya tienes fit_HP (ajustado sobre tus datos/WH):
qx_HP_10 <- tabla_HP %>%
  filter(edad == 10) %>%
  pull(qx_HP)


## 3) Calcular factor de escala y re-escalar Opperman -------------------

factor <- qx_HP_10 / qx_OP_10   # generalmente < 1 en tu caso

qx_OP_0_9_scaled <- qx_OP_0_9 * factor

tabla_OP_scaled <- data.frame(
  edad   = edad_OP_0_9,
  qx_inf = qx_OP_0_9_scaled   # qx infantil ajustado a la escala de tu población
)


## 4) Armar tabla final (ejemplo de unión con el resto) -----------------
# Aquí solo te muestro cómo podrías engancharlo.
# Supongamos que ya tienes:
# - tabla_WH: edades 20–84 con qx_WH (graduado WH)
# - tabla_HP_total: qx de HP para 10–109 (cabeza y cola)

# Ejemplo:
edad_HP_all <- 10:109
qx_HP_all   <- predict(fit_HP, x = edad_HP_all)

tabla_HP_total <- data.frame(
  edad  = edad_HP_all,
  qx_HP = qx_HP_all
)

# Tramo observado graduado (20–84)
# (ajusta nombres según tu objeto real de WH)
tabla_WH <- base2 %>%
  select(edad, qx_WH = TasasEsperadas.2)

# Construimos qx_final siguiendo:
# 0–9: infantil ajustado
# 10–19: HP
# 20–84: WH
# 85–109: HP

tabla_final <- bind_rows(
  # 0–9: Opperman escalado
  tabla_OP_scaled %>%
    transmute(edad, qx_final = qx_inf),
  
  # 10–19 y 85–109: HP
  tabla_HP_total %>%
    transmute(edad, qx_final = qx_HP),
  
  # 20–84: WH (reemplaza el HP en ese tramo)
  tabla_WH %>%
    transmute(edad, qx_final = qx_WH)
) %>%
  arrange(edad) %>%
  distinct(edad, .keep_all = TRUE)

plot(tabla_final$edad, tabla_final$qx_final,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Extrapolación Heligman–Pollard y Opperman")

tabla_extrapolada <- tabla_final %>%
  select(edad, qx = qx_final)

plot(tabla_extrapolada$edad, tabla_extrapolada$qx,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Extrapolación Heligman–Pollard y Opperman")
lines(tabla_extrapolada$edad[0:9], tabla_extrapolada$qx[0:9], lwd = 4, col="lightgreen")
lines(tabla_extrapolada$edad[10:19], tabla_extrapolada$qx[10:19], lwd = 4, col="lightblue")
lines(tabla_extrapolada$edad[85:110], tabla_extrapolada$qx[85:110], lwd = 4, col="lightblue")

# library(openxlsx)
# write.xlsx(tabla_extrapolada, file = "tabla_extrapolada2.xlsx")

#######################################
# VISUALIZACIONES CON GGPLOT2         #
#######################################

library(ggplot2)
library(scales)

# Tema personalizado para los gráficos
tema_informe <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray50"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# 1. Tasa bruta de mortalidad (datos completos)
g1 <- ggplot(tabla_expo, aes(x = edad, y = TasaBruta)) +
  geom_point(color = "gray40", size = 1.5, alpha = 0.7) +
  labs(
    title = "Tasa Bruta de Mortalidad por Edad",
    subtitle = "Población masculina, Origen 2 (2000-2012)",
    x = "Edad (años)",
    y = expression(q[x] ~ "(Tasa de mortalidad)")
  ) +
  tema_informe
print(g1)

# 2. Comparación: Tasa bruta vs Suavizada (Whittaker)
g2 <- ggplot(base2, aes(x = edad)) +
  geom_point(aes(y = TasaBruta, color = "Observada"), size = 2, alpha = 0.6) +
  geom_line(aes(y = TasasEsperadas.2, color = "Suavizada (WH)"), linewidth = 1.2) +
  scale_color_manual(
    name = "Tipo",
    values = c("Observada" = "gray40", "Suavizada (WH)" = "firebrick")
  ) +
  labs(
    title = "Graduación Whittaker-Henderson",
    subtitle = "Edades 20-84 años",
    x = "Edad (años)",
    y = expression(q[x] ~ "(Tasa de mortalidad)")
  ) +
  tema_informe
print(g2)

# 3. Escala logarítmica para visualizar mejor el patrón
g3 <- ggplot(base2, aes(x = edad)) +
  geom_point(aes(y = TasaBruta, color = "Observada"), size = 2, alpha = 0.6) +
  geom_line(aes(y = TasasEsperadas.2, color = "Suavizada (WH)"), linewidth = 1.2) +
  scale_y_log10(labels = scales::scientific) +
  scale_color_manual(
    name = "Tipo",
    values = c("Observada" = "gray40", "Suavizada (WH)" = "firebrick")
  ) +
  labs(
    title = "Graduación Whittaker-Henderson (Escala Log)",
    subtitle = "Edades 20-84 años",
    x = "Edad (años)",
    y = expression(log(q[x]))
  ) +
  tema_informe
print(g3)

# 4. Tabla extrapolada completa con tramos diferenciados
tabla_final_graf <- tabla_final %>%
  mutate(
    tramo = case_when(
      edad <= 9 ~ "Opperman (0-9)",
      edad <= 19 ~ "HP (10-19)",
      edad <= 84 ~ "WH (20-84)",
      TRUE ~ "HP (85-109)"
    ),
    tramo = factor(tramo, levels = c("Opperman (0-9)", "HP (10-19)", 
                                     "WH (20-84)", "HP (85-109)"))
  )

g4 <- ggplot(tabla_final_graf, aes(x = edad, y = qx_final, color = tramo)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1, alpha = 0.7) +
  scale_color_manual(
    name = "Método de ajuste",
    values = c("Opperman (0-9)" = "forestgreen", 
               "HP (10-19)" = "steelblue",
               "WH (20-84)" = "firebrick", 
               "HP (85-109)" = "steelblue")
  ) +
  labs(
    title = "Tabla de Mortalidad Completa",
    subtitle = "Combinación: Opperman + Heligman-Pollard + Whittaker-Henderson",
    x = "Edad (años)",
    y = expression(q[x] ~ "(Probabilidad de muerte)")
  ) +
  tema_informe
print(g4)

# 5. Escala logarítmica de la tabla completa
g5 <- ggplot(tabla_final_graf, aes(x = edad, y = qx_final, color = tramo)) +
  geom_line(linewidth = 1.2) +
  scale_y_log10(labels = scales::scientific) +
  scale_color_manual(
    name = "Método de ajuste",
    values = c("Opperman (0-9)" = "forestgreen", 
               "HP (10-19)" = "steelblue",
               "WH (20-84)" = "firebrick", 
               "HP (85-109)" = "steelblue")
  ) +
  labs(
    title = "Tabla de Mortalidad Completa (Escala Log)",
    subtitle = "Combinación: Opperman + Heligman-Pollard + Whittaker-Henderson",
    x = "Edad (años)",
    y = expression(log(q[x]))
  ) +
  tema_informe
print(g5)

# 6. Exposición y muertes por edad
g6 <- ggplot(base2, aes(x = edad)) +
  geom_bar(aes(y = Exposicion), stat = "identity", fill = "steelblue", alpha = 0.6) +
  geom_line(aes(y = Muertes * max(Exposicion)/max(Muertes)), 
            color = "firebrick", linewidth = 1) +
  scale_y_continuous(
    name = "Exposición (años-persona)",
    sec.axis = sec_axis(~ . * max(base2$Muertes)/max(base2$Exposicion), 
                        name = "Muertes")
  ) +
  labs(
    title = "Exposición y Muertes por Edad",
    subtitle = "Edades 20-84 años",
    x = "Edad (años)"
  ) +
  tema_informe
print(g6)

# 7. Residuos del ajuste Whittaker
base2 <- base2 %>%
  mutate(
    residuo = Muertes - MuertesEsperadas.2,
    residuo_std = residuo / sqrt(pmax(MuertesEsperadas.2, 0.01))
  )

g7 <- ggplot(base2, aes(x = edad, y = residuo_std)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = c(-2, 2), linetype = "dotted", color = "firebrick") +
  geom_point(color = "steelblue", size = 2) +
  geom_line(color = "steelblue", alpha = 0.5) +
  labs(
    title = "Residuos Estandarizados del Ajuste Whittaker",
    subtitle = "Líneas punteadas: ±2 desviaciones estándar",
    x = "Edad (años)",
    y = "Residuo estandarizado"
  ) +
  tema_informe
print(g7)


#######################################
# INFORMACIÓN PARA EL INFORME         #
#######################################

cat("\n========================================\n")
cat("   RESUMEN ESTADÍSTICO PARA INFORME   \n")
cat("========================================\n\n")

# 1. Información de la base de datos
cat("1. DESCRIPCIÓN DE LA BASE DE DATOS\n")
cat("-----------------------------------\n")
cat("• Población: Masculina (TM_SEXO = 'M'), Origen = 2\n")
cat("• Período de estudio:", format(study_start, "%d/%m/%Y"), "-", 
    format(study_end, "%d/%m/%Y"), "\n")
cat("• Registros originales:", format(nrow(base), big.mark = "."), "\n")
cat("• Muertes en base original:", format(sum(!is.na(base$FMUERTE)), big.mark = "."), "\n")
cat("• Registros en análisis:", format(nrow(df_obs), big.mark = "."), "\n")
cat("• Muertes en ventana de observación:", format(sum(df_obs$death_in_window), big.mark = "."), "\n\n")

# 2. Exposición total
cat("2. EXPOSICIÓN Y MORTALIDAD\n")
cat("--------------------------\n")
cat("• Exposición total (años-persona):", format(round(sum(tabla_expo$Exposicion, na.rm = TRUE), 2), big.mark = "."), "\n")
cat("• Total de muertes:", format(sum(tabla_expo$Muertes, na.rm = TRUE), big.mark = "."), "\n")
cat("• Tasa cruda global:", round(sum(tabla_expo$Muertes)/sum(tabla_expo$Exposicion), 6), "\n")
cat("• Rango de edades observadas:", min(tabla_expo$edad), "-", max(tabla_expo$edad), "años\n")
cat("• Rango para graduación (base2):", min(base2$edad), "-", max(base2$edad), "años\n\n")

# 3. Estadísticas de la graduación
cat("3. GRADUACIÓN WHITTAKER-HENDERSON\n")
cat("---------------------------------\n")
cat("• Parámetro lambda: 1/50 = 0.02\n")
cat("• Orden de diferencias (d): 2\n")
cat("• qx mínimo suavizado:", format(min(TasasEsperadas.2), scientific = TRUE, digits = 4), "\n")
cat("• qx máximo suavizado:", format(max(TasasEsperadas.2), scientific = TRUE, digits = 4), "\n\n")

# 4. Tests de bondad de ajuste
cat("4. TESTS DE BONDAD DE AJUSTE\n")
cat("----------------------------\n")
cat("• Test KS:\n")
cat("    - Estadístico D:", round(ks_res$statistic, 4), "\n")
cat("    - p-valor:", format(ks_res$p.value, scientific = TRUE, digits = 4), "\n")
cat("    - Conclusión:", ifelse(ks_res$p.value > 0.05, "No se rechaza H0 (α=0.05)", "Se rechaza H0 (α=0.05)"), "\n\n")

cat("• Test del Signo:\n")
cat("    - Estadístico S:", sign_res$statistic, "\n")
cat("    - p-valor:", format(sign_res$p.value, digits = 4), "\n")
cat("    - Conclusión:", ifelse(sign_res$p.value > 0.05, "No se rechaza H0 (α=0.05)", "Se rechaza H0 (α=0.05)"), "\n\n")

cat("• Test Chi-Cuadrado:\n")
cat("    - Estadístico χ²:", round(chi_val, 2), "\n")
cat("    - Grados de libertad:", gl, "\n")
cat("    - p-valor:", format(p_chi, scientific = TRUE, digits = 4), "\n")
cat("    - Conclusión:", ifelse(p_chi > 0.05, "No se rechaza H0 (α=0.05)", "Se rechaza H0 (α=0.05)"), "\n\n")

# 5. Extrapolación
cat("5. EXTRAPOLACIÓN\n")
cat("----------------\n")
cat("• Tramo infantil (0-9): Ley de Opperman\n")
cat("• Tramo juvenil (10-19): Heligman-Pollard\n")
cat("• Tramo adulto (20-84): Whittaker-Henderson\n")
cat("• Tramo senil (85-109): Heligman-Pollard\n")
cat("• Factor de escala Opperman:", round(factor, 6), "\n\n")

# 6. Tabla final
cat("6. TABLA FINAL EXTRAPOLADA\n")
cat("--------------------------\n")
cat("• Rango de edades:", min(tabla_extrapolada$edad), "-", max(tabla_extrapolada$edad), "años\n")
cat("• qx edad 0:", format(tabla_extrapolada$qx[tabla_extrapolada$edad == 0], scientific = TRUE, digits = 4), "\n")
cat("• qx edad 30:", format(tabla_extrapolada$qx[tabla_extrapolada$edad == 30], scientific = TRUE, digits = 4), "\n")
cat("• qx edad 65:", format(tabla_extrapolada$qx[tabla_extrapolada$edad == 65], scientific = TRUE, digits = 4), "\n")
cat("• qx edad 85:", format(tabla_extrapolada$qx[tabla_extrapolada$edad == 85], scientific = TRUE, digits = 4), "\n")

# Crear data.frame resumen para exportar
resumen_informe <- data.frame(
  Metrica = c(
    "Registros originales", "Muertes en base", "Registros en análisis",
    "Muertes en ventana", "Exposición total", "Total muertes (análisis)",
    "Tasa cruda global", "KS p-valor", "Signo p-valor", "Chi2 p-valor",
    "Factor escala Opperman"
  ),
  Valor = c(
    nrow(base), sum(!is.na(base$FMUERTE)), nrow(df_obs),
    sum(df_obs$death_in_window), round(sum(tabla_expo$Exposicion), 2),
    sum(tabla_expo$Muertes), round(sum(tabla_expo$Muertes)/sum(tabla_expo$Exposicion), 6),
    round(ks_res$p.value, 6), round(sign_res$p.value, 6), round(p_chi, 6),
    round(factor, 6)
  )
)

cat("\n• Data frame 'resumen_informe' creado con métricas clave\n")
cat("• Gráficos guardados en variables g1 a g7\n")

# Guardar gráficos (opcional)
ggsave("g1_tasa_bruta.png", g1, width = 10, height = 6, dpi = 300)
ggsave("g2_whittaker.png", g2, width = 10, height = 6, dpi = 300)
ggsave("g4_tabla_completa.png", g4, width = 12, height = 6, dpi = 300)

