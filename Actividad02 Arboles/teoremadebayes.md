# Explicación Teórica y Aplicación de Naive Bayes en R

## 1. Fundamentos del Teorema de Bayes

El clasificador **Naive Bayes** es un método de aprendizaje supervisado que entrena un modelo matemático para determinar la clase $c$ más probable a asignar a un registro, dado un conjunto de características o atributos de entrada $X = (x_1, x_2, ..., x_n)$.

El algoritmo se fundamenta directamente en el **Teorema de Bayes** clásico:

$$P(c | x_1, ..., x_n) = \frac{P(c) \cdot P(x_1, ..., x_n | c)}{P(x_1, ..., x_n)}$$

### El Supuesto "Ingenuo" (Naive)
Se le denomina "ingenuo" debido a que aplica un estricto supuesto de **independencia condicional** entre todas las variables predictoras dada la clase objetivo[cite: 3]. Esto significa que asume que la presencia o magnitud de un atributo no guarda ninguna relación ni correlación con los demás[cite: 3]. Al aplicar matemáticamente esta condición, la verosimilitud conjunta se transforma en una productoria de probabilidades individuales[cite: 3]:

$$P(c | x_1, ..., x_n) = \frac{P(c) \cdot \prod_{i=1}^{n} P(x_i | c)}{P(x_1, ..., x_n)}$$

### Optimización del Clasificador
Dado que el denominador $P(x_1, ..., x_n)$ representa la probabilidad de la evidencia (los datos de entrada), este valor es constante y exactamente el mismo para todas las clases $C_j$ que se estén comparando[cite: 3]. Al no afectar la relación ni la comparación relativa entre las clases, se puede remover de la ecuación para optimizar el cómputo del modelo[cite: 3]:

$$P(c_j | x_1, ..., x_n) = P(c_j) \cdot \prod_{i=1}^{n} P(x_i | c_j)$$

### Versión con Logaritmos (Evitar Underflow)
En aplicaciones computacionales con vectores de características extensos, multiplicar de forma sucesiva múltiples probabilidades (valores flotantes muy pequeños entre 0 y 1) puede causar que el resultado digital se aproxime a cero de forma abrupta, provocando un error de desbordamiento numérico (*underflow*)[cite: 3]. Para mitigar este problema, el algoritmo implementa sumatorias de logaritmos en lugar de productorias[cite: 3]:

$$\text{clase predicha} = \arg\max_{c_j} \left[ \log(P(c_j)) + \sum_{i=1}^{n} \log(P(x_i | c_j)) \right]$$

---

## 2. Estimación de Probabilidades según el Tipo de Atributo

La estimación de la verosimilitud $P(x_i | c)$ se procesa de dos formas dependiendo de los datos[cite: 3]:

### A. Atributos Discretos (Caso del Dataset "Jugar")
Cuando los predictores son categóricos o discretos (por ejemplo: Ambiente: *lluvioso, nublado, soleado*; Viento: *sí, no*), las probabilidades condicionales se estiman contando de forma directa las frecuencias relativas dentro del conjunto de entrenamiento[cite: 2, 3]. 

* **Probabilidad a priori de la clase:** $P(c) = \frac{n_c}{N}$, donde $n_c$ es la cantidad de registros de la clase $c$ y $N$ es el total de elementos[cite: 3].
* **Ejemplo práctico:** De acuerdo a los datos analizados, si se tiene un espacio donde la clase *Jugar = No* ($JN$) cuenta con 5 renglones, y de ellos el Ambiente es *Soleado* ($S$) en 3 ocasiones, la probabilidad condicional es $P(\text{Ambiente}=S | \text{Jugar}=N) = \frac{3}{5} = 0.6$[cite: 2]. Por el contrario, si la clase *Jugar = Sí* ($JS$) acumula 9 renglones y el Ambiente es *Soleado* en 2 de ellos, se obtiene $P(\text{Ambiente}=S | \text{Jugar}=S) = \frac{2}{9} \approx 0.222$[cite: 2].

### B. Atributos Continuos (Caso del Dataset "Iris")
Cuando los atributos son numéricos continuos (como las dimensiones en centímetros de `Sepal.Length`, `Sepal.Width`, `Petal.Length` y `Petal.Width`), no es viable calcular frecuencias de ocurrencia exactas[cite: 3]. En este escenario, el algoritmo asume de forma matemática que cada atributo sigue una **distribución Normal o Gaussiana** dentro de cada clase[cite: 3]:

$$x_i | c \sim N(\mu_i^c, (\sigma_i^c)^2)$$

El modelo calcula de manera automática la media ($\mu_i^c$) y la desviación estándar ($\sigma_i^c$) para cada variable de las flores y procesa la verosimilitun empleando la función de densidad de probabilidad gaussiana[cite: 3]:

$$P(x_i | c) = \frac{1}{\sqrt{2\pi}\sigma_i^c} \exp\left(-\frac{(x_i - \mu_i^c)^2}{2(\sigma_i^c)^2}\right)$$

---

## 3. Código de Implementación Práctica en R

A continuación se detalla el script en R para entrenar y evaluar el clasificador utilizando el paquete estadístico `e1071`[cite: 3]:

```r
# 1. Validación e instalación de dependencias necesarias
if(!require(e1071)) install.packages("e1071")
if(!require(caret)) install.packages("caret")

library(e1071)
library(caret)

# 2. Carga del dataset nativo de R
data(iris)
summary(iris)

# 3. Construcción del modelo probabilístico Naive Bayes
modelo_nb <- naiveBayes(Species ~ ., data = iris)

# Despliegue de probabilidades a priori y parámetros gaussianos calculados
print(modelo_nb)

# 4. Ejecución de predicciones sobre el dataset
predicciones_nb <- predict(modelo_nb, iris)

# 5. Matriz de confusión detallada utilizando caret
matriz_completa <- confusionMatrix(predicciones_nb, iris$Species)
print(matriz_completa)