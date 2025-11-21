# CONFIGURACIÓN ESPECÍFICA DEL GRUPO
# Asignación: Origen = 2, TM_SEXO = M
# Tabla de Referencia: INVALIDEZ 2014 - Masculino

## Parámetros del Proyecto

```
Criterios de Filtrado:
  - Origen: 2
  - TM_SEXO: M (Masculino)
  - Tabla: (No especificada, usar Origen + TM_SEXO)

Tabla de Referencia Oficial:
  - Nombre: INVALIDEZ 2014 - Masculino
  - Tipo: Tabla de Invalidez
  - Período: 2014
  - Sexo: Masculino

Período de Análisis:
  - Inicio: 01/01/2000
  - Fin: 31/12/2012
  - Total: 13 años

Tasa de Interés Técnico:
  - Valor: 5% anual
  - Aplicar en: Cálculo de conmutaciones (Módulo 2)
```

## Proceso de Ejecución

### Paso 1: Exploración y Filtrado
**Archivo**: `01_construccion_tabla_mortalidad/01_carga_y_exploracion.R`

Este script:
- Carga `Base_act.RData`
- Filtra datos con `Origen == 2 & TM_SEXO == "M"`
- Genera `data/datos_seleccionados.RData`

**Acción**: Verifica que los nombres de columnas coincidan con tu base de datos

### Paso 2: Período de Análisis (2000-2012)
**Archivo**: `01_construccion_tabla_mortalidad/02_periodo_analisis.R`

Este script:
- Filtra registros con exposición entre 2000-2012
- Genera cuadro descriptivo (registros y muertes)
- Crea `resultados/cuadro_descriptivo.csv`

**Salida esperada**: Número de registros y muertes para documentar

### Paso 3: Graduación
**Archivo**: `01_construccion_tabla_mortalidad/03_graduacion.R`

Este script prueba 3 métodos:
1. **Spline cúbica** - Suavizamiento no paramétrico
2. **Gompertz** - Modelo exponencial (ln(qx) = a + b×edad)
3. **Polinomio** - Regresión polinómica grado 3

**Salida**: `resultados/tasas_graduadas.csv`

### Paso 4: Tests de Bondad de Ajuste
**Archivo**: `01_construccion_tabla_mortalidad/04_bondad_ajuste.R`

Evalúa 4 pruebas estadísticas para cada método:
1. **Chi-Cuadrado (χ²)** - Compara frecuencias observadas vs esperadas
2. **Kolmogorov-Smirnov (KS)** - Prueba de distribuciones
3. **Rachas** - Detecta patrones no aleatorios
4. **Signos** - Verifica balance de residuos

**Salida**: `resultados/resumen_bondad_ajuste.csv`
**Gráfico**: `resultados/comparacion_metodos.png`

**Instrucción**: Selecciona el método con:
- Valores-p > 0.05 en todos los tests
- Menores valores de estadísticos
- Mejor aspecto visual en el gráfico

### Paso 5: Extrapolación y Tabla Completa
**Archivo**: `01_construccion_tabla_mortalidad/05_extrapolacion_tabla_completa.R`

Este script:
- Extrapola edades 10-{edad_mín-1} (cabeza)
- Usa datos graduados como núcleo
- Extrapola edades {edad_máx+1}-109 (cola)
- Calcula tabla de vida completa con l(x) = 10.000.000

**Salida**: `resultados/tabla_vida_completa.csv`

### Paso 6: Valores de Conmutación
**Archivo**: `02_valores_conmutacion/01_conmutaciones.R`

Calcula:
- **D(x)** = l(x) × v^x
- **N(x)** = Σ D(k) desde k=x hasta k=109
- **C(x)** = d(x) × v^(x+1)
- **M(x)** = Σ C(k) desde k=x hasta k=109
- **R(x)** = Σ N(k) desde k=x hasta k=109

Con v = 1/(1.05) = 0.952381

**Salida**: `resultados/tabla_conmutaciones.csv`

### Paso 7: Cálculo de Rentas
**Archivo**: `03_valores_actuales/01_rentas_seguros.R`

Calcula 5 tipos de rentas:

1. **Dotal Puro** (Edad final 70)
   - Fórmula: $_xE_{70} = D_{70}/D_x$
   - Edades: 38, 54, 62

2. **Renta Vitalicia Vencida**
   - Fórmula: $_x a = N_{x+1}/D_x$
   - Edades: 45, 60, 90

3. **Renta Diferida Anticipada** (Cuotas desde 75)
   - Fórmula: $_{75}/_x \ddot{a} = N_{75}/D_x$
   - Edades: 25, 40, 70

4. **Renta Temporal Vencida** (Fin 80)
   - Fórmula: $_x a_{\overline{80-x|}} = (N_{x+1} - N_{81})/D_x$
   - Edades: 25, 50, 75

5. **Renta Temporal Diferida Anticipada** (Fin 70)
   - Fórmula: $_x \ddot{a}_{\overline{70-x|}} = (N_{70} - N_{71})/D_x$
   - Edades: 32, 50, 68

**Salidas**: 5 archivos CSV con resultados

## Tabla de Referencia INVALIDEZ 2014

Para completar el comparativo con tabla de referencia:

### Fuentes posibles:
1. **Superintendencia de Pensiones** (Chile)
   - www.spensiones.cl
   - Búscar: "Tablas de Mortalidad Invalidez 2014"

2. **Instituto Actuarial de América Latina**
   - Bases de datos actuariales

3. **Documentación del curso**
   - Página web de la asignatura
   - Material de referencia del profesor

### Archivos CSV con tabla referencia:
Una vez obtengas la tabla oficial, crea archivos en `resultados/`:
- `tabla_referencia_invalidez_2014_m.csv`

Formato sugerido:
```
edad,qx_ref,lx_ref,dx_ref,ex_ref
10,0.00123,10000000,12300,60.50
11,0.00130,9987700,12984,59.75
...
```

## Resumen de Entregables

### Módulo 1: Construcción Tabla (60%)

- ✅ Cuadro descriptivo: `resultados/cuadro_descriptivo.csv`
  - Registros originales y de análisis
  - Muertes originales y de análisis

- ✅ Justificación edades límites (en documento)
  - Rango de graduación utilizado
  - Razones de exclusión

- ✅ Parámetros graduación (en documento)
  - Método seleccionado: Spline/Gompertz/Polinomio
  - Script utilizado: #03

- ✅ Tests de bondad: `resultados/resumen_bondad_ajuste.csv`
  - Chi²: valor, p-value
  - KS: valor, p-value
  - Rachas: valor, p-value
  - Signos: valor, p-value

- ✅ Método extrapolación (en documento)
  - Método seleccionado
  - Edades cabeza y cola

- ✅ Tabla completa: `resultados/tabla_vida_completa.csv`
  - Edades 10-109
  - l(x), d(x), p(x), L(x), T(x), e(x)
  - l(x)=10.000.000

### Módulo 2: Conmutaciones (10%)

- ✅ Tabla conmutaciones: `resultados/tabla_conmutaciones.csv`
  - D(x), N(x), C(x), M(x), R(x)
  - Tasa: 5%

### Módulo 3: Valores Actuales (30%)

- ✅ 5 cuadros comparativos (CSV)
  - Dotal puro
  - Renta vitalicia vencida
  - Renta diferida anticipada
  - Renta temporal vencida
  - Renta temporal diferida anticipada

Cada uno con:
  - Edad
  - Valor tabla referencia
  - Valor tabla obtenida
  - Diferencial %

## Próximos Pasos

1. **Preparar datos**: Copia `Base_act.RData` a `data/`
2. **Ajustar nombres columnas**: Verifica en script #01 
3. **Ejecutar secuencialmente**: Scripts 1 → 2 → 3 → 4 → 5 → 6 → 7
4. **Obtener tabla referencia**: INVALIDEZ 2014 - Masculino
5. **Completar comparativos**: Llenar columna "Tabla_Referencia"
6. **Documentar**: Crear informe final

## Fechas Importantes

- **Entrega**: Lunes 08 de diciembre antes de 22:00 hrs
- **Revisión final**: 2-3 días antes de entregar

---

**Creado para**: Proyecto Final EYP2605
**Período**: Noviembre 2025
