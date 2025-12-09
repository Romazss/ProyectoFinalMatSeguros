
###############################################################################
# TAREA FINAL EYP2605 - TABLA DE MORTALIDAD (VERSIÓN OPTIMIZADA)
# Asignación: Origen = 2, Sexo = M (Invalidez Masculino)
# Esteban Román y Juan pablo Cuevas
###############################################################################

# Limpiar entorno
rm(list = ls())
gc()

# ============================================
# PASO 1: LIBRERÍAS
# ============================================
library(data.table)
library(dplyr)
library(readxl)
library(openxlsx)
library(MortalityTables)

# ============================================
# PASO 2: PARÁMETROS GLOBALES
# ============================================
L0 <- 10000000L
i  <- 0.05
v  <- 1 / (1 + i)
STUDY_START <- as.Date("2000-01-01")
STUDY_END   <- as.Date("2012-12-31")

# ============================================
# PASO 3: CARGAR DATOS
# ============================================
load("base_act.RData")

dt_base <- as.data.table(baseR)[
  Origen == 2 & TM_SEXO == "M",
  .(FNAC = TM_FEC_NAC, FMUERTE = TM_FEC_FALL)
]

dt_base[, `:=`(
  FNAC    = fifelse(FNAC == 0, NA_integer_, FNAC),
  FMUERTE = fifelse(FMUERTE == 0, NA_integer_, FMUERTE)
)]

dt_base[, `:=`(
  FNAC    = as.Date(as.character(FNAC), format = "%Y%m%d"),
  FMUERTE = as.Date(as.character(FMUERTE), format = "%Y%m%d")
)]

cat("Registros cargados:", nrow(dt_base), "\n")

# ============================================
# PASO 4: VENTANA DE OBSERVACIÓN
# ============================================
dt_obs <- copy(dt_base)

dt_obs[, `:=`(
  death_in_window = !is.na(FMUERTE) & FMUERTE >= STUDY_START & FMUERTE <= STUDY_END,
  end_obs = fifelse(!is.na(FMUERTE) & FMUERTE <= STUDY_END, FMUERTE, STUDY_END),
  start_obs = pmax(FNAC, STUDY_START)
)]

dt_obs <- dt_obs[end_obs > start_obs]

to_years <- function(d2, d1) as.numeric(d2 - d1) / 365.25

dt_obs[, `:=`(
  age_start = to_years(start_obs, FNAC),
  age_end   = to_years(end_obs, FNAC),
  age_death = fifelse(death_in_window, as.integer(floor(to_years(FMUERTE, FNAC))), NA_integer_)
)]

dt_obs[, id := .I]

cat("Registros en análisis:", nrow(dt_obs), "\n")
cat("Muertes en ventana:", sum(dt_obs$death_in_window), "\n")

# ============================================
# PASO 5: CÁLCULO DE EXPOSICIÓN (VECTORIZADO)
# ============================================
cat("\nCalculando exposición...\n")
t0 <- Sys.time()

dt_exp <- dt_obs[, {
  e0 <- floor(age_start)
  e1 <- floor(age_end)
  edades <- e0:e1
  left  <- pmax(edades, age_start)
  right <- pmin(edades + 1, age_end)
  .(
    edad = edades,
    expos = pmax(0, right - left),
    muerta_en_edad = as.integer(!is.na(age_death) & age_death == edades)
  )
}, by = id]

tabla_expo <- dt_exp[, .(
  Exposicion = sum(expos),
  Muertes = sum(muerta_en_edad)
), by = edad][order(edad)]

tabla_expo <- tabla_expo[Exposicion > 0]
tabla_expo[, TasaBruta := Muertes / Exposicion]

cat("Tiempo:", round(difftime(Sys.time(), t0, units = "secs"), 2), "seg\n")

plot(tabla_expo$edad, tabla_expo$TasaBruta,
     type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = expression(q[x]),
     main = "Tasas de Mortalidad Brutas")

# ============================================
# PASO 6: VERIFICACIÓN
# ============================================
cat("\n=== RESUMEN ===\n")
cat("Exposición total:", round(sum(tabla_expo$Exposicion), 2), "\n")
cat("Muertes totales:", sum(tabla_expo$Muertes), "\n")

# ============================================
# PASO 7: SUAVIZAMIENTO WHITTAKER
# ============================================
base2 <- tabla_expo[edad >= 20 & edad < 85]

obsTable <- mortalityTable.period(
  name = "Observada",
  ages = base2$edad,
  deathProbs = base2$TasaBruta,
  exposures = base2$Exposicion
)

obsTable.suave <- whittaker.mortalityTable(obsTable, lambda = 1/50, d = 2)

TasasSuavizadas <- obsTable.suave@deathProbs
MuertesEsperadas <- base2$Exposicion * TasasSuavizadas

base2[, qx_suavizado := TasasSuavizadas]
base2[, muertes_esp := MuertesEsperadas]

plot(base2$edad, base2$TasaBruta, type = "p", pch = 19, col = "gray40",
     xlab = "Edad", ylab = expression(q[x]), main = "Graduación Whittaker")
lines(base2$edad, base2$qx_suavizado, lwd = 3, col = "red")

# ============================================
# PASO 8: TESTS DE BONDAD
# ============================================
cat("\n=== TESTS DE BONDAD ===\n")
obs <- base2$Muertes
esp <- base2$muertes_esp
n <- length(obs)

chi_val <- sum((obs - esp)^2 / pmax(esp, 0.001))
p_chi <- 1 - pchisq(chi_val, df = n - 1)
cat("Chi²: p =", round(p_chi, 4), "\n")

n_pos <- sum(obs > esp)
p_signo <- 2 * min(pbinom(n_pos, n_pos + sum(obs < esp), 0.5), 
                   1 - pbinom(n_pos - 1, n_pos + sum(obs < esp), 0.5))
cat("Signos: p =", round(p_signo, 4), "\n")

tabla_ref <- data.table(
  Edad = 0:110,
  qx = c(
    # Edades 0-9
    0.01080429, 0.00440199, 0.00454767, 0.00471059, 0.00484162,
    0.00504765, 0.00524207, 0.00543836, 0.00563282, 0.00582620,
    # Edades 10-19
    0.00613027, 0.00634584, 0.00658733, 0.00686127, 0.00715908,
    0.00812627, 0.00845708, 0.00878197, 0.00909460, 0.00939622,
    # Edades 20-29
    0.00954636, 0.00984314, 0.01012160, 0.01037641, 0.01061386,
    0.01071761, 0.01094971, 0.01118516, 0.01142773, 0.01167715,
    # Edades 30-39
    0.01183078, 0.01217004, 0.01242405, 0.01260603, 0.01274172,
    0.01286990, 0.01313684, 0.01348688, 0.01392834, 0.01446344,
    # Edades 40-49
    0.01491453, 0.01560964, 0.01637149, 0.01718933, 0.01805512,
    0.01883983, 0.01978603, 0.02077704, 0.02181627, 0.02290607,
    # Edades 50-59
    0.02419355, 0.02537782, 0.02658361, 0.02778798, 0.02896646,
    0.03023407, 0.03130672, 0.03230843, 0.03323900, 0.03410416,
    # Edades 60-69
    0.03568219, 0.03646622, 0.03722138, 0.03796311, 0.03870763,
    0.04007493, 0.04089640, 0.04178883, 0.04278337, 0.04391568,
    # Edades 70-79
    0.04529994, 0.04683533, 0.04864091, 0.05076533, 0.05325630,
    0.05714919, 0.06055723, 0.06444797, 0.06883571, 0.07371979,
    # Edades 80-89
    0.08005169, 0.08593481, 0.09222398, 0.09885844, 0.10576601,
    0.11424258, 0.12153400, 0.12964852, 0.13990696, 0.15006501,
    # Edades 90-99
    0.16293381, 0.17478192, 0.18747762, 0.20106321, 0.21557974,
    0.23386842, 0.25056103, 0.26830449, 0.28712621, 0.30704706,
    # Edades 100-110
    0.33204660, 0.35446258, 0.37799926, 0.40263525, 0.42833402,
    0.45504205, 0.48268701, 0.51117625, 0.54039544, 0.57020773,
    1.00000000  # Edad 110 (omega)
  ),
  Factor_Aax = c(
    # Edades 0-9
    0.0437, 0.0437, 0.0437, 0.0437, 0.0437,
    0.0416, 0.0416, 0.0416, 0.0416, 0.0416,
    # Edades 10-19
    0.0374, 0.0374, 0.0374, 0.0374, 0.0374,
    0.0168, 0.0168, 0.0168, 0.0168, 0.0168,
    # Edades 20-29
    0.0207, 0.0207, 0.0207, 0.0207, 0.0207,
    0.0236, 0.0236, 0.0236, 0.0236, 0.0236,
    # Edades 30-39
    0.0256, 0.0256, 0.0256, 0.0256, 0.0256,
    0.0269, 0.0269, 0.0269, 0.0269, 0.0269,
    # Edades 40-49
    0.0297, 0.0297, 0.0297, 0.0297, 0.0297,
    0.0313, 0.0313, 0.0313, 0.0313, 0.0313,
    # Edades 50-59
    0.0298, 0.0298, 0.0298, 0.0298, 0.0298,
    0.0287, 0.0287, 0.0287, 0.0287, 0.0287,
    # Edades 60-69
    0.0234, 0.0234, 0.0234, 0.0234, 0.0234,
    0.0197, 0.0197, 0.0197, 0.0197, 0.0197,
    # Edades 70-79
    0.0193, 0.0193, 0.0193, 0.0193, 0.0193,
    0.0150, 0.0150, 0.0150, 0.0150, 0.0150,
    # Edades 80-89
    0.0120, 0.0120, 0.0120, 0.0120, 0.0120,
    0.0090, 0.0090, 0.0090, 0.0090, 0.0090,
    # Edades 90-99
    0.0060, 0.0060, 0.0060, 0.0060, 0.0060,
    0.0030, 0.0030, 0.0030, 0.0030, 0.0030,
    # Edades 100-110
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  )
)

# ============================================
# PASO 10: EXTRAPOLACIÓN GOMPERTZ-MAKEHAM
# ============================================
datos_fit <- data.table(edad = base2$edad, qx = base2$qx_suavizado)
datos_fit[, mu := -log(1 - pmin(qx, 0.99))]

fit_result <- tryCatch({
  fit <- nls(mu ~ A + B * c^edad, data = datos_fit,
             start = list(A = 0.001, B = 0.00001, c = 1.1),
             control = nls.control(maxiter = 500, warnOnly = TRUE))
  list(A = coef(fit)["A"], B = coef(fit)["B"], c = coef(fit)["c"], metodo = "Makeham")
}, error = function(e) {
  fit_lin <- lm(log(pmax(mu, 1e-10)) ~ edad, data = datos_fit)
  list(A = 0, B = exp(coef(fit_lin)[1]), c = exp(coef(fit_lin)[2]), metodo = "Gompertz")
})

cat("\nMétodo:", fit_result$metodo, "\n")

qx_extrapolar <- function(x, params) {
  mu <- pmax(0, params$A) + params$B * params$c^x
  pmin(1 - exp(-mu), 0.999)
}

edad_cola <- 85:109
qx_cola <- sapply(edad_cola, function(x) qx_extrapolar(x, fit_result))

# ============================================
# PASO 11: TABLA FINAL (0-109)
# ============================================
tabla_final <- data.table(edad = 0:109)

tabla_final <- merge(tabla_final, base2[, .(edad, qx_obs = qx_suavizado)], 
                     by = "edad", all.x = TRUE)
tabla_final <- merge(tabla_final, tabla_ref[, .(edad = Edad, qx_ref = qx)], 
                     by = "edad", all.x = TRUE)
tabla_final <- merge(tabla_final, data.table(edad = edad_cola, qx_extrap = qx_cola), 
                     by = "edad", all.x = TRUE)

tabla_final[, qx := fcase(
  edad <= 19,             qx_ref,
  edad >= 20 & edad < 85, qx_obs,
  edad >= 85,             qx_extrap,
  default = NA_real_
)]
tabla_final[edad == 109, qx := 1]

setorder(tabla_final, edad)
cat("\nNA en qx:", sum(is.na(tabla_final$qx)), "\n")

# ============================================
# PASO 12: COMPARACIÓN
# ============================================
tabla_final[, diferencial := (qx - qx_ref) / qx_ref * 100]

plot(tabla_final$edad, tabla_final$qx, type = "l", lwd = 2, col = "blue",
     xlab = "Edad", ylab = expression(q[x]), main = "Obtenida vs Referencia")
lines(tabla_final$edad, tabla_final$qx_ref, lwd = 2, col = "red", lty = 2)
legend("topleft", c("Obtenida", "Referencia"), col = c("blue", "red"), lwd = 2, lty = c(1,2))

# ============================================
# PASO 13: FUNCIONES DE CONMUTACIÓN
# ============================================
tabla_mort <- copy(tabla_final[, .(edad, qx, qx_ref)])

tabla_mort[, `:=`(px = 1 - qx, lx = L0 * cumprod(c(1, head(1 - qx, -1))))]
tabla_mort[, `:=`(dx = lx * qx, Dx = lx * v^edad, Cx = lx * qx * v^(edad + 0.5))]

setorder(tabla_mort, -edad)
tabla_mort[, `:=`(Nx = cumsum(Dx), Mx = cumsum(Cx))]
setorder(tabla_mort, edad)

tabla_mort[, `:=`(ex = Nx / Dx - 0.5, ax = Nx / Dx)]

cat("\n=== TABLA MORTALIDAD ===\n")
print(tabla_mort[edad %in% c(0, 20, 40, 60, 80, 100, 109), 
                 .(edad, qx = round(qx, 6), lx = round(lx, 0), ex = round(ex, 2))])

# ============================================
# PASO 14: FUNCIONES ACTUARIALES
# ============================================
dotal_puro <- function(x, n) tabla_mort[edad == x + n, Dx] / tabla_mort[edad == x, Dx]
renta_vit_venc <- function(x) tabla_mort[edad == x + 1, Nx] / tabla_mort[edad == x, Dx]
seguro_vida <- function(x) tabla_mort[edad == x, Mx] / tabla_mort[edad == x, Dx]

cat("\n=== EJEMPLOS (edad 40) ===\n")
cat("10E40:", round(dotal_puro(40, 10), 6), "\n")
cat("a40:", round(renta_vit_venc(40), 4), "\n")
cat("A40:", round(seguro_vida(40), 6), "\n")
cat("e40:", round(tabla_mort[edad == 40, ex], 2), "\n")

# ============================================
# PASO 15: EXPORTAR
# ============================================
write.xlsx(as.data.frame(tabla_mort), "tabla_mortalidad_completa.xlsx")
write.xlsx(as.data.frame(tabla_mort[, .(edad, qx, lx, dx, Dx, Nx, Cx, Mx, ex)]), 
           "tabla_mortalidad_entrega.xlsx")
write.xlsx(as.data.frame(tabla_final[, .(edad, qx, qx_ref, diferencial)]), 
           "comparacion_referencia.xlsx")

cat("\n✅ Exportado:\n  • tabla_mortalidad_completa.xlsx\n  • tabla_mortalidad_entrega.xlsx\n  • comparacion_referencia.xlsx\n")

