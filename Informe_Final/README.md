# Estructura Modular - Informe Final

## Descripción General

Este directorio contiene una estructura modular completa en LaTeX para el informe final del proyecto de muestreo. La estructura está diseñada para facilitar:

- **Organización clara**: Cada sección del informe está en un archivo separado
- **Colaboración**: Múltiples autores pueden trabajar en diferentes secciones simultáneamente
- **Mantenimiento**: Es fácil actualizar o reorganizar secciones
- **Reutilización**: Los módulos pueden adaptarse para otros documentos

## Archivos Incluidos

### Archivos de Configuración

| Archivo | Descripción |
|---------|-------------|
| `00_preambulo.tex` | Configuración de paquetes, estilos y ajustes globales |
| `informe_principal.tex` | Archivo maestro que compila todo el informe |
| `GUIA_COMPILACION.md` | Instrucciones detalladas de compilación |

### Archivos de Contenido

| Archivo | Sección | Descripción |
|---------|---------|-------------|
| `01_resumen.tex` | Resumen | Resumen ejecutivo (150-250 palabras) |
| `02_introduccion.tex` | Introducción | Contexto, justificación y objetivos |
| `03_metodos.tex` | Métodos | Diseño muestral y procedimientos analíticos |
| `04_resultados.tex` | Resultados | Tablas, gráficos y estimaciones ajustadas |
| `05_discusion.tex` | Discusión | Interpretación, antecedentes y limitaciones |
| `06_conclusiones.tex` | Conclusiones | Hallazgos principales y recomendaciones |
| `07_referencias.tex` | Bibliografía | Referencias bibliográficas |

## Características del Preámbulo

El archivo `00_preambulo.tex` incluye:

```latex
% Idioma y codificación
- UTF-8 encoding
- Soporte para español

% Márgenes y espaciado
- Márgenes de 2.5 cm
- Espaciado de 1.5 líneas

% Tipografía
- Fuente Times
- Tamaño 12pt

% Elementos especializados
- Tablas profesionales (booktabs)
- Gráficos y figuras
- Referencias bibliográficas (biblatex)
- Enlaces (hyperref)

% Estilos personalizados
- Encabezados y pies de página
- Formato de secciones y subsecciones
- Formato de código (si es necesario)
```

## Estructura de Contenido

### Resumen (`01_resumen.tex`)
```
- Objetivo
- Metodología
- Resultados principales
- Conclusiones
- Palabras clave
```

### Introducción (`02_introduccion.tex`)
```
- Contexto
- Justificación
- Objetivo general y específicos
- Estructura del informe
```

### Métodos (`03_metodos.tex`)
```
- Diseño muestral
  - Población y marco
  - Estrategia de muestreo
- Recolección de datos
- Variables de estudio
- Análisis estadístico
  - Estimación
  - Análisis de precisión
  - Procedimientos analíticos
```

### Resultados (`04_resultados.tex`)
```
- Características de la muestra
- Estimaciones principales (ponderadas)
- Análisis por subgrupos
- Visualizaciones (gráficos)
- Evaluación de precisión (DEFF, CV)
- Modelos analíticos
```

### Discusión (`05_discusion.tex`)
```
- Síntesis de hallazgos
- Comparación con antecedentes
- Consideraciones metodológicas
  - Fortalezas
  - Limitaciones
- Implicaciones prácticas
- Sugerencias para futuras investigaciones
```

### Conclusiones (`06_conclusiones.tex`)
```
- Hallazgos principales
- Respuesta a objetivos
- Contribuciones del estudio
- Recomendaciones
  - Políticas
  - Investigación
- Reflexión final
```

## Instrucciones de Uso

### 1. Compilación Inicial

```bash
# Con LaTeX básico
pdflatex informe_principal.tex

# Con biblatex/biber (recomendado)
pdflatex informe_principal.tex
biber informe_principal
pdflatex informe_principal.tex
```

### 2. Edición de Secciones

- Abre directamente cada archivo `.tex` necesario
- Las cambios se incluyen automáticamente al compilar `informe_principal.tex`
- No necesitas modificar el archivo maestro

### 3. Agregar Elementos

**Para agregar una figura:**
```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{figures/nombre.pdf}
    \caption{Descripción}
    \label{fig:identificador}
\end{figure}
```

**Para agregar una tabla:**
```latex
\begin{table}[H]
    \centering
    \caption{Título de tabla}
    \label{tab:identificador}
    \begin{tabular}{lcc}
    \toprule
    % Contenido
    \bottomrule
    \end{tabular}
\end{table}
```

**Para citar referencias:**
```latex
\cite{autor2023}  % Con biblatex
\citep{autor2023} % Con parentesis
```

## Estructura de Carpetas Recomendada

```
Informe_Final/
├── *.tex                    # Todos los archivos LaTeX
├── GUIA_COMPILACION.md
├── README.md
├── referencias.bib          # Base de datos bibliográfica
├── figures/                 # Gráficos y figuras
│   ├── grafico1.pdf
│   ├── grafico2.pdf
│   └── tabla_resultados.png
└── output/                  # Archivos generados (ignorar)
    ├── informe_principal.pdf
    ├── *.aux
    ├── *.log
    └── ...
```

## Consideraciones para Diseño Muestral

Dado que este informe es sobre muestreo, se han incluido espacios específicos para:

- **Factores de diseño (DEFF)**: Para evaluar el efecto del diseño
- **Errores estándar**: Considerando la estructura de conglomerados
- **Intervalos de confianza**: Ajustados al diseño muestral
- **Ponderaciones**: Para estimaciones representativas
- **Coeficientes de variación**: Para evaluar precisión

## Validación Antes de Entrega

- [ ] Tabla de contenidos actualizada
- [ ] Todas las referencias citadas están en bibliografía
- [ ] Figuras y tablas numeradas correctamente
- [ ] Ausencia de errores de compilación
- [ ] Márgenes y espaciado consistentes
- [ ] Ortografía y gramática revisadas

## Próximos Pasos

1. **Llena los espacios**: Reemplaza los comentarios con contenido real
2. **Agrega figuras**: Coloca tus gráficos en la carpeta `figures/`
3. **Completa referencias**: Crea `referencias.bib` con tus fuentes
4. **Compila regularmente**: Verifica que todo se vea correctamente
5. **Revisa**: Comprueba coherencia y consistencia

## Soporte

Para problemas o dudas:
- Consulta `GUIA_COMPILACION.md`
- Revisa la documentación de paquetes LaTeX específicos
- Valida la sintaxis en archivos `.log` después de compilar

---

**Última actualización:** Diciembre 2025
**Versión:** 1.0
