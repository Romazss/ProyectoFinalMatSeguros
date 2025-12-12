# ============================================================================
# MÓDULO 6: CÁLCULO DE VALORES ACTUALES (RENTAS Y SEGUROS)
# ============================================================================
# Descripción: Calcula 5 tipos de rentas/seguros especificados en el proyecto
# Input:  tabla_conmut_obtenida, tabla_conmut_referencia (de Módulo 5)
# Output: resultados de valores actuales para cada producto
# ============================================================================

# Cargar configuración y datos
source("R/00_config.R")
load(file.path(DIR_DATA, "conmutacion.RData"))

mensaje("MÓDULO 6: VALORES ACTUALES", "titulo")

# ----------------------------------------------------------------------------
# 1. FUNCIONES PARA CÁLCULO DE VALORES ACTUALES
# ----------------------------------------------------------------------------

mensaje("Definiendo funciones de valores actuales...", "subtitulo")

# Función auxiliar para obtener valores de conmutación
obtener_conmutacion <- function(tabla, edad) {
  if (edad < 0 || edad > max(tabla$Edad)) return(NULL)
  fila <- tabla[tabla$Edad == edad, ]
  if (nrow(fila) == 0) return(NULL)
  return(fila)
}

# 3.1 Dotal puro: nEx = D(x+n) / Dx
dotal_puro <- function(tabla, x, n) {
  datos_x <- obtener_conmutacion(tabla, x)
  datos_xn <- obtener_conmutacion(tabla, x + n)
  
  if (is.null(datos_x) || is.null(datos_xn)) return(NA)
  if (datos_x$Dx == 0) return(NA)
  
  return(datos_xn$Dx / datos_x$Dx)
}

# 3.2 Renta vitalicia vencida: äx = Nx+1 / Dx
renta_vitalicia_vencida <- function(tabla, x) {
  datos_x <- obtener_conmutacion(tabla, x)
  datos_x1 <- obtener_conmutacion(tabla, x + 1)
  
  if (is.null(datos_x) || is.null(datos_x1)) return(NA)
  if (datos_x$Dx == 0) return(NA)
  
  return(datos_x1$Nx / datos_x$Dx)
}

# 3.3 Renta vitalicia diferida anticipada: m|äx = Nx+m / Dx
renta_diferida_anticipada <- function(tabla, x, m) {
  datos_x <- obtener_conmutacion(tabla, x)
  datos_xm <- obtener_conmutacion(tabla, x + m)
  
  if (is.null(datos_x) || is.null(datos_xm)) return(NA)
  if (datos_x$Dx == 0) return(NA)
  
  return(datos_xm$Nx / datos_x$Dx)
}

# 3.4 Renta temporal vencida: äx:n| = (Nx+1 - Nx+n+1) / Dx
renta_temporal_vencida <- function(tabla, x, n) {
  datos_x <- obtener_conmutacion(tabla, x)
  datos_x1 <- obtener_conmutacion(tabla, x + 1)
  datos_xn1 <- obtener_conmutacion(tabla, x + n + 1)
  
  if (is.null(datos_x) || is.null(datos_x1) || is.null(datos_xn1)) return(NA)
  if (datos_x$Dx == 0) return(NA)
  
  return((datos_x1$Nx - datos_xn1$Nx) / datos_x$Dx)
}

# 3.5 Renta temporal diferida anticipada: m|äx:n| = (Nx+m - Nx+m+n) / Dx
renta_temporal_diferida_anticipada <- function(tabla, x, m, n) {
  datos_x <- obtener_conmutacion(tabla, x)
  datos_xm <- obtener_conmutacion(tabla, x + m)
  datos_xmn <- obtener_conmutacion(tabla, x + m + n)
  
  if (is.null(datos_x) || is.null(datos_xm) || is.null(datos_xmn)) return(NA)
  if (datos_x$Dx == 0) return(NA)
  
  return((datos_xm$Nx - datos_xmn$Nx) / datos_x$Dx)
}

# Seguro de vida (adicional): Ax = Mx / Dx
seguro_vida <- function(tabla, x) {
  datos_x <- obtener_conmutacion(tabla, x)
  
  if (is.null(datos_x)) return(NA)
  if (datos_x$Dx == 0) return(NA)
  
  return(datos_x$Mx / datos_x$Dx)
}

cat("✓ Funciones definidas\n\n")

# ----------------------------------------------------------------------------
# 2. ESPECIFICACIONES DEL PROYECTO
# ----------------------------------------------------------------------------

mensaje("Parámetros de cálculo según proyecto:", "subtitulo")

# Según el proyecto:
# 3.1: Dotal puro - edad final 70
# 3.2: Renta vitalicia vencida
# 3.3: Renta diferida anticipada desde 75
# 3.4: Renta temporal vencida final 80
# 3.5: Renta temporal diferida anticipada final 70

# Edades de ejemplo para cálculo
edades_calculo <- list(
  dotal = c(38, 54, 62),         # Para llegar a edad 70
  vitalicia = c(45, 60, 90),
  diferida_75 = c(25, 40, 70),
  temporal_80 = c(25, 50, 75),
  temp_dif_70 = c(32, 50, 68)
)

cat("Productos a calcular:\n")
cat("  1. Dotal puro (edad final 70)\n")
cat("  2. Renta vitalicia vencida\n")
cat("  3. Renta vitalicia diferida anticipada (desde edad 75)\n")
cat("  4. Renta temporal vencida (hasta edad 80)\n")
cat("  5. Renta temporal diferida anticipada (hasta edad 70)\n\n")

# ----------------------------------------------------------------------------
# 3. CÁLCULO PARA TABLA OBTENIDA
# ----------------------------------------------------------------------------

mensaje("Calculando valores actuales - TABLA OBTENIDA", "titulo")

# 3.1 Dotal puro
cat("\n3.1 Dotal Puro (edad final 70):\n")
cat("    Fórmula: nEx = D(x+n) / Dx\n\n")

resultados_dotal_obt <- tibble(
  Edad = as.integer(edades_calculo$dotal),
  n = as.integer(70 - Edad),
  Valor = as.numeric(sapply(Edad, function(x) dotal_puro(tabla_conmut_obtenida, x, 70 - x)))
) %>% as_tibble()

print(resultados_dotal_obt %>% mutate(Valor = round(Valor, 6)))

# 3.2 Renta vitalicia vencida
cat("\n3.2 Renta Vitalicia Vencida:\n")
cat("    Fórmula: äx = Nx+1 / Dx\n\n")

resultados_vitalicia_obt <- tibble(
  Edad = as.integer(edades_calculo$vitalicia),
  Valor = as.numeric(sapply(Edad, function(x) renta_vitalicia_vencida(tabla_conmut_obtenida, x)))
) %>% as_tibble()

print(resultados_vitalicia_obt %>% mutate(Valor = round(Valor, 4)))

# 3.3 Renta diferida anticipada
cat("\n3.3 Renta Vitalicia Diferida Anticipada (desde 75):\n")
cat("    Fórmula: m|äx = Nx+m / Dx\n\n")

resultados_diferida_obt <- tibble(
  Edad = as.integer(edades_calculo$diferida_75),
  m = as.integer(75 - Edad),
  Valor = as.numeric(sapply(Edad, function(x) renta_diferida_anticipada(tabla_conmut_obtenida, x, 75 - x)))
) %>% as_tibble()

print(resultados_diferida_obt %>% mutate(Valor = round(Valor, 4)))

# 3.4 Renta temporal vencida
cat("\n3.4 Renta Temporal Vencida (final 80):\n")
cat("    Fórmula: äx:n| = (Nx+1 - Nx+n+1) / Dx\n\n")

resultados_temporal_obt <- tibble(
  Edad = as.integer(edades_calculo$temporal_80),
  n = as.integer(80 - Edad),
  Valor = as.numeric(sapply(Edad, function(x) renta_temporal_vencida(tabla_conmut_obtenida, x, 80 - x)))
) %>% as_tibble()

print(resultados_temporal_obt %>% mutate(Valor = round(Valor, 4)))

# 3.5 Renta temporal diferida anticipada
cat("\n3.5 Renta Temporal Diferida Anticipada (final 70):\n")
cat("    Fórmula: m|äx:n| = (Nx+m - Nx+m+n) / Dx\n\n")

resultados_temp_dif_obt <- tibble(
  Edad = as.integer(edades_calculo$temp_dif_70)
) %>%
  mutate(
    m = as.integer(case_when(
      Edad < 65 ~ 65 - Edad,
      TRUE ~ 0
    )),
    n = as.integer(case_when(
      Edad < 65 ~ 5,
      TRUE ~ 70 - Edad
    )),
    Valor = as.numeric(mapply(
      function(x, m_val, n_val) {
        renta_temporal_diferida_anticipada(tabla_conmut_obtenida, x, m_val, n_val)
      },
      Edad, m, n
    ))
  ) %>%
  as_tibble()

print(resultados_temp_dif_obt %>% mutate(Valor = round(Valor, 6)))

# ----------------------------------------------------------------------------
# 4. CÁLCULO PARA TABLA DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Calculando valores actuales - TABLA REFERENCIA MI-2014", "titulo")

# Calcular para tabla de referencia (mismo proceso)
resultados_dotal_ref <- tibble(
  Edad = as.integer(edades_calculo$dotal),
  n = as.integer(70 - Edad),
  Valor = as.numeric(sapply(Edad, function(x) dotal_puro(tabla_conmut_referencia, x, 70 - x)))
) %>% as_tibble()

resultados_vitalicia_ref <- tibble(
  Edad = as.integer(edades_calculo$vitalicia),
  Valor = as.numeric(sapply(Edad, function(x) renta_vitalicia_vencida(tabla_conmut_referencia, x)))
) %>% as_tibble()

resultados_diferida_ref <- tibble(
  Edad = as.integer(edades_calculo$diferida_75),
  m = as.integer(75 - Edad),
  Valor = as.numeric(sapply(Edad, function(x) renta_diferida_anticipada(tabla_conmut_referencia, x, 75 - x)))
) %>% as_tibble()

resultados_temporal_ref <- tibble(
  Edad = as.integer(edades_calculo$temporal_80),
  n = as.integer(80 - Edad),
  Valor = as.numeric(sapply(Edad, function(x) renta_temporal_vencida(tabla_conmut_referencia, x, 80 - x)))
) %>% as_tibble()

resultados_temp_dif_ref <- tibble(
  Edad = as.integer(edades_calculo$temp_dif_70)
) %>%
  mutate(
    m = as.integer(case_when(Edad < 65 ~ 65 - Edad, TRUE ~ 0)),
    n = as.integer(case_when(Edad < 65 ~ 5, TRUE ~ 70 - Edad)),
    Valor = as.numeric(mapply(
      function(x, m_val, n_val) {
        renta_temporal_diferida_anticipada(tabla_conmut_referencia, x, m_val, n_val)
      },
      Edad, m, n
    ))
  ) %>%
  as_tibble()

cat("✓ Valores actuales calculados para tabla de referencia\n")

# ----------------------------------------------------------------------------
# 5. COMPARACIÓN
# ----------------------------------------------------------------------------

mensaje("COMPARACIÓN: OBTENIDA VS REFERENCIA", "titulo")

# Función para comparar
comparar_resultados <- function(obt, ref, nombre) {
  comp <- obt %>%
    as_tibble() %>%
    left_join(ref %>% as_tibble() %>% select(-any_of(c("m", "n"))), 
              by = "Edad", suffix = c("_obt", "_ref")) %>%
    mutate(
      Diferencia = as.numeric(Valor_obt - Valor_ref),
      Dif_pct = as.numeric((Valor_obt - Valor_ref) / Valor_ref * 100)
    ) %>%
    as_tibble()
  
  cat(sprintf("\n%s:\n", nombre))
  print(comp %>% 
          mutate(across(starts_with("Valor"), ~round(., 6))) %>%
          mutate(Dif_pct = round(Dif_pct, 2)))
  
  return(comp)
}

comp_dotal <- comparar_resultados(resultados_dotal_obt, resultados_dotal_ref, 
                                   "3.1 Dotal Puro")
comp_vitalicia <- comparar_resultados(resultados_vitalicia_obt, resultados_vitalicia_ref,
                                      "3.2 Renta Vitalicia Vencida")
comp_diferida <- comparar_resultados(resultados_diferida_obt, resultados_diferida_ref,
                                     "3.3 Renta Diferida Anticipada")
comp_temporal <- comparar_resultados(resultados_temporal_obt, resultados_temporal_ref,
                                     "3.4 Renta Temporal Vencida")
comp_temp_dif <- comparar_resultados(resultados_temp_dif_obt, resultados_temp_dif_ref,
                                     "3.5 Renta Temporal Diferida Anticipada")

# ----------------------------------------------------------------------------
# 6. TABLA RESUMEN
# ----------------------------------------------------------------------------

mensaje("Tabla resumen de valores actuales:", "subtitulo")

# Crear tabla consolidada
tabla_resumen <- bind_rows(
  comp_dotal %>% mutate(Producto = "Dotal puro"),
  comp_vitalicia %>% mutate(Producto = "Renta vitalicia vencida"),
  comp_diferida %>% mutate(Producto = "Renta diferida anticipada"),
  comp_temporal %>% mutate(Producto = "Renta temporal vencida"),
  comp_temp_dif %>% mutate(Producto = "Renta temp. dif. anticipada")
) %>%
  as_tibble() %>%
  select(Producto, Edad, Valor_obt, Valor_ref, Dif_pct) %>%
  mutate(
    Producto = as.character(Producto),
    Edad = as.integer(Edad),
    Valor_obt = as.numeric(round(Valor_obt, 6)),
    Valor_ref = as.numeric(round(Valor_ref, 6)),
    Dif_pct = as.numeric(round(Dif_pct, 2))
  ) %>%
  as_tibble()

print(tabla_resumen)

# ----------------------------------------------------------------------------
# 7. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando resultados...", "subtitulo")

# Guardar cada producto
guardar_resultado(comp_dotal, "06_dotal_puro.csv")
guardar_resultado(comp_vitalicia, "06_renta_vitalicia_vencida.csv")
guardar_resultado(comp_diferida, "06_renta_diferida_anticipada.csv")
guardar_resultado(comp_temporal, "06_renta_temporal_vencida.csv")
guardar_resultado(comp_temp_dif, "06_renta_temporal_diferida_anticipada.csv")

# Tabla resumen
guardar_resultado(tabla_resumen, "06_resumen_valores_actuales.csv")

# Guardar en RData
save(resultados_dotal_obt, resultados_vitalicia_obt, resultados_diferida_obt,
     resultados_temporal_obt, resultados_temp_dif_obt,
     resultados_dotal_ref, resultados_vitalicia_ref, resultados_diferida_ref,
     resultados_temporal_ref, resultados_temp_dif_ref,
     tabla_resumen,
     file = file.path(DIR_DATA, "valores_actuales.RData"))

cat("✓ Resultados guardados\n")

# ----------------------------------------------------------------------------
# 8. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 6 COMPLETADO", "titulo")
cat("Productos calculados:     5 tipos de rentas/seguros\n")
cat("Tablas comparadas:        Obtenida vs MI-2014 Referencia\n")
cat(sprintf("Tasa técnica:             %.1f%% anual\n", I_TEC * 100))

cat("\nDiferencias promedio (valor absoluto):\n")
cat(sprintf("  Dotal puro:                %.2f%%\n", 
            mean(abs(comp_dotal$Dif_pct), na.rm = TRUE)))
cat(sprintf("  Renta vitalicia:           %.2f%%\n", 
            mean(abs(comp_vitalicia$Dif_pct), na.rm = TRUE)))
cat(sprintf("  Renta diferida:            %.2f%%\n", 
            mean(abs(comp_diferida$Dif_pct), na.rm = TRUE)))
cat(sprintf("  Renta temporal:            %.2f%%\n", 
            mean(abs(comp_temporal$Dif_pct), na.rm = TRUE)))
cat(sprintf("  Renta temporal diferida:   %.2f%%\n", 
            mean(abs(comp_temp_dif$Dif_pct), na.rm = TRUE)))

cat("\nCálculos de valores actuales completados ✓\n")
mensaje("", "titulo")

# Limpiar
rm(edades_calculo, comp_dotal, comp_vitalicia, comp_diferida, 
   comp_temporal, comp_temp_dif)
