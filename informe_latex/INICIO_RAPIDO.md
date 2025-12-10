# 📘 Informe LaTeX Modular - Inicio Rápido

## ✅ Estructura Creada

Se ha creado exitosamente la carpeta `informe_latex/` con todo lo necesario para responder al Proyecto Final de Matemáticas Actuariales.

---

## 📂 Ubicación

```
C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex\
```

---

## 🚀 Inicio Rápido (3 pasos)

### 1. Navegar al directorio

```powershell
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex
```

### 2. Leer la documentación

```powershell
# Abrir el resumen del proyecto
notepad RESUMEN_PROYECTO.md

# O abrir el README completo
notepad README.md
```

### 3. Compilar el template

```powershell
# Compilar dos veces para referencias
pdflatex -interaction=nonstopmode informe_principal.tex
pdflatex -interaction=nonstopmode informe_principal.tex

# Abrir el PDF generado
Start-Process informe_principal.pdf
```

---

## 📋 Archivos Incluidos

### LaTeX (7 archivos)
- ✅ `informe_principal.tex` - Documento maestro
- ✅ `00_preambulo.tex` - Configuración de estilo PUC
- ✅ `01_introduccion.tex` - Introducción completa
- ✅ `02_construccion_tabla.tex` - Sección 1 (60%) con plantillas
- ✅ `03_conmutacion.tex` - Sección 2 (10%) con plantillas
- ✅ `04_valores_actuales.tex` - Sección 3 (30%) con plantillas
- ✅ `05_conclusiones.tex` - Conclusiones y referencias

### Documentación (4 archivos)
- ✅ `README.md` - Documentación completa (350+ líneas)
- ✅ `GUIA_COMPILACION.md` - Guía rápida de uso
- ✅ `PLANTILLA_RESPUESTAS.md` - Plantillas y ejemplos
- ✅ `RESUMEN_PROYECTO.md` - Resumen ejecutivo

### Recursos
- ✅ `Imagenes/` - Logos UC y Kovan copiados
- ✅ `tablas/` - Carpeta para archivos CSV

---

## 🎯 Próximos Pasos

### Paso 1: Actualizar Integrantes
Editar `informe_principal.tex` líneas 96-103

### Paso 2: Completar Datos
Buscar `[COMPLETAR]` en todos los archivos `.tex`

Total: **~120 marcadores a completar**

### Paso 3: Agregar Resultados
1. Exportar tablas desde R a `tablas/*.csv`
2. Generar gráficos y guardar en `Imagenes/`
3. Completar análisis y comentarios

### Paso 4: Compilar y Entregar
Fecha límite: **11 de diciembre, 2025 - 22:00 hrs**

---

## 📖 Documentación por Archivo

| Archivo | Propósito | Cuándo Usar |
|---------|-----------|-------------|
| `RESUMEN_PROYECTO.md` | Vista general completa | **Leer primero** |
| `README.md` | Documentación técnica detallada | Para referencia |
| `GUIA_COMPILACION.md` | Comandos y checklist | Durante el trabajo |
| `PLANTILLA_RESPUESTAS.md` | Ejemplos y formatos | Para completar datos |

---

## 💡 Características Principales

### ✨ Estilo Profesional
- Colores institucionales PUC (celestes)
- Logos oficiales incluidos
- Formato académico pulido
- Portada personalizada

### 📊 Listo para Usar
- Todas las secciones estructuradas
- Fórmulas actuariales predefinidas
- Tablas con formato correcto
- Comandos matemáticos personalizados

### 🔧 Modular y Flexible
- Cada sección en archivo separado
- Fácil de editar y mantener
- Permite trabajo colaborativo
- Compilación independiente de secciones

---

## 📊 Contenido del Informe

### Distribución de Puntos

```
1. Construcción de Tabla (60%)
   ├── Registros y muertes
   ├── Graduación con 4 tests
   ├── Extrapolación (cabeza y cola)
   └── Tabla completa con e_x

2. Valores de Conmutación (10%)
   ├── Tabla obtenida (D, N, S, C, M)
   └── Tabla referencia MI2014

3. Valores Actuales (30%)
   ├── Dotal puro (70 años)
   ├── Renta vitalicia vencida
   ├── Renta diferida anticipada (75 años)
   ├── Renta temporal vencida (80 años)
   ├── Renta temporal diferida anticipada (70 años)
   └── Análisis comparativo
```

---

## 🔍 Verificación Rápida

```powershell
# Verificar que todos los archivos existen
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex
Get-ChildItem -Name

# Buscar todos los marcadores [COMPLETAR]
Select-String -Path "*.tex" -Pattern "\[COMPLETAR\]" | Measure-Object

# Verificar logos
Test-Path "Imagenes/logo_uc.png"
Test-Path "Imagenes/logo_kovan.jpg"
```

---

## 🎓 Especificaciones del Proyecto

- **Tabla:** INVALIDEZ 2014 - Masculino
- **Origen:** 2 (TM_SEXO = M)
- **Período:** 01/01/2000 - 31/12/2012
- **Tasa de interés:** 5% anual
- **Raíz:** l_10 = 10,000,000
- **Edad límite:** ω = 109 años

---

## 📞 Ayuda

Si tienes problemas:

1. **Compilación:** Ver `GUIA_COMPILACION.md`
2. **Formato:** Ver `PLANTILLA_RESPUESTAS.md`
3. **Estructura:** Ver `README.md`
4. **Overview:** Ver `RESUMEN_PROYECTO.md`

---

## ✅ Todo Listo Para:

- ✅ Comenzar a trabajar inmediatamente
- ✅ Compilar el template base
- ✅ Completar con tus resultados
- ✅ Generar PDF profesional
- ✅ Entregar antes del 11 de diciembre

---

**¡Éxito con tu proyecto! 🎉**

*Creado: Diciembre 9, 2025*
*Proyecto: EYP2605 - Matemáticas Actuariales*
*Institución: Pontificia Universidad Católica de Chile*
