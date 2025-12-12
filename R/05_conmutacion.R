# ============================================================================
# MÓDULO 5: VALORES DE CONMUTACIÓN
# ============================================================================
# Descripción: Calcula funciones de conmutación para ambas tablas
# Input:  tabla_mortalidad, tabla_referencia (de Módulo 4)
# Output: tabla_conmutacion_obtenida, tabla_conmutacion_referencia
# ============================================================================

# Cargar configuración y datos
source("R/00_config.R")
load(file.path(DIR_DATA, "tabla_completa.RData"))
load(file.path(DIR_DATA, "referencia_calculada.RData"))

mensaje("MÓDULO 5: VALORES DE CONMUTACIÓN", "titulo")

# ----------------------------------------------------------------------------
# 1. FUNCIONES DE CONMUTACIÓN
# ----------------------------------------------------------------------------

mensaje("Definiendo funciones de conmutación...", "subtitulo")

cat("Fórmulas con tasa de interés i = 5%:\n")
cat("  Dx = lx × v^x          donde v = 1/(1+i)\n")
cat("  Nx = Σ Dk (k≥x)        suma desde edad x hasta ω\n")
cat("  Cx = dx × v^(x+1)\n")
cat("  Mx = Σ Ck (k≥x)        suma desde edad x hasta ω\n")
cat("  Rx = Σ Nk (k≥x)        suma desde edad x hasta ω\n\n")

cat(sprintf("Tasa técnica i: %.1f%%\n", I_TEC * 100))
cat(sprintf("Factor de descuento v: %.6f\n", V))

# ----------------------------------------------------------------------------
# 2. CALCULAR CONMUTACIONES - TABLA OBTENIDA
# ----------------------------------------------------------------------------

mensaje("Calculando conmutaciones para tabla obtenida...", "subtitulo")

tabla_conmut_obtenida <- tabla_mortalidad %>%
  as_tibble() %>%
  select(Edad, qx, px, lx, dx) %>%
  mutate(
    # Dx = lx × v^x
    Dx = as.numeric(lx * V^Edad),
    
    # Cx = dx × v^(x+1)
    Cx = as.numeric(dx * V^(Edad + 1))
  ) %>%
  # Ordenar de mayor a menor edad para sumas acumuladas
  arrange(desc(Edad)) %>%
  mutate(
    # Nx = suma acumulada de Dx desde x hasta ω
    Nx = as.numeric(cumsum(Dx)),
    
    # Mx = suma acumulada de Cx desde x hasta ω
    Mx = as.numeric(cumsum(Cx))
  ) %>%
  # Volver a orden ascendente
  arrange(Edad) %>%
  # Calcular Rx = suma acumulada de Nx desde x hasta ω
  arrange(desc(Edad)) %>%
  mutate(
    Rx = as.numeric(cumsum(Nx))
  ) %>%
  arrange(Edad) %>%
  as_tibble()

cat("✓ Conmutaciones calculadas para tabla obtenida\n")

# Verificar valores no negativos
if (any(tabla_conmut_obtenida$Dx < 0, na.rm = TRUE)) {
  warning("Hay valores negativos en Dx")
}

# ----------------------------------------------------------------------------
# 3. CALCULAR CONMUTACIONES - TABLA DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Calculando conmutaciones para tabla de referencia...", "subtitulo")

# Usar la tabla de conmutación calculada en módulo 0
tabla_conmut_referencia <- tabla_conmut_referencia_calc %>%
  as_tibble() %>%
  select(Edad, qx, lx, dx, Dx, Nx, Cx, Mx, Rx)

cat("✓ Conmutaciones calculadas para tabla de referencia\n")

# ----------------------------------------------------------------------------
# 4. MOSTRAR EJEMPLOS
# ----------------------------------------------------------------------------

mensaje("Ejemplos de valores de conmutación:", "subtitulo")

edades_ejemplo <- c(0, 20, 40, 60, 80, 100)

cat("\nTABLA OBTENIDA:\n")
tabla_ejemplo_obt <- tabla_conmut_obtenida %>%
  filter(Edad %in% edades_ejemplo) %>%
  select(Edad, Dx, Nx, Cx, Mx) %>%
  mutate(
    Dx = round(Dx, 2),
    Nx = round(Nx, 2),
    Cx = round(Cx, 4),
    Mx = round(Mx, 4)
  )
print(tabla_ejemplo_obt)

cat("\nTABLA REFERENCIA MI-2014:\n")
tabla_ejemplo_ref <- tabla_conmut_referencia %>%
  filter(Edad %in% edades_ejemplo) %>%
  select(Edad, Dx, Nx, Cx, Mx) %>%
  mutate(
    Dx = round(Dx, 2),
    Nx = round(Nx, 2),
    Cx = round(Cx, 4),
    Mx = round(Mx, 4)
  )
print(tabla_ejemplo_ref)

# ----------------------------------------------------------------------------
# 5. COMPARACIÓN ENTRE TABLAS
# ----------------------------------------------------------------------------

mensaje("Comparando conmutaciones...", "subtitulo")

comparacion_conmut <- tabla_conmut_obtenida %>%
  select(Edad, Dx_obt = Dx, Nx_obt = Nx, Mx_obt = Mx) %>%
  left_join(
    tabla_conmut_referencia %>% 
      select(Edad, Dx_ref = Dx, Nx_ref = Nx, Mx_ref = Mx),
    by = "Edad"
  ) %>%
  mutate(
    dif_Dx_pct = (Dx_obt - Dx_ref) / Dx_ref * 100,
    dif_Nx_pct = (Nx_obt - Nx_ref) / Nx_ref * 100,
    dif_Mx_pct = (Mx_obt - Mx_ref) / Mx_ref * 100
  )

# Estadísticas de diferencia (excluyendo edades muy avanzadas)
comparacion_valida <- comparacion_conmut %>%
  filter(Edad <= 100, !is.na(dif_Dx_pct))

cat(sprintf("\nDiferencias promedio (edades 0-100):\n"))
cat(sprintf("  Dx: %.2f%%\n", mean(abs(comparacion_valida$dif_Dx_pct), na.rm = TRUE)))
cat(sprintf("  Nx: %.2f%%\n", mean(abs(comparacion_valida$dif_Nx_pct), na.rm = TRUE)))
cat(sprintf("  Mx: %.2f%%\n", mean(abs(comparacion_valida$dif_Mx_pct), na.rm = TRUE)))

# ----------------------------------------------------------------------------
# 6. GRÁFICOS
# ----------------------------------------------------------------------------

mensaje("Generando gráficos...", "subtitulo")

# Gráfico 1: Dx
p1 <- ggplot() +
  geom_line(data = tabla_conmut_obtenida, 
            aes(x = Edad, y = Dx), 
            color = "darkblue", linewidth = 1.2) +
  geom_line(data = tabla_conmut_referencia, 
            aes(x = Edad, y = Dx), 
            color = "red", linewidth = 1, linetype = "dashed") +
  scale_y_continuous(labels = scales::label_number(scale = 1e-6, suffix = "M")) +
  labs(
    title = "Función de Conmutación Dx",
    subtitle = "Azul: Tabla Obtenida | Rojo: Referencia MI-2014",
    x = "Edad (años)",
    y = "Dx (millones)",
    caption = sprintf("Tasa técnica i = %.1f%%, v = %.6f", I_TEC * 100, V)
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave(
  filename = file.path(DIR_GRAFICOS, "05_conmutacion_Dx.png"),
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 2: Nx (escala log)
p2 <- ggplot() +
  geom_line(data = tabla_conmut_obtenida %>% filter(Nx > 0), 
            aes(x = Edad, y = Nx), 
            color = "darkgreen", linewidth = 1.2) +
  geom_line(data = tabla_conmut_referencia %>% filter(Nx > 0), 
            aes(x = Edad, y = Nx), 
            color = "red", linewidth = 1, linetype = "dashed") +
  scale_y_log10(labels = scales::label_number(scale = 1e-6, suffix = "M")) +
  labs(
    title = "Función de Conmutación Nx (escala log)",
    subtitle = "Verde: Tabla Obtenida | Rojo: Referencia MI-2014",
    x = "Edad (años)",
    y = "Nx (millones, escala log)",
    caption = "Nx = Σ Dk para k ≥ x"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave(
  filename = file.path(DIR_GRAFICOS, "05_conmutacion_Nx.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 3: Mx (escala log)
p3 <- ggplot() +
  geom_line(data = tabla_conmut_obtenida %>% filter(Mx > 0), 
            aes(x = Edad, y = Mx), 
            color = "purple", linewidth = 1.2) +
  geom_line(data = tabla_conmut_referencia %>% filter(Mx > 0), 
            aes(x = Edad, y = Mx), 
            color = "red", linewidth = 1, linetype = "dashed") +
  scale_y_log10(labels = scales::label_number(scale = 1e-3, suffix = "K")) +
  labs(
    title = "Función de Conmutación Mx (escala log)",
    subtitle = "Morado: Tabla Obtenida | Rojo: Referencia MI-2014",
    x = "Edad (años)",
    y = "Mx (miles, escala log)",
    caption = "Mx = Σ Ck para k ≥ x"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave(
  filename = file.path(DIR_GRAFICOS, "05_conmutacion_Mx.png"),
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Gráficos guardados\n")

print(p1)
print(p2)
print(p3)

# ----------------------------------------------------------------------------
# 7. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando resultados...", "subtitulo")

# Tabla obtenida
guardar_resultado(
  tabla_conmut_obtenida %>%
    mutate(across(c(Dx, Nx, Rx), ~round(., 4))) %>%
    mutate(across(c(Cx, Mx), ~round(., 6))),
  "05_conmutacion_obtenida.csv"
)

# Tabla referencia
guardar_resultado(
  tabla_conmut_referencia %>%
    mutate(across(c(Dx, Nx, Rx), ~round(., 4))) %>%
    mutate(across(c(Cx, Mx), ~round(., 6))),
  "05_conmutacion_referencia.csv"
)

# Comparación
guardar_resultado(
  comparacion_conmut %>%
    select(Edad, Dx_obt, Dx_ref, dif_Dx_pct,
           Nx_obt, Nx_ref, dif_Nx_pct) %>%
    mutate(across(c(Dx_obt, Dx_ref, Nx_obt, Nx_ref), ~round(., 4))) %>%
    mutate(across(c(dif_Dx_pct, dif_Nx_pct), ~round(., 2))),
  "05_comparacion_conmutacion.csv"
)

# Guardar en RData
save(tabla_conmut_obtenida, tabla_conmut_referencia,
     file = file.path(DIR_DATA, "conmutacion.RData"))

cat("✓ Resultados guardados\n")

# ----------------------------------------------------------------------------
# 8. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 5 COMPLETADO", "titulo")
cat(sprintf("Funciones calculadas:     Dx, Nx, Cx, Mx, Rx\n"))
cat(sprintf("Tasa técnica:             %.1f%% anual\n", I_TEC * 100))
cat(sprintf("Factor descuento v:       %.6f\n", V))
cat(sprintf("Edades:                   0 a %d años\n", EDAD_MAX))

cat("\nValores clave (Tabla Obtenida):\n")
cat(sprintf("  N0 (valor presente vidas): %.2f\n", 
            tabla_conmut_obtenida$Nx[tabla_conmut_obtenida$Edad == 0]))
cat(sprintf("  M0 (valor presente muertes): %.2f\n", 
            tabla_conmut_obtenida$Mx[tabla_conmut_obtenida$Edad == 0]))

cat("\nConmutaciones listas para cálculo de valores actuales ✓\n")
mensaje("", "titulo")

# Limpiar
rm(edades_ejemplo, tabla_ejemplo_obt, tabla_ejemplo_ref, 
   comparacion_conmut, comparacion_valida, p1, p2, p3)
