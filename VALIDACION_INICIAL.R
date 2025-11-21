# ============================================================================
# SCRIPT DE VALIDACIÓN INICIAL
# Verifica que los datos están correctamente cargados y filtrados
# Asignación: Origen=2, TM_SEXO=M (INVALIDEZ 2014 - Masculino)
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("VALIDACIÓN INICIAL - PROYECTO FINAL MATEMÁTICAS ACTUARIALES\n")
cat("="^80 %+% "\n\n")

# ============================================================================
# 1. VERIFICAR ARCHIVO DE DATOS
# ============================================================================

cat("1. VERIFICACIÓN DE ARCHIVOS\n")
cat("-" %+% "="^40 %+% "\n\n")

rdata_path <- "./data/Base_act.RData"

if (!file.exists(rdata_path)) {
  cat("❌ ERROR: No se encontró Base_act.RData\n")
  cat("   Asegúrate de copiar el archivo a: ./data/Base_act.RData\n")
  stop("Archivo no encontrado")
} else {
  cat("✓ Base_act.RData encontrado\n")
}

# ============================================================================
# 2. CARGAR Y EXPLORAR DATOS
# ============================================================================

cat("\n2. CARGA DE DATOS\n")
cat("-" %+% "="^40 %+% "\n\n")

load(rdata_path)

cat("Objetos cargados:\n")
objetos <- ls()
for (obj in objetos) {
  cat("  -", obj, "\n")
}

# Verificar que existe base_act
if (!exists("base_act")) {
  cat("\n❌ ERROR: No se encontró objeto 'base_act' en RData\n")
  stop("Objeto base_act no existe")
}

cat("\n✓ Objeto 'base_act' cargado correctamente\n")

# ============================================================================
# 3. INFORMACIÓN GENERAL DE LA BASE
# ============================================================================

cat("\n3. INFORMACIÓN GENERAL\n")
cat("-" %+% "="^40 %+% "\n\n")

cat("Dimensiones:\n")
cat("  Filas:   ", nrow(base_act), "\n")
cat("  Columnas:", ncol(base_act), "\n")

cat("\nNombres de columnas:\n")
for (i in seq(1, length(names(base_act)), by = 5)) {
  j <- min(i + 4, length(names(base_act)))
  cat("  ", paste(names(base_act)[i:j], collapse = ", "), "\n")
}

# ============================================================================
# 4. VERIFICAR COLUMNAS CLAVE
# ============================================================================

cat("\n4. VERIFICACIÓN DE COLUMNAS CLAVE\n")
cat("-" %+% "="^40 %+% "\n\n")

# Columnas necesarias
columnas_necesarias <- c("Origen", "TM_SEXO")

for (col in columnas_necesarias) {
  if (col %in% names(base_act)) {
    cat("✓", col, "encontrada\n")
  } else {
    cat("❌", col, "NO ENCONTRADA\n")
  }
}

# Verificar otras columnas potenciales
cat("\nOtras columnas disponibles:\n")
cat("  - Columnas con 'edad': ", 
    paste(names(base_act)[grepl("edad|age|Age", names(base_act), ignore.case = TRUE)], 
          collapse = ", "), "\n")
cat("  - Columnas con 'fecha': ", 
    paste(names(base_act)[grepl("fecha|date|Date", names(base_act), ignore.case = TRUE)], 
          collapse = ", "), "\n")
cat("  - Columnas con 'muerte': ", 
    paste(names(base_act)[grepl("muerte|death|Death", names(base_act), ignore.case = TRUE)], 
          collapse = ", "), "\n")

# ============================================================================
# 5. VALORES ÚNICOS DE FILTRADO
# ============================================================================

cat("\n5. VALORES DE FILTRADO\n")
cat("-" %+% "="^40 %+% "\n\n")

cat("Valores únicos de 'Origen':\n")
tabla_origen <- table(base_act$Origen)
for (origen in names(tabla_origen)) {
  cat(sprintf("  Origen = %s: %8d registros", origen, tabla_origen[[origen]]), "\n")
}

cat("\nValores únicos de 'TM_SEXO':\n")
tabla_sexo <- table(base_act$TM_SEXO)
for (sexo in names(tabla_sexo)) {
  cat(sprintf("  TM_SEXO = %s: %8d registros", sexo, tabla_sexo[[sexo]]), "\n")
}

cat("\nCombinación Origen x TM_SEXO:\n")
tabla_cruzada <- table(base_act$Origen, base_act$TM_SEXO)
print(tabla_cruzada)

# ============================================================================
# 6. FILTRADO ESPECÍFICO DEL GRUPO
# ============================================================================

cat("\n6. APLICAR FILTROS DEL GRUPO\n")
cat("-" %+% "="^40 %+% "\n\n")

cat("Criterios:\n")
cat("  - Origen: 2\n")
cat("  - TM_SEXO: M\n")
cat("  - Tabla de Referencia: INVALIDEZ 2014 - Masculino\n\n")

# Verificar que existan esos valores
if (!(2 %in% base_act$Origen)) {
  cat("❌ ERROR: No hay registros con Origen = 2\n")
  stop("Valor Origen no encontrado")
}

if (!("M" %in% base_act$TM_SEXO)) {
  cat("❌ ERROR: No hay registros con TM_SEXO = M\n")
  stop("Valor TM_SEXO no encontrado")
}

# Aplicar filtro
datos_grupo <- base_act %>%
  dplyr::filter(Origen == 2 & TM_SEXO == "M")

cat("✓ Filtrado aplicado:\n")
cat("  Registros originales: ", nrow(base_act), "\n")
cat("  Registros filtrados: ", nrow(datos_grupo), "\n")
cat("  % mantenido: ", round(100 * nrow(datos_grupo) / nrow(base_act), 2), "%\n")

# ============================================================================
# 7. EXPLORACIÓN DE DATOS FILTRADOS
# ============================================================================

cat("\n7. EXPLORACIÓN DE DATOS FILTRADOS\n")
cat("-" %+% "="^40 %+% "\n\n")

cat("Primeras filas:\n")
print(head(datos_grupo, 5))

cat("\nÚltimas filas:\n")
print(tail(datos_grupo, 5))

cat("\nTipo de datos por columna:\n")
str(datos_grupo, max.level = 1)

# ============================================================================
# 8. VERIFICACIÓN DE FECHAS (si existen)
# ============================================================================

cat("\n8. VERIFICACIÓN DE FECHAS Y PERÍODOS\n")
cat("-" %+% "="^40 %+% "\n\n")

fecha_cols <- names(datos_grupo)[grepl("fecha|date", names(datos_grupo), ignore.case = TRUE)]

if (length(fecha_cols) > 0) {
  cat("Columnas de fecha encontradas:", paste(fecha_cols, collapse = ", "), "\n\n")
  
  for (fecha_col in fecha_cols) {
    cat("Análisis de:", fecha_col, "\n")
    valores <- datos_grupo[[fecha_col]]
    
    # Intentar convertir a fecha si es necesario
    if (is.character(valores)) {
      cat("  Tipo: caracteres\n")
    } else if (is.numeric(valores)) {
      cat("  Tipo: numéricos\n")
    } else {
      cat("  Tipo:", class(valores), "\n")
    }
    
    cat("  Primeros valores: ", paste(head(valores, 3), collapse = ", "), "\n")
    cat("  Últimos valores: ", paste(tail(valores, 3), collapse = ", "), "\n\n")
  }
} else {
  cat("⚠ No se encontraron columnas de fecha\n")
  cat("  Verifica que el período de análisis esté definido correctamente\n")
}

# ============================================================================
# 9. VERIFICACIÓN DE MUERTES
# ============================================================================

cat("\n9. VERIFICACIÓN DE REGISTROS DE MUERTES\n")
cat("-" %+% "="^40 %+% "\n\n")

muerte_cols <- names(datos_grupo)[grepl("muerte|death", names(datos_grupo), ignore.case = TRUE)]

if (length(muerte_cols) > 0) {
  cat("Columnas de muerte encontradas:", paste(muerte_cols, collapse = ", "), "\n\n")
  
  for (muerte_col in muerte_cols) {
    cat("Análisis de:", muerte_col, "\n")
    valores <- datos_grupo[[muerte_col]]
    
    cat("  Tipo:", class(valores), "\n")
    
    if (is.numeric(valores)) {
      cat("  Mínimo: ", min(valores, na.rm = TRUE), "\n")
      cat("  Máximo: ", max(valores, na.rm = TRUE), "\n")
      cat("  Media: ", round(mean(valores, na.rm = TRUE), 4), "\n")
      cat("  Total muertes: ", sum(valores, na.rm = TRUE), "\n")
    } else if (is.logical(valores)) {
      cat("  Muertes (TRUE): ", sum(valores, na.rm = TRUE), "\n")
      cat("  Vivos (FALSE): ", sum(!valores, na.rm = TRUE), "\n")
    }
    cat("\n")
  }
} else {
  cat("⚠ No se encontraron columnas de muerte\n")
  cat("  Verifica que exista columna con información de mortalidad\n")
}

# ============================================================================
# 10. VERIFICACIÓN DE EDAD
# ============================================================================

cat("\n10. VERIFICACIÓN DE EDADES\n")
cat("-" %+% "="^40 %+% "\n\n")

edad_cols <- names(datos_grupo)[grepl("edad|age", names(datos_grupo), ignore.case = TRUE)]

if (length(edad_cols) > 0) {
  cat("Columnas de edad encontradas:", paste(edad_cols, collapse = ", "), "\n\n")
  
  for (edad_col in edad_cols) {
    cat("Análisis de:", edad_col, "\n")
    valores <- datos_grupo[[edad_col]]
    
    cat("  Tipo:", class(valores), "\n")
    cat("  Mínima edad: ", min(valores, na.rm = TRUE), "\n")
    cat("  Máxima edad: ", max(valores, na.rm = TRUE), "\n")
    cat("  Edad media: ", round(mean(valores, na.rm = TRUE), 2), "\n")
    cat("  Desv. Estándar: ", round(sd(valores, na.rm = TRUE), 2), "\n")
    cat("\n")
  }
} else {
  cat("⚠ No se encontraron columnas de edad\n")
  cat("  Verifica que exista columna con información de edades\n")
}

# ============================================================================
# 11. RESUMEN Y RECOMENDACIONES
# ============================================================================

cat("\n" %+% "="^80 %+% "\n")
cat("RESUMEN Y PRÓXIMOS PASOS\n")
cat("="^80 %+% "\n\n")

cat("✓ VALIDACIÓN COMPLETADA\n\n")

cat("Pasos siguientes:\n")
cat("1. Abre: 01_construccion_tabla_mortalidad/01_carga_y_exploracion.R\n")
cat("2. Ajusta nombres de columnas según lo que ves arriba\n")
cat("3. Ejecuta scripts en orden:\n")
cat("   - 01_carga_y_exploracion.R\n")
cat("   - 02_periodo_analisis.R\n")
cat("   - 03_graduacion.R\n")
cat("   - 04_bondad_ajuste.R\n")
cat("   - 05_extrapolacion_tabla_completa.R\n")
cat("   - ../02_valores_conmutacion/01_conmutaciones.R\n")
cat("   - ../03_valores_actuales/01_rentas_seguros.R\n\n")

cat("Información importante:\n")
cat("- Período de análisis: 01/01/2000 a 31/12/2012\n")
cat("- Tasa de interés técnico: 5%\n")
cat("- Tabla de referencia: INVALIDEZ 2014 - Masculino\n")
cat("- Radix (l(x) inicial): 10.000.000\n\n")

cat("Dudas o problemas:\n")
cat("- Revisar: CONFIGURACION_GRUPO.md\n")
cat("- Consultar: README.md\n")
cat("- Proyecto: PROYECTO_FINAL.md\n")

cat("\n" %+% "="^80 %+% "\n\n")
