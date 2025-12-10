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

# head(base)
# summary(base$FNAC)
# summary(base$FMUERTE)

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
