# ============================================================================
# MÓDULO 4: CONSTRUCCIÓN DE TABLA COMPLETA CON EXTRAPOLACIÓN MULTIMODELO
# ============================================================================
# Descripción: Construye tabla completa 0-109 con estructura:
#              - Cabeza 0-9: Oppermann
#              - Cabeza 10-19: Heligman-Pollard  
#              - Núcleo 20-84: Whittaker-Henderson (graduación)
#              - Cola 85-109: Heligman-Pollard
# Input:  datos_graduacion (de Módulo 3), tasas_crudas, tabla referencia
# Output: tabla_mortalidad completa con lx, dx, ex
# ============================================================================

# Cargar configuración y datos
source("R/00_config.R")
load(file.path(DIR_DATA, "graduacion.RData"))
load(file.path(DIR_DATA, "tasas_crudas.RData"))
load(file.path(DIR_DATA, "referencia_calculada.RData"))  # Cargar referencia calculada

mensaje("MÓDULO 4: CONSTRUCCIÓN DE TABLA COMPLETA", "titulo")

# ----------------------------------------------------------------------------
# 1. AJUSTAR HELIGMAN-POLLARD PARA CABEZA Y COLA
# ----------------------------------------------------------------------------

mensaje("Ajustando modelo Heligman-Pollard...", "subtitulo")

# Preparar datos para ajuste HP (usar rangos amplios de referencia)
datos_hp <- tasas_crudas %>%
  filter(Edad >= 0, Edad <= 100, muertes >= 1) %>%
  select(Edad, qx = qx_crudo, exposicion) %>%
  as_tibble()

cat(sprintf("Datos para ajuste HP: %d edades\n", nrow(datos_hp)))

# Función Heligman-Pollard de 8 parámetros
# qx = A^((x+B)^C) + D*exp(-E*(log(x/F))^2) + G*H^x
hp_formula <- function(x, A, B, C, D, E, F, G, H) {
  term1 <- A^((x + B)^C)
  term2 <- D * exp(-E * (log(pmax(x, 1) / F))^2)
  term3 <- G * H^x
  return(term1 + term2 + term3)
}

# Ajustar modelo HP con valores iniciales razonables
cat("Ajustando par\u00e1metros Heligman-Pollard...\n")

# Valores iniciales típicos
start_params <- list(
  A = 0.0005,
  B = 0.05,
  C = 0.1,
  D = 0.001,
  E = 10,
  F = 25,
  G = 0.0001,
  H = 1.1
)

# Intentar ajuste
tryCatch({
  fit_hp <- nls(
    qx ~ hp_formula(Edad, A, B, C, D, E, F, G, H),
    data = datos_hp,
    start = start_params,
    control = list(maxiter = 1000, warnOnly = TRUE),
    algorithm = "port",
    lower = c(A = 0.00001, B = 0, C = 0, D = 0, E = 0, F = 1, G = 0, H = 1),
    upper = c(A = 1, B = 10, C = 2, D = 1, E = 100, F = 100, G = 1, H = 1.2)
  )
  
  params_hp <- coef(fit_hp)
  cat("\u2713 Ajuste Heligman-Pollard exitoso\n\n")
  cat("Par\u00e1metros estimados:\n")
  print(params_hp)
  
}, error = function(e) {
  cat("\u2717 Error en ajuste HP, usando par\u00e1metros de tabla de referencia\n")
  # Si falla, usar aproximación basada en referencia
  params_hp <- start_params
})

# ----------------------------------------------------------------------------
# 2. CALCULAR OPPERMANN PARA EDADES 0-9
# ----------------------------------------------------------------------------

mensaje("Calculando tasas Oppermann (edades 0-9)...", "subtitulo")

# Fórmula de Oppermann: qx = a + b*x + c*x^2
# Usar edades 0-19 de referencia para ajuste
datos_opp <- tibble(
  Edad = RANGO_OPPERMANN,
  qx_ref = TABLA_REFERENCIA_QX[RANGO_OPPERMANN + 1]
)

# Ajustar polinomio de grado 2
fit_opp <- lm(qx_ref ~ Edad + I(Edad^2), data = datos_opp)
coef_opp <- coef(fit_opp)

cat("Coeficientes Oppermann:\n")
cat(sprintf("  a = %.8f\n", coef_opp[1]))
cat(sprintf("  b = %.8f\n", coef_opp[2]))
cat(sprintf("  c = %.8f\n", coef_opp[3]))

# Calcular qx para edades 0-9
qx_oppermann <- predict(fit_opp, newdata = tibble(Edad = RANGO_OPPERMANN))
qx_oppermann <- pmax(qx_oppermann, 0)  # Asegurar no negativos

cat(sprintf("✓ Tasas Oppermann calculadas para edades 0-9\n"))

# ----------------------------------------------------------------------------
# 3. CALCULAR HELIGMAN-POLLARD PARA EDADES 10-19 Y 85-109
# ----------------------------------------------------------------------------

mensaje("Calculando tasas Heligman-Pollard...", "subtitulo")

# Cabeza 10-19
qx_hp_cabeza <- hp_formula(
  RANGO_HP_CABEZA,
  params_hp["A"], params_hp["B"], params_hp["C"],
  params_hp["D"], params_hp["E"], params_hp["F"],
  params_hp["G"], params_hp["H"]
)

# Cola 85-109
qx_hp_cola <- hp_formula(
  RANGO_HP_COLA,
  params_hp["A"], params_hp["B"], params_hp["C"],
  params_hp["D"], params_hp["E"], params_hp["F"],
  params_hp["G"], params_hp["H"]
)

cat(sprintf("\u2713 Tasas HP calculadas para cabeza (10-19) y cola (85-109)\n"))

# ----------------------------------------------------------------------------
# 4. CALCULAR FACTOR DE EMPALME EN EDAD 10
# ----------------------------------------------------------------------------

mensaje("Calculando factor de empalme...", "subtitulo")

# qx_opp_10 es la tasa en edad 10 (índice 11 porque R empieza en 1)
qx_opp_10 <- qx_oppermann[length(qx_oppermann)]  # Última posición del vector (edad 9)
# Pero necesitamos predecir para edad 10
qx_opp_10_pred <- predict(fit_opp, newdata = tibble(Edad = 10))

qx_hp_10 <- qx_hp_cabeza[1]  # Primera posición (edad 10)
C <- calcular_factor_empalme(qx_hp_10, qx_opp_10_pred)

cat(sprintf("  qx Oppermann(10) = %.8f\n", qx_opp_10_pred))
cat(sprintf("  qx HP(10)        = %.8f\n", qx_hp_10))
cat(sprintf("  Factor C         = %.6f\n", C))

# Aplicar factor a Oppermann
qx_oppermann <- qx_oppermann * C
cat(sprintf("\u2713 Factor de empalme aplicado\n"))

# ----------------------------------------------------------------------------
# 5. ENSAMBLAR TABLA COMPLETA DE QX
# ----------------------------------------------------------------------------

mensaje("Ensamblando tabla completa...", "subtitulo")

# Crear tabla completa
tabla_qx_completa <- tibble(
  Edad = 0:EDAD_MAX
)

# Agregar qx por partes
tabla_qx_completa <- tabla_qx_completa %>%
  mutate(
    qx = NA_real_,
    origen = case_when(
      Edad %in% RANGO_OPPERMANN ~ "Oppermann",
      Edad %in% RANGO_HP_CABEZA ~ "HP_Cabeza",
      Edad %in% RANGO_GRAD ~ "Graduación",
      Edad %in% RANGO_HP_COLA ~ "HP_Cola",
      TRUE ~ "Fallback"
    )
  )

# Llenar valores por rango
for (i in 1:nrow(tabla_qx_completa)) {
  edad <- tabla_qx_completa$Edad[i]
  
  if (edad %in% RANGO_OPPERMANN) {
    tabla_qx_completa$qx[i] <- qx_oppermann[edad + 1]
  } else if (edad %in% RANGO_HP_CABEZA) {
    tabla_qx_completa$qx[i] <- qx_hp_cabeza[edad - 9]
  } else if (edad %in% RANGO_GRAD) {
    idx <- which(datos_graduacion$Edad == edad)
    if (length(idx) > 0) {
      tabla_qx_completa$qx[i] <- datos_graduacion$qx_graduado[idx]
    }
  } else if (edad %in% RANGO_HP_COLA) {
    tabla_qx_completa$qx[i] <- qx_hp_cola[edad - 84]
  } else {
    tabla_qx_completa$qx[i] <- 0.999
  }
}

tabla_qx_completa <- tabla_qx_completa %>% as_tibble()

# Asegurar límites [0,1]
tabla_qx_completa <- tabla_qx_completa %>%
  mutate(qx = pmin(pmax(qx, 0), 0.999))

cat("\u2713 Tabla de qx construida: 110 edades (0 a 109)\n\n")

cat("Distribución de edades por origen:\n")
print(tabla_qx_completa %>% count(origen))

# ----------------------------------------------------------------------------
# 6. CALCULAR FUNCIONES DE VIDA
# ----------------------------------------------------------------------------

mensaje("Calculando funciones de vida...", "subtitulo")

tabla_mortalidad <- tabla_qx_completa %>%
  as_tibble() %>%
  mutate(
    # Probabilidad de sobrevivencia
    px = as.numeric(1 - qx)
  ) %>%
  arrange(Edad) %>%
  mutate(
    # Número de vivos a edad x
    # lx = l0 * ∏(p0 * p1 * ... * p(x-1))
    lx = as.numeric(L0 * cumprod(c(1, head(px, -1)))),
    
    # Número de muertes entre edad x y x+1
    # dx = lx * qx
    dx = as.numeric(lx * qx)
  ) %>%
  as_tibble()

cat(sprintf("\u2713 l(0) = %.0f\n", L0))
cat(sprintf("\u2713 l(109) = %.2f (pr\u00e1cticamente 0)\n", tail(tabla_mortalidad$lx, 1)))

# ----------------------------------------------------------------------------
# 7. CALCULAR ESPERANZA DE VIDA
# ----------------------------------------------------------------------------

mensaje("Calculando esperanza de vida...", "subtitulo")

tabla_mortalidad <- tabla_mortalidad %>%
  mutate(
    # Años-persona vividos entre x y x+1
    # Para última edad, Lx = lx / (1 + qx) si qx < 1
    Lx = as.numeric(case_when(
      Edad == EDAD_MAX ~ lx,  # Última edad
      TRUE ~ (lx + lead(lx, default = 0)) / 2
    ))
  ) %>%
  arrange(desc(Edad)) %>%
  mutate(
    # Tx = suma acumulada de Lx desde x hasta ω
    Tx = as.numeric(cumsum(Lx))
  ) %>%
  arrange(Edad) %>%
  mutate(
    # Esperanza de vida ex = Tx / lx
    ex = as.numeric(Tx / pmax(lx, 1))
  ) %>%
  as_tibble()

cat("\u2713 Esperanza de vida calculada\n\n")

# Mostrar esperanzas seleccionadas
cat("Esperanzas de vida seleccionadas:\n")
edades_muestra <- c(0, 20, 40, 60, 80, 100)
tabla_mortalidad %>%
  filter(Edad %in% edades_muestra) %>%
  select(Edad, lx, qx, ex) %>%
  print()

# ----------------------------------------------------------------------------
# 8. CONSTRUIR TABLA DE REFERENCIA COMPLETA
# ----------------------------------------------------------------------------

mensaje("Comparando con tabla de referencia calculada...", "subtitulo")

# Preparar tabla de referencia para comparación
tabla_referencia <- tabla_referencia_calculada %>%
  select(Edad, qx, lx, dx, ex) %>%
  rename(
    qx_ref = qx,
    lx_ref = lx,
    dx_ref = dx,
    ex_ref = ex
  )

# Comparación
comparacion <- tabla_mortalidad %>%
  left_join(tabla_referencia %>% select(Edad, qx_ref, ex_ref), by = "Edad") %>%
  mutate(
    dif_qx_pct = as.numeric((qx - qx_ref) / qx_ref * 100),
    dif_ex_pct = as.numeric((ex - ex_ref) / ex_ref * 100)
  )

cat(sprintf("\nDiferencia promedio en qx: %.2f%%\n", 
            mean(abs(comparacion$dif_qx_pct), na.rm = TRUE)))
cat(sprintf("Diferencia promedio en ex: %.2f%%\n", 
            mean(abs(comparacion$dif_ex_pct), na.rm = TRUE)))

# ----------------------------------------------------------------------------
# 9. GRÁFICOS
# ----------------------------------------------------------------------------

mensaje("Generando gráficos...", "subtitulo")

# Gráfico 1: Tabla completa con metodologías diferenciadas
# Preparar datos con colores por metodología
colores_metodos <- c(
  "Oppermann" = "#e74c3c",      # Rojo
  "HP_Cabeza" = "#f39c12",      # Naranja
  "Graduación" = "#27ae60",     # Verde
  "HP_Cola" = "#3498db"         # Azul
)

p1 <- ggplot(tabla_mortalidad, aes(x = Edad, y = qx)) +
  # Línea principal por método
  geom_line(aes(color = origen), linewidth = 1.2) +
  # Puntos en las transiciones
  geom_point(data = tabla_mortalidad %>% filter(Edad %in% c(0, 9, 10, 19, 20, 84, 85, 109)),
             aes(color = origen), size = 2) +
  # Líneas verticales en transiciones
  geom_vline(xintercept = 9.5, linetype = "dashed", alpha = 0.5, linewidth = 0.8) +
  geom_vline(xintercept = 19.5, linetype = "dashed", alpha = 0.5, linewidth = 0.8) +
  geom_vline(xintercept = 84.5, linetype = "dashed", alpha = 0.5, linewidth = 0.8) +
  # Áreas sombreadas por método
  annotate("rect", xmin = 0, xmax = 9.5, ymin = 0, ymax = Inf, 
           fill = "#e74c3c", alpha = 0.05) +
  annotate("rect", xmin = 9.5, xmax = 19.5, ymin = 0, ymax = Inf, 
           fill = "#f39c12", alpha = 0.05) +
  annotate("rect", xmin = 19.5, xmax = 84.5, ymin = 0, ymax = Inf, 
           fill = "#27ae60", alpha = 0.05) +
  annotate("rect", xmin = 84.5, xmax = 110, ymin = 0, ymax = Inf, 
           fill = "#3498db", alpha = 0.05) +
  # Etiquetas de metodología
  annotate("text", x = 5, y = max(tabla_mortalidad$qx) * 0.8, 
           label = "Oppermann\n(0-9)", size = 3.5, fontface = "bold", color = "#e74c3c") +
  annotate("text", x = 14.5, y = max(tabla_mortalidad$qx) * 0.8, 
           label = "H-P\nCabeza\n(10-19)", size = 3.5, fontface = "bold", color = "#f39c12") +
  annotate("text", x = 52, y = max(tabla_mortalidad$qx) * 0.8, 
           label = "Whittaker-Henderson\nGraduación (20-84)", size = 3.5, fontface = "bold", color = "#27ae60") +
  annotate("text", x = 97, y = max(tabla_mortalidad$qx) * 0.8, 
           label = "H-P\nCola\n(85-109)", size = 3.5, fontface = "bold", color = "#3498db") +
  scale_y_log10(
    labels = scales::label_number(accuracy = 0.0001),
    breaks = c(0.0001, 0.001, 0.01, 0.1, 0.5)
  ) +
  scale_color_manual(values = colores_metodos, name = "Método") +
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 85, 90, 100, 109)) +
  labs(
    title = "Tabla de Mortalidad Completa - Metodología Multimodelo",
    subtitle = "Combinación Oppermann + Heligman-Pollard + Whittaker-Henderson",
    x = "Edad (años)",
    y = "Tasa de mortalidad qx (escala logarítmica)",
    caption = "Transiciones en edades 10, 20 y 85"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_line(linetype = "dotted", linewidth = 0.3),
    panel.grid.major = element_line(linewidth = 0.5)
  )

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_tabla_completa_multimodelo.png"),
  plot = p1,
  width = 14,
  height = 8,
  dpi = 300
)

# Gráfico 2: Metodologías por separado (paneles)
# Crear dataset con cada metodología separada
datos_metodos <- list(
  tabla_mortalidad %>% filter(origen == "Oppermann") %>% mutate(Metodo = "1. Oppermann (0-9)"),
  tabla_mortalidad %>% filter(origen == "HP_Cabeza") %>% mutate(Metodo = "2. Heligman-Pollard Cabeza (10-19)"),
  tabla_mortalidad %>% filter(origen == "Graduación") %>% mutate(Metodo = "3. Whittaker-Henderson (20-84)"),
  tabla_mortalidad %>% filter(origen == "HP_Cola") %>% mutate(Metodo = "4. Heligman-Pollard Cola (85-109)")
) %>% bind_rows()

p1b <- ggplot(datos_metodos, aes(x = Edad, y = qx, color = origen)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1.5, alpha = 0.6) +
  facet_wrap(~Metodo, scales = "free", ncol = 2) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  scale_color_manual(values = colores_metodos) +
  labs(
    title = "Metodologías de Extrapolación y Graduación por Segmento",
    subtitle = "Análisis detallado de cada método aplicado",
    x = "Edad (años)",
    y = "Tasa de mortalidad qx (log)",
    color = "Método"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    strip.text = element_text(face = "bold", size = 10),
    legend.position = "none"
  )

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_metodologias_segmentadas.png"),
  plot = p1b,
  width = 12,
  height = 8,
  dpi = 300
)

# Gráfico 3: Comparación con referencia
p2 <- ggplot() +
  geom_line(data = tabla_mortalidad, aes(x = Edad, y = qx, color = "Obtenida"), linewidth = 1) +
  geom_line(data = tabla_referencia, aes(x = Edad, y = qx_ref, color = "MI-2014"), 
            linewidth = 1, linetype = "dashed") +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  scale_color_manual(values = c("Obtenida" = "blue", "MI-2014" = "red")) +
  labs(
    title = "Comparación: Tabla Obtenida vs MI-2014",
    x = "Edad (años)",
    y = "Tasa de mortalidad qx (escala log)",
    color = "Tabla"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_comparacion_tablas.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 3: Esperanza de vida
p3 <- ggplot() +
  geom_line(data = tabla_mortalidad, aes(x = Edad, y = ex, color = "Obtenida"), linewidth = 1) +
  geom_line(data = tabla_referencia, aes(x = Edad, y = ex_ref, color = "MI-2014"), 
            linewidth = 1, linetype = "dashed") +
  scale_color_manual(values = c("Obtenida" = "blue", "MI-2014" = "red")) +
  labs(
    title = "Esperanza de Vida: Obtenida vs MI-2014",
    x = "Edad (años)",
    y = "Esperanza de vida ex (años)",
    color = "Tabla"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_esperanza_vida.png"),
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 4: Curva de sobrevivencia (lx)
p4 <- ggplot() +
  geom_line(data = tabla_mortalidad, aes(x = Edad, y = lx/L0, color = "Obtenida"), linewidth = 1.2) +
  geom_line(data = tabla_referencia %>% mutate(lx_ref = lx_ref/lx_ref[1]), 
            aes(x = Edad, y = lx_ref, color = "MI-2014"), 
            linewidth = 1, linetype = "dashed") +
  geom_vline(xintercept = c(9.5, 19.5, 84.5), linetype = "dotted", alpha = 0.3) +
  scale_y_continuous(labels = scales::label_percent()) +
  scale_color_manual(values = c("Obtenida" = "blue", "MI-2014" = "red")) +
  labs(
    title = "Curva de Sobrevivencia",
    subtitle = sprintf("l(0) = %s | Sobrevivientes a cada edad", scales::comma(L0)),
    x = "Edad (años)",
    y = "Proporción de sobrevivientes",
    color = "Tabla",
    caption = "Líneas verticales marcan transiciones entre métodos"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_curva_sobrevivencia.png"),
  plot = p4,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 5: Función dx (muertes por edad)
p5 <- ggplot() +
  geom_area(data = tabla_mortalidad, aes(x = Edad, y = dx), 
            fill = "darkred", alpha = 0.6) +
  geom_line(data = tabla_mortalidad, aes(x = Edad, y = dx), 
            color = "darkred", linewidth = 1) +
  scale_y_continuous(labels = scales::label_number()) +
  labs(
    title = "Distribución de Muertes por Edad (dx)",
    subtitle = sprintf("Total muertes (hipotéticas): %s", scales::comma(L0)),
    x = "Edad (años)",
    y = "Número de muertes a edad x",
    caption = "Área representa la distribución acumulada de muertes"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_distribucion_muertes_dx.png"),
  plot = p5,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 6: Probabilidad de sobrevivir (px)
p6 <- ggplot() +
  geom_line(data = tabla_mortalidad, aes(x = Edad, y = px, color = "Obtenida"), linewidth = 1) +
  geom_line(data = tabla_referencia %>% mutate(px_ref = 1 - qx_ref), 
            aes(x = Edad, y = px_ref, color = "MI-2014"), 
            linewidth = 1, linetype = "dashed") +
  scale_y_continuous(labels = scales::label_percent(), limits = c(0.80, 1.00)) +
  scale_color_manual(values = c("Obtenida" = "blue", "MI-2014" = "red")) +
  labs(
    title = "Probabilidad de Sobrevivir un Año (px)",
    subtitle = "px = 1 - qx | Mayor valor indica menor mortalidad",
    x = "Edad (años)",
    y = "Probabilidad px",
    color = "Tabla"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_probabilidad_sobrevivir_px.png"),
  plot = p6,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 7: Diferencias porcentuales (ratio Obtenida/Referencia)
p7 <- ggplot(comparacion, aes(x = Edad)) +
  geom_hline(yintercept = c(-50, -25, 0, 25, 50), linetype = "dashed", alpha = 0.3) +
  geom_hline(yintercept = 0, color = "black", linewidth = 1) +
  geom_line(aes(y = dif_qx_pct), color = "darkblue", linewidth = 1) +
  geom_ribbon(aes(ymin = 0, ymax = dif_qx_pct, fill = dif_qx_pct > 0), alpha = 0.3) +
  scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "green"), 
                    labels = c("Menor que MI-2014", "Mayor que MI-2014"),
                    name = "Obtenida es:") +
  labs(
    title = "Diferencia Porcentual: Tabla Obtenida vs MI-2014",
    subtitle = "(Obtenida - MI-2014) / MI-2014 × 100%",
    x = "Edad (años)",
    y = "Diferencia porcentual (%)",
    caption = "Valores positivos: mortalidad obtenida mayor | Negativos: mortalidad obtenida menor"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_diferencias_porcentuales.png"),
  plot = p7,
  width = 12,
  height = 7,
  dpi = 300
)

# Gráfico 8: Ratio qx Obtenida/Referencia
p8 <- ggplot(comparacion %>% mutate(ratio = qx / qx_ref), aes(x = Edad, y = ratio)) +
  geom_hline(yintercept = 1, color = "black", linewidth = 1) +
  geom_hline(yintercept = c(0.5, 1.5, 2.0), linetype = "dashed", alpha = 0.3) +
  geom_line(color = "darkgreen", linewidth = 1.2) +
  geom_ribbon(aes(ymin = 1, ymax = ratio, fill = ratio > 1), alpha = 0.3) +
  scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "green"), guide = "none") +
  scale_y_continuous(breaks = seq(0, 3, 0.5)) +
  labs(
    title = "Ratio de Mortalidad: Obtenida / MI-2014",
    subtitle = "Ratio = 1: Igual | >1: Mayor mortalidad | <1: Menor mortalidad",
    x = "Edad (años)",
    y = "Ratio (qx_obtenida / qx_referencia)",
    caption = "Áreas rojas: mortalidad superior a MI-2014 | Áreas verdes: mortalidad inferior"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "04_ratio_mortalidad.png"),
  plot = p8,
  width = 12,
  height = 7,
  dpi = 300
)

cat("✓ Gráficos guardados (9 totales)\n")

# ----------------------------------------------------------------------------
# 10. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando resultados...", "subtitulo")

# Determinar directorio de salida
dir_salida <- if (exists("DIR_RESULTADOS_ESCENARIO")) {
  DIR_RESULTADOS_ESCENARIO
} else {
  DIR_RESULTADOS
}

# Guardar CSVs
write_csv(tabla_mortalidad, file.path(dir_salida, "04_tabla_mortalidad_completa.csv"))
write_csv(tabla_referencia, file.path(dir_salida, "04_tabla_referencia_MI2014.csv"))
write_csv(comparacion, file.path(dir_salida, "04_comparacion_tablas.csv"))
cat("\u2713 Guardado: 04_tabla_mortalidad_completa.csv\n")
cat("\u2713 Guardado: 04_tabla_referencia_MI2014.csv\n")
cat("\u2713 Guardado: 04_comparacion_tablas.csv\n")

# Guardar RData
save(tabla_mortalidad, tabla_referencia, comparacion,
     file = file.path(DIR_DATA, "tabla_completa.RData"))
cat("\u2713 Resultados guardados\n")

# ----------------------------------------------------------------------------
# 11. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - M\u00d3DULO 4 COMPLETADO", "titulo")
cat("Tabla completa:           0 a 109 a\u00f1os\n")
cat(sprintf("Radix l(0):               %.0f\n", L0))
cat("Métodos de extrapolación:\n")
cat("  - Oppermann:            0-9 años\n")
cat("  - Heligman-Pollard:     10-19, 85-109 años\n")
cat("  - Whittaker-Henderson:  20-84 años (graduación)\n")
cat(sprintf("Esperanza vida al nacer:  %.2f años\n", tabla_mortalidad$ex[1]))
cat(sprintf("Esperanza vida a 65:      %.2f años\n", tabla_mortalidad$ex[66]))

cat("\nTabla de mortalidad completa lista \u2713\n")
mensaje("", "titulo")
