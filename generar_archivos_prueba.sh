#!/bin/bash

# Script para generar archivos de prueba
# Este script genera una estructura de directorios y archivos para probar args.sh

# Crear directorios de prueba (ya deberían estar creados por ejemplos_uso.sh)
mkdir -p entrada/subdir1
mkdir -p entrada/subdir2
mkdir -p salida
mkdir -p logs

# Generar archivos con distintas extensiones y patrones en el nombre
# Archivos de log con patrón "backup"
echo "Contenido de prueba" > entrada/backup_20230101.log
echo "Contenido de prueba" > entrada/backup_20230102.log
echo "Contenido de prueba" > entrada/backup_20230103.log
echo "Contenido de prueba" > entrada/otro_20230104.log

# Archivos de texto con patrón "informe"
echo "Contenido de prueba" > entrada/informe_enero.txt
echo "Contenido de prueba" > entrada/informe_febrero.txt
echo "Contenido de prueba" > entrada/datos_marzo.txt

# Archivos CSV con varios patrones
echo "id,nombre,edad" > entrada/usuarios_2023.csv
echo "id,producto,precio" > entrada/inventario_2023.csv

# Archivos en subdirectorios
echo "Contenido de prueba" > entrada/subdir1/backup_subdir1.log
echo "Contenido de prueba" > entrada/subdir1/informe_subdir1.txt
echo "Contenido de prueba" > entrada/subdir2/backup_subdir2.log
echo "Contenido de prueba" > entrada/subdir2/datos_subdir2.csv

echo "Archivos de prueba generados correctamente."