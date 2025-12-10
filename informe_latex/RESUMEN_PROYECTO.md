# 📘 Informe LaTeX Modular - Resumen del Proyecto

## ✅ ESTADO: COMPLETADO

Se ha creado exitosamente una estructura modular completa de LaTeX para responder al Proyecto Final de Matemáticas Actuariales.

---

## 📁 Archivos Creados

### Documentos LaTeX Principales

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `informe_principal.tex` | Documento maestro con portada y estructura | ✅ Completo |
| `00_preambulo.tex` | Configuración de paquetes y estilos PUC | ✅ Completo |
| `01_introduccion.tex` | Introducción y contexto del proyecto | ✅ Completo |
| `02_construccion_tabla.tex` | Sección 1 del proyecto (60%) | ⚠️ Requiere datos |
| `03_conmutacion.tex` | Sección 2 del proyecto (10%) | ⚠️ Requiere datos |
| `04_valores_actuales.tex` | Sección 3 del proyecto (30%) | ⚠️ Requiere datos |
| `05_conclusiones.tex` | Conclusiones y referencias | ⚠️ Requiere análisis |

### Documentación

| Archivo | Propósito |
|---------|-----------|
| `README.md` | Documentación completa del proyecto |
| `GUIA_COMPILACION.md` | Guía rápida de uso y compilación |
| `PLANTILLA_RESPUESTAS.md` | Plantillas y ejemplos para completar |

### Recursos

| Carpeta/Archivo | Contenido |
|-----------------|-----------|
| `Imagenes/` | Logos UC y Kovan (copiados) |
| `tablas/` | Directorio para archivos CSV de resultados |

---

## 🎯 Características del Template

### ✨ Estilo Profesional PUC

- **Colores institucionales:** Paleta celeste UC
- **Logos oficiales:** UC y Kovan incluidos
- **Tipografía:** Times New Roman (elegante y profesional)
- **Márgenes:** Optimizados para impresión A4
- **Encabezados:** Con nombre del curso y numeración

### 📊 Elementos Predefinidos

- **Cajas destacadas:** `hallazgobox` (azul) y `notabox` (amarilla)
- **Tablas estilizadas:** Con encabezados de color
- **Comandos actuariales:** `\qx{x}`, `\px{x}`, `\lx{x}`, etc.
- **Numeración automática:** Secciones, figuras, tablas, ecuaciones
- **Tabla de contenidos:** Generada automáticamente

### 🔧 Modularidad

- **Secciones independientes:** Cada sección en su propio archivo
- **Fácil colaboración:** Múltiples personas pueden trabajar simultáneamente
- **Mantenimiento simple:** Editar una sección no afecta las demás
- **Compilación rápida:** Comentar secciones para pruebas rápidas

---

## 📋 Estructura del Proyecto Final

### Distribución de Puntos

```
Construcción de Tabla (60%)
├── Cuadro de registros (5%)
├── Graduación (25%)
│   ├── Edades límites justificadas
│   ├── Parámetros de suavidad
│   └── 4 tests de bondad de ajuste
├── Extrapolación (15%)
│   ├── Cabeza (10-x años)
│   └── Cola (x-109 años)
└── Tabla completa (15%)
    └── Incluyendo esperanza de vida

Valores de Conmutación (10%)
├── Tabla obtenida (5%)
└── Tabla de referencia (5%)

Valores Actuales (30%)
├── Dotal puro - 70 años (6%)
├── Renta vitalicia vencida (6%)
├── Renta diferida anticipada - 75 años (6%)
├── Renta temporal vencida - 80 años (6%)
├── Renta temporal diferida anticipada - 70 años (6%)
└── Comentarios y análisis (variable)
```

---

## 🚀 Cómo Usar Este Template

### Paso 1: Actualizar Información Personal

Archivo: `informe_principal.tex`

```latex
% Líneas 96-103: Reemplazar nombres de integrantes
$\bullet$ \quad Tu Nombre \\[0.2cm]
$\bullet$ \quad Nombre Compañero 2 \\[0.2cm]
...
```

### Paso 2: Completar Resultados

Buscar en todos los archivos `.tex` el marcador:
```
[COMPLETAR]
```

Total de marcadores a completar: **~120 ubicaciones**

### Paso 3: Agregar Gráficos

1. Generar gráficos en R
2. Exportar como PNG o PDF
3. Guardar en carpeta `Imagenes/`
4. Descomentar las secciones de figuras en los `.tex`

### Paso 4: Exportar Tablas

```r
# En R, exportar resultados
write.csv(tabla_mortalidad, "tablas/tabla_mortalidad_obtenida.csv")
write.csv(conmutacion_obtenida, "tablas/conmutacion_tabla_obtenida.csv")
write.csv(conmutacion_referencia, "tablas/conmutacion_tabla_referencia.csv")
```

### Paso 5: Compilar

```powershell
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex
pdflatex -interaction=nonstopmode informe_principal.tex
pdflatex -interaction=nonstopmode informe_principal.tex
```

---

## 📊 Productos Actuariales Incluidos

### 1. Dotal Puro (Edad final = 70)

| Edad | Fórmula |
|------|---------|
| 38 | ${}_{32}E_{38} = \frac{D_{70}}{D_{38}}$ |
| 54 | ${}_{16}E_{54} = \frac{D_{70}}{D_{54}}$ |
| 62 | ${}_{8}E_{62} = \frac{D_{70}}{D_{62}}$ |

### 2. Renta Vitalicia Vencida

| Edad | Fórmula |
|------|---------|
| 45 | $a_{45} = \frac{N_{46}}{D_{45}}$ |
| 60 | $a_{60} = \frac{N_{61}}{D_{60}}$ |
| 90 | $a_{90} = \frac{N_{91}}{D_{90}}$ |

### 3. Renta Diferida Anticipada (desde 75)

| Edad | Fórmula |
|------|---------|
| 25 | ${}_{|50}\ddot{a}_{25} = \frac{N_{75}}{D_{25}}$ |
| 40 | ${}_{|35}\ddot{a}_{40} = \frac{N_{75}}{D_{40}}$ |
| 70 | ${}_{|5}\ddot{a}_{70} = \frac{N_{75}}{D_{70}}$ |

### 4. Renta Temporal Vencida (hasta 80)

| Edad | Fórmula |
|------|---------|
| 25 | $a_{25:\overline{55}|} = \frac{N_{26} - N_{81}}{D_{25}}$ |
| 50 | $a_{50:\overline{30}|} = \frac{N_{51} - N_{81}}{D_{50}}$ |
| 75 | $a_{75:\overline{5}|} = \frac{N_{76} - N_{81}}{D_{75}}$ |

### 5. Renta Temporal Diferida Anticipada (hasta 70)

| Edad | Fórmula |
|------|---------|
| 32 | $\ddot{a}_{32:\overline{38}|} = \frac{N_{32} - N_{70}}{D_{32}}$ |
| 50 | $\ddot{a}_{50:\overline{20}|} = \frac{N_{50} - N_{70}}{D_{50}}$ |
| 68 | $\ddot{a}_{68:\overline{2}|} = \frac{N_{68} - N_{70}}{D_{68}}$ |

---

## 💡 Tips y Recomendaciones

### Para Compilación

1. **Compilar dos veces:** LaTeX necesita dos pasadas para referencias cruzadas
2. **Limpiar auxiliares:** Si hay errores extraños, borrar `.aux`, `.log`, `.toc`
3. **Comentar imágenes:** Durante edición, comentar imágenes grandes para compilar más rápido

### Para Edición

1. **Trabajar por secciones:** Editar un archivo `.tex` a la vez
2. **Guardar frecuentemente:** LaTeX puede fallar si hay errores de sintaxis
3. **Verificar sintaxis:** Cada `\begin{}` debe tener su `\end{}`
4. **Usar editores con resaltado:** VS Code, TeXstudio, o Overleaf

### Para Resultados

1. **Formato consistente:** Usar mismo número de decimales en todas las tablas
2. **Verificar signos:** Los diferenciales pueden ser positivos o negativos
3. **Comentar resultados:** No solo poner números, interpretar qué significan
4. **Revisar fórmulas:** Asegurarse que las fórmulas LaTeX coincidan con el código R

---

## 🔍 Búsqueda de Marcadores

Para encontrar todos los lugares que requieren completar:

```powershell
# Windows PowerShell
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex
Select-String -Path "*.tex" -Pattern "\[COMPLETAR\]" | Select-Object Filename, LineNumber
```

---

## 📅 Timeline Sugerido

| Días restantes | Actividad |
|----------------|-----------|
| **Hoy** | Actualizar nombres, familiarizarse con estructura |
| **-3 días** | Completar Sección 2 (Construcción tabla) |
| **-2 días** | Completar Secciones 3 y 4 (Conmutación y Valores actuales) |
| **-1 día** | Completar Sección 5 (Conclusiones), agregar gráficos |
| **Día entrega** | Revisión final, compilación, entrega antes de 22:00 |

---

## ✅ Checklist Final de Entrega

### Documentos

- [ ] PDF compilado sin errores
- [ ] Todos los `[COMPLETAR]` reemplazados
- [ ] Nombres de integrantes actualizados
- [ ] Numeración de páginas correcta
- [ ] Tabla de contenidos actualizada

### Contenido

- [ ] 5 productos con 3 edades cada uno = 15 valores calculados
- [ ] Todos los diferenciales calculados
- [ ] 4 tests de bondad de ajuste completos
- [ ] Tablas de conmutación (obtenida y referencia)
- [ ] Comentarios y análisis en cada sección

### Recursos

- [ ] Gráficos incluidos y referenciados
- [ ] Archivos CSV exportados
- [ ] Scripts de R documentados
- [ ] Logos y formato correcto

### Calidad

- [ ] Sin errores ortográficos
- [ ] Fórmulas correctamente escritas
- [ ] Referencias cruzadas funcionando
- [ ] Formato consistente en todas las tablas

---

## 📞 Soporte

Si encuentras problemas:

1. **Revisar GUIA_COMPILACION.md:** Soluciones a problemas comunes
2. **Revisar README.md:** Documentación completa
3. **Revisar PLANTILLA_RESPUESTAS.md:** Ejemplos y formatos

---

## 🎓 Información del Curso

- **Asignatura:** EYP2605 - Matemáticas Actuariales
- **Institución:** Pontificia Universidad Católica de Chile
- **Facultad:** Facultad de Matemáticas
- **Período:** Noviembre 2025
- **Fecha límite:** 11 de diciembre de 2025, 22:00 hrs

---

## 📝 Notas Finales

Este template está diseñado para:

✅ Facilitar la escritura del informe final
✅ Mantener consistencia visual profesional
✅ Permitir trabajo colaborativo
✅ Reutilizar el estilo del proyecto anterior
✅ Cumplir con todos los requisitos del proyecto

**¡Éxito con tu proyecto final!** 🎉

---

*Última actualización: Diciembre 9, 2025*
*Template creado para: ProyectoFinalMatSeguros*
