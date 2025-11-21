# 🎯 GUÍA RÁPIDA - Proyecto Final Matemáticas Actuariales

## Tu Asignación

```
Criterios:
  ✓ Origen: 2
  ✓ TM_SEXO: M (Masculino)
  ✓ Tabla Referencia: INVALIDEZ 2014 - Masculino

Período de Análisis:
  ✓ Inicio: 01/01/2000
  ✓ Fin: 31/12/2012

Tasa de Interés Técnico:
  ✓ 5% anual

Radix para Tabla de Vida:
  ✓ l(x) = 10.000.000

Fecha de Entrega:
  ✓ Lunes 08 de diciembre antes de 22:00 hrs
```

---

## 🚀 Ejecución Rápida (Checklist)

### Fase 1: Preparación ✓ HECHO

- [x] Estructura de carpetas creada
- [x] Scripts personalizados para tu asignación
- [x] Documentación específica

### Fase 2: Validación Inicial

**Archivo**: `VALIDACION_INICIAL.R`

```
⚠️ OBLIGATORIO: Ejecuta primero este script para:
1. Verificar que Base_act.RData está en /data/
2. Explorar estructura de datos
3. Identificar nombres correctos de columnas
4. Confirmar filtros (Origen=2, TM_SEXO=M)
```

**Acciones**:
1. Copia `Base_act.RData` a `/data/`
2. Abre R o RStudio
3. `source("VALIDACION_INICIAL.R")`
4. **ANOTA** los nombres de columnas para edad, fecha, muerte

### Fase 3: Ajustar Scripts

En cada script, busca comentarios tipo:
```r
# NOTA: Ajustar nombre de la columna según tu base de datos
```

**Columnas a verificar**:
- Edad: `edad`, `Edad`, `age`, `AGE`?
- Muerte: `muerte`, `Muerte`, `fallecimiento`?
- Fecha: `fecha_inicio_vigencia`, `fecha_muerte`?

### Fase 4: Construcción de Tabla (60%)

**Scripts a ejecutar en orden:**

1. **01_carga_y_exploracion.R**
   ```r
   # Ubicación: 01_construccion_tabla_mortalidad/
   # Ejecuta: source("01_carga_y_exploracion.R")
   # Output: data/datos_seleccionados.RData
   ```

2. **02_periodo_analisis.R**
   ```r
   # Output: cuadro_descriptivo.csv, tabla_edad.csv
   # IMPORTANTE: Incluir en informe la tabla descriptiva
   ```

3. **03_graduacion.R**
   ```r
   # Prueba 3 métodos: Spline, Gompertz, Polinomio
   # Output: tasas_graduadas.csv
   ```

4. **04_bondad_ajuste.R**
   ```r
   # Evalúa: Chi², KS, Rachas, Signos
   # Output: resumen_bondad_ajuste.csv, comparacion_metodos.png
   # ⭐ ELEGIR MEJOR MÉTODO aquí
   ```

5. **05_extrapolacion_tabla_completa.R**
   ```r
   # Construye tabla 10-109 años con l(x)=10.000.000
   # Output: tabla_vida_completa.csv
   # ⭐ PRINCIPAL ENTREGABLE
   ```

### Fase 5: Conmutaciones (10%)

**Script a ejecutar:**

```r
# Ubicación: 02_valores_conmutacion/
# source("02_valores_conmutacion/01_conmutaciones.R")
# Output: tabla_conmutaciones.csv
```

**Verifica**:
- Tasa de interés = 5%
- Calcula D(x), N(x), C(x), M(x), R(x)

### Fase 6: Valores Actuales (30%)

**Script a ejecutar:**

```r
# Ubicación: 03_valores_actuales/
# source("03_valores_actuales/01_rentas_seguros.R")
# Output: 5 archivos CSV
```

**Completa tabla de referencia ANTES:**
1. Descarga tabla INVALIDEZ 2014 - Masculino
2. Crea `tabla_referencia_invalidez_2014_m.csv`
3. Copia valores de referencia en los scripts

---

## 📊 Entregables (Resumen)

### Módulo 1: Construcción de Tabla (60%)

| Concepto | Archivo | Incluir en Informe |
|----------|---------|-------------------|
| Cuadro descriptivo | `cuadro_descriptivo.csv` | Sí |
| Justificación edades límites | (Documento) | Sí |
| Parámetros de graduación | (Documento) | Sí |
| Tests de bondad | `resumen_bondad_ajuste.csv` | Sí |
| Método extrapolación | (Documento) | Sí |
| Tabla de vida completa | `tabla_vida_completa.csv` | Sí |
| Gráfico métodos | `comparacion_metodos.png` | Sí (opcional) |

### Módulo 2: Conmutaciones (10%)

| Concepto | Archivo |
|----------|---------|
| D(x), N(x), C(x), M(x), R(x) | `tabla_conmutaciones.csv` |
| Tasa 5% | (Documentado en script) |

### Módulo 3: Valores Actuales (30%)

| Tipo de Renta | Archivo | Edades |
|---------------|---------|--------|
| Dotal Puro | `dotal_puro.csv` | 38, 54, 62 |
| Renta Vitalicia Vencida | `renta_vitalicia_vencida.csv` | 45, 60, 90 |
| Renta Diferida Anticipada | `renta_diferida_anticipada.csv` | 25, 40, 70 |
| Renta Temporal Vencida | `renta_temporal_vencida.csv` | 25, 50, 75 |
| Renta Temporal Diferida Anticipada | `renta_temporal_diferida_anticipada.csv` | 32, 50, 68 |

---

## 📝 Documento Final (Informe)

**Estructura recomendada:**

```markdown
# INFORME FINAL - PROYECTO EYP2605

## 1. Introducción
   - Asignación: Origen=2, TM_SEXO=M, INVALIDEZ 2014
   - Período: 2000-2012

## 2. Módulo 1: Construcción de Tabla (60%)
   
   ### 2.1 Datos Originales
   - Tabla descriptiva (cuadro_descriptivo.csv)
   - Registros originales vs período de análisis
   
   ### 2.2 Graduación
   - Rango de edades seleccionado y justificación
   - Métodos probados: Spline, Gompertz, Polinomio
   - Método seleccionado: [SELECCIONAR]
   - Parámetros utilizados: [AGREGAR]
   
   ### 2.3 Tests de Bondad de Ajuste
   | Test | Valor | p-value | Conclusión |
   |------|-------|---------|-----------|
   | Chi² | ... | ... | ✓/✗ |
   | KS | ... | ... | ✓/✗ |
   | Rachas | ... | ... | ✓/✗ |
   | Signos | ... | ... | ✓/✗ |
   
   ### 2.4 Extrapolación
   - Método seleccionado: [Especificar]
   - Cabeza: edades 10 a [edad mín]
   - Cola: edades [edad máx] a 109
   
   ### 2.5 Tabla de Vida Final
   - Radix: 10.000.000
   - Rango: 10 a 109 años
   - e(10), e(40), e(65) [valores]

## 3. Módulo 2: Conmutaciones (10%)
   - Tasa técnica: 5%
   - Tabla conmutaciones: [mostrar primeras y últimas filas]

## 4. Módulo 3: Valores Actuales (30%)
   - 5 cuadros comparativos
   - Fórmulas utilizadas
   - Análisis de diferencias

## 5. Conclusiones y Comentarios

## Anexo 1: Scripts R utilizados

## Anexo 2: Gráficos

## Anexo 3: Tablas detalladas
```

---

## 🔧 Comandos Rápidos

### Verificación inicial
```r
source("VALIDACION_INICIAL.R")
```

### Ejecutar todo el proyecto (si todo está listo)
```r
# Módulo 1
source("01_construccion_tabla_mortalidad/01_carga_y_exploracion.R")
source("01_construccion_tabla_mortalidad/02_periodo_analisis.R")
source("01_construccion_tabla_mortalidad/03_graduacion.R")
source("01_construccion_tabla_mortalidad/04_bondad_ajuste.R")
source("01_construccion_tabla_mortalidad/05_extrapolacion_tabla_completa.R")

# Módulo 2
source("02_valores_conmutacion/01_conmutaciones.R")

# Módulo 3
source("03_valores_actuales/01_rentas_seguros.R")
```

### Cargar tabla de referencia
```r
tabla_ref <- read.csv("resultados/tabla_referencia_invalidez_2014_m.csv")
head(tabla_ref)
```

---

## ⚠️ Errores Comunes

| Error | Solución |
|-------|----------|
| `object 'base_act' not found` | Copiar Base_act.RData a /data/ |
| `No such file or directory` | Verifica rutas relativas (usa setwd() si es necesario) |
| `Column 'edad' not found` | Ejecuta VALIDACION_INICIAL.R para identificar nombre correcto |
| Diferencias >50% con tabla referencia | Verifica criterios de filtrado (Origen=2, TM_SEXO=M) |
| `Error in lm()` | Insuficientes datos en rango, ajusta edades límites |

---

## 📞 Recursos Útiles

**Este proyecto incluye:**
- ✅ PROYECTO_FINAL.md - Especificaciones completas
- ✅ README.md - Guía de estructura
- ✅ CONFIGURACION_GRUPO.md - Tu configuración específica
- ✅ TABLA_REFERENCIA_INVALIDEZ_2014.md - Cómo obtener tabla referencia
- ✅ VALIDACION_INICIAL.R - Script de verificación
- ✅ 7 scripts R personalizados para tu asignación

**Estructura:**
```
01_construccion_tabla_mortalidad/  (5 scripts)
02_valores_conmutacion/             (1 script)
03_valores_actuales/                (1 script)
data/                               (Aquí copiar Base_act.RData)
resultados/                         (Aquí se guardan outputs)
```

---

## ✅ CHECKLIST FINAL

- [ ] Base_act.RData copiado a /data/
- [ ] Ejecuté VALIDACION_INICIAL.R
- [ ] Identifiqué nombres correctos de columnas
- [ ] Ejecuté script 01_carga_y_exploracion.R
- [ ] Ejecuté script 02_periodo_analisis.R ← Guardar tabla descriptiva
- [ ] Ejecuté script 03_graduacion.R
- [ ] Ejecuté script 04_bondad_ajuste.R ← Seleccionar mejor método
- [ ] Ejecuté script 05_extrapolacion_tabla_completa.R ← Verificar tabla_vida
- [ ] Ejecuté conmutaciones
- [ ] Descargué tabla INVALIDEZ 2014-M
- [ ] Ejecuté script rentas y completé tabla referencia
- [ ] Documenté justificaciones y fórmulas
- [ ] Creé informe final
- [ ] Entregué antes del 08/dic a las 22:00 hrs

---

**¡Éxito en tu proyecto! 🎓**

Cualquier duda, revisa:
1. CONFIGURACION_GRUPO.md (tu config específica)
2. README.md (estructura general)
3. Scripts con comentarios detallados
