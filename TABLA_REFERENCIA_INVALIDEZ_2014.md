# TABLA DE REFERENCIA: INVALIDEZ 2014 - MASCULINO

## Información General

**Nombre oficial**: Tabla de Mortalidad de Inválidos 2014 - Masculino  
**Tipo**: Tabla de Invalidez  
**Período de referencia**: 2014  
**Sexo**: Masculino  
**País de origen**: Chile  
**Aplicabilidad**: Cálculos actuariales en rentas de invalidez y seguros relacionados

---

## Características de la Tabla

### Cobertura de Edades
- **Edad mínima**: Generalmente 10 años
- **Edad máxima**: Generalmente 109 años
- **Intervalo**: 1 año

### Probabilidades de Muerte
- La tabla presenta q(x) para cada edad x
- Representa la probabilidad de que un inválido de edad x fallezca antes de alcanzar la edad x+1
- Las tasas de invalidez son generalmente más altas que las de la población general

### Características Específicas de la Invalidez
- Refleja la mortalidad de personas inválidas (con limitaciones funcionales)
- Las probabilidades de muerte aumentan considerablemente con la edad
- Pueden incluir factores de ajuste por tipo de invalidez

---

## Dónde Obtener la Tabla

### Fuentes Oficiales Recomendadas

#### 1. Superintendencia de Pensiones (Chile)
- **Sitio web**: www.spensiones.cl
- **Sección**: "Estadísticas y Estudios" o "Tablas Biométricas"
- **Búsqueda**: "Tabla de Mortalidad Invalidez 2014"
- **Formato**: Generalmente en PDF o Excel

#### 2. Banco Central de Chile
- **Sitio web**: www.bcentral.cl
- **Sección**: "Estadísticas" → "Tablas de Mortalidad"

#### 3. Instituto Nacional de Estadísticas (INE)
- **Sitio web**: www.ine.cl
- **Búsqueda**: "Tablas de vida o mortalidad"

#### 4. Documentación del Curso
- **Material de referencia** del profesor
- **Página web** de la asignatura
- **Plataforma virtual** (Canvas, Blackboard, etc.)

#### 5. Bibliografía Actuarial
- Libros de matemática actuarial
- Publicaciones de la Sociedad de Actuarios (SOA)
- Materiales de seguros

---

## Estructura de la Tabla

La tabla típicamente contiene:

| Columna | Descripción | Símbolo |
|---------|-------------|---------|
| Edad | Edad x | x |
| Probabilidad de muerte | Probabilidad de muerte de x a x+1 | q(x) |
| Sobrevivientes | Número de sobrevivientes a edad x (radix = 100,000 o 1,000,000) | l(x) |
| Muertes | Número de muertes entre x y x+1 | d(x) |
| Años persona | Años vividos entre x y x+1 | L(x) |
| Esperanza de vida | Años esperados de vida a partir de edad x | e(x) |

---

## Formato Esperado para los Archivos

### Formato CSV Recomendado

```
edad,qx,lx,dx,Lx,Tx,ex
10,0.00123,10000000,12300,9994007,607850000,60.79
11,0.00130,9987700,12984,9981308,597856000,59.88
12,0.00138,9974716,13761,9968036,587875000,58.95
...
109,1.00000,10000,10000,5000,5000,0.50
```

### Columnas Necesarias (mínimo)

Para completar los comparativos, necesitas al menos:
- **edad**: Edad (10-109)
- **qx**: Probabilidad de muerte
- **lx**: Sobrevivientes (se puede usar radix diferente, se ajustará proporcionalmente)
- **ex**: Esperanza de vida

---

## Paso a Paso para Obtener y Usar la Tabla

### Paso 1: Buscar y Descargar
1. Ingresa a uno de los sitios recomendados arriba
2. Busca "Tabla Invalidez 2014" o "Mortalidad Inválidos 2014"
3. Verifica que sea para SEXO MASCULINO
4. Descarga en formato Excel o PDF

### Paso 2: Extraer Datos (si está en PDF)
Si la tabla está en PDF:
1. Copia los datos manualmente o
2. Usa herramienta en línea para convertir PDF a Excel (ej: smallpdf.com)
3. Guarda como CSV

### Paso 3: Preparar Archivo CSV
Crea archivo `tabla_referencia_invalidez_2014_m.csv`:

```csv
edad,qx,lx,ex
10,0.00123,10000000,60.79
11,0.00130,9987700,59.88
...
```

### Paso 4: Integrar en Análisis
En el script `03_valores_actuales/01_rentas_seguros.R`, cargar así:

```r
tabla_ref <- read.csv("../resultados/tabla_referencia_invalidez_2014_m.csv")

# Obtener valores de referencia
qx_ref_45 <- tabla_ref$qx[tabla_ref$edad == 45]
ex_ref_65 <- tabla_ref$ex[tabla_ref$edad == 65]
```

---

## Notas Importantes

### Radix
- Tu tabla: **l(x) = 10.000.000**
- Tabla referencia: Verificar (generalmente 100,000 o 1,000,000)
- Si son diferentes, **escalar proporcionalmente** para comparar q(x) directamente

### Período de Análisis vs. Tabla de Referencia
- **Tu análisis**: 2000-2012 (datos del fondo de pensiones)
- **Tabla referencia**: 2014 (tabla oficial publicada)
- Esto es correcto - usas datos históricos para graduación y comparas con tabla oficial

### Interpretación de Diferencias
- Diferencias del ±5%: Razonables
- Diferencias >10%: Requiere investigación
- Si hay diferencias muy grandes: Verificar:
  - Correctitud del método de graduación
  - Correctitud de los filtros aplicados
  - Suficiencia de datos en edades

---

## Contactos y Recursos Adicionales

### Para consultas sobre la tabla:
- Email: estadisticas@spensiones.cl
- Teléfono: +56 2 2655 6000 (Superintendencia de Pensiones)

### Recursos en línea:
- [Society of Actuaries (SOA)](https://www.soa.org/)
- [International Actuarial Association](https://www.actuaries.org/)
- [Colegio de Actuarios de Chile](https://www.actuarios.cl/)

---

## Checklist para Usar la Tabla

- [ ] Descargué la tabla de referencia INVALIDEZ 2014 - Masculino
- [ ] Verifiqué que sea para sexo MASCULINO
- [ ] Convertí a formato CSV si era necesario
- [ ] Guardé como `tabla_referencia_invalidez_2014_m.csv` en `resultados/`
- [ ] Verifiqué que contenga: edad, qx, lx, ex (al menos)
- [ ] Probé cargar en R: `read.csv("tabla_referencia_invalidez_2014_m.csv")`
- [ ] Completé las columnas "Tabla_Referencia" en los resultados
- [ ] Calculé diferenciales porcentuales
- [ ] Documenté discrepancias >5%

---

## Preguntas Frecuentes

**P: ¿Dónde exactamente busco en Spensiones?**  
R: Menú → Estadísticas → Tablas de Mortalidad o Biométricas

**P: ¿Qué pasa si no encuentro exactamente 2014?**  
R: Usa la más cercana disponible (2013, 2015) y documenta cual usaste

**P: ¿Puedo usar una tabla de población general?**  
R: No, debe ser específicamente de INVALIDEZ

**P: ¿El radix debe ser igual?**  
R: No necesariamente, pero documenta cual usas para cada tabla

**P: ¿Cómo ajusto si los radix son diferentes?**  
R: Factor de ajuste = radix_tabla / radix_referencia; multiplica q(x) para comparar

---

**Actualizado**: Noviembre 2025  
**Para**: Proyecto Final EYP2605 - Matemáticas Actuariales
