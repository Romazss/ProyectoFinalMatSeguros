# Guía de Compilación - Informe Final

## Estructura del Proyecto

La estructura modular del informe está organizada de la siguiente manera:

```
Informe_Final/
├── 00_preambulo.tex           # Configuración de paquetes y estilos
├── 01_resumen.tex             # Resumen ejecutivo
├── 02_introduccion.tex        # Introducción y objetivos
├── 03_metodos.tex             # Métodos y diseño muestral
├── 04_resultados.tex          # Resultados y tablas
├── 05_discusion.tex           # Discusión e interpretación
├── 06_conclusiones.tex        # Conclusiones y recomendaciones
├── 07_referencias.tex         # Bibliografía
├── informe_principal.tex      # Archivo maestro (compilar este)
├── referencias.bib            # Archivo de referencias (si usas biblatex)
└── figures/                   # Carpeta para gráficos y figuras
    ├── grafico1.pdf
    ├── grafico2.pdf
    └── ...
```

## Compilación

### Opción 1: LaTeX básico (con referencias manuales)

```bash
pdflatex informe_principal.tex
pdflatex informe_principal.tex  # Ejecutar dos veces para actualizar referencias
```

### Opción 2: Con biblatex/biber (recomendado)

1. Primero, crea el archivo `referencias.bib` con tus referencias
2. En `00_preambulo.tex`, asegúrate de tener:
   ```latex
   \usepackage[style=authoryear, backend=biber]{biblatex}
   \addbibresource{referencias.bib}
   ```
3. En `informe_principal.tex`, descomenta:
   ```latex
   \printbibliography[title=Bibliografía]
   ```
4. Compila con:
   ```bash
   pdflatex informe_principal.tex
   biber informe_principal
   pdflatex informe_principal.tex
   pdflatex informe_principal.tex
   ```

### Opción 3: Con Visual Studio Code (recomendado)

Si tienes instalada la extensión LaTeX Workshop:
1. Abre `informe_principal.tex`
2. Usa el atajo: `Ctrl + Shift + B` o haz clic en "Build LaTeX project"

### Opción 4: Scripts de compilación (PowerShell)

Crea un archivo `compilar.ps1`:

```powershell
# Compilar informe
pdflatex -interaction=nonstopmode informe_principal.tex
biber informe_principal
pdflatex -interaction=nonstopmode informe_principal.tex
pdflatex -interaction=nonstopmode informe_principal.tex

Write-Host "Compilación completada. Archivo: informe_principal.pdf"
```

Ejecuta con: `.\compilar.ps1`

## Instrucciones para Completar el Informe

### 1. Resumen (`01_resumen.tex`)
- Escribe 150-250 palabras
- Incluye objetivo, metodología, resultados y conclusiones
- Define palabras clave

### 2. Introducción (`02_introduccion.tex`)
- Presenta el contexto y justificación
- Define objetivos general y específicos
- Describe la estructura del informe

### 3. Métodos (`03_metodos.tex`)
- Detalla el diseño muestral
- Describe la población y marco de muestreo
- Especifica variables de estudio
- Explica procedimientos analíticos

### 4. Resultados (`04_resultados.tex`)
- Presenta tablas con estimaciones ponderadas
- Incluye gráficos relevantes
- Reporta errores estándar e intervalos de confianza
- Evalúa precisión (DEFF, CV)

### 5. Discusión (`05_discusion.tex`)
- Interpreta hallazgos
- Compara con antecedentes
- Discute limitaciones
- Propone futuras investigaciones

### 6. Conclusiones (`06_conclusiones.tex`)
- Reafirma hallazgos principales
- Responde a objetivos
- Proporciona recomendaciones

### 7. Bibliografía (`07_referencias.tex` o `referencias.bib`)
- Agrega todas las referencias citadas
- Usa formato consistente

## Consideraciones Importantes

### Figuras y Gráficos
- Guarda las figuras en la carpeta `figures/`
- Usa formato PDF para mejor calidad
- Referencia con: `\ref{fig:nombre}`

### Tablas
- Utiliza `\label` para referencias cruzadas
- Incluye notas al pie explicativas
- Especifica si son estimaciones ponderadas

### Errores Comunes
- Asegúrate de que el encoding sea UTF-8
- Verifica que todos los archivos `.tex` estén en la misma carpeta
- Los nombres de archivo deben ser consistentes en los `\input{}`

### Personalización
- Modifica títulos de secciones según sea necesario
- Ajusta márgenes en `00_preambulo.tex`
- Cambia estilos de referencias según requerimientos

## Validación Final

Antes de entregar:
1. Verifica que la tabla de contenidos sea correcta
2. Revisa numeración de figuras y tablas
3. Comprueba que todas las referencias estén citadas
4. Valida ortografía y gramática
5. Asegúrate de que el PDF se genera sin errores

## Soporte

Para problemas comunes con LaTeX:
- Verifica sintaxis en `00_preambulo.tex`
- Revisa archivos `.log` para mensajes de error
- Consulta la documentación de paquetes utilizados
