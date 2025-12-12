# ============================================================================
# MÓDULO 2: CÁLCULO DE TASAS CRUDAS DE MORTALIDAD
# ============================================================================
# Descripción: Calcula exposición al riesgo y tasas crudas por edad
# Input:  datos_periodo (de Módulo 1)
# Output: tasas_crudas (tibble con edad, exposición, muertes, qx_crudo)
# ============================================================================

# Cargar configuración y datos del módulo anterior
source("R/00_config.R")
load(file.path(DIR_DATA, "datos_procesados.RData"))

mensaje("MÓDULO 2: CÁLCULO DE TASAS CRUDAS", "titulo")

# ----------------------------------------------------------------------------
# 1. CÁLCULO DE EXPOSICIÓN AL RIESGO
# ----------------------------------------------------------------------------

mensaje("Calculando exposición al riesgo...", "subtitulo")

# Para cada individuo, calcular:
# - Edad al inicio de la exposición (en el período)
# - Edad al fin de la exposición (en el período)
# - Fracción de año expuesto en cada edad

datos_exposicion <- datos_periodo %>%
  mutate(
    # Edad al inicio del período (o nacimiento si es después)
    # Para nacidos durante el período, edad inicial es 0 (desde nacimiento)
    Edad_inicio_exposicion = pmax(0, Edad_inicio),
    
    # Fecha efectiva de inicio de exposición
    # Para nacidos durante período: desde su nacimiento
    # Para existentes al inicio: desde FECHA_INICIO
    Fecha_inicio_exposicion = if_else(
      Edad_inicio < 0,
      Fecha_nacimiento,  # Nacidos durante período: desde nacimiento
      FECHA_INICIO       # Existentes al inicio: desde inicio período
    ),
    
    # Fecha efectiva de fin de observación para cada individuo
    Fecha_fin_individuo = pmin(
      coalesce(Fecha_fallecimiento, FECHA_FIN),
      FECHA_FIN,
      na.rm = TRUE
    ),
    
    # Edad al fin de la exposición
    Edad_fin_exposicion = floor(fecha_a_anios(Fecha_fin_individuo, Fecha_nacimiento)),
    
    # Indicador si murió
    Murio = Muerte_periodo == 1
  ) %>%
  # Filtrar registros válidos
  filter(
    Edad_inicio_exposicion <= Edad_fin_exposicion,
    Fecha_inicio_exposicion < Fecha_fin_individuo
  )

cat(sprintf("✓ Individuos con exposición válida: %s\n", 
            format(nrow(datos_exposicion), big.mark = ".")))

# ----------------------------------------------------------------------------
# 2. EXPANDIR POR EDADES VIVIDAS
# ----------------------------------------------------------------------------

mensaje("Expandiendo a nivel de edad...", "subtitulo")
cat("Este proceso puede tomar algunos segundos...\n")

# Para cada individuo, crear un registro por cada edad vivida durante el período
datos_expandidos <- datos_exposicion %>%
  rowwise() %>%
  mutate(
    edades_lista = list(seq(Edad_inicio_exposicion, Edad_fin_exposicion))
  ) %>%
  unnest(edades_lista) %>%
  rename(Edad = edades_lista) %>%
  ungroup()

cat(sprintf("✓ Registros edad-individuo generados: %s\n", 
            format(nrow(datos_expandidos), big.mark = ".")))

# ----------------------------------------------------------------------------
# 3. CALCULAR FRACCIÓN DE EXPOSICIÓN EN CADA EDAD
# ----------------------------------------------------------------------------

mensaje("Calculando fracción de exposición por edad...", "subtitulo")

datos_expandidos <- datos_expandidos %>%
  mutate(
    # Fecha en que cumple esta edad
    Fecha_cumple_edad = Fecha_nacimiento + Edad * 365.25,
    
    # Fecha en que cumple la siguiente edad
    Fecha_cumple_sig_edad = Fecha_nacimiento + (Edad + 1) * 365.25,
    
    # Fecha inicio de exposición en esta edad
    # Para nacidos durante período: max(cumple edad, nacimiento, inicio período)
    Fecha_inicio_exp = pmax(Fecha_cumple_edad, Fecha_inicio_exposicion),
    
    # Fecha fin de exposición en esta edad
    Fecha_fin_exp = case_when(
      # Si murió en esta edad, hasta la fecha de fallecimiento
      Murio & Edad == Edad_fin_exposicion ~ Fecha_fin_individuo,
      # Si no, hasta que cumple la siguiente edad o fin del período
      TRUE ~ pmin(Fecha_cumple_sig_edad, FECHA_FIN)
    ),
    
    # Fracción de año expuesto en esta edad (entre 0 y 1)
    Exposicion = fecha_a_anios(Fecha_fin_exp, Fecha_inicio_exp),
    
    # Limitar exposición entre 0 y 1
    Exposicion = pmax(0, pmin(1, Exposicion)),
    
    # Muerte ocurre en esta edad específica
    Muerte_edad = as.integer(Murio & Edad == Edad_fin_exposicion)
  )

cat("✓ Exposiciones calculadas\n")

# Verificar lógica
exposicion_invalida <- sum(datos_expandidos$Exposicion < 0 | datos_expandidos$Exposicion > 1)
if (exposicion_invalida > 0) {
  warning(sprintf("Advertencia: %d registros con exposición fuera de [0,1]", exposicion_invalida))
}

# ----------------------------------------------------------------------------
# 4. AGREGAR POR EDAD
# ----------------------------------------------------------------------------

mensaje("Agregando por edad...", "subtitulo")

tasas_crudas <- datos_expandidos %>%
  group_by(Edad) %>%
  summarise(
    exposicion = as.numeric(sum(Exposicion, na.rm = TRUE)),
    muertes = as.integer(sum(Muerte_edad, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  # Filtrar edades con exposición positiva
  filter(exposicion > 0) %>%
  # Calcular tasa cruda
  mutate(
    qx_crudo = as.numeric(muertes / exposicion)
  ) %>%
  arrange(Edad) %>%
  as_tibble()

cat(sprintf("✓ Edades con datos: %d (de %d a %d años)\n", 
            nrow(tasas_crudas), 
            min(tasas_crudas$Edad), 
            max(tasas_crudas$Edad)))

# ----------------------------------------------------------------------------
# 5. ESTADÍSTICAS RESUMEN
# ----------------------------------------------------------------------------

mensaje("Estadísticas resumen:", "subtitulo")

cat(sprintf("Exposición total: %.2f años-persona\n", sum(tasas_crudas$exposicion)))
cat(sprintf("Muertes totales: %d\n", sum(tasas_crudas$muertes)))
cat(sprintf("Tasa cruda promedio: %.4f\n", sum(tasas_crudas$muertes) / sum(tasas_crudas$exposicion)))

# Distribución de muertes
cat("\nDistribución de muertes por edad:\n")
cat(sprintf("  Edades con 0 muertes: %d\n", sum(tasas_crudas$muertes == 0)))
cat(sprintf("  Edades con 1-4 muertes: %d\n", sum(tasas_crudas$muertes >= 1 & tasas_crudas$muertes < 5)))
cat(sprintf("  Edades con 5+ muertes: %d\n", sum(tasas_crudas$muertes >= 5)))

# ----------------------------------------------------------------------------
# 6. GRÁFICO EXPLORATORIO
# ----------------------------------------------------------------------------

mensaje("Generando gráfico exploratorio...", "subtitulo")

# Filtrar edades con al menos 1 muerte para el gráfico
tasas_con_muertes <- tasas_crudas %>% filter(muertes > 0)

p1 <- ggplot(tasas_con_muertes, aes(x = Edad, y = qx_crudo)) +
  geom_point(aes(size = exposicion), alpha = 0.6, color = "steelblue") +
  geom_line(alpha = 0.3, color = "gray40") +
  scale_y_log10(
    labels = scales::label_number(accuracy = 0.0001)
  ) +
  scale_size_continuous(name = "Exposición\n(años-persona)") +
  labs(
    title = "Tasas Crudas de Mortalidad por Edad",
    subtitle = sprintf("Invalidez 2014 - Masculino | Período %d-%d", 
                      year(FECHA_INICIO), year(FECHA_FIN)),
    x = "Edad (años)",
    y = "Tasa cruda qx (escala logarítmica)",
    caption = sprintf("Datos: %d edades, %d muertes, %.0f años-persona exposición",
                     nrow(tasas_con_muertes),
                     sum(tasas_con_muertes$muertes),
                     sum(tasas_con_muertes$exposicion))
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    legend.position = "right"
  )

# Guardar gráfico
if (exists("DIR_GRAFICOS_ESCENARIO")) {
  guardar_grafico_escenario(p1, "02_tasas_crudas.png")
} else {
  ggsave(
    filename = file.path(DIR_GRAFICOS, "02_tasas_crudas.png"),
    plot = p1,
    width = 10,
    height = 6,
    dpi = 300
  )
  cat("✓ Gráfico guardado: imagenes/02_tasas_crudas.png\n")
}

# Mostrar gráfico en consola
print(p1)

# Gráfico 2: Distribución de exposición por edad
p2 <- ggplot(tasas_crudas, aes(x = Edad, y = exposicion/1000)) +
  geom_col(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Distribución de Exposición por Edad",
    subtitle = sprintf("Total: %.1f millones de años-persona", sum(tasas_crudas$exposicion)/1e6),
    x = "Edad (años)",
    y = "Exposición (miles de años-persona)",
    caption = sprintf("Rango: %d-%d años | Media: %.1f años", 
                     min(tasas_crudas$Edad), max(tasas_crudas$Edad),
                     weighted.mean(tasas_crudas$Edad, tasas_crudas$exposicion))
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "02_distribucion_exposicion.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 3: Muertes observadas por edad
p3 <- ggplot(tasas_crudas %>% filter(muertes > 0), aes(x = Edad, y = muertes)) +
  geom_col(fill = "darkred", alpha = 0.7) +
  geom_smooth(method = "loess", se = FALSE, color = "orange", linewidth = 1) +
  labs(
    title = "Muertes Observadas por Edad",
    subtitle = sprintf("Total: %d muertes", sum(tasas_crudas$muertes)),
    x = "Edad (años)",
    y = "Número de muertes",
    caption = sprintf("Rango: %d-%d años | Edad promedio muerte: %.1f años",
                     min(tasas_crudas$Edad[tasas_crudas$muertes > 0]),
                     max(tasas_crudas$Edad[tasas_crudas$muertes > 0]),
                     weighted.mean(tasas_crudas$Edad, tasas_crudas$muertes))
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "02_muertes_por_edad.png"),
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 4: Relación exposición-muertes (densidad)
tasas_densidad <- tasas_crudas %>%
  filter(muertes > 0) %>%
  mutate(
    tasa_por_mil = (muertes / exposicion) * 1000,
    categoria_edad = cut(Edad, breaks = c(0, 20, 40, 60, 80, 110),
                        labels = c("0-19", "20-39", "40-59", "60-79", "80+"))
  )

p4 <- ggplot(tasas_densidad, aes(x = Edad, y = tasa_por_mil)) +
  geom_point(aes(size = exposicion, color = categoria_edad), alpha = 0.6) +
  geom_smooth(method = "loess", se = TRUE, color = "black", linewidth = 1) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.1)) +
  scale_size_continuous(name = "Exposición\n(años-persona)", labels = scales::label_number()) +
  scale_color_brewer(palette = "Set1", name = "Grupo\nEtario") +
  labs(
    title = "Tasa de Mortalidad por Mil Expuestos",
    subtitle = "Con ajuste LOESS para identificar tendencia",
    x = "Edad (años)",
    y = "Muertes por 1,000 expuestos (escala log)",
    caption = "Tamaño de punto proporcional a exposición"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave(
  filename = file.path(DIR_GRAFICOS, "02_densidad_mortalidad.png"),
  plot = p4,
  width = 12,
  height = 7,
  dpi = 300
)

cat("✓ Gráficos adicionales guardados (4 totales)\n")

# ----------------------------------------------------------------------------
# 7. IDENTIFICAR RANGO ÚTIL PARA GRADUACIÓN
# ----------------------------------------------------------------------------

mensaje("Identificando rango útil para graduación...", "subtitulo")

# Buscar edades con suficiente información
edades_suficientes <- tasas_crudas %>%
  filter(muertes >= MIN_MUERTES, exposicion >= MIN_EXPOSICION)

cat(sprintf("Edades con muertes >= %d y exposición >= %d: %d edades\n",
            MIN_MUERTES, MIN_EXPOSICION, nrow(edades_suficientes)))

if (nrow(edades_suficientes) > 0) {
  cat(sprintf("  Rango: %d a %d años\n", 
              min(edades_suficientes$Edad),
              max(edades_suficientes$Edad)))
}

# ----------------------------------------------------------------------------
# 8. TABLA DETALLADA POR EDAD (MUESTRA)
# ----------------------------------------------------------------------------

mensaje("Muestra de tasas crudas (cada 5 años):", "subtitulo")

tabla_muestra <- tasas_crudas %>%
  filter(Edad %% 5 == 0) %>%
  mutate(
    exposicion = round(exposicion, 2),
    qx_crudo = round(qx_crudo, 6)
  )

print(tabla_muestra, n = 20)

# ----------------------------------------------------------------------------
# 9. GUARDAR RESULTADOS
# ----------------------------------------------------------------------------

mensaje("Guardando resultados...", "subtitulo")

# Guardar tasas crudas (en escenario si está activo, sino en carpeta normal)
if (exists("DIR_RESULTADOS_ESCENARIO")) {
  guardar_resultado_escenario(tasas_crudas, "02_tasas_crudas.csv")
  save(tasas_crudas, file = file.path(DIR_DATA_ESCENARIO, "tasas_crudas.RData"))
  cat("✓ Tasas crudas guardadas en escenario\n")
} else {
  guardar_resultado(tasas_crudas, "02_tasas_crudas.csv")
  save(tasas_crudas, file = file.path(DIR_DATA, "tasas_crudas.RData"))
  cat("✓ Tasas crudas guardadas en: data/tasas_crudas.RData\n")
}

# ----------------------------------------------------------------------------
# 10. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 2 COMPLETADO", "titulo")
cat(sprintf("Edades analizadas:        %d (de %d a %d años)\n", 
            nrow(tasas_crudas),
            min(tasas_crudas$Edad),
            max(tasas_crudas$Edad)))
cat(sprintf("Exposición total:         %.2f años-persona\n", 
            sum(tasas_crudas$exposicion)))
cat(sprintf("Muertes observadas:       %d\n", 
            sum(tasas_crudas$muertes)))
cat(sprintf("Tasa cruda global:        %.4f\n", 
            sum(tasas_crudas$muertes) / sum(tasas_crudas$exposicion)))
cat("\nTasas crudas listas para graduación ✓\n")
mensaje("", "titulo")

# Limpiar variables intermedias
rm(datos_exposicion, datos_expandidos, tasas_con_muertes, edades_suficientes, 
   tabla_muestra, p1, exposicion_invalida)
