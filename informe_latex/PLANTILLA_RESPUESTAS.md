# Plantilla de Respuestas Rápidas

Este archivo contiene plantillas para completar rápidamente las secciones del informe.

## 📋 Datos del Proyecto

**IMPORTANTE:** Estos son tus datos asignados. Verifica que coincidan con tu asignación.

```
Tabla Asignada:     INVALIDEZ 2014 - Masculino
Origen:             2
Sexo:               Masculino (TM_SEXO = M)
Período Análisis:   01/01/2000 - 31/12/2012
Tasa Interés:       5% anual
Raíz de tabla:      l_10 = 10,000,000
Edad límite:        ω = 109 años
```

## 🔢 Plantillas de Tablas

### Registros y Muertes (Sección 2.3)

```latex
Original    & XXX,XXX  & X,XXX  & XX,XXX.X  & X.XXXX  \\
Análisis    & XXX,XXX  & X,XXX  & XX,XXX.X  & X.XXXX  \\
```

### Tests de Bondad de Ajuste (Sección 2.4.3)

```latex
Chi-cuadrado         & XX.XXX  & 0.XXX  & Aprobado/Rechazado \\
Kolmogorov-Smirnov   & 0.XXXX  & 0.XXX  & Aprobado/Rechazado \\
Test de Rachas       & X.XXXX  & 0.XXX  & Aprobado/Rechazado \\
Test de Signos       & X.XXXX  & 0.XXX  & Aprobado/Rechazado \\
```

**Interpretación:** Valor-p > 0.05 indica que NO se rechaza el ajuste (APROBADO)

### Dotal Puro (Sección 4.2.3)

```latex
38  & 0.XXXXX  & 0.XXXXX  & +X.XX\%  \\
54  & 0.XXXXX  & 0.XXXXX  & +X.XX\%  \\
62  & 0.XXXXX  & 0.XXXXX  & +X.XX\%  \\
```

### Renta Vitalicia Vencida (Sección 4.3.3)

```latex
45  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
60  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
90  & X.XXXX   & X.XXXX   & +X.XX\%  \\
```

### Renta Diferida 75 Anticipada (Sección 4.4.3)

```latex
25  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
40  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
70  & X.XXXX   & X.XXXX   & +X.XX\%  \\
```

### Renta Temporal 80 Vencida (Sección 4.5.3)

```latex
25  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
50  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
75  & X.XXXX   & X.XXXX   & +X.XX\%  \\
```

### Renta Temporal 70 Diferida Anticipada (Sección 4.6.3)

```latex
32  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
50  & XX.XXXX  & XX.XXXX  & +X.XX\%  \\
68  & X.XXXX   & X.XXXX   & +X.XX\%  \\
```

## 📐 Fórmulas Comunes en LaTeX

### Notación Actuarial

```latex
% Probabilidades
\qx{x}               → q_x
\px{x}               → p_x

% Funciones biométricas
\lx{x}               → l_x
\dx{x}               → d_x
\Lx{x}               → L_x
\Tx{x}               → T_x
\ex{x}               → e_x

% Conmutación
\Dx{x}               → D_x
\Nx{x}               → N_x
\Sx{x}               → S_x
\Cx{x}               → C_x
\Mx{x}               → M_x

% Valores actuales
a_x                  → renta vencida
\ddot{a}_x           → renta anticipada
{}_{n}E_x            → dotal puro n años
{}_{|m}a_x           → renta diferida m años
a_{x:\overline{n}|}  → renta temporal n años
```

### Fórmulas de Valores Actuales

```latex
% Dotal puro
{}_{n}E_x = \frac{\Dx{x+n}}{\Dx{x}}

% Renta vitalicia vencida
a_x = \frac{\Nx{x+1}}{\Dx{x}}

% Renta vitalicia anticipada
\ddot{a}_x = \frac{\Nx{x}}{\Dx{x}}

% Renta diferida y-x años, anticipada
{}_{|y-x}\ddot{a}_x = \frac{\Nx{y}}{\Dx{x}}

% Renta temporal n años, vencida
a_{x:\overline{n}|} = \frac{\Nx{x+1} - \Nx{x+n+1}}{\Dx{x}}

% Renta temporal n años, anticipada
\ddot{a}_{x:\overline{n}|} = \frac{\Nx{x} - \Nx{x+n}}{\Dx{x}}
```

## 💬 Plantillas de Comentarios

### Para Tests de Bondad de Ajuste

```latex
\textbf{Interpretación de resultados:}

Los cuatro tests de bondad de ajuste presentados muestran que:

\begin{itemize}
    \item \textbf{Chi-cuadrado:} Con un valor-p de X.XXX [mayor/menor] que 0.05, 
          [no hay evidencia para rechazar/se rechaza] la hipótesis de que el 
          ajuste es adecuado.
    
    \item \textbf{Kolmogorov-Smirnov:} El estadístico de X.XXXX con valor-p X.XXX 
          indica que [la distribución graduada se ajusta bien/no se ajusta] a los 
          datos observados.
    
    \item \textbf{Test de Rachas:} [No se detecta/Se detecta] un patrón sistemático 
          en los residuos, lo que sugiere [aleatoriedad/sesgo] en el ajuste.
    
    \item \textbf{Test de Signos:} El balance entre residuos positivos y negativos 
          [es equilibrado/muestra sesgo], con valor-p X.XXX.
\end{itemize}

En conclusión, el método de graduación aplicado [es adecuado/requiere ajustes] 
para representar la mortalidad observada en la población estudiada.
```

### Para Comparación de Valores Actuales

```latex
\textbf{Comentarios:}

Al comparar los valores actuales entre la tabla obtenida y la de referencia MI2014, 
se observa que:

\begin{itemize}
    \item Los diferenciales oscilan entre X.XX\% y X.XX\%, siendo [positivos/negativos] 
          en su mayoría.
    
    \item Para edades [jóvenes/avanzadas], las diferencias son [mayores/menores], 
          lo que puede atribuirse a [razón].
    
    \item Esto implica que la tabla obtenida refleja una mortalidad [mayor/menor] 
          que la tabla de referencia, lo que se traduce en valores actuales 
          [más bajos/más altos].
    
    \item Desde la perspectiva de una aseguradora, esto significa que [las primas 
          deberían ser mayores/menores] y las reservas [más altas/más bajas] 
          que las calculadas con MI2014.
\end{itemize}
```

## 🎯 Checklist por Sección

### ✅ Sección 2: Construcción de Tabla

- [ ] Número de registros original
- [ ] Número de registros en análisis
- [ ] Número de muertes original
- [ ] Número de muertes en análisis
- [ ] Edad mínima de graduación
- [ ] Edad máxima de graduación
- [ ] Justificación de edades límites
- [ ] Método de graduación usado
- [ ] Parámetro de suavidad (h o λ)
- [ ] Orden de diferencias
- [ ] Valor Chi-cuadrado + p-valor
- [ ] Valor KS + p-valor
- [ ] Valor Test Rachas + p-valor
- [ ] Valor Test Signos + p-valor
- [ ] Método de extrapolación elegido
- [ ] Justificación del método
- [ ] Tabla completa (al menos extracto)
- [ ] Gráfico comparativo q_x
- [ ] Esperanzas de vida clave

### ✅ Sección 3: Conmutación

- [ ] Tabla D_x (obtenida)
- [ ] Tabla N_x (obtenida)
- [ ] Tabla S_x (obtenida)
- [ ] Tabla C_x (obtenida)
- [ ] Tabla M_x (obtenida)
- [ ] Tabla D_x (referencia)
- [ ] Tabla N_x (referencia)
- [ ] Tabla S_x (referencia)
- [ ] Tabla C_x (referencia)
- [ ] Tabla M_x (referencia)
- [ ] Verificación exitosa
- [ ] Gráficos comparativos

### ✅ Sección 4: Valores Actuales

- [ ] Dotal puro (3 edades)
- [ ] Renta vitalicia vencida (3 edades)
- [ ] Renta diferida anticipada (3 edades)
- [ ] Renta temporal vencida (3 edades)
- [ ] Renta temporal diferida (3 edades)
- [ ] Todos los diferenciales calculados
- [ ] Comentarios por producto
- [ ] Análisis comparativo global
- [ ] Resumen de diferenciales
- [ ] Interpretación actuarial

### ✅ Sección 5: Conclusiones

- [ ] Síntesis construcción tabla
- [ ] Síntesis conmutación
- [ ] Síntesis valores actuales
- [ ] Fortalezas del estudio
- [ ] Limitaciones identificadas
- [ ] Implicaciones para riesgos
- [ ] Implicaciones para productos
- [ ] Recomendaciones futuras
- [ ] Reflexiones finales

## 📊 Ejemplo Completo: Edad 40 años

```latex
% Ejemplo de cálculos para edad 40 (ficticio - reemplazar con datos reales)

% Tabla de mortalidad
l_{40} = 9,850,432
q_{40} = 0.002156
e_{40} = 38.24 \text{ años}

% Conmutación (i=5%)
D_{40} = 1,234,567.89
N_{40} = 15,678,901.23
S_{40} = 234,567,890.12

% Valores actuales
E_{40}^{30} = \frac{D_{70}}{D_{40}} = 0.52341

a_{40} = \frac{N_{41}}{D_{40}} = 16.2845

{}_{|35}\ddot{a}_{40} = \frac{N_{75}}{D_{40}} = 3.4567

% Diferencial
\text{Diferencial} = \frac{\text{Obtenida} - \text{Referencia}}{\text{Referencia}} \times 100\%
                   = \frac{16.2845 - 16.1234}{16.1234} \times 100\%
                   = +1.00\%
```

## 🚀 Comandos R Útiles

```r
# Calcular diferencial porcentual
calcular_diferencial <- function(obtenida, referencia) {
  ((obtenida - referencia) / referencia) * 100
}

# Redondear a formato LaTeX
format_latex <- function(x, decimals = 4) {
  format(round(x, decimals), nsmall = decimals, big.mark = ",")
}

# Ejemplo de uso
valor_obtenido <- 16.2845
valor_referencia <- 16.1234
diferencial <- calcular_diferencial(valor_obtenido, valor_referencia)

cat(sprintf("%.4f & %.4f & %+.2f\\%% \\\\", 
            valor_obtenido, valor_referencia, diferencial))
```

---

**Nota:** Este es un archivo de trabajo. Los valores mostrados son ejemplos. 
Reemplázalos con tus resultados reales del análisis.
