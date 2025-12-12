# ============================================================================
# ANÁLISIS: ¿INCLUIR O EXCLUIR NACIDOS DURANTE EL PERÍODO?
# ============================================================================
# Pregunta: ¿Deberíamos mantener las 19,588 personas que nacieron durante
#           el período de análisis (2000-2012)?
# ============================================================================

library(dplyr)
library(tibble)
library(ggplot2)

fecha_a_anios <- function(fecha2, fecha1) {
  as.numeric(fecha2 - fecha1) / 365.25
}

cat("\n")
cat("============================================================\n")
cat("  ANÁLISIS: NACIDOS DURANTE EL PERÍODO DE ESTUDIO\n")
cat("============================================================\n\n")

# ----------------------------------------------------------------------------
# 1. CARGAR DATOS
# ----------------------------------------------------------------------------

load('data/base_act.RData')
datos <- as_tibble(baseR) %>%
  filter(Origen == 2, TM_SEXO == 'M') %>%
  mutate(
    Fecha_nacimiento = as.Date(
      ifelse(TM_FEC_NAC == 0 | is.na(TM_FEC_NAC), NA, as.character(TM_FEC_NAC)), 
      format = "%Y%m%d"
    ),
    Fecha_fallecimiento = as.Date(
      ifelse(TM_FEC_FALL == 0 | is.na(TM_FEC_FALL), NA, as.character(TM_FEC_FALL)), 
      format = "%Y%m%d"
    ),
    Muerte = as.integer(TM_FEC_FALL != 0 & !is.na(TM_FEC_FALL))
  ) %>%
  filter(
    !is.na(Fecha_nacimiento),
    Fecha_nacimiento < as.Date('2012-12-31'),
    Fecha_nacimiento <= Sys.Date()
  )

FECHA_INICIO <- as.Date('2000-01-01')
FECHA_FIN <- as.Date('2012-12-31')

# Calcular edad al inicio
datos <- datos %>%
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
# 2. IDENTIFICAR GRUPOS
# ----------------------------------------------------------------------------

cat("--- CLASIFICACIÓN DE REGISTROS ---\n\n")

# Grupo A: Nacidos ANTES del período (edad >= 0)
grupo_antes <- datos %>% filter(Edad_inicio >= 0)

# Grupo B: Nacidos DURANTE el período (edad < 0)
grupo_durante <- datos %>% filter(Edad_inicio < 0)

cat(sprintf("Grupo A - Nacidos ANTES del período (edad >= 0): %s registros\n",
            format(nrow(grupo_antes), big.mark = ".")))
cat(sprintf("Grupo B - Nacidos DURANTE el período (edad < 0): %s registros\n",
            format(nrow(grupo_durante), big.mark = ".")))
cat(sprintf("\nTotal: %s registros\n", format(nrow(datos), big.mark = ".")))

# ----------------------------------------------------------------------------
# 3. ARGUMENTOS PARA EXCLUIR (Enfoque Actual)
# ----------------------------------------------------------------------------

cat("\n")
cat("============================================================\n")
cat("  ARGUMENTOS PARA EXCLUIR (Enfoque Actual)\n")
cat("============================================================\n\n")

cat("1. COHESIÓN METODOLÓGICA:\n")
cat("   • Una tabla de mortalidad describe la experiencia de una\n")
cat("     COHORTE que existe al inicio del estudio\n")
cat("   • Incluir nacimientos crea una población dinámica (cohorte abierta)\n")
cat("   • Complica la interpretación: ¿tabla de cohorte o de período?\n\n")

cat("2. EXPOSICIÓN AL RIESGO:\n")
cat("   • Los nacidos DESPUÉS de 2000 no estuvieron expuestos desde el inicio\n")
cat("   • Su exposición es PARCIAL (solo desde su nacimiento)\n")
cat("   • Requiere ajuste de exposición por fecha de entrada\n\n")

cat("3. ESTÁNDAR ACTUARIAL:\n")
cat("   • La mayoría de tablas de mortalidad se construyen con población\n")
cat("     que existe al inicio del período\n")
cat("   • Ejemplos: RV-2014, CMI, SOA, etc.\n")
cat("   • Facilita comparación con otras tablas\n\n")

cat("4. IMPACTO MÍNIMO:\n")
cat(sprintf("   • Solo %s muertes (%.2f%% del total)\n",
            format(sum(grupo_durante$Muerte_periodo), big.mark = "."),
            100 * sum(grupo_durante$Muerte_periodo) / sum(datos$Muerte_periodo)))
cat("   • No afecta significativamente los resultados\n\n")

# ----------------------------------------------------------------------------
# 4. ARGUMENTOS PARA INCLUIR (Enfoque Alternativo)
# ----------------------------------------------------------------------------

cat("============================================================\n")
cat("  ARGUMENTOS PARA INCLUIR (Enfoque Alternativo)\n")
cat("============================================================\n\n")

cat("1. INTEGRIDAD DE LA POBLACIÓN:\n")
cat("   • Son parte LEGÍTIMA de la población Origen=2, Sexo=M\n")
cat("   • Sus eventos (muertes) son REALES y observados\n")
cat("   • Excluirlos introduce SESGO de selección\n\n")

cat("2. CONTRIBUCIÓN A EDADES JÓVENES:\n")
cat("   • Aportan exposición a edades 0-13 años (escasas en datos)\n")
cat("   • Pueden mejorar estimación de qx en edades bajas\n")
cat("   • En invalidez, pueden ser dependientes con cobertura\n\n")

cat("3. EXPOSICIÓN AJUSTABLE:\n")
cat("   • Se puede calcular exposición correctamente desde fecha de nacimiento\n")
cat("   • Método estándar: exposición = (Fecha_salida - Fecha_entrada) / 365.25\n")
cat("   • No es conceptualmente diferente a ajustar por entrada tardía\n\n")

cat("4. TABLA DE PERÍODO vs COHORTE:\n")
cat("   • Una tabla de PERÍODO (como esta) puede incluir nacimientos\n")
cat("   • Representa la experiencia durante 2000-2012, independiente de cohorte\n")
cat("   • Es una perspectiva válida en actuaría\n\n")

# ----------------------------------------------------------------------------
# 5. ANÁLISIS CUANTITATIVO: ¿QUÉ APORTAN?
# ----------------------------------------------------------------------------

cat("============================================================\n")
cat("  ANÁLISIS CUANTITATIVO\n")
cat("============================================================\n\n")

# Distribución por año de nacimiento
dist_nacimiento <- grupo_durante %>%
  mutate(Anio_nacimiento = as.integer(format(Fecha_nacimiento, "%Y"))) %>%
  group_by(Anio_nacimiento) %>%
  summarise(
    Registros = n(),
    Muertes = sum(Muerte_periodo),
    Tasa_mortalidad = if_else(n() > 0, sum(Muerte_periodo) / n(), 0),
    .groups = "drop"
  )

cat("Distribución de nacidos durante el período:\n\n")
print(dist_nacimiento)

# Exposición potencial
grupo_durante_exp <- grupo_durante %>%
  mutate(
    # Fecha de entrada = nacimiento (o inicio del período si ya existía)
    Fecha_entrada = pmax(Fecha_nacimiento, FECHA_INICIO),
    # Fecha de salida = fallecimiento o fin del período
    Fecha_salida = if_else(Muerte_periodo == 1 & !is.na(Fecha_fallecimiento),
                           Fecha_fallecimiento,
                           FECHA_FIN),
    # Exposición en años
    Exposicion_anios = fecha_a_anios(Fecha_salida, Fecha_entrada),
    # Edad al final del período o al fallecer
    Edad_final = floor(fecha_a_anios(Fecha_salida, Fecha_nacimiento))
  )

exposicion_total <- sum(grupo_durante_exp$Exposicion_anios)
muertes_total <- sum(grupo_durante_exp$Muerte_periodo)

cat(sprintf("\nExposición total del Grupo B: %.2f años-persona\n", exposicion_total))
cat(sprintf("Muertes del Grupo B: %s\n", muertes_total))
cat(sprintf("Tasa bruta: %.4f por año\n", muertes_total / exposicion_total))

# Por grupo de edad
exp_por_edad <- grupo_durante_exp %>%
  filter(Edad_final >= 0) %>%
  mutate(Grupo_edad = cut(Edad_final, 
                          breaks = c(0, 1, 5, 10, 15),
                          labels = c("0", "1-4", "5-9", "10-14"),
                          right = FALSE,
                          include.lowest = TRUE)) %>%
  group_by(Grupo_edad) %>%
  summarise(
    Registros = n(),
    Exposicion = sum(Exposicion_anios),
    Muertes = sum(Muerte_periodo),
    Tasa_qx = if_else(Exposicion > 0, Muertes / Exposicion, 0),
    .groups = "drop"
  )

cat("\nExposición por grupo de edad:\n\n")
print(exp_por_edad)

# ----------------------------------------------------------------------------
# 6. COMPARACIÓN: CON vs SIN NACIDOS EN PERÍODO
# ----------------------------------------------------------------------------

cat("\n")
cat("============================================================\n")
cat("  COMPARACIÓN: ANÁLISIS CON vs SIN GRUPO B\n")
cat("============================================================\n\n")

# Escenario 1: SIN Grupo B (actual)
cat("ESCENARIO 1 - SIN Grupo B (enfoque actual):\n")
cat(sprintf("  Registros: %s\n", format(nrow(grupo_antes), big.mark = ".")))
cat(sprintf("  Muertes: %s\n", format(sum(grupo_antes$Muerte_periodo), big.mark = ".")))
cat(sprintf("  Edades: 0 a %d años\n", max(grupo_antes$Edad_inicio)))

# Escenario 2: CON Grupo B
cat("\nESCENARIO 2 - CON Grupo B (enfoque alternativo):\n")
cat(sprintf("  Registros: %s (+%.1f%%)\n", 
            format(nrow(datos), big.mark = "."),
            100 * nrow(grupo_durante) / nrow(grupo_antes)))
cat(sprintf("  Muertes: %s (+%.1f%%)\n",
            format(sum(datos$Muerte_periodo), big.mark = "."),
            100 * sum(grupo_durante$Muerte_periodo) / sum(grupo_antes$Muerte_periodo)))
cat(sprintf("  Exposición adicional en 0-14 años: %.0f años-persona\n", exposicion_total))

# Impacto en edades jóvenes
cat("\n¿Impacto en estimación de qx para edades 0-14?\n")
cat("  • Grupo B aporta exposición principalmente en edades 0-13\n")
cat(sprintf("  • Actualmente tenemos %d registros con edad 0-14 en Grupo A\n",
            sum(grupo_antes$Edad_inicio <= 14)))
cat(sprintf("  • Grupo B agregaría %d registros más en ese rango\n",
            nrow(grupo_durante)))
cat("  • Podría MEJORAR estimación de qx en edades bajas (más datos)\n")

# ----------------------------------------------------------------------------
# 7. RECOMENDACIÓN ACTUARIAL
# ----------------------------------------------------------------------------

cat("\n")
cat("============================================================\n")
cat("  RECOMENDACIÓN ACTUARIAL\n")
cat("============================================================\n\n")

cat("OPCIÓN 1 - EXCLUIR (Recomendada para este proyecto):\n")
cat("✓ Enfoque estándar y ortodoxo\n")
cat("✓ Más fácil de explicar y justificar\n")
cat("✓ Coherente con definición de tabla de cohorte\n")
cat("✓ Impacto mínimo (solo 0.07% de muertes)\n")
cat("✓ Facilita comparación con tabla referencia MI-2014\n\n")

cat("OPCIÓN 2 - INCLUIR (Alternativa válida):\n")
cat("✓ Más completo (incluye toda la población observada)\n")
cat("✓ Mejor estimación en edades bajas (más datos)\n")
cat("✓ Coherente con enfoque de tabla de período\n")
cat("✗ Requiere explicación metodológica adicional\n")
cat("✗ Menos estándar en tablas de mortalidad/invalidez\n\n")

cat("CONCLUSIÓN:\n")
cat("Para un Proyecto Final de Matemáticas Actuariales, se recomienda\n")
cat("MANTENER el enfoque actual (EXCLUIR Grupo B) porque:\n\n")
cat("1. Es el estándar en construcción de tablas de mortalidad\n")
cat("2. Evita confusión metodológica (cohorte vs período)\n")
cat("3. El impacto es estadísticamente insignificante (0.07% muertes)\n")
cat("4. Facilita comparación con tabla de referencia MI-2014\n")
cat("5. Es más fácil de defender metodológicamente\n\n")

cat("Si se quisiera incluir Grupo B, se debería:\n")
cat("• Justificar como 'tabla de período' (no de cohorte)\n")
cat("• Calcular exposición correcta (desde fecha de nacimiento)\n")
cat("• Documentar claramente la diferencia metodológica\n")
cat("• Comparar resultados con/sin para mostrar impacto\n\n")

cat("============================================================\n")

# ----------------------------------------------------------------------------
# 8. EXPORTAR RESULTADOS
# ----------------------------------------------------------------------------

cat("\n--- GUARDANDO RESULTADOS ---\n\n")

# Resumen comparativo
resumen_comp <- tibble(
  Escenario = c("SIN Grupo B (actual)", "CON Grupo B (alternativo)"),
  Registros = c(nrow(grupo_antes), nrow(datos)),
  Muertes = c(sum(grupo_antes$Muerte_periodo), sum(datos$Muerte_periodo)),
  Exposicion_adicional_0_14 = c(0, exposicion_total)
)

write.csv(resumen_comp, "resultados/NACIDOS_PERIODO_comparacion.csv", row.names = FALSE)
cat("✓ Guardado: NACIDOS_PERIODO_comparacion.csv\n")

write.csv(dist_nacimiento, "resultados/NACIDOS_PERIODO_por_anio.csv", row.names = FALSE)
cat("✓ Guardado: NACIDOS_PERIODO_por_anio.csv\n")

write.csv(exp_por_edad, "resultados/NACIDOS_PERIODO_exposicion_edad.csv", row.names = FALSE)
cat("✓ Guardado: NACIDOS_PERIODO_exposicion_edad.csv\n")

# Gráfico
p <- dist_nacimiento %>%
  ggplot(aes(x = Anio_nacimiento, y = Registros)) +
  geom_col(fill = "#3498db", alpha = 0.8) +
  geom_text(aes(label = format(Registros, big.mark = ".")), 
            vjust = -0.5, size = 3) +
  labs(
    title = "Distribución de Nacidos Durante el Período de Análisis",
    subtitle = "Personas con fecha de nacimiento 2000-2012 (Grupo B excluido actualmente)",
    x = "Año de nacimiento",
    y = "Cantidad de registros"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.x = element_blank()
  )

ggsave("imagenes/NACIDOS_PERIODO_distribucion.png", p, width = 10, height = 6, dpi = 300)
cat("✓ Guardado: NACIDOS_PERIODO_distribucion.png\n\n")
