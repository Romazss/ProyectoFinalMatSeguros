# Informe Final - Matemáticas Actuariales

## 📋 Descripción del Proyecto

Informe modular en LaTeX para el Proyecto Final de la asignatura **EYP2605 - Matemáticas Actuariales** (Noviembre 2025).

**Objetivo:** Construcción de una tabla de mortalidad y cálculo de valores actuales para productos de seguros.

**Especificaciones:**
- **Tabla Asignada:** INVALIDEZ 2014 - Masculino
- **Período de Análisis:** 01/01/2000 - 31/12/2012
- **Tasa de Interés Técnico:** 5% anual

---

## 📁 Estructura del Proyecto

```
informe_latex/
│
├── informe_principal.tex          # Documento principal (compilar este archivo)
├── 00_preambulo.tex                # Configuración de paquetes y estilo
├── 01_introduccion.tex             # Sección 1: Introducción
├── 02_construccion_tabla.tex       # Sección 2: Construcción de tabla (60%)
├── 03_conmutacion.tex              # Sección 3: Valores de conmutación (10%)
├── 04_valores_actuales.tex         # Sección 4: Cálculo de valores actuales (30%)
├── 05_conclusiones.tex             # Sección 5: Conclusiones y referencias
├── README.md                       # Este archivo
│
├── Imagenes/                       # Logos y gráficos
│   ├── logo_uc.png                 # Logo Universidad Católica
│   └── logo_kovan.jpg              # Logo secundario
│
└── tablas/                         # Archivos CSV con datos
    ├── tabla_mortalidad_obtenida.csv
    ├── conmutacion_tabla_obtenida.csv
    └── conmutacion_tabla_referencia.csv
```

---

## 🚀 Compilación del Documento

### Requisitos Previos

Necesitas tener instalada una distribución de LaTeX:

- **Windows:** [MiKTeX](https://miktex.org/) o [TeX Live](https://www.tug.org/texlive/)
- **Mac:** [MacTeX](https://www.tug.org/mactex/)
- **Linux:** TeX Live (disponible en repositorios)

### Opción 1: Compilación Manual (Línea de Comandos)

```bash
# Navega al directorio del informe
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex

# Compila el documento (ejecutar dos veces para referencias cruzadas)
pdflatex -interaction=nonstopmode informe_principal.tex
pdflatex -interaction=nonstopmode informe_principal.tex
```

### Opción 2: Compilación con Editor LaTeX

Si usas un editor como **TeXstudio**, **Overleaf**, o **VS Code con LaTeX Workshop**:

1. Abre `informe_principal.tex`
2. Presiona el botón de compilar (o F5/F6 según el editor)
3. El PDF se generará automáticamente

### Opción 3: Desde PowerShell (Recomendado para este proyecto)

```powershell
# Navegar al directorio
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex

# Compilar
pdflatex -interaction=nonstopmode informe_principal.tex; pdflatex -interaction=nonstopmode informe_principal.tex

# Limpiar archivos auxiliares (opcional)
Remove-Item *.aux, *.log, *.toc, *.out -ErrorAction SilentlyContinue
```

---

## 📝 Guía de Uso y Completado

### Paso 1: Actualizar Información de Integrantes

En `informe_principal.tex`, líneas 96-103, reemplaza:

```latex
\begin{tabular}{l}
    $\bullet$ \quad [Nombre Integrante 1] \\[0.2cm]
    $\bullet$ \quad [Nombre Integrante 2] \\[0.2cm]
    $\bullet$ \quad [Nombre Integrante 3] \\[0.2cm]
    $\bullet$ \quad [Nombre Integrante 4] \\
\end{tabular}
```

### Paso 2: Completar Resultados

Busca los marcadores `[COMPLETAR]` en cada archivo `.tex` y reemplázalos con tus resultados:

#### En `02_construccion_tabla.tex`:
- Tabla de registros y muertes (línea ~40)
- Edades límites de graduación (línea ~65)
- Parámetros de suavidad (línea ~75)
- Tests de bondad de ajuste (línea ~90)
- Métodos de extrapolación (línea ~110)
- Tabla completa de mortalidad (línea ~145)

#### En `03_conmutacion.tex`:
- Valores de conmutación para ambas tablas (líneas ~60 y ~95)

#### En `04_valores_actuales.tex`:
- Resultados de los 5 productos actuariales:
  - Dotal puro (línea ~85)
  - Renta vitalicia vencida (línea ~115)
  - Renta diferida anticipada (línea ~145)
  - Renta temporal vencida (línea ~175)
  - Renta temporal diferida (línea ~205)
- Análisis comparativo (línea ~235)

#### En `05_conclusiones.tex`:
- Hallazgos principales (línea ~10)
- Análisis crítico (línea ~40)
- Implicaciones actuariales (línea ~70)

### Paso 3: Agregar Gráficos

Para insertar imágenes, copia tus archivos a la carpeta `Imagenes/` y descomenta las secciones correspondientes:

```latex
% Descomenta estas líneas y ajusta el nombre del archivo
\begin{figure}[H]
\centering
\includegraphics[width=0.85\textwidth]{Imagenes/comparacion_qx.png}
\caption{Comparación de tasas de mortalidad}
\label{fig:comparacion_qx}
\end{figure}
```

### Paso 4: Exportar Tablas desde R

Guarda tus resultados en formato CSV en la carpeta `tablas/`:

```r
# Ejemplo en R
write.csv(tabla_mortalidad, 
          "tablas/tabla_mortalidad_obtenida.csv", 
          row.names = FALSE)

write.csv(conmutacion_obtenida, 
          "tablas/conmutacion_tabla_obtenida.csv", 
          row.names = FALSE)

write.csv(conmutacion_referencia, 
          "tablas/conmutacion_tabla_referencia.csv", 
          row.names = FALSE)
```

---

## 🎨 Personalización del Estilo

### Colores Disponibles

El preámbulo define los siguientes colores (estilo PUC):

```latex
\definecolor{celesteprincipal}{RGB}{0,150,200}
\definecolor{celestesuave}{RGB}{135,206,235}
\definecolor{celesteclaro}{RGB}{173,216,230}
\definecolor{celesteoscuro}{RGB}{0,105,148}
\definecolor{celestefondo}{RGB}{230,245,255}
\definecolor{grisoscuro}{RGB}{64,64,64}
```

### Cajas Destacadas

```latex
% Caja para hallazgos importantes (azul)
\begin{hallazgobox}
Contenido destacado
\end{hallazgobox}

% Caja para notas (amarillo)
\begin{notabox}
Nota importante
\end{notabox}
```

### Notación Actuarial

Comandos personalizados definidos en el preámbulo:

```latex
\qx{x}    % q_x (probabilidad de muerte)
\px{x}    % p_x (probabilidad de supervivencia)
\lx{x}    % l_x (sobrevivientes)
\dx{x}    % d_x (fallecidos)
\ex{x}    % e_x (esperanza de vida)
\Dx{x}    % D_x (función de conmutación)
\Nx{x}    % N_x (función de conmutación)
```

---

## 📊 Secciones del Informe

### Sección 1: Introducción (01_introduccion.tex)
- Contexto del proyecto
- Especificaciones asignadas
- Objetivos y metodología
- Estructura del informe

### Sección 2: Construcción de Tabla de Mortalidad (02_construccion_tabla.tex) - 60%
- Análisis de datos originales
- Cuadro de registros y muertes
- Graduación con tests de bondad de ajuste
- Extrapolación (cabeza y cola)
- Tabla completa con esperanza de vida

### Sección 3: Valores de Conmutación (03_conmutacion.tex) - 10%
- Fundamentos teóricos
- Cálculo de D_x, N_x, S_x, C_x, M_x
- Para tabla obtenida y tabla de referencia
- Verificación de cálculos

### Sección 4: Cálculo de Valores Actuales (04_valores_actuales.tex) - 30%
- Dotal puro (edad final 70)
- Renta vitalicia vencida
- Renta vitalicia diferida anticipada (desde 75 años)
- Renta temporal vencida (hasta 80 años)
- Renta temporal diferida anticipada (hasta 70 años)
- Análisis comparativo y sensibilidad

### Sección 5: Conclusiones y Referencias (05_conclusiones.tex)
- Principales hallazgos
- Análisis crítico
- Implicaciones actuariales
- Recomendaciones
- Bibliografía y referencias

---

## 🔧 Solución de Problemas

### Error: "File not found"

Asegúrate de que:
- Todos los archivos `.tex` estén en el mismo directorio
- La carpeta `Imagenes/` existe y contiene los logos
- Las rutas en `\includegraphics{}` sean correctas

### Error: "Package not found"

Instala los paquetes faltantes:
- **MiKTeX:** Se instalan automáticamente al compilar
- **TeX Live:** Usa `tlmgr install <paquete>`

### Tablas muy anchas

Usa `\small` o `\footnotesize` antes de la tabla:

```latex
\begin{table}[H]
\centering
\small  % Reduce el tamaño de fuente
\begin{tabular}{...}
```

### Compilación lenta

Comenta las imágenes grandes temporalmente durante la edición:

```latex
% \includegraphics[width=0.85\textwidth]{Imagenes/grafico_grande.png}
```

---

## 📅 Entrega del Proyecto

**Fecha límite:** 11 de diciembre de 2025 (antes de las 22:00 hrs)

**Archivos a entregar:**
1. `informe_principal.pdf` (documento compilado)
2. Todos los archivos `.tex` fuente
3. Carpeta `Imagenes/` con gráficos
4. Carpeta `tablas/` con datos CSV
5. Scripts de R utilizados

---

## 📖 Referencias Útiles

- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [CTAN - Comprehensive TeX Archive Network](https://www.ctan.org/)
- [Detexify - Búsqueda de símbolos LaTeX](http://detexify.kirelabs.org/classify.html)
- [Tables Generator](https://www.tablesgenerator.com/) - Generador visual de tablas LaTeX

---

## 👥 Contribuciones

Este template fue creado reutilizando el estilo del proyecto `Informe_Final` con los logos y colores institucionales de la Pontificia Universidad Católica de Chile.

**Estructura modular:** Permite trabajar en secciones independientes y facilita la colaboración entre integrantes del equipo.

---

## 📄 Licencia

Este proyecto es para uso académico en el contexto de la asignatura EYP2605 - Matemáticas Actuariales, PUC Chile.

---

**¡Éxito con tu proyecto final! 🎓**
