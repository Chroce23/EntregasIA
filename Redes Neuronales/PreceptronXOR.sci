// =================================================================
// Nombre: Christian Omar Ceballos Hernandez
// Matricula: 210487
// Tarea Final: Perceptrón XOR con Ingeniería de Características
// =================================================================

clear;
clc;

printf("=== PROGRAMA: PERCEPTRON XOR EN 3D ===\n\n");

// 1. Entradas originales de la compuerta XOR (usando -1 y 1)
x1 = [-1; -1;  1;  1];
x2 = [-1;  1; -1;  1];

// 2. INGENIERÍA DE CARACTERÍSTICAS (Kernel polinomial 3D)
// Creamos una tercera dimensión multiplicando x1 por x2
x3 = x1 .* x2;

// 3. Salidas esperadas de la compuerta XOR
// Si son iguales da -1 (Falso), si son diferentes da 1 (Verdadero)
y = [-1;  1;  1; -1];

// Mostrar los datos organizados en el espacio 3D
printf("Datos de entrenamiento [x1, x2, x3] -> Salida XOR:\n");
disp([x1, x2, x3, y]);

// 4. Inicialización de los Pesos y el Umbral (Bias)
w1 = 0.0;
w2 = 0.0;
w3 = 0.0;
b  = 0.0;

lr = 0.5;      // Tasa de aprendizaje
max_iter = 50; // Límite de iteraciones para evitar bucles infinitos

printf("\n=== Iniciando Entrenamiento ===\n");

for epoch = 1:max_iter
    errores = 0;
    
    for i = 1:4
        // Calcular la combinación lineal
        suma_lineal = (w1 * x1(i)) + (w2 * x2(i)) + (w3 * x3(i)) + b;
        
        // Función de activación (Signo: regresa -1 si es negativo, 1 si es positivo)
        if suma_lineal >= 0 then
            prediccion = 1;
        else
            prediccion = -1;
        end
        
        // Calcular el error de la predicción
        error_actual = y(i) - prediccion;
        
        // Si hay error, actualizamos los pesos de forma uniforme
        if error_actual <> 0 then
            w1 = w1 + lr * error_actual * x1(i);
            w2 = w2 + lr * error_actual * x2(i);
            w3 = w3 + lr * error_actual * x3(i);
            b  = b  + lr * error_actual;
            errores = errores + 1;
        end
    end
    
    // Si terminamos una vuelta por los 4 puntos sin errores, ya terminó
    if errores == 0 then
        printf("✨ ¡Convergencia alcanzada con éxito en la iteración %d!\n", epoch);
        break;
    end
end

// 5. Mostrar los resultados finales encontrados
printf("\n=== PESOS FINALES ENCONTRADOS ===\n");
printf("w1 (Peso X1) = %.1f\n", w1);
printf("w2 (Peso X2) = %.1f\n", w2);
printf("w3 (Peso X3) = %.1f\n", w3);
printf("b  (Umbral)  = %.1f\n", b);

printf("\n=== ECUACIÓN EXACTA PARA GEOGEBRA 3D ===\n");
printf("Introduce esta ecuación en GeoGebra para ver el plano separador:\n");
printf("(%.1f)x + (%.1f)y + (%.1f)z + (%.1f) = 0\n", w1, w2, w3, b);
