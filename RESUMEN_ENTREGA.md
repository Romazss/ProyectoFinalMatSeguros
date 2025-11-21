# 📋 RESUMEN DE ENTREGA - Proyecto Final EYP2605

## 👥 Grupo: ORIGEN=2, TM_SEXO=M

### Asignación Confirmada
✅ **Origen**: 2  
✅ **Sexo**: Masculino (M)  
✅ **Tabla de Referencia**: INVALIDEZ 2014 - Masculino  
✅ **Período de Análisis**: 01/01/2000 a 31/12/2012  
✅ **Tasa de Interés Técnico**: 5% anual  
✅ **Radix**: 10.000.000  

---

## 📂 Archivos Creados para Ti

### 📚 Documentación (6 archivos)

1. **GUIA_RAPIDA.md** ⭐ LEER PRIMERO
   - Checklist paso a paso
   - Comandos rápidos
   - Errores comunes

2. **CONFIGURACION_GRUPO.md**
   - Tu configuración específica
   - Proceso detallado
   - Entregas esperadas

3. **ESTRUCTURA_COMPLETA.md**
   - Mapa visual completo
   - Lista de todos los outputs
   - Verificación final

4. **TABLA_REFERENCIA_INVALIDEZ_2014.md**
   - Cómo descargar tabla oficial
   - Fuentes recomendadas
   - Formato esperado

5. **PROYECTO_FINAL.md**
   - Especificaciones oficiales
   - Fórmulas actuariales

6. **README.md** (actualizado)
   - Estructura del proyecto
   - Guía de ejecución

### 🔧 Scripts R (7 archivos)

**Módulo 1: Construcción Tabla (60%)**
- ✅ `01_carga_y_exploracion.R` - Carga y filtrado
- ✅ `02_periodo_analisis.R` - Período 2000-2012
- ✅ `03_graduacion.R` - 3 métodos de graduación
- ✅ `04_bondad_ajuste.R` - 4 tests estadísticos
- ✅ `05_extrapolacion_tabla_completa.R` - Tabla final

**Módulo 2: Conmutaciones (10%)**
- ✅ `01_conmutaciones.R` - D(x), N(x), C(x), M(x), R(x)

**Módulo 3: Valores Actuales (30%)**
- ✅ `01_rentas_seguros.R` - 5 tipos de rentas

### 🔍 Validación

- ✅ `VALIDACION_INICIAL.R` - Diagnostica tus datos

---

## 🚀 PRÓXIMOS PASOS (Orden Específico)

### PASO 1: Leer (5 min)
```
Abre: GUIA_RAPIDA.md
Lee: Secciones 1-2
```

### PASO 2: Preparar (5 min)
```
Copia: Base_act.RData → /data/
```

### PASO 3: Diagnosticar (10 min)
```r
source("VALIDACION_INICIAL.R")
# Esto te dirá si todo está bien
```

### PASO 4: Ajustar (5-15 min)
Si VALIDACION_INICIAL.R encuentra errores:
1. Identifica nombres de columnas correctos
2. Abre scripts y reemplaza nombres
3. Re-ejecuta VALIDACION_INICIAL.R

### PASO 5: Ejecutar Scripts (depende de datos)

**Módulo 1** (tiempo: ~10-20 min total)
```r
source("01_construccion_tabla_mortalidad/01_carga_y_exploracion.R")
source("01_construccion_tabla_mortalidad/02_periodo_analisis.R")
source("01_construccion_tabla_mortalidad/03_graduacion.R")
source("01_construccion_tabla_mortalidad/04_bondad_ajuste.R")
source("01_construccion_tabla_mortalidad/05_extrapolacion_tabla_completa.R")
```

**Módulo 2** (tiempo: ~2 min)
```r
source("02_valores_conmutacion/01_conmutaciones.R")
```

**Módulo 3** (tiempo: ~5 min, después de obtener tabla)
```r
source("03_valores_actuales/01_rentas_seguros.R")
```

### PASO 6: Obtener Tabla de Referencia (30-60 min)

Descarga tabla INVALIDEZ 2014 - Masculino de:
- Superintendencia de Pensiones (spensiones.cl)
- Convierte a CSV si es necesario
- Copia a: `resultados/tabla_referencia_invalidez_2014_m.csv`

Ver: **TABLA_REFERENCIA_INVALIDEZ_2014.md** para detalles

### PASO 7: Completar Comparativos (15 min)

Edita 5 archivos CSV en `resultados/`:
- Llena columnas "Tabla_Referencia"
- Verifica diferenciales calculados
- Documenta discrepancias >5%

### PASO 8: Crear Informe (1-2 horas)

Documento final con:
- Introducción
- Módulo 1: Tabla construcción (con tablas/gráficos)
- Módulo 2: Conmutaciones
- Módulo 3: Valores actuales (con comparativos)
- Conclusiones

---

## ✅ CHECKLIST FINAL

### Antes de Entregar

- [ ] Base_act.RData copiado a `/data/`
- [ ] Ejecuté VALIDACION_INICIAL.R exitosamente
- [ ] Todos 7 scripts se ejecutaron sin errores
- [ ] Tabla INVALIDEZ 2014-M descargada
- [ ] 5 tablas comparativas completadas
- [ ] Todos los CSV tienen datos (no vacíos)
- [ ] Diferencial % calculado en todas las rentas
- [ ] Gráfico comparacion_metodos.png generado
- [ ] Informe final redactado
- [ ] Informe contiene todas las justificaciones
- [ ] Fórmulas actuariales incluidas
- [ ] Fecha de entrega: 08 de diciembre antes 22:00 hrs

### Archivos a Entregar

```
Informe Final contiene:
├── Caratula
├── Introducción
├── Módulo 1 (60%):
│   ├── Cuadro descriptivo (copy-paste)
│   ├── Edades límites (justificación escrita)
│   ├── Parámetros de graduación
│   ├── Tests de bondad (copy-paste tabla)
│   ├── Método extrapolación (documentado)
│   └── Tabla vida completa (copy-paste primeras y últimas)
├── Módulo 2 (10%):
│   └── Tabla conmutaciones (copy-paste)
├── Módulo 3 (30%):
│   ├── 5 cuadros comparativos (copy-paste)
│   ├── Fórmulas (escritas o en LaTeX)
│   └── Análisis de diferenciales
├── Conclusiones
├── Anexo: Scripts R utilizados
└── Anexo: Gráficos

Archivos para entregar también:
├── Todos los CSV de resultados/
├── Gráficos PNG
└── Archivo RData con tabla_vida_completa
```

---

## 📊 ARCHIVOS GENERADOS (Preview)

Después de ejecutar todos los scripts, tendrás estos outputs:

### En `resultados/`:

**Tablas Principales:**
- `cuadro_descriptivo.csv` - 8 filas, 2 columnas
- `tabla_edad.csv` - 50-80 filas, 5 columnas
- `tasas_graduadas.csv` - 50-80 filas, 6 columnas
- `resumen_bondad_ajuste.csv` - 3 filas (métodos), 9 columnas (tests)
- `tabla_vida_completa.csv` - ⭐ 100 filas, 8 columnas
- `tabla_conmutaciones.csv` - ⭐ 100 filas, 8 columnas

**5 Comparativos:**
- `dotal_puro.csv` - 3 edades (38, 54, 62)
- `renta_vitalicia_vencida.csv` - 3 edades (45, 60, 90)
- `renta_diferida_anticipada.csv` - 3 edades (25, 40, 70)
- `renta_temporal_vencida.csv` - 3 edades (25, 50, 75)
- `renta_temporal_diferida_anticipada.csv` - 3 edades (32, 50, 68)

**Gráficos:**
- `comparacion_metodos.png` - Visualización 3 métodos

### En `data/`:
- Archivos RData internos (no se entregan)

---

## 🎓 INFORMACIÓN IMPORTANTE

### Contactos Útiles
- **Superintendencia de Pensiones**: www.spensiones.cl (tabla referencia)
- **Correo Profesor**: (agregar)
- **Horario Atención**: (agregar)

### Recursos Adicionales
- Biblioteca Digital de la Universidad
- Material del curso (plataforma)
- Textos recomendados de Matemática Actuarial

### Fechas Críticas
- **Fecha Límite**: 08 de diciembre 2025
- **Hora**: Antes de 22:00 hrs
- **Entrega**: (Plataforma/Email/Presencial - confirmar)

---

## 🔐 RESPALDO DE SEGURIDAD

Recomendación:
1. Guardar en GitHub (repositorio)
2. Backup en Google Drive
3. Copia en USB
4. Enviar a todos los integrantes del grupo

---

## 📝 NOTAS ADICIONALES

### Si algo no funciona:

1. **"object not found"** → Ejecutaste script sin cargar datos antes
   - Solución: Ejecuta en orden (01 → 02 → ... → 07)

2. **"Column not found"** → Nombres de columnas diferentes
   - Solución: Ejecuta VALIDACION_INICIAL.R y ajusta

3. **Diferencias >50% con tabla referencia** → Problema en filtrado
   - Solución: Verifica Origen=2, TM_SEXO=M en VALIDACION_INICIAL.R

4. **Gráfico no se genera** → Problema con PNG
   - Solución: Revisa permisos carpeta `resultados/`

### Preguntas frecuentes

**P: ¿Qué hago si no encuentro la tabla de referencia?**
A: Consulta al profesor o usa otra tabla de invalidez cercana (documentar)

**P: ¿Puedo cambiar las edades de las rentas?**
A: NO, están especificadas en PROYECTO_FINAL.md

**P: ¿Puedo usar otro método de graduación?**
A: Sí, pero documenta por qué elegiste ese método

**P: ¿Qué hago con los valores NA en resultados?**
A: Verifica que tabla_referencia_invalidez_2014_m.csv esté en resultados/

---

## 🎉 ¡LISTO PARA COMENZAR!

### Próxima acción:

1. Abre: `GUIA_RAPIDA.md`
2. Sigue: Checklist paso a paso
3. ¡Éxito en tu proyecto!

---

**Fecha de preparación**: Noviembre 21, 2025  
**Grupo**: Origen=2, TM_SEXO=M  
**Tabla Referencia**: INVALIDEZ 2014 - Masculino  
**Entrega**: 08 de diciembre 2025 antes 22:00 hrs
