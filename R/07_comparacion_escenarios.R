# ============================================================================
# MÓDULO 7: COMPARACIÓN ENTRE ESCENARIOS
# ============================================================================
# Descripción: Compara resultados de diferentes configuraciones
# Input:  Resultados de múltiples escenarios
# Output: Tablas y gráficos comparativos
# ============================================================================

# Cargar configuración
source("R/00_config.R")
library(tidyverse)

mensaje("MÓDULO 7: COMPARACIÓN DE ESCENARIOS", "titulo")

# ----------------------------------------------------------------------------
# 1. CARGAR RESULTADOS DE TODOS LOS ESCENARIOS
# ----------------------------------------------------------------------------

mensaje("Cargando resultados de escenarios...", "subtitulo")

# Buscar carpetas de escenarios
carpetas_escenarios <- list.dirs("resultados", recursive = FALSE, full.names = TRUE)
carpetas_escenarios <- carpetas_escenarios[grepl("escenario_", carpetas_escenarios)]

if (length(carpetas_escenarios) == 0) {
  stop("No se encontraron carpetas de escenarios. Ejecuta primero algunos escenarios.")
}

cat(sprintf("✓ Se encontraron %d escenarios\n", length(carpetas_escenarios)))

# Función para cargar tabla de mortalidad de un escenario
cargar_escenario <- function(carpeta) {
  nombre <- basename(carpeta)
  nombre_escenario <- gsub("escenario_", "", nombre)
  
  # Cargar datos
  archivo_tabla <- file.path(carpeta, "04_tabla_mortalidad_completa.csv")
  archivo_tests <- file.path(carpeta, "03_tests_bondad_ajuste.csv")
  archivo_valores <- file.path(carpeta, "06_resumen_valores_actuales.csv")
  
  resultado <- list(
    nombre = nombre_escenario,
    carpeta = carpeta
  )
  
  if (file.exists(archivo_tabla)) {
    resultado$tabla <- read_csv(archivo_tabla, show_col_types = FALSE) %>% as_tibble()
  }
  
  if (file.exists(archivo_tests)) {
    resultado$tests <- read_csv(archivo_tests, show_col_types = FALSE) %>% as_tibble()
  }
  
  if (file.exists(archivo_valores)) {
    resultado$valores <- read_csv(archivo_valores, show_col_types = FALSE) %>% as_tibble()
  }
  
  return(resultado)
}

# Cargar todos los escenarios
escenarios <- lapply(carpetas_escenarios, cargar_escenario)
names(escenarios) <- sapply(escenarios, function(x) x$nombre)

cat(sprintf("✓ Escenarios cargados: %s\n", paste(names(escenarios), collapse = ", ")))

# ----------------------------------------------------------------------------
# 2. COMPARAR TASAS DE MORTALIDAD
# ----------------------------------------------------------------------------

mensaje("Comparando tasas de mortalidad...", "subtitulo")

# Combinar todas las tablas
tablas_combinadas <- bind_rows(
  lapply(names(escenarios), function(nom) {
    if (!is.null(escenarios[[nom]]$tabla)) {
      escenarios[[nom]]$tabla %>%
        as_tibble() %>%
        mutate(
          Escenario = as.character(nom),
          Edad = as.integer(Edad),
          qx = as.numeric(qx),
          lx = as.numeric(lx),
          ex = as.numeric(ex)
        ) %>%
        select(Escenario, Edad, qx, lx, ex)
    }
  })
) %>% as_tibble()

# Calcular estadísticas por edad
stats_por_edad <- tablas_combinadas %>%
  group_by(Edad) %>%
  summarise(
    n_escenarios = as.integer(n()),
    qx_min = as.numeric(min(qx, na.rm = TRUE)),
    qx_max = as.numeric(max(qx, na.rm = TRUE)),
    qx_mean = as.numeric(mean(qx, na.rm = TRUE)),
    qx_sd = as.numeric(sd(qx, na.rm = TRUE)),
    ex_min = as.numeric(min(ex, na.rm = TRUE)),
    ex_max = as.numeric(max(ex, na.rm = TRUE)),
    ex_mean = as.numeric(mean(ex, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  as_tibble()

cat("\nEstadísticas de variación entre escenarios:\n")
cat(sprintf("  Desviación estándar promedio en qx: %.6f\n", 
            mean(stats_por_edad$qx_sd, na.rm = TRUE)))
cat(sprintf("  Rango promedio en qx: %.6f\n", 
            mean(stats_por_edad$qx_max - stats_por_edad$qx_min, na.rm = TRUE)))

# ----------------------------------------------------------------------------
# 3. GRÁFICOS COMPARATIVOS - TASAS DE MORTALIDAD
# ----------------------------------------------------------------------------

mensaje("Generando gráficos comparativos...", "subtitulo")

# Gráfico 1: Todas las curvas qx
p1 <- ggplot(tablas_combinadas %>% filter(Edad >= 20, Edad <= 100), 
             aes(x = Edad, y = qx, color = Escenario, linetype = Escenario)) +
  geom_line(linewidth = 1) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Comparación de Tasas de Mortalidad qx",
    subtitle = "Múltiples escenarios de graduación",
    x = "Edad (años)",
    y = "Tasa de mortalidad qx (escala log)",
    color = "Escenario",
    linetype = "Escenario"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    legend.direction = "vertical"
  )

ggsave(
  filename = file.path(DIR_GRAFICOS, "07_comparacion_qx_todos.png"),
  plot = p1,
  width = 12,
  height = 8,
  dpi = 300
)

# Gráfico 2: Bandas de confianza
p2 <- ggplot(stats_por_edad %>% filter(Edad >= 20, Edad <= 100), 
             aes(x = Edad)) +
  geom_ribbon(aes(ymin = qx_min, ymax = qx_max), 
              alpha = 0.3, fill = "steelblue") +
  geom_line(aes(y = qx_mean), 
            color = "darkblue", linewidth = 1.2) +
  scale_y_log10(labels = scales::label_number(accuracy = 0.0001)) +
  labs(
    title = "Rango de Tasas de Mortalidad entre Escenarios",
    subtitle = "Banda: mín-máx | Línea: promedio",
    x = "Edad (años)",
    y = "Tasa de mortalidad qx (escala log)",
    caption = sprintf("Basado en %d escenarios", length(escenarios))
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave(
  filename = file.path(DIR_GRAFICOS, "07_comparacion_qx_bandas.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

# Gráfico 3: Esperanza de vida
p3 <- ggplot(tablas_combinadas %>% filter(Edad <= 100), 
             aes(x = Edad, y = ex, color = Escenario, linetype = Escenario)) +
  geom_line(linewidth = 1) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Comparación de Esperanza de Vida ex",
    subtitle = "Múltiples escenarios",
    x = "Edad (años)",
    y = "Esperanza de vida ex (años)",
    color = "Escenario",
    linetype = "Escenario"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    legend.direction = "vertical"
  )

ggsave(
  filename = file.path(DIR_GRAFICOS, "07_comparacion_ex_todos.png"),
  plot = p3,
  width = 12,
  height = 8,
  dpi = 300
)

cat("✓ Gráficos guardados\n")

# ----------------------------------------------------------------------------
# 4. COMPARAR TESTS DE BONDAD
# ----------------------------------------------------------------------------

mensaje("Comparando tests de bondad de ajuste...", "subtitulo")

# Combinar tests
tests_combinados <- bind_rows(
  lapply(names(escenarios), function(nom) {
    if (!is.null(escenarios[[nom]]$tests)) {
      escenarios[[nom]]$tests %>%
        as_tibble() %>%
        mutate(Escenario = as.character(nom))
    }
  })
) %>% as_tibble()

# Tabla resumen de p-valores
if (nrow(tests_combinados) > 0) {
  tabla_tests <- tests_combinados %>%
    select(Escenario, Test, Valor_p, Resultado) %>%
    pivot_wider(
      names_from = Test,
      values_from = c(Valor_p, Resultado)
    )
  
  cat("\nResumen de tests de bondad:\n")
  print(tabla_tests)
  
  # Guardar
  guardar_resultado(tabla_tests, "07_comparacion_tests_bondad.csv")
}

# ----------------------------------------------------------------------------
# 5. COMPARAR VALORES ACTUALES
# ----------------------------------------------------------------------------

mensaje("Comparando valores actuales...", "subtitulo")

# Combinar valores actuales
valores_combinados <- bind_rows(
  lapply(names(escenarios), function(nom) {
    if (!is.null(escenarios[[nom]]$valores)) {
      escenarios[[nom]]$valores %>%
        as_tibble() %>%
        mutate(Escenario = as.character(nom))
    }
  })
) %>% as_tibble()

if (nrow(valores_combinados) > 0) {
  # Calcular diferencias entre escenarios
  comparacion_valores <- valores_combinados %>%
    select(Escenario, Producto, Edad, Valor_obt) %>%
    pivot_wider(
      names_from = Escenario,
      values_from = Valor_obt
    )
  
  cat("\nVariación en valores actuales entre escenarios:\n")
  print(comparacion_valores %>% head(10))
  
  # Guardar
  guardar_resultado(comparacion_valores, "07_comparacion_valores_actuales.csv")
  
  # Gráfico de valores actuales
  if (length(unique(valores_combinados$Escenario)) > 1) {
    p4 <- ggplot(valores_combinados, 
                 aes(x = Edad, y = Valor_obt, color = Escenario, shape = Producto)) +
      geom_point(size = 3, alpha = 0.7) +
      geom_line(aes(group = interaction(Escenario, Producto)), alpha = 0.5) +
      facet_wrap(~Producto, scales = "free_y", ncol = 2) +
      scale_color_brewer(palette = "Set1") +
      labs(
        title = "Comparación de Valores Actuales entre Escenarios",
        subtitle = "Por tipo de producto y edad",
        x = "Edad (años)",
        y = "Valor actual",
        color = "Escenario"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold", size = 14),
        legend.position = "bottom"
      )
    
    ggsave(
      filename = file.path(DIR_GRAFICOS, "07_comparacion_valores_actuales.png"),
      plot = p4,
      width = 14,
      height = 10,
      dpi = 300
    )
  }
}

# ----------------------------------------------------------------------------
# 6. TABLA RESUMEN DE DIFERENCIAS
# ----------------------------------------------------------------------------

mensaje("Generando tabla resumen de diferencias...", "subtitulo")

# Calcular diferencias clave entre escenarios
resumen_diferencias <- tibble(
  Escenario_1 = character(),
  Escenario_2 = character(),
  Dif_qx_pct = numeric(),
  Dif_ex_pct = numeric(),
  n_edades = integer()
)

for (i in 1:(length(escenarios)-1)) {
  for (j in (i+1):length(escenarios)) {
    esc1 <- names(escenarios)[i]
    esc2 <- names(escenarios)[j]
    
    if (!is.null(escenarios[[esc1]]$tabla) && !is.null(escenarios[[esc2]]$tabla)) {
      tabla1 <- escenarios[[esc1]]$tabla
      tabla2 <- escenarios[[esc2]]$tabla
      
      # Calcular diferencias en edades comunes
      edades_comunes <- intersect(tabla1$Edad, tabla2$Edad)
      
      if (length(edades_comunes) > 0) {
        t1 <- tabla1 %>% as_tibble() %>% filter(Edad %in% edades_comunes) %>% arrange(Edad)
        t2 <- tabla2 %>% as_tibble() %>% filter(Edad %in% edades_comunes) %>% arrange(Edad)
        
        dif_qx_media <- as.numeric(mean(abs(t1$qx - t2$qx) / t1$qx * 100, na.rm = TRUE))
        dif_ex_media <- as.numeric(mean(abs(t1$ex - t2$ex) / t1$ex * 100, na.rm = TRUE))
        
        resumen_diferencias <- bind_rows(
          resumen_diferencias,
          tibble(
            Escenario_1 = as.character(esc1),
            Escenario_2 = as.character(esc2),
            Dif_qx_pct = dif_qx_media,
            Dif_ex_pct = dif_ex_media,
            n_edades = as.integer(length(edades_comunes))
          )
        ) %>% as_tibble()
      }
    }
  }
}

if (nrow(resumen_diferencias) > 0) {
  cat("\nDiferencias promedio entre pares de escenarios:\n")
  print(resumen_diferencias %>% 
          mutate(across(c(Dif_qx_pct, Dif_ex_pct), ~round(., 2))))
  
  guardar_resultado(resumen_diferencias, "07_resumen_diferencias.csv")
}

# ----------------------------------------------------------------------------
# 7. RECOMENDACIÓN DE MEJOR ESCENARIO
# ----------------------------------------------------------------------------

mensaje("Evaluación de escenarios...", "subtitulo")

# Evaluar cada escenario basándose en tests de bondad
if (nrow(tests_combinados) > 0) {
  evaluacion <- tests_combinados %>%
    group_by(Escenario) %>%
    summarise(
      n_tests_buenos = as.integer(sum(Resultado == "Buen ajuste", na.rm = TRUE)),
      valor_p_promedio = as.numeric(mean(Valor_p, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(desc(n_tests_buenos), desc(valor_p_promedio)) %>%
    as_tibble()
  
  cat("\nEvaluación de escenarios (por bondad de ajuste):\n")
  print(evaluacion)
  
  mejor_escenario <- evaluacion$Escenario[1]
  cat(sprintf("\n✨ Mejor escenario recomendado: %s\n", mejor_escenario))
  cat(sprintf("   Tests con buen ajuste: %d de 4\n", 
              evaluacion$n_tests_buenos[1]))
  cat(sprintf("   Valor-p promedio: %.4f\n", 
              evaluacion$valor_p_promedio[1]))
  
  guardar_resultado(evaluacion, "07_evaluacion_escenarios.csv")
}

# ----------------------------------------------------------------------------
# 8. RESUMEN FINAL
# ----------------------------------------------------------------------------

mensaje("RESUMEN - MÓDULO 7 COMPLETADO", "titulo")
cat(sprintf("Escenarios comparados:    %d\n", length(escenarios)))
cat(sprintf("Archivos generados:       Tablas comparativas y gráficos\n"))
cat("\nArchivos principales:\n")
cat("  • 07_comparacion_qx_todos.png\n")
cat("  • 07_comparacion_qx_bandas.png\n")
cat("  • 07_comparacion_ex_todos.png\n")
cat("  • 07_comparacion_tests_bondad.csv\n")
cat("  • 07_comparacion_valores_actuales.csv\n")
cat("  • 07_evaluacion_escenarios.csv\n")
cat("\nComparación de escenarios completada ✓\n")
mensaje("", "titulo")

# Limpiar
rm(carpetas_escenarios, tablas_combinadas, stats_por_edad,
   tests_combinados, valores_combinados, comparacion_valores,
   resumen_diferencias, evaluacion, p1, p2, p3)
