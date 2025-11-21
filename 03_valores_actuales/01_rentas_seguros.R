# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 3: Cálculo de Valores Actuales
# Script 01: Cálculo de Rentas y Seguros
# ASIGNACIÓN: Origen=2, TM_SEXO=M (INVALIDEZ 2014 - Masculino)
# ============================================================================

library(tidyverse)

# ============================================================================
# 1. CARGAR DATOS
# ============================================================================

load("../data/tabla_conmutaciones.RData")

# ============================================================================
# 2. PARÁMETROS
# ============================================================================

tasa_interes <- 0.05  # 5% - AJUSTAR SEGÚN ASIGNACIÓN

cat("="^80, "\n")
cat("CÁLCULO DE VALORES ACTUALES\n")
cat("="^80, "\n")
cat("Tasa de interés técnico: ", 100 * tasa_interes, "%\n\n")

# ============================================================================
# 3. FUNCIONES PARA CÁLCULOS ACTUARIALES
# ============================================================================

# Función: Dotal Puro
# Fórmula: _x E_n = D(x+n) / D(x)
dotal_puro <- function(edad_inicio, edad_final, conmut) {
  if (edad_final > max(conmut$edad) | edad_inicio > max(conmut$edad)) {
    return(NA)
  }
  
  Dx_inicio <- conmut$Dx[conmut$edad == edad_inicio]
  Dx_final <- conmut$Dx[conmut$edad == edad_final]
  
  if (length(Dx_inicio) == 0 | length(Dx_final) == 0) {
    return(NA)
  }
  
  return(Dx_final / Dx_inicio)
}

# Función: Renta vitalicia vencida
# Fórmula: _x a = N(x+1) / D(x)
renta_vitalicia_vencida <- function(edad, conmut) {
  if (edad > max(conmut$edad) - 1) {
    return(NA)
  }
  
  Dx <- conmut$Dx[conmut$edad == edad]
  Nx_siguiente <- conmut$Nx[conmut$edad == edad + 1]
  
  if (length(Dx) == 0 | length(Nx_siguiente) == 0) {
    return(NA)
  }
  
  return(Nx_siguiente / Dx)
}

# Función: Renta vitalicia anticipada
# Fórmula: _x ä = N(x) / D(x)
renta_vitalicia_anticipada <- function(edad, conmut) {
  if (edad > max(conmut$edad)) {
    return(NA)
  }
  
  Dx <- conmut$Dx[conmut$edad == edad]
  Nx <- conmut$Nx[conmut$edad == edad]
  
  if (length(Dx) == 0 | length(Nx) == 0) {
    return(NA)
  }
  
  return(Nx / Dx)
}

# Función: Renta vitalicia diferida vencida
# Fórmula: _m/_x a = N(x+m+1) / D(x)
renta_diferida_vencida <- function(edad_inicio, edad_inicio_renta, conmut) {
  if (edad_inicio > max(conmut$edad) | edad_inicio_renta > max(conmut$edad)) {
    return(NA)
  }
  
  Dx_inicio <- conmut$Dx[conmut$edad == edad_inicio]
  Nx_siguiente <- conmut$Nx[conmut$edad == edad_inicio_renta + 1]
  
  if (length(Dx_inicio) == 0 | length(Nx_siguiente) == 0) {
    return(NA)
  }
  
  return(Nx_siguiente / Dx_inicio)
}

# Función: Renta vitalicia diferida anticipada
# Fórmula: _m/_x ä = N(x+m) / D(x)
renta_diferida_anticipada <- function(edad_inicio, edad_inicio_renta, conmut) {
  if (edad_inicio > max(conmut$edad) | edad_inicio_renta > max(conmut$edad)) {
    return(NA)
  }
  
  Dx_inicio <- conmut$Dx[conmut$edad == edad_inicio]
  Nx <- conmut$Nx[conmut$edad == edad_inicio_renta]
  
  if (length(Dx_inicio) == 0 | length(Nx) == 0) {
    return(NA)
  }
  
  return(Nx / Dx_inicio)
}

# Función: Renta temporal vencida
# Fórmula: _x a_n| = [N(x+1) - N(x+n+1)] / D(x)
renta_temporal_vencida <- function(edad_inicio, edad_fin, conmut) {
  if (edad_fin < edad_inicio | edad_fin > max(conmut$edad)) {
    return(NA)
  }
  
  Dx <- conmut$Dx[conmut$edad == edad_inicio]
  Nx_siguiente <- conmut$Nx[conmut$edad == edad_inicio + 1]
  
  # Edad fin + 1 para la fórmula
  edad_despues_fin <- edad_fin + 1
  if (edad_despues_fin > max(conmut$edad)) {
    Nx_fin <- 0
  } else {
    Nx_fin <- conmut$Nx[conmut$edad == edad_despues_fin]
    if (length(Nx_fin) == 0) Nx_fin <- 0
  }
  
  if (length(Dx) == 0 | length(Nx_siguiente) == 0) {
    return(NA)
  }
  
  return((Nx_siguiente - Nx_fin) / Dx)
}

# Función: Renta temporal diferida vencida
# Fórmula: _m/_x a_n| = [N(x+m+1) - N(x+n+1)] / D(x)
renta_temporal_diferida_vencida <- function(edad_inicio, edad_inicio_renta, edad_fin, conmut) {
  # Similar a temporal vencida pero desplazada
  if (edad_fin < edad_inicio_renta | edad_fin > max(conmut$edad)) {
    return(NA)
  }
  
  Dx <- conmut$Dx[conmut$edad == edad_inicio]
  Nx_siguiente <- conmut$Nx[conmut$edad == edad_inicio_renta + 1]
  
  edad_despues_fin <- edad_fin + 1
  if (edad_despues_fin > max(conmut$edad)) {
    Nx_fin <- 0
  } else {
    Nx_fin <- conmut$Nx[conmut$edad == edad_despues_fin]
    if (length(Nx_fin) == 0) Nx_fin <- 0
  }
  
  if (length(Dx) == 0 | length(Nx_siguiente) == 0) {
    return(NA)
  }
  
  return((Nx_siguiente - Nx_fin) / Dx)
}

# Función: Renta temporal diferida anticipada
# Fórmula: _m/_x ä_n| = [N(x+m) - N(x+n+1)] / D(x)
renta_temporal_diferida_anticipada <- function(edad_inicio, edad_inicio_renta, edad_fin, conmut) {
  if (edad_fin < edad_inicio_renta | edad_fin > max(conmut$edad)) {
    return(NA)
  }
  
  Dx <- conmut$Dx[conmut$edad == edad_inicio]
  Nx <- conmut$Nx[conmut$edad == edad_inicio_renta]
  
  edad_despues_fin <- edad_fin + 1
  if (edad_despues_fin > max(conmut$edad)) {
    Nx_fin <- 0
  } else {
    Nx_fin <- conmut$Nx[conmut$edad == edad_despues_fin]
    if (length(Nx_fin) == 0) Nx_fin <- 0
  }
  
  if (length(Dx) == 0 | length(Nx) == 0) {
    return(NA)
  }
  
  return((Nx - Nx_fin) / Dx)
}

# ============================================================================
# 4. CALCULAR VALORES ACTUALES SOLICITADOS
# ============================================================================

# 3.1 DOTAL PURO (Edad final = 70 años)
cat("\n" %+% "="^80 %+% "\n")
cat("3.1 - DOTAL PURO (Edad final = 70 años)\n")
cat("Fórmula: _x E_70 = D(70) / D(x)\n")
cat("="^80 %+% "\n\n")

dotal <- data.frame(
  Edad = c(38, 54, 62),
  Tabla_Obtenida = NA_real_
)

for (i in 1:nrow(dotal)) {
  dotal$Tabla_Obtenida[i] <- dotal_puro(dotal$Edad[i], 70, conmutaciones)
}

dotal$Tabla_Referencia <- NA_real_  # Completar con tabla de referencia
dotal$Diferencial_pct <- ((dotal$Tabla_Obtenida - dotal$Tabla_Referencia) / 
                           dotal$Tabla_Referencia * 100)

print(dotal)

# 3.2 RENTA VITALICIA VENCIDA
cat("\n" %+% "="^80 %+% "\n")
cat("3.2 - RENTA VITALICIA CON PAGO VENCIDO\n")
cat("Fórmula: _x a = N(x+1) / D(x)\n")
cat("="^80 %+% "\n\n")

renta_vencida <- data.frame(
  Edad = c(45, 60, 90),
  Tabla_Obtenida = NA_real_
)

for (i in 1:nrow(renta_vencida)) {
  renta_vencida$Tabla_Obtenida[i] <- renta_vitalicia_vencida(renta_vencida$Edad[i], conmutaciones)
}

renta_vencida$Tabla_Referencia <- NA_real_
renta_vencida$Diferencial_pct <- ((renta_vencida$Tabla_Obtenida - renta_vencida$Tabla_Referencia) / 
                                   renta_vencida$Tabla_Referencia * 100)

print(renta_vencida)

# 3.3 RENTA DIFERIDA ANTICIPADA (Cuotas a partir de los 75 años)
cat("\n" %+% "="^80 %+% "\n")
cat("3.3 - RENTA DIFERIDA ANTICIPADA (Cuotas a partir de los 75 años)\n")
cat("Fórmula: _75/_x ä = N(75) / D(x)\n")
cat("="^80 %+% "\n\n")

renta_diferida_ant <- data.frame(
  Edad = c(25, 40, 70),
  Tabla_Obtenida = NA_real_
)

for (i in 1:nrow(renta_diferida_ant)) {
  renta_diferida_ant$Tabla_Obtenida[i] <- renta_diferida_anticipada(
    renta_diferida_ant$Edad[i], 75, conmutaciones
  )
}

renta_diferida_ant$Tabla_Referencia <- NA_real_
renta_diferida_ant$Diferencial_pct <- ((renta_diferida_ant$Tabla_Obtenida - renta_diferida_ant$Tabla_Referencia) / 
                                        renta_diferida_ant$Tabla_Referencia * 100)

print(renta_diferida_ant)

# 3.4 RENTA TEMPORAL VENCIDA (Edad final = 80 años)
cat("\n" %+% "="^80 %+% "\n")
cat("3.4 - RENTA TEMPORAL CON PAGO VENCIDO (Edad final = 80 años)\n")
cat("Fórmula: _x a_80-x| = [N(x+1) - N(81)] / D(x)\n")
cat("="^80 %+% "\n\n")

renta_temporal_venc <- data.frame(
  Edad = c(25, 50, 75),
  Tabla_Obtenida = NA_real_
)

for (i in 1:nrow(renta_temporal_venc)) {
  renta_temporal_venc$Tabla_Obtenida[i] <- renta_temporal_vencida(
    renta_temporal_venc$Edad[i], 80, conmutaciones
  )
}

renta_temporal_venc$Tabla_Referencia <- NA_real_
renta_temporal_venc$Diferencial_pct <- ((renta_temporal_venc$Tabla_Obtenida - renta_temporal_venc$Tabla_Referencia) / 
                                         renta_temporal_venc$Tabla_Referencia * 100)

print(renta_temporal_venc)

# 3.5 RENTA TEMPORAL DIFERIDA ANTICIPADA (Edad final = 70 años)
cat("\n" %+% "="^80 %+% "\n")
cat("3.5 - RENTA TEMPORAL DIFERIDA ANTICIPADA (Edad final = 70 años)\n")
cat("Fórmula según enunciado: _70-x/_x ä_70-x| = [N(70) - N(71)] / D(x)\n")
cat("Nota: Esta fórmula corresponde matemáticamente a un Dotal Puro a los 70 años.\n")
cat("="^80 %+% "\n\n")

renta_temporal_dif_ant <- data.frame(
  Edad = c(32, 50, 68),
  Tabla_Obtenida = NA_real_
)

# Función específica para el caso 3.5 según fórmula del enunciado
calculo_caso_3_5 <- function(edad_actual, conmut) {
  if (edad_actual > 70) return(NA)
  
  Dx <- conmut$Dx[conmut$edad == edad_actual]
  N70 <- conmut$Nx[conmut$edad == 70]
  N71 <- conmut$Nx[conmut$edad == 71]
  
  if (length(Dx) == 0 || length(N70) == 0 || length(N71) == 0) return(NA)
  
  return((N70 - N71) / Dx)
}

for (i in seq_len(nrow(renta_temporal_dif_ant))) {
  renta_temporal_dif_ant$Tabla_Obtenida[i] <- calculo_caso_3_5(
    renta_temporal_dif_ant$Edad[i], 
    conmutaciones
  )
}

renta_temporal_dif_ant$Tabla_Referencia <- NA_real_
renta_temporal_dif_ant$Diferencial_pct <- ((renta_temporal_dif_ant$Tabla_Obtenida - renta_temporal_dif_ant$Tabla_Referencia) / 
                                            renta_temporal_dif_ant$Tabla_Referencia * 100)

print(renta_temporal_dif_ant)

# ============================================================================
# 5. GUARDAR RESULTADOS
# ============================================================================

write.csv(dotal, "../resultados/dotal_puro.csv", row.names = FALSE)
write.csv(renta_vencida, "../resultados/renta_vitalicia_vencida.csv", row.names = FALSE)
write.csv(renta_diferida_ant, "../resultados/renta_diferida_anticipada.csv", row.names = FALSE)
write.csv(renta_temporal_venc, "../resultados/renta_temporal_vencida.csv", row.names = FALSE)
write.csv(renta_temporal_dif_ant, "../resultados/renta_temporal_diferida_anticipada.csv", row.names = FALSE)

cat("\n" %+% "="^80 %+% "\n")
cat("Resultados guardados en carpeta 'resultados/'\n")
cat("="^80 %+% "\n")

# ============================================================================
# 6. INSTRUCCIONES PARA TABLA DE REFERENCIA
# ============================================================================

cat("\nINSTRUCCIONES:\n")
cat("1. Completar columna 'Tabla_Referencia' con valores de tabla oficial\n")
cat("2. Las fórmulas utilizadas se muestran arriba\n")
cat("3. Revisar valores en: https://www.superintendencia.cl/ (o página web asignada)\n")
