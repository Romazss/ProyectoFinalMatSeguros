# ============================================================================
# PROYECTO FINAL - MATEMÁTICAS ACTUARIALES
# Módulo 2: Valores de Conmutación
# Script 01: Cálculo de Valores de Conmutación
# ASIGNACIÓN: Origen=2, TM_SEXO=M (INVALIDEZ 2014 - Masculino)
# ============================================================================

library(tidyverse)

# ============================================================================
# 1. CARGAR DATOS
# ============================================================================

load("../data/tabla_vida_completa.RData")

# ============================================================================
# 2. PARÁMETROS
# ============================================================================

i_tecnico <- 0.05  # 5% tasa de interés técnico
v <- 1 / (1 + i_tecnico)  # Factor de descuento anual

cat("="^80, "\n")
cat("CÁLCULO DE VALORES DE CONMUTACIÓN\n")
cat("="^80, "\n")
cat("Tasa de interés técnico: ", 100 * i_tecnico, "%\n")
cat("Factor de descuento (v): ", round(v, 6), "\n\n")

# ============================================================================
# 3. CALCULAR VALORES DE CONMUTACIÓN
# ============================================================================

# D(x) = l(x) * v^x
# N(x) = Σ D(k) para k ≥ x
# C(x) = d(x) * v^(x+1)
# M(x) = Σ C(k) para k ≥ x
# R(x) = Σ N(k) para k ≥ x

conmutaciones <- tabla_vida %>%
  mutate(
    # D(x) - Factor de descuento de capital
    Dx = lx * (v ^ edad),
    
    # C(x) - Factor de descuento de muertes
    Cx = dx * (v ^ (edad + 1)),
    
    # N(x) - Suma de D(x) desde edad x hasta edad máxima
    Nx = NA_real_,
    
    # M(x) - Suma de C(x) desde edad x hasta edad máxima
    Mx = NA_real_,
    
    # R(x) - Suma de N(x) desde edad x hasta edad máxima
    Rx = NA_real_
  )

# Calcular N(x), M(x) y R(x) mediante cumsum inverso
conmutaciones <- conmutaciones %>%
  arrange(desc(edad)) %>%
  mutate(
    Nx = cumsum(Dx),
    Mx = cumsum(Cx),
    Rx = cumsum(Nx)
  ) %>%
  arrange(edad)

# ============================================================================
# 4. VERIFICACIONES
# ============================================================================

cat("Valores de conmutación calculados.\n")
cat("Primeras edades:\n")
print(head(conmutaciones[, c("edad", "lx", "dx", "Dx", "Nx", "Cx", "Mx", "Rx")], 10))

cat("\nÚltimas edades:\n")
print(tail(conmutaciones[, c("edad", "lx", "dx", "Dx", "Nx", "Cx", "Mx", "Rx")], 10))

# ============================================================================
# 5. GUARDAR RESULTADOS
# ============================================================================

tabla_conmutaciones <- conmutaciones %>%
  select(edad, lx, dx, ex, Dx, Nx, Cx, Mx, Rx)

write.csv(tabla_conmutaciones, "../resultados/tabla_conmutaciones.csv", row.names = FALSE)
save(conmutaciones, file = "../data/tabla_conmutaciones.RData")

cat("\nTabla de conmutaciones guardada.\n")

# ============================================================================
# 6. RESUMEN ESTADÍSTICO
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("RESUMEN ESTADÍSTICO\n")
cat("="^80 %+% "\n")

resumen <- data.frame(
  Valor = c("D(10)", "N(10)", "M(10)", "R(10)", 
            "D(40)", "N(40)", "M(40)", 
            "D(65)", "N(65)", "M(65)"),
  Monto = c(
    round(conmutaciones$Dx[conmutaciones$edad == 10], 2),
    round(conmutaciones$Nx[conmutaciones$edad == 10], 2),
    round(conmutaciones$Mx[conmutaciones$edad == 10], 2),
    round(conmutaciones$Rx[conmutaciones$edad == 10], 2),
    round(conmutaciones$Dx[conmutaciones$edad == 40], 2),
    round(conmutaciones$Nx[conmutaciones$edad == 40], 2),
    round(conmutaciones$Mx[conmutaciones$edad == 40], 2),
    round(conmutaciones$Dx[conmutaciones$edad == 65], 2),
    round(conmutaciones$Nx[conmutaciones$edad == 65], 2),
    round(conmutaciones$Mx[conmutaciones$edad == 65], 2)
  )
)

print(resumen)

cat("\nLos valores de conmutación se utilizarán en el cálculo de rentas.\n")
