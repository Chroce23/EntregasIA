# Reporte de Actividad: Naive Bayes en la FCI

## 1. Tabulación del Conjunto de Datos (20 Estudiantes)

A continuación se presenta el conjunto de datos recopilado de 20 estudiantes de la FCI con sus variables predictoras de hábitos académicos y su variable objetivo (`Rendimiento`):

| # Est. | TiempoEstudio | Asistencia | Participacion | SituacionEcon | Rendimiento  |
|:------:|:-------------:|:----------:|:-------------:|:-------------:|:------------:|
| 1      | Alto          | Alta       | Alta          | Buena         | Excelente    |
| 2      | Medio         | Media      | Baja          | Mala          | Regular      |
| 3      | Bajo          | Baja       | Baja          | Mala          | Deficiente   |
| 4      | Alto          | Alta       | Media         | Buena         | Bueno        |
| 5      | Medio         | Media      | Media         | Buena         | Bueno        |
| 6      | Alto          | Alta       | Alta          | Buena         | Excelente    |
| 7      | Bajo          | Baja       | Baja          | Mala          | Deficiente   |
| 8      | Medio         | Alta       | Media         | Buena         | Bueno        |
| 9      | Alto          | Media      | Alta          | Buena         | Excelente    |
| 10     | Bajo          | Baja       | Media         | Mala          | Regular      |
| 11     | Alto          | Alta       | Alta          | Buena         | Excelente    |
| 12     | Medio         | Media      | Media         | Buena         | Regular      |
| 13     | Bajo          | Baja       | Baja          | Mala          | Deficiente   |
| 14     | Alto          | Alta       | Media         | Buena         | Bueno        |
| 15     | Medio         | Alta       | Alta          | Buena         | Excelente    |
| 16     | Bajo          | Media      | Baja          | Mala          | Deficiente   |
| 17     | Medio         | Media      | Media         | Mala          | Regular      |
| 18     | Alto          | Alta       | Alta          | Buena         | Excelente    |
| 19     | Medio         | Alta       | Media         | Buena         | Bueno        |
| 20     | Bajo          | Baja       | Baja          | Buena         | Deficiente   |

---

## 2. Código de Implementación en R (Google Colab / RStudio)

Puedes ejecutar el siguiente script directamente en tu cuaderno para entrenar con el 80% de los datos y evaluar con el 20% restante:

```r
# 1. Cargar la librería necesaria para Naive Bayes
if(!require(e1071)) install.packages("e1071")
library(e1071)

# 2. Crear el Data Frame con los datos tabulados de la FCI
datos_fci <- data.frame(
  TiempoEstudio = c("Alto","Medio","Bajo","Alto","Medio","Alto","Bajo","Medio","Alto","Bajo",
                    "Alto","Medio","Bajo","Alto","Medio","Bajo","Medio","Alto","Medio","Bajo"),
  Asistencia    = c("Alta","Media","Baja","Alta","Media","Alta","Baja","Alta","Media","Baja",
                    "Alta","Media","Baja","Alta","Alta","Media","Media","Alta","Alta","Baja"),
  Participacion = c("Alta","Baja","Baja","Media","Media","Alta","Baja","Media","Alta","Media",
                    "Alta","Media","Baja","Media","Alta","Baja","Media","Alta","Media","Baja"),
  SituacionEcon = c("Buena","Mala","Mala","Buena","Buena","Buena","Mala","Buena","Buena","Mala",
                    "Buena","Buena","Mala","Buena","Buena","Mala","Mala","Buena","Buena","Buena"),
  Rendimiento   = c("Excelente","Regular","Deficiente","Bueno","Bueno","Excelente","Deficiente",
                    "Bueno","Excelente","Regular","Excelente","Regular","Deficiente","Bueno",
                    "Excelente","Deficiente","Regular","Excelente","Bueno","Deficiente")
)

# Convertir todas las columnas a factores (categorías categóricas)
datos_fci[] <- lapply(datos_fci, as.factor)

# Asegurar orden formal en la variable objetivo
niveles_rendimiento <- c("Excelente", "Bueno", "Regular", "Deficiente")
datos_fci$Rendimiento <- factor(datos_fci$Rendimiento, levels = niveles_rendimiento)

# 3. División de datos: 80% Entrenamiento (16 alumnos) y 20% Prueba (4 alumnos)
set.seed(123) # Semilla fija para reproducibilidad
indices_entrenamiento <- sample(1:20, 16)

entrenamiento <- datos_fci[indices_entrenamiento, ]
prueba        <- datos_fci[-indices_entrenamiento, ]

# 4. Entrenar el clasificador Naive Bayes con los datos discretos
modelo_nb_fci <- naiveBayes(Rendimiento ~ ., data = entrenamiento)

# 5. Probar el modelo con el 20% de datos restante
predicciones <- predict(modelo_nb_fci, prueba)

# 6. Generar la Matriz de Confusión formal
matriz_confusion <- table(Predicho = predicciones, Real = prueba$Rendimiento)

# Imprimir resultados en consola
print("=== MATRIZ DE CONFUSIÓN (EVALUACIÓN 20%) ===")
print(matriz_confusion)