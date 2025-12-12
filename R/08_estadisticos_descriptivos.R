# ============================================================================
# MÓDULO 8: ESTADÍSTICOS DESCRIPTIVOS
# ============================================================================
# Descripción: Calcula estadísticos descriptivos completos de la tabla
# Entrada: tabla_mortalidad, tabla_referencia, tasas_crudas
# Salida: CSV con estadísticos, gráficos de análisis
# ============================================================================

mensaje("MÓDULO 8: ESTADÍSTICOS DESCRIPTIVOS", "titulo")

# Cargar librería para Excel
library(openxlsx)

# ----------------------------------------------------------------------------
# 1. VERIFICAR DATOS NECESARIOS
# ----------------------------------------------------------------------------

if (!exists("tabla_mortalidad")) {
  stop("❌ Error: tabla_mortalidad no encontrada. Ejecutar módulo 04 primero.")
}

if (!exists("tabla_referencia")) {
  stop("❌ Error: tabla_referencia no encontrada. Ejecutar módulo 00 primero.")
}

if (!exists("tasas_crudas")) {
  stop("❌ Error: tasas_crudas no encontrada. Ejecutar módulo 02 primero.")
}

# ----------------------------------------------------------------------------
# 2. ESTADÍSTICOS DE LA TABLA OBTENIDA
# ----------------------------------------------------------------------------

mensaje("Calculando estadísticos de tabla obtenida...", "subtitulo")

# Estadísticos básicos de qx
stats_qx_obtenida <- tibble(
  Métrica = c("Media", "Mediana", "Desv. Estándar", "Mínimo", "Máximo", 
              "Q1 (25%)", "Q3 (75%)", "Coef. Variación"),
  Valor = c(
    mean(tabla_mortalidad$qx, na.rm = TRUE),
    median(tabla_mortalidad$qx, na.rm = TRUE),
    sd(tabla_mortalidad$qx, na.rm = TRUE),
    min(tabla_mortalidad$qx, na.rm = TRUE),
    max(tabla_mortalidad$qx, na.rm = TRUE),
    quantile(tabla_mortalidad$qx, 0.25, na.rm = TRUE),
    quantile(tabla_mortalidad$qx, 0.75, na.rm = TRUE),
    sd(tabla_mortalidad$qx, na.rm = TRUE) / mean(tabla_mortalidad$qx, na.rm = TRUE)
  )
) %>%
  mutate(Valor_formateado = case_when(
    Métrica %in% c("Media", "Mediana", "Desv. Estándar", "Mínimo", "Máximo", "Q1 (25%)", "Q3 (75%)") ~ 
      sprintf("%.6f", Valor),
    Métrica == "Coef. Variación" ~ sprintf("%.2f", Valor),
    TRUE ~ as.character(Valor)
  ))

# Estadísticos de esperanza de vida
stats_ex_obtenida <- tibble(
  Métrica = c("e(0) - Nacimiento", "e(20)", "e(40)", "e(60)", "e(65)", "e(80)", "e(100)"),
  Valor = c(
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 0],
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 20],
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 40],
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 60],
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 65],
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 80],
    tabla_mortalidad$ex[tabla_mortalidad$Edad == 100]
  )
) %>%
  mutate(Valor_formateado = sprintf("%.2f años", Valor))

# Estadísticos de sobrevivencia
stats_lx_obtenida <- tibble(
  Métrica = c("l(0) - Radix", "l(20)", "l(40)", "l(60)", "l(65)", "l(80)", "l(100)", "l(109)"),
  Valor = c(
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 0],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 20],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 40],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 60],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 65],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 80],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 100],
    tabla_mortalidad$lx[tabla_mortalidad$Edad == 109]
  )
) %>%
  mutate(
    Porcentaje = Valor / L0 * 100,
    Valor_formateado = sprintf("%s (%.1f%%)", scales::comma(Valor), Porcentaje)
  )

cat("\n=== ESTADÍSTICOS qx ===\n")
print(stats_qx_obtenida %>% select(Métrica, Valor_formateado))

cat("\n=== ESPERANZA DE VIDA ===\n")
print(stats_ex_obtenida)

cat("\n=== SOBREVIVENCIA ===\n")
print(stats_lx_obtenida %>% select(Métrica, Valor_formateado))

# ----------------------------------------------------------------------------
# 3. COMPARACIÓN CON TABLA DE REFERENCIA
# ----------------------------------------------------------------------------

mensaje("Comparación con tabla de referencia...", "subtitulo")

# Estadísticos comparativos
comparacion_stats <- tabla_mortalidad %>%
  left_join(tabla_referencia %>% select(Edad, qx_ref, ex_ref, lx_ref), by = "Edad") %>%
  summarise(
    # Diferencias en qx
    qx_dif_media = mean(qx - qx_ref, na.rm = TRUE),
    qx_dif_abs_media = mean(abs(qx - qx_ref), na.rm = TRUE),
    qx_dif_pct_media = mean((qx - qx_ref) / qx_ref * 100, na.rm = TRUE),
    qx_dif_pct_abs_media = mean(abs((qx - qx_ref) / qx_ref * 100), na.rm = TRUE),
    qx_correlacion = cor(qx, qx_ref, use = "complete.obs"),
    
    # Diferencias en ex
    ex_dif_media = mean(ex - ex_ref, na.rm = TRUE),
    ex_dif_abs_media = mean(abs(ex - ex_ref), na.rm = TRUE),
    ex_correlacion = cor(ex, ex_ref, use = "complete.obs"),
    
    # Diferencias en lx (porcentaje)
    lx_dif_pct_media = mean(abs((lx/L0 - lx_ref/lx_ref[1]) * 100), na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Métrica", values_to = "Valor") %>%
  mutate(
    Descripción = case_when(
      Métrica == "qx_dif_media" ~ "Diferencia media qx (Obt - Ref)",
      Métrica == "qx_dif_abs_media" ~ "Diferencia absoluta media qx",
      Métrica == "qx_dif_pct_media" ~ "Diferencia porcentual media qx (%)",
      Métrica == "qx_dif_pct_abs_media" ~ "Diferencia porcentual absoluta media qx (%)",
      Métrica == "qx_correlacion" ~ "Correlación qx",
      Métrica == "ex_dif_media" ~ "Diferencia media ex (años)",
      Métrica == "ex_dif_abs_media" ~ "Diferencia absoluta media ex (años)",
      Métrica == "ex_correlacion" ~ "Correlación ex",
      Métrica == "lx_dif_pct_media" ~ "Diferencia porcentual media lx (%)",
      TRUE ~ Métrica
    ),
    Valor_formateado = case_when(
      str_detect(Métrica, "correlacion") ~ sprintf("%.4f", Valor),
      str_detect(Métrica, "pct") ~ sprintf("%.2f%%", Valor),
      str_detect(Métrica, "ex") ~ sprintf("%.3f años", Valor),
      TRUE ~ sprintf("%.6f", Valor)
    )
  )

cat("\n=== COMPARACIÓN CON MI-2014 ===\n")
print(comparacion_stats %>% select(Descripción, Valor_formateado))

# ----------------------------------------------------------------------------
# 4. ESTADÍSTICOS POR GRUPO ETARIO
# ----------------------------------------------------------------------------

mensaje("Estadísticos por grupo etario...", "subtitulo")

stats_grupos <- tabla_mortalidad %>%
  mutate(
    Grupo = case_when(
      Edad < 20 ~ "0-19 años",
      Edad >= 20 & Edad < 40 ~ "20-39 años",
      Edad >= 40 & Edad < 60 ~ "40-59 años",
      Edad >= 60 & Edad < 80 ~ "60-79 años",
      Edad >= 80 ~ "80+ años"
    )
  ) %>%
  group_by(Grupo) %>%
  summarise(
    N_edades = n(),
    qx_media = mean(qx, na.rm = TRUE),
    qx_mediana = median(qx, na.rm = TRUE),
    qx_min = min(qx, na.rm = TRUE),
    qx_max = max(qx, na.rm = TRUE),
    ex_media = mean(ex, na.rm = TRUE),
    sobrevivencia_inicio = first(lx) / L0 * 100,
    sobrevivencia_fin = last(lx) / L0 * 100,
    perdida_vida = sobrevivencia_inicio - sobrevivencia_fin
  ) %>%
  mutate(across(where(is.numeric), ~round(., 4)))

cat("\n=== ESTADÍSTICOS POR GRUPO ETARIO ===\n")
print(stats_grupos)

# ----------------------------------------------------------------------------
# 5. ESTADÍSTICOS DE DATOS CRUDOS
# ----------------------------------------------------------------------------

mensaje("Estadísticos de datos crudos...", "subtitulo")

stats_crudos <- tibble(
  Métrica = c(
    "Total exposición (años-persona)",
    "Total muertes observadas",
    "Tasa cruda global (por 1,000)",
    "Edad min con datos",
    "Edad max con datos",
    "Edades con muertes > 0",
    "Edades con exposición > 100 años",
    "Exposición media por edad",
    "Muertes media por edad"
  ),
  Valor = c(
    sum(tasas_crudas$exposicion, na.rm = TRUE),
    sum(tasas_crudas$muertes, na.rm = TRUE),
    sum(tasas_crudas$muertes, na.rm = TRUE) / sum(tasas_crudas$exposicion, na.rm = TRUE) * 1000,
    min(tasas_crudas$Edad),
    max(tasas_crudas$Edad),
    sum(tasas_crudas$muertes > 0),
    sum(tasas_crudas$exposicion > 100),
    mean(tasas_crudas$exposicion, na.rm = TRUE),
    mean(tasas_crudas$muertes, na.rm = TRUE)
  )
) %>%
  mutate(Valor_formateado = case_when(
    str_detect(Métrica, "Total exposición") ~ scales::comma(Valor),
    str_detect(Métrica, "Total muertes") ~ scales::comma(Valor),
    str_detect(Métrica, "Tasa cruda") ~ sprintf("%.2f", Valor),
    str_detect(Métrica, "media") ~ sprintf("%.1f", Valor),
    TRUE ~ as.character(as.integer(Valor))
  ))

cat("\n=== ESTADÍSTICOS DATOS CRUDOS ===\n")
print(stats_crudos %>% select(Métrica, Valor_formateado))

# ----------------------------------------------------------------------------
# 6. ANÁLISIS DE CALIDAD DE AJUSTE
# ----------------------------------------------------------------------------

mensaje("Análisis de calidad de ajuste...", "subtitulo")

# Calcular métricas de bondad de ajuste
comparacion_completa <- tabla_mortalidad %>%
  left_join(tabla_referencia %>% select(Edad, qx_ref), by = "Edad") %>%
  filter(!is.na(qx_ref))

# Métricas de error
metricas_error <- tibble(
  Métrica = c(
    "MAE (Mean Absolute Error)",
    "RMSE (Root Mean Square Error)",
    "MAPE (Mean Absolute Percentage Error)",
    "R² (Coeficiente de determinación)",
    "Correlación de Pearson",
    "Correlación de Spearman"
  ),
  Valor = c(
    mean(abs(comparacion_completa$qx - comparacion_completa$qx_ref)),
    sqrt(mean((comparacion_completa$qx - comparacion_completa$qx_ref)^2)),
    mean(abs((comparacion_completa$qx - comparacion_completa$qx_ref) / comparacion_completa$qx_ref * 100)),
    cor(comparacion_completa$qx, comparacion_completa$qx_ref)^2,
    cor(comparacion_completa$qx, comparacion_completa$qx_ref),
    cor(comparacion_completa$qx, comparacion_completa$qx_ref, method = "spearman")
  )
) %>%
  mutate(Valor_formateado = case_when(
    str_detect(Métrica, "MAPE") ~ sprintf("%.2f%%", Valor),
    str_detect(Métrica, "Correlación|R²") ~ sprintf("%.6f", Valor),
    TRUE ~ sprintf("%.8f", Valor)
  ))

cat("\n=== MÉTRICAS DE CALIDAD DE AJUSTE ===\n")
print(metricas_error %>% select(Métrica, Valor_formateado))

# ----------------------------------------------------------------------------
# 7. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando estadísticos...", "subtitulo")

# Crear lista completa de estadísticos
estadisticos_completos <- list(
  qx_tabla_obtenida = stats_qx_obtenida,
  esperanza_vida = stats_ex_obtenida,
  sobrevivencia = stats_lx_obtenida,
  comparacion_referencia = comparacion_stats,
  grupos_etarios = stats_grupos,
  datos_crudos = stats_crudos,
  metricas_ajuste = metricas_error
)

# Guardar en Excel con múltiples hojas
wb <- createWorkbook()

addWorksheet(wb, "Resumen qx")
writeData(wb, "Resumen qx", stats_qx_obtenida %>% select(-Valor))

addWorksheet(wb, "Esperanza Vida")
writeData(wb, "Esperanza Vida", stats_ex_obtenida)

addWorksheet(wb, "Sobrevivencia")
writeData(wb, "Sobrevivencia", stats_lx_obtenida %>% select(-Valor, -Porcentaje))

addWorksheet(wb, "Comparación MI-2014")
writeData(wb, "Comparación MI-2014", comparacion_stats %>% select(-Valor))

addWorksheet(wb, "Grupos Etarios")
writeData(wb, "Grupos Etarios", stats_grupos)

addWorksheet(wb, "Datos Crudos")
writeData(wb, "Datos Crudos", stats_crudos %>% select(-Valor))

addWorksheet(wb, "Métricas Ajuste")
writeData(wb, "Métricas Ajuste", metricas_error %>% select(-Valor))

saveWorkbook(wb, file.path(DIR_RESULTADOS, "08_estadisticos_descriptivos.xlsx"), 
             overwrite = TRUE)

cat("✓ Guardado: 08_estadisticos_descriptivos.xlsx\n")

# Guardar también versión RData
save(estadisticos_completos, 
     file = file.path(DIR_DATA, "estadisticos_descriptivos.RData"))
cat("✓ Guardado: estadisticos_descriptivos.RData\n")

# ----------------------------------------------------------------------------
# 8. GRÁFICOS ADICIONALES DE ANÁLISIS
# ----------------------------------------------------------------------------

mensaje("Generando gráficos de análisis...", "subtitulo")

# Gráfico 1: Boxplot de qx por grupo etario
p1 <- tabla_mortalidad %>%
  mutate(
    Grupo = case_when(
      Edad < 20 ~ "0-19\naños",
      Edad >= 20 & Edad < 40 ~ "20-39\naños",
      Edad >= 40 & Edad < 60 ~ "40-59\naños",
      Edad >= 60 & Edad < 80 ~ "60-79\naños",
      Edad >= 80 ~ "80+\naños"
    )
  ) %>%
  ggplot(aes(x = Grupo, y = qx, fill = Grupo)) +
  geom_boxplot(alpha = 0.7) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Distribución de qx por Grupo Etario",
    subtitle = "Escala logarítmica para visualizar variabilidad",
    x = "Grupo Etario",
    y = "Tasa de mortalidad qx (escala log)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )

ggsave(
  filename = file.path(DIR_GRAFICOS, "08_boxplot_qx_grupos.png"),
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 2: Scatter plot qx obtenida vs referencia
p2 <- comparacion_completa %>%
  ggplot(aes(x = qx_ref, y = qx)) +
  geom_abline(intercept = 0, slope = 1, color = "red", linewidth = 1, linetype = "dashed") +
  geom_point(aes(color = Edad), alpha = 0.6, size = 2) +
  scale_x_log10(labels = scales::label_number(accuracy = 0.0001)) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  scale_color_viridis_c() +
  labs(
    title = "Concordancia: qx Obtenida vs MI-2014",
    subtitle = sprintf("Correlación: %.4f | Línea roja: concordancia perfecta",
                      cor(comparacion_completa$qx, comparacion_completa$qx_ref)),
    x = "qx MI-2014 (escala log)",
    y = "qx Obtenida (escala log)",
    color = "Edad"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "08_scatter_concordancia.png"),
  plot = p2,
  width = 10,
  height = 8,
  dpi = 300
)

# Gráfico 3: Histograma de diferencias porcentuales
p3 <- comparacion_completa %>%
  mutate(dif_pct = (qx - qx_ref) / qx_ref * 100) %>%
  ggplot(aes(x = dif_pct)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7, color = "black") +
  geom_vline(xintercept = 0, color = "red", linewidth = 1, linetype = "dashed") +
  geom_vline(xintercept = median((comparacion_completa$qx - comparacion_completa$qx_ref) / comparacion_completa$qx_ref * 100),
             color = "orange", linewidth = 1, linetype = "dotted") +
  labs(
    title = "Distribución de Diferencias Porcentuales",
    subtitle = "(qx_obtenida - qx_MI2014) / qx_MI2014 × 100%",
    x = "Diferencia porcentual (%)",
    y = "Frecuencia (número de edades)",
    caption = "Línea roja: diferencia cero | Línea naranja: mediana"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "08_histograma_diferencias.png"),
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Gráficos de análisis guardados (3 totales)\n")

# ----------------------------------------------------------------------------
# 9. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 8 COMPLETADO", "titulo")
cat(sprintf("Esperanza de vida al nacer:  %.2f años\n", 
            tabla_mortalidad$ex[tabla_mortalidad$Edad == 0]))
cat(sprintf("Esperanza de vida a 65:      %.2f años\n", 
            tabla_mortalidad$ex[tabla_mortalidad$Edad == 65]))
cat(sprintf("Sobrevivientes a 65 años:    %.1f%%\n",
            tabla_mortalidad$lx[tabla_mortalidad$Edad == 65] / L0 * 100))
cat(sprintf("Correlación con MI-2014:     %.4f\n",
            cor(comparacion_completa$qx, comparacion_completa$qx_ref)))
cat(sprintf("Error porcentual medio:      %.2f%%\n",
            mean(abs((comparacion_completa$qx - comparacion_completa$qx_ref) / comparacion_completa$qx_ref * 100))))

cat("\nEstadísticos descriptivos completos ✓\n")
mensaje("", "titulo")
