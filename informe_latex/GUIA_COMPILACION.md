# Guía Rápida de Compilación

## 🚀 Compilación Rápida desde PowerShell

Ejecuta estos comandos desde el directorio del proyecto:

```powershell
# Navegar al directorio del informe
cd C:\Users\esteb\GitHub\ProyectoFinalMatSeguros\informe_latex

# Compilar el documento (2 veces para referencias)
pdflatex -interaction=nonstopmode informe_principal.tex
pdflatex -interaction=nonstopmode informe_principal.tex

# Abrir el PDF generado
Start-Process informe_principal.pdf
```

## 📝 Orden de Trabajo Recomendado

1. **Actualizar integrantes** en `informe_principal.tex` (líneas 96-103)

2. **Completar Sección 2** (`02_construccion_tabla.tex`):
   - Tabla de registros y muertes
   - Parámetros de graduación
   - Tests de bondad de ajuste
   - Tabla completa de mortalidad

3. **Completar Sección 3** (`03_conmutacion.tex`):
   - Valores de conmutación para ambas tablas

4. **Completar Sección 4** (`04_valores_actuales.tex`):
   - Los 5 productos actuariales solicitados
   - Análisis comparativo

5. **Completar Sección 5** (`05_conclusiones.tex`):
   - Hallazgos y análisis crítico

6. **Agregar gráficos** a la carpeta `Imagenes/`

7. **Revisar y compilar** versión final

## 🔍 Búsqueda de Marcadores

Para encontrar todos los lugares que necesitas completar:

```powershell
# Buscar todos los [COMPLETAR] en los archivos
Select-String -Path "*.tex" -Pattern "\[COMPLETAR\]"
```

## 🧹 Limpiar Archivos Auxiliares

```powershell
Remove-Item *.aux, *.log, *.toc, *.out, *.synctex.gz -ErrorAction SilentlyContinue
```

## ✅ Checklist de Entrega

- [ ] Nombres de integrantes actualizados
- [ ] Todos los `[COMPLETAR]` reemplazados con datos reales
- [ ] Tablas con valores numéricos completos
- [ ] Gráficos insertados y referenciados
- [ ] Comentarios y análisis escritos
- [ ] Fórmulas verificadas
- [ ] Documento compila sin errores
- [ ] PDF revisado visualmente
- [ ] Archivos CSV exportados a `tablas/`
- [ ] Scripts de R incluidos

## 📊 Estructura de Datos Requerida

### Carpeta `tablas/`:
- `tabla_mortalidad_obtenida.csv`
- `conmutacion_tabla_obtenida.csv`
- `conmutacion_tabla_referencia.csv`

### Carpeta `Imagenes/`:
- `logo_uc.png` ✓ (ya incluido)
- `logo_kovan.jpg` ✓ (ya incluido)
- `comparacion_qx.png` (por crear)
- `comparacion_Dx.png` (por crear)
- `comparacion_Nx.png` (por crear)
- `comparacion_productos.png` (por crear)

## 💡 Comandos Útiles de LaTeX

### Insertar tabla:
```latex
\begin{table}[H]
\centering
\caption{Título de la tabla}
\label{tab:etiqueta}
\begin{tabular}{ccc}
\toprule
\tableheadercolor
Col1 & Col2 & Col3 \\
\midrule
Dato1 & Dato2 & Dato3 \\
\bottomrule
\end{tabular}
\end{table}
```

### Insertar figura:
```latex
\begin{figure}[H]
\centering
\includegraphics[width=0.85\textwidth]{Imagenes/archivo.png}
\caption{Título de la figura}
\label{fig:etiqueta}
\end{figure}
```

### Ecuación numerada:
```latex
\begin{equation}
\qx{x} = \frac{\dx{x}}{\lx{x}}
\end{equation}
```

### Ecuación sin número:
```latex
\begin{equation*}
a_x = \frac{\Nx{x+1}}{\Dx{x}}
\end{equation*}
```

## 🎯 Puntos Clave por Sección

### Sección 1 (Introducción) - ✓ LISTA
Ya está completa, solo actualizar nombres de integrantes.

### Sección 2 (Construcción Tabla) - 60%
**Elementos críticos a completar:**
- Cuadro de registros original vs. análisis
- Edades límites justificadas
- Parámetros de graduación justificados
- 4 tests de bondad de ajuste (valor + p-valor)
- Método de extrapolación elegido
- Tabla completa de mortalidad

### Sección 3 (Conmutación) - 10%
**Elementos críticos a completar:**
- Tabla de D_x, N_x, S_x, C_x, M_x (obtenida)
- Tabla de D_x, N_x, S_x, C_x, M_x (referencia)
- Verificación de relaciones recursivas

### Sección 4 (Valores Actuales) - 30%
**Elementos críticos a completar:**
- 5 productos con 3 edades cada uno = 15 valores
- Diferencial % entre tablas
- Análisis comparativo global
- Interpretación de resultados

### Sección 5 (Conclusiones)
**Elementos críticos a completar:**
- Síntesis de hallazgos principales
- Análisis crítico (fortalezas y limitaciones)
- Implicaciones actuariales
- Reflexiones finales

## ⏰ Fecha de Entrega

**11 de diciembre de 2025 - antes de las 22:00 hrs**

---

**Última actualización:** Diciembre 2025
