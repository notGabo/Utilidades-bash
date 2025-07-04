#!/bin/bash

# Script con ejemplos de uso de args.sh usando rutas relativas

echo "====================================="
echo "Ejemplos de uso del script args.sh"
echo "====================================="

# Crear estructura de directorios si no existen
mkdir -p entrada/subdir1 entrada/subdir2 salida logs

# Primero generamos los archivos de prueba
echo "Generando archivos de prueba..."
bash generar_archivos_prueba.sh

# Ejemplo 1: Comprimir todos los archivos .log y .txt de los últimos 30 días
echo -e "\n\n===== EJEMPLO 1: Comprimir todos los archivos .log y .txt ====="
echo "bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --logfile=./logs/ejemplo1.log --borrar"
bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --logfile=./logs/ejemplo1.log --borrar

# Ejemplo 2: Comprimir solo los archivos que empiezan con "backup"
echo -e "\n\n===== EJEMPLO 2: Comprimir archivos que empiezan con \"backup\" ====="
echo "bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --expresion=^backup --logfile=./logs/ejemplo2.log --borrar"
bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --expresion=^backup --logfile=./logs/ejemplo2.log --borrar

# Ejemplo 3: Comprimir archivos con patrón "informe" y borrarlos después
echo -e "\n\n===== EJEMPLO 3: Comprimir archivos con patrón \"informe\" y borrarlos ====="
echo "bash args.sh --archivos=txt --dias=30 --entrada=./entrada --salida=./salida --expresion=informe --borrar --logfile=./logs/ejemplo3.log --borrar"
bash args.sh --archivos=txt --dias=30 --entrada=./entrada --salida=./salida --expresion=informe --borrar --logfile=./logs/ejemplo3.log --borrar

# Ejemplo 4: Comprimir archivos CSV que tengan números en el nombre
echo -e "\n\n===== EJEMPLO 4: Comprimir archivos CSV con números en el nombre ====="
echo "bash args.sh --archivos=csv --dias=30 --entrada=./entrada --salida=./salida --expresion=[0-9] --logfile=./logs/ejemplo4.log --borrar"
bash args.sh --archivos=csv --dias=30 --entrada=./entrada --salida=./salida --expresion=[0-9] --logfile=./logs/ejemplo4.log --borrar

# Ejemplo 5: Mostrar contenido de los logs
echo -e "\n\n===== EJEMPLO 5: Contenido de los logs generados ====="
echo "--- Ejemplo 1 ---"
cat ./logs/ejemplo1.log
echo -e "\n--- Ejemplo 2 ---"
cat ./logs/ejemplo2.log
echo -e "\n--- Ejemplo 3 ---"
cat ./logs/ejemplo3.log
echo -e "\n--- Ejemplo 4 ---"
cat ./logs/ejemplo4.log