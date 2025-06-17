#!/bin/bash

# Constantes
VERSION="0.1"
DATE=$(date +%Y%m%d)

BORRAR=false
condiciones_logfile=""

# Control de argumentos
for arg in "$@"
do
  case $arg in
    --help|-h)
        echo "Uso: $0 [--archivos=lista de archivos separados por coma] [--dias=<dias>] [--entrada=directorio] [--salida=directorio] [--borrar] [--help] [--version] [--logfile=archivo]"
        echo "Opciones:"
        echo "  --archivos=formatos      [Obligatorio] Especifica los tipos de archivos permitidos. Ejemplo: --archivos=txt,log,csv"
        echo "  --entrada=directorio     [Obligatorio] Especifica el directorio de entrada (no relativo)"
        echo "  --salida=directorio      [Obligatorio] Especifica el directorio de salida (no relativo)"
        echo "  --dias=<dias>            [Obligatorio] Especifica el número de días para filtrar archivos"
        echo "  --borrar                 [Opcional] Especifica si se debe los archivos a comprimir"
        echo "  --logfile=archivo        [Opcional] Especifica el archivo de log"
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
    --borrar)
        BORRAR=true
        ;;
    --logfile=*)
        LOGFILE="${arg#*=}"
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

# Validación de argumentos
if [ -z "$ARCHIVOS" ] || [ -z "$SALIDA" ] || [ -z "$ENTRADA" ] || [ -z "$DIAS" ]; then
  echo "Error: Los argumentos --archivos, --salida, --entrada y --dias son obligatorios."
  exit 1
fi
# Validación de logfile
if [ -n "$LOGFILE" ]; then
  condiciones_logfile=">> \"$LOGFILE\" 2>&1"
fi

# Construcción de condiciones para find
condiciones_archivos="$(echo "$ARCHIVOS" | sed 's/,/" -o -name "*./g' | sed 's/^/-name "*./' | sed 's/$/"/')"

# Ejecucion del script
eval "find \"$ENTRADA\" -type f -mtime -\"$DIAS\" \\( $condiciones_archivos \\) -print | zip -r \"$SALIDA/backup_files_hasta_${DATE}.zip\" -@ $condiciones_logfile"

# Borrado de archivos si se especifica
if [ "$BORRAR" = true ]; then
    eval "find \"$ENTRADA\" -type f -mtime -\"$DIAS\" \\( $condiciones_archivos \\) -print0 | xargs -0 rm -f >> \"$LOGFILE\" 2>&1"
fi