#!/bin/bash

BORRAR=false
VERSION="0.1"

for arg in "$@"
do
  case $arg in
    --help|-h)
        echo "Uso: $0 [--archivos=lista de archivos separados por coma] [--dias=<dias>] [--entrada=directorio] [--salida=directorio] [--borrar] [--help] [--version]"
        echo "Opciones:"
        echo "  --archivos=xlsx,csv,txt  [Obligatorio] Especifica los tipos de archivos permitidos"
        echo "  --entrada=directorio     [Obligatorio] Especifica el directorio de entrada (no relativo)"
        echo "  --salida=directorio      [Obligatorio] Especifica el directorio de salida (no relativo)"
        echo "  --dias=<dias>            [Obligatorio] Especifica el número de días para filtrar archivos"
        echo "  --borrar                 [Opcional] Especifica si se debe los archivos a comprimir"
        echo "  --help, -h               Muestra esta ayuda"
        echo "  --version, -v            Muestra la versión del script"
        exit 0
        ;;
    --archivos=*)
        ARCHIVOS="${arg#*=}"
        ;;
    --entrada=*)
        ENTRADA="${arg#*=}"
        ;;
    --dias=*)
        DIAS="${arg#*=}"
        ;;
    --borrar=*)
        BORRAR=true
        ;;
    --salida=*)
        SALIDA="${arg#*=}"
        ;;
    --version|-v)
        echo "Versión: $VERSION"
        exit 0
        ;;
    *)
  esac
done

if [ -z "$ARCHIVOS" ] || [ -z "$SALIDA" ] || [ -z "$ENTRADA" ] || [ -z "$DIAS" ]; then
  echo "Error: Los argumentos --archivos, --salida, --entrada y --dias son obligatorios."
  exit 1
fi

# Comando find para obtener los archivos
condiciones_archivos="$(echo "$ARCHIVOS" | sed 's/,/" -o -name "*./g' | sed 's/^/-name "*./' | sed 's/$/"/')"
eval "find \"$ENTRADA\" -type f -mtime -\"$DIAS\" \\( $condiciones_archivos \\) -print"