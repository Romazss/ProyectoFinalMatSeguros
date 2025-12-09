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
mortalidad.WH <- WH(base2$Muertes, base2$Exposicion)
TasasEsperadas <- exp(mortalidad.WH$y_hat)              # m_x suavizada
MuertesEsperadas <- base2$Exposicion * TasasEsperadas   # E_x * m_x

plot(base2$edad, base2$TasaBruta,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Tasa de Mortalidad con curva WH")
lines(base2$edad, TasasEsperadas, lwd = 3, col = "lightblue")

# Suavizamento Whittaker con MortalityTables
obsTable = mortalityTable.period(
  name = "Tabla observada",
  ages = base2$edad,
  deathProbs = base2$TasaBruta,
  exposures = base2$Exposicion)
obsTable.suave1 = whittaker.mortalityTable(obsTable,
                                           lambda = 1/50, d = 2, name.postfix = "smoothed (d=2, lambda=1/10)")

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

# Datos de referencia 0–9 años
ref_0_9 <- data %>% select(edad = Edad, qx) %>%
  filter(edad >= 0, edad <= 9)

fit_OP <- MortalityLaw(
  x  = ref_0_9$edad,
  qx = ref_0_9$qx,
  law = "opperman"
)

edad_0_9 <- 0:9
qx_OP <- predict(fit_OP, x = edad_0_9)

tabla_OP <- data.frame(
  edad  = edad_0_9,
  qx_OP = qx_OP
)

## 2) AJUSTE HELIGMAN–POLLARD EN TRAMO ESTABLE ----------

# base2: tabla asignada con edades 20–84 y TasaBruta = qx observada

fit_HP <- MortalityLaw(
  x  = base2$edad,
  qx = base2$TasaBruta,
  law = "HP"
)

# predecir HP para 10–109
edad_HP_all <- 10:109
qx_HP <- predict(fit_HP, x = edad_HP_all)

tabla_HP <- data.frame(
  edad  = edad_HP_all,
  qx_HP = qx_HP
)

# combinar HP con observados en 20–84
tabla_HP_obs <- tabla_HP %>%
  left_join(base2 %>% select(edad, qx_obs = TasaBruta), by = "edad") %>%
  mutate(
    qx_HP_obs = case_when(
      edad >= 20 & edad <= 84 ~ qx_obs,  # tramo observado
      TRUE                    ~ qx_HP    # cabeza 10–19 y cola 85–109
    )
  )


## 3) UNIR TODO: OPPEMAN (0–9) + HP/OBSERVADOS (10–109) -----------------

tabla_completa <- tabla_OP %>%
  rename(qx_infantil = qx_OP) %>%
  full_join(
    tabla_HP_obs %>% select(edad, qx_HP_obs),
    by = "edad"
  ) %>%
  mutate(
    qx_final = case_when(
      edad <= 9           ~ qx_infantil,  # 0–9: Opperman
      TRUE                ~ qx_HP_obs     # 10–109: HP + observados
    )
  ) %>%
  arrange(edad)

plot(tabla_completa$edad, tabla_completa$qx_final,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = "Tasa de mortalidad",
     main = "Extrapolación Heligman–Pollard y Opperman")
lines(tabla_completa$edad[0:9], tabla_completa$qx_final[0:9], lwd = 3, col="lightgreen")
lines(tabla_completa$edad[10:19], tabla_completa$qx_final[10:19], lwd = 3, col="lightblue")
lines(tabla_completa$edad[85:110], tabla_completa$qx_final[85:110], lwd = 3, col="lightpink")

tabla_extrapolada <- tabla_completa %>%
  select(edad, qx = qx_final)

library(openxlsx)
write.xlsx(tabla_extrapolada, file = "tabla_extrapolada.xlsx")
