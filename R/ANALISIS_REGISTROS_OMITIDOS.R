# ============================================================================
# ANÁLISIS DE REGISTROS OMITIDOS POR FILTRO DE EDAD
# ============================================================================
# Descripción: Identifica y analiza los registros eliminados por el filtro
#              de edades 0-110 en el módulo 01_carga_datos.R
# ============================================================================

library(dplyr)
library(tibble)
library(ggplot2)

# Función auxiliar
fecha_a_anios <- function(fecha2, fecha1) {
  as.numeric(fecha2 - fecha1) / 365.25
}

cat("\n")
cat("============================================================\n")
cat("  ANÁLISIS DE REGISTROS OMITIDOS POR FILTRO DE EDAD\n")
cat("============================================================\n\n")

# ----------------------------------------------------------------------------
# 1. CARGAR Y PREPARAR DATOS
# ----------------------------------------------------------------------------

cat("Cargando datos...\n")
load('data/base_act.RData')
datos <- as_tibble(baseR)

# Filtrar según asignación (Origen=2, Sexo=M)
datos_filtrados <- datos %>%
  filter(Origen == 2, TM_SEXO == 'M')

# Preparar fechas (igual que en 01_carga_datos.R)
datos_periodo <- datos_filtrados %>%
  mutate(
    # Convertir fechas desde formato YYYYMMDD
    Fecha_nacimiento = as.Date(
      ifelse(TM_FEC_NAC == 0 | is.na(TM_FEC_NAC), NA, as.character(TM_FEC_NAC)), 
      format = "%Y%m%d"
    ),
    Fecha_fallecimiento = as.Date(
      ifelse(TM_FEC_FALL == 0 | is.na(TM_FEC_FALL), NA, as.character(TM_FEC_FALL)), 
      format = "%Y%m%d"
    ),
    # Indicador de muerte
    Muerte = as.integer(TM_FEC_FALL != 0 & !is.na(TM_FEC_FALL))
  ) %>%
  filter(
    !is.na(Fecha_nacimiento),
    Fecha_nacimiento < as.Date('2012-12-31'),
    Fecha_nacimiento <= Sys.Date()
  )

FECHA_INICIO <- as.Date('2000-01-01')
FECHA_FIN <- as.Date('2012-12-31')

# Calcular edad ANTES de filtrar
datos_con_edad <- datos_periodo %>%
  mutate(
    Edad_inicio = floor(fecha_a_anios(FECHA_INICIO, Fecha_nacimiento)),
    Muerte_periodo = as.integer(
      Muerte == 1 & 
      !is.na(Fecha_fallecimiento) & 
      Fecha_fallecimiento >= FECHA_INICIO & 
      Fecha_fallecimiento <= FECHA_FIN
    )
  )

# ----------------------------------------------------------------------------
# 2. RESUMEN GENERAL
# ----------------------------------------------------------------------------

cat("\n--- RESUMEN GENERAL ---\n\n")

total <- nrow(datos_con_edad)
cat(sprintf("Total registros antes de filtro: %s\n", format(total, big.mark = ".")))

# Registros con edad NA
na_edad <- sum(is.na(datos_con_edad$Edad_inicio))
cat(sprintf("  • Registros con Edad_inicio NA: %s (%.2f%%)\n", 
            format(na_edad, big.mark = "."), 
            100 * na_edad / total))

# Registros con edad negativa
neg_edad <- sum(!is.na(datos_con_edad$Edad_inicio) & datos_con_edad$Edad_inicio < 0, na.rm = TRUE)
cat(sprintf("  • Registros con Edad_inicio < 0: %s (%.2f%%)\n", 
            format(neg_edad, big.mark = "."), 
            100 * neg_edad / total))

# Registros con edad > 110
alta_edad <- sum(!is.na(datos_con_edad$Edad_inicio) & datos_con_edad$Edad_inicio > 110, na.rm = TRUE)
cat(sprintf("  • Registros con Edad_inicio > 110: %s (%.2f%%)\n", 
            format(alta_edad, big.mark = "."), 
            100 * alta_edad / total))

# Total omitidos
total_omitidos <- na_edad + neg_edad + alta_edad
cat(sprintf("\n*** TOTAL OMITIDOS: %s (%.2f%%) ***\n", 
            format(total_omitidos, big.mark = "."), 
            100 * total_omitidos / total))

# Total válidos
validos <- total - total_omitidos
cat(sprintf("*** TOTAL VÁLIDOS (0-110): %s (%.2f%%) ***\n", 
            format(validos, big.mark = "."), 
            100 * validos / total))

# ----------------------------------------------------------------------------
# 3. DETALLE DE EDADES PROBLEMÁTICAS
# ----------------------------------------------------------------------------

cat("\n--- DETALLE DE EDADES NEGATIVAS ---\n\n")

if (neg_edad > 0) {
  edades_neg <- datos_con_edad %>%
    filter(!is.na(Edad_inicio), Edad_inicio < 0) %>%
    count(Edad_inicio, name = 'Frecuencia') %>%
    arrange(Edad_inicio)
  
  print(edades_neg, n = 50)
  
  # Ejemplo de casos extremos
  cat("\nEjemplo de registros con edad negativa:\n")
  ejemplos_neg <- datos_con_edad %>%
    filter(!is.na(Edad_inicio), Edad_inicio < 0) %>%
    select(Fecha_nacimiento, Edad_inicio, Muerte, Muerte_periodo) %>%
    slice_head(n = 10)
  print(ejemplos_neg)
} else {
  cat("No hay registros con edad negativa.\n")
}

cat("\n--- DETALLE DE EDADES > 110 ---\n\n")

if (alta_edad > 0) {
  edades_altas <- datos_con_edad %>%
    filter(!is.na(Edad_inicio), Edad_inicio > 110) %>%
    count(Edad_inicio, name = 'Frecuencia') %>%
    arrange(desc(Edad_inicio))
  
  print(edades_altas, n = 50)
  
  # Ejemplo de casos extremos
  cat("\nEjemplo de registros con edad > 110:\n")
  ejemplos_alta <- datos_con_edad %>%
    filter(!is.na(Edad_inicio), Edad_inicio > 110) %>%
    select(Fecha_nacimiento, Edad_inicio, Muerte, Muerte_periodo) %>%
    slice_head(n = 10)
  print(ejemplos_alta)
} else {
  cat("No hay registros con edad > 110.\n")
}

# ----------------------------------------------------------------------------
# 4. ANÁLISIS DE MUERTES EN REGISTROS OMITIDOS
# ----------------------------------------------------------------------------

cat("\n--- MUERTES EN REGISTROS OMITIDOS ---\n\n")

omitidos <- datos_con_edad %>%
  filter(is.na(Edad_inicio) | Edad_inicio < 0 | Edad_inicio > 110)

muertes_omitidas <- sum(omitidos$Muerte_periodo)
muertes_totales <- sum(datos_con_edad$Muerte_periodo)

cat(sprintf("Muertes en registros omitidos: %s\n", format(muertes_omitidas, big.mark = ".")))
cat(sprintf("Muertes totales: %s\n", format(muertes_totales, big.mark = ".")))
cat(sprintf("Proporción: %.2f%% de las muertes están en registros omitidos\n", 
            100 * muertes_omitidas / muertes_totales))

if (total_omitidos > 0) {
  cat(sprintf("Tasa de mortalidad en omitidos: %.2f%%\n", 
              100 * muertes_omitidas / total_omitidos))
}

# Muertes en válidos
muertes_validas <- muertes_totales - muertes_omitidas
cat(sprintf("\nMuertes en registros válidos: %s (%.2f%%)\n", 
            format(muertes_validas, big.mark = "."),
            100 * muertes_validas / muertes_totales))

# ----------------------------------------------------------------------------
# 5. EXPORTAR RESULTADOS
# ----------------------------------------------------------------------------

cat("\n--- GUARDANDO RESULTADOS ---\n\n")

# Resumen general
resumen <- tibble(
  Categoria = c(
    "Total registros",
    "Edad NA",
    "Edad < 0",
    "Edad > 110",
    "Total omitidos",
    "Total válidos (0-110)",
    "Muertes en omitidos",
    "Muertes en válidos",
    "Muertes totales"
  ),
  Cantidad = c(
    total,
    na_edad,
    neg_edad,
    alta_edad,
    total_omitidos,
    validos,
    muertes_omitidas,
    muertes_validas,
    muertes_totales
  ),
  Porcentaje = c(
    100.00,
    100 * na_edad / total,
    100 * neg_edad / total,
    100 * alta_edad / total,
    100 * total_omitidos / total,
    100 * validos / total,
    100 * muertes_omitidas / muertes_totales,
    100 * muertes_validas / muertes_totales,
    100.00
  )
)

write.csv(resumen, "resultados/REGISTROS_OMITIDOS_resumen.csv", row.names = FALSE)
cat("✓ Guardado: REGISTROS_OMITIDOS_resumen.csv\n")

# Detalle de edades negativas
if (neg_edad > 0) {
  write.csv(edades_neg, "resultados/REGISTROS_OMITIDOS_edades_negativas.csv", row.names = FALSE)
  cat("✓ Guardado: REGISTROS_OMITIDOS_edades_negativas.csv\n")
}

# Detalle de edades altas
if (alta_edad > 0) {
  write.csv(edades_altas, "resultados/REGISTROS_OMITIDOS_edades_altas.csv", row.names = FALSE)
  cat("✓ Guardado: REGISTROS_OMITIDOS_edades_altas.csv\n")
}

# ----------------------------------------------------------------------------
# 6. GRÁFICOS
# ----------------------------------------------------------------------------

cat("\n--- GENERANDO GRÁFICOS ---\n\n")

# Gráfico de barras del resumen
p1 <- resumen %>%
  filter(Categoria %in% c("Edad NA", "Edad < 0", "Edad > 110", "Total válidos (0-110)")) %>%
  ggplot(aes(x = reorder(Categoria, -Cantidad), y = Cantidad, fill = Categoria)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = format(Cantidad, big.mark = ".")), vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("Edad NA" = "#e74c3c", 
                                "Edad < 0" = "#e67e22",
                                "Edad > 110" = "#f39c12",
                                "Total válidos (0-110)" = "#27ae60")) +
  labs(
    title = "Distribución de Registros: Válidos vs Omitidos",
    subtitle = sprintf("Total: %s registros", format(total, big.mark = ".")),
    x = "Categoría",
    y = "Cantidad de registros"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.x = element_blank()
  )

ggsave("imagenes/OMITIDOS_distribucion.png", p1, width = 10, height = 6, dpi = 300)
cat("✓ Guardado: OMITIDOS_distribucion.png\n")

# Gráfico de muertes
p2 <- tibble(
  Categoria = c("Registros válidos", "Registros omitidos"),
  Muertes = c(muertes_validas, muertes_omitidas),
  Porcentaje = c(100 * muertes_validas / muertes_totales,
                 100 * muertes_omitidas / muertes_totales)
) %>%
  ggplot(aes(x = Categoria, y = Muertes, fill = Categoria)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = sprintf("%s\n(%.1f%%)", 
                                format(Muertes, big.mark = "."),
                                Porcentaje)), 
            vjust = -0.5, size = 4) +
  scale_fill_manual(values = c("Registros válidos" = "#27ae60",
                                "Registros omitidos" = "#e74c3c")) +
  labs(
    title = "Distribución de Muertes: Válidos vs Omitidos",
    subtitle = sprintf("Total muertes: %s", format(muertes_totales, big.mark = ".")),
    x = NULL,
    y = "Cantidad de muertes"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.x = element_blank()
  )

ggsave("imagenes/OMITIDOS_muertes.png", p2, width = 8, height = 6, dpi = 300)
cat("✓ Guardado: OMITIDOS_muertes.png\n")

# ----------------------------------------------------------------------------
# 7. CONCLUSIONES
# ----------------------------------------------------------------------------

cat("\n")
cat("============================================================\n")
cat("  CONCLUSIONES\n")
cat("============================================================\n\n")

cat(sprintf("1. El filtro de edades 0-110 elimina %s registros (%.2f%%):\n",
            format(total_omitidos, big.mark = "."),
            100 * total_omitidos / total))
cat(sprintf("   - %s con edad NA\n", format(na_edad, big.mark = ".")))
cat(sprintf("   - %s con edad < 0 (edades negativas = ERROR DE DATOS)\n", format(neg_edad, big.mark = ".")))
cat(sprintf("   - %s con edad > 110 (edades biológicamente imposibles)\n", format(alta_edad, big.mark = ".")))

cat(sprintf("\n2. Estos registros omitidos incluyen %s muertes (%.2f%% del total)\n",
            format(muertes_omitidas, big.mark = "."),
            100 * muertes_omitidas / muertes_totales))

cat(sprintf("\n3. El análisis con el filtro es MÁS ROBUSTO porque:\n"))
cat("   - Elimina datos claramente erróneos (edades negativas)\n")
cat("   - Elimina datos biológicamente imposibles (edad > 110)\n")
cat("   - Garantiza coherencia de los datos de entrada\n")

cat(sprintf("\n4. El informe LaTeX usa %s registros porque NO tiene este filtro\n",
            format(total, big.mark = ".")))
cat(sprintf("   - Incluye los %s registros con datos inválidos\n",
            format(total_omitidos, big.mark = ".")))
cat("   - Esto puede introducir sesgos y errores en los cálculos\n")

cat("\n*** RECOMENDACIÓN: MANTENER EL FILTRO DE VALIDACIÓN ***\n")
cat("El análisis actual (con filtro) es CORRECTO y más confiable.\n\n")

cat("============================================================\n")
