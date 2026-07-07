package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// Ingrediente representa lo que requiere la receta
type Ingrediente struct {
	Nombre   string
	Cantidad int
}

// Platillo contiene la información del menú
type Platillo struct {
	Nombre       string
	Ingredientes []Ingrediente
}

// Base de conocimientos estática del Menú
var Menu = map[string]Platillo{
	"1": {
		Nombre: "Tacos de Res",
		Ingredientes: []Ingrediente{
			{Nombre: "Gramos de carne de res", Cantidad: 200},
			{Nombre: "Piezas de tortillas", Cantidad: 4},
			{Nombre: "Piezas de cebolla", Cantidad: 1},
		},
	},
	"2": {
		Nombre: "Caldo de Pollo",
		Ingredientes: []Ingrediente{
			{Nombre: "Gramos de pollo", Cantidad: 300},
			{Nombre: "Piezas de jitomate", Cantidad: 2},
			{Nombre: "Piezas de cebolla", Cantidad: 1},
		},
	},
	"3": {
		Nombre: "Quesadillas",
		Ingredientes: []Ingrediente{
			{Nombre: "Piezas de tortillas", Cantidad: 2},
			{Nombre: "Gramos de queso", Cantidad: 100},
		},
	},
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	fmt.Println("==================================================")
	fmt.Println("   SISTEMA EXPERTO DE COCINA (INTERACTIVO) ")
	fmt.Println("==================================================")
	fmt.Println("Menú disponible:")
	for id, platillo := range Menu {
		fmt.Printf("[%s] %s\n", id, platillo.Nombre)
	}
	fmt.Println("==================================================")
	fmt.Print("👉 Selecciona el número del guiso que deseas preparar: ")

	scanner.Scan()
	seleccion := strings.TrimSpace(scanner.Text())

	platillo, existe := Menu[seleccion]
	if !existe {
		fmt.Println("❌ Opción no válida. Saliendo del sistema.")
		return
	}

	fmt.Printf("\nPerfecto, vamos a evaluar si puedes preparar: %s\n", platillo.Nombre)
	fmt.Println("Por favor, responde cuántas unidades tienes actualmente en tu cocina:\n")

	inventarioUsuario := make(map[string]int)

	// CORRECCIÓN: Agregamos el "_" para ignorar el índice del arreglo
	for _, ing := range platillo.Ingredientes {
		fmt.Printf("❓ ¿Cuánto tienes de [%s]? (Requiere %d): ", ing.Nombre, ing.Cantidad)
		scanner.Scan()
		entrada := strings.TrimSpace(scanner.Text())

		cantidad, err := strconv.Atoi(entrada)
		if err != nil {
			fmt.Println("⚠️ Entrada no válida. Se asumirá que tienes 0.")
			cantidad = 0
		}
		inventarioUsuario[ing.Nombre] = cantidad
	}

	fmt.Println("\n==================================================")
	fmt.Println("           DIAGNÓSTICO DEL SISTEMA EXPERTO        ")
	fmt.Println("==================================================")

	sePuedeCocinar := true
	var faltantes []string

	// CORRECCIÓN: Agregamos el "_" también aquí para que lea los datos correctamente
	for _, ing := range platillo.Ingredientes {
		tengo := inventarioUsuario[ing.Nombre]
		if tengo < ing.Cantidad {
			sePuedeCocinar = false
			diferencia := ing.Cantidad - tengo
			faltantes = append(faltantes, fmt.Sprintf("- %s (Te faltan: %d)", ing.Nombre, diferencia))
		}
	}

	if sePuedeCocinar {
		fmt.Println("✅ ¡TODO LISTO! Tienes todos los insumos necesarios.")
		fmt.Printf("¡El cocinero ya puede empezar a preparar %s!\n", platillo.Nombre)
	} else {
		fmt.Println("❌ NO SE PUEDE PREPARAR EL GUISO.")
		fmt.Println("\n🛒 Lista de ingredientes faltantes por comprar:")
		for _, item := range faltantes {
			fmt.Println(item)
		}
	}
	fmt.Println("==================================================")
}
