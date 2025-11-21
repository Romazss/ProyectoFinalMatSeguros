# EYP2605 - Matemáticas Actuariales
## Proyecto Final - Noviembre 2025

---

## 📅 Información General

| Aspecto | Detalle |
|--------|---------|
| **Asignatura** | EYP2605 - Matemáticas Actuariales |
| **Mes** | Noviembre 2025 |
| **Fecha Límite de Entrega** | Lunes 08 de diciembre antes de las 22:00 hrs |

---

## 📋 Componentes del Proyecto

### 1️⃣ Construcción de Tabla de Mortalidad (60%)

#### 1.1 Obtener el cuerpo de la tabla de mortalidad

**Insumos:** Base_act.RData

##### Tabla Asignada según Criterios

| Origen | TM_SEXO | Tabla | Descripción | Tabla de Referencia |
|--------|---------|-------|-------------|-------------------|
| 2 | F | - | - | INVALIDEZ 2014 – Fem |
| 2 | M | - | - | INVALIDEZ 2014 - Mas |
| 3 | F | - | - | SOBREVIV – 2014 - Fem |
| 3 | M | - | - | SOBREVIV – 2014 - Mas |
| - | M | 1 | - | SOBREV – 2020 - Fem |
| - | F | 2 | - | SOBREV – 2020 - Mas |
| - | F | - | - | TABLA F |
| - | M | - | - | TABLA M |
| - | - | 4 | - | MIXTA |

#### 1.2 Período de Análisis
- **Inicio:** 01/01/2000
- **Fin:** 31/12/2012

#### 1.3 Cuadro Descriptivo Requerido

Debe presentar un cuadro que muestre:
- Número de registros originales
- Número de muertes originales
- Número de registros a incluirse en el análisis (registros que cumplen con exposición en el período)
- Número de muertes a incluirse en el análisis

#### 1.4 Graduación

**Requisitos:**
- Indicar y fundamentar las edades límites escogidas
- Indicar los parámetros de suavidad
- Especificar script de R utilizado

**Evaluar 4 Test de Bondad de Ajuste:**
1. **Chi cuadrado (χ²)**
   - Valor de la prueba: _______
   - Valor-p: _______

2. **Kolmogorov-Smirnov (KS)**
   - Valor de la prueba: _______
   - Valor-p: _______

3. **Rachas**
   - Valor de la prueba: _______
   - Valor-p: _______

4. **Signos**
   - Valor de la prueba: _______
   - Valor-p: _______

#### 1.5 Extrapolación

**Requisitos:**
- Seleccionar uno de los métodos vistos en clase (indicarlo explícitamente)
- Con la tabla asignada, construir:
  - **Cabeza:** de 10 a edad x
  - **Cola:** de edad x hasta w = 109 años

#### 1.6 Tablas Completadas

Completar ambas tablas para **l(x) = 10.000.000**, incluyendo:
- Función de sobrevivencia
- Función de decremento
- **Esperanza de vida (e(x))**

---

### 2️⃣ Valores de Conmutación (10%)

**Tasa de Interés Técnico:** 5%

Calcular para ambas tablas:
- D(x) = l(x) × v^x
- N(x) = Σ D(k) para k ≥ x
- C(x) = d(x) × v^(x+1)
- M(x) = Σ C(k) para k ≥ x
- R(x) = Σ N(k) para k ≥ x

---

### 3️⃣ Cálculo de Valores Actuales (30%)

**Requisitos:**
- Usar tasa de interés técnico asignado
- Usar la tabla obtenida en sección 1
- Usar la tabla de referencia (página web)
- Mostrar la fórmula utilizada
- Comentar los resultados

#### 3.1 Dotal Puro (Edad final = 70 años)

**Fórmula:** $_xE_{70} = \frac{D_{70}}{D_x}$

| Edad | Tabla Referencia | Tabla Obtenida | Diferencial % |
|------|-----------------|----------------|---------------|
| 38 | | | |
| 54 | | | |
| 62 | | | |

#### 3.2 Renta Incierta Vitalicia con Pago Vencido

**Fórmula:** $_x a = \frac{N_{x+1}}{D_x}$

| Edad | Tabla Referencia | Tabla Obtenida | Diferencial % |
|------|-----------------|----------------|---------------|
| 45 | | | |
| 60 | | | |
| 90 | | | |

#### 3.3 Renta Incierta Vitalicia Diferida con Pago Anticipado

**Cuotas a partir de los 75 años**

**Fórmula:** $_{75}/_x \ddot{a} = \frac{N_{75}}{D_x}$

| Edad | Tabla Referencia | Tabla Obtenida | Diferencial % |
|------|-----------------|----------------|---------------|
| 25 | | | |
| 40 | | | |
| 70 | | | |

#### 3.4 Renta Incierta Temporal con Pago Vencido

**Edad final = 80 años**

**Fórmula:** $_x a_{\overline{80-x|}} = \frac{N_{x+1} - N_{80+1}}{D_x}$

| Edad | Tabla Referencia | Tabla Obtenida | Diferencial % |
|------|-----------------|----------------|---------------|
| 25 | | | |
| 50 | | | |
| 75 | | | |

#### 3.5 Renta Incierta Temporal Diferida con Pago Anticipado

**Edad final = 70 años**

**Fórmula:** $_{70-x}/_x \ddot{a}_{\overline{70-x|}} = \frac{N_{70} - N_{71}}{D_x}$

| Edad | Tabla Referencia | Tabla Obtenida | Diferencial % |
|------|-----------------|----------------|---------------|
| 32 | | | |
| 50 | | | |
| 68 | | | |

---

## 📝 Notas Importantes

- Todos los cálculos deben estar debidamente fundamentados
- Se debe incluir el código R utilizado
- Los resultados deben ser comentados y analizados
- La presentación debe ser clara y ordenada
- Respetar formato y estructura requerida

---

## ✅ Checklist de Entrega

- [ ] Tabla de mortalidad construida y validada
- [ ] Cuadro descriptivo de registros completado
- [ ] Graduación con edades límites justificadas
- [ ] 4 tests de bondad de ajuste evaluados
- [ ] Extrapolación realizada y método especificado
- [ ] Tablas con l(x) = 10.000.000 y esperanza de vida
- [ ] Valores de conmutación calculados (5% tasa técnica)
- [ ] Valores actuales para todos los productos calculados
- [ ] Fórmulas mostradas para cada cálculo
- [ ] Resultados comentados y analizados
- [ ] Código R incluido
- [ ] Documento entregado antes del 08/dic a las 22:00 hrs

---

**Última actualización:** Noviembre 2025
