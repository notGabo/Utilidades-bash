#!/bin/bash

# Constantes
VERSION="0.1"
DATE=$(date +%Y%m%d)

BORRAR=false
condiciones_logfile=""
regex=""

# Control de argumentos
for arg in "$@"
do
  case $arg in
    --help|-h)
        echo "Uso: $0 [--archivos=lista de archivos separados por coma] [--entrada=directorio] [--salida=directorio] [--expresion=regex] [--dias=<dias>] [--borrar] [--logfile=archivo] [--help] [--verbose] [--version]"
        echo "Opciones:"
        echo "  --archivos=formatos      [Obligatorio] Especifica los tipos de archivos permitidos. Ejemplo: --archivos=txt,log,csv"
        echo "  --entrada=directorio     [Obligatorio] Especifica el directorio de entrada (no relativo)"
        echo "  --salida=directorio      [Obligatorio] Especifica el directorio de salida (no relativo)"
        echo "  --expresion=regex        [TODO][Opcional] Expresión regular para filtrar archivos por su titulo. Ejemplo: --expresion=backup_[0-9]+"
        echo "  --dias=<dias>            [Obligatorio] Especifica el número de días para filtrar archivos"
        echo "  --borrar                 [Opcional] Especifica si se debe los archivos a comprimir"
        echo "  --logfile=archivo        [Opcional] Especifica el archivo de log"
        echo "  --help, -h               Muestra esta ayuda"
        echo "  --verbose                Muestra información detallada durante la ejecución"
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
    --regex=*)
        regex="${arg#*=}"
        ;;
    --verbose)
        set -x  # Habilita el modo verbose
        ;;
    --version|-v)
        echo "Versión: $VERSION"
        exit 0
        ;;
    *)
  esac
done

# Validación de argumentos vitales
if [ -z "$ARCHIVOS" ] || [ -z "$SALIDA" ] || [ -z "$ENTRADA" ] || [ -z "$DIAS" ]; then
  echo "Error: Los argumentos --archivos, --salida, --entrada y --dias son obligatorios."
  exit 1
fi

# Validación de logfile
if [ -n "$LOGFILE" ]; then
    if [ ! -d "$(dirname "$LOGFILE")" ]; then
        mkdir -p "$(dirname "$LOGFILE")"
    fi
  condiciones_logfile=">> \"$LOGFILE\" 2>&1"
fi

# Construcción de condiciones para find (solo extensiones)
condiciones_archivos="$(echo "$ARCHIVOS" | sed 's/,/" -o -name "*./g' | sed 's/^/-name "*./' | sed 's/$/"/')"

# Validar entrada de regex (se agrega como condición adicional)
if [ -n "$regex" ]; then
    # Escapa la regex para evitar problemas con Bash y find
    escaped_regex=$(sed 's/[()]/\\&/g' <<< "$regex")  # Escapa paréntesis
    condiciones_regex="-regextype posix-extended -regex \".*/$escaped_regex\""
    # Combina condiciones: (extensiones) O (regex)
    find_conditions="\\( $condiciones_archivos \\) -o \\( $condiciones_regex \\)"
else
    find_conditions="\\( $condiciones_archivos \\)"
fi

# Ejecución del find
files=$(eval "find \"$ENTRADA\" -type f -mtime -\"$DIAS\" $find_conditions -print")
if [ -z "$files" ]; then
    echo "[$(date +"%m/%d/%y %T")] Error: No se han encontrado archivos, no se comprimirá nada" >> "$LOGFILE"
    exit 1
fi
echo "$files" | xargs tar -czf "$SALIDA/backup_files_hasta_${DATE}.tar.gz"
tar_exit_code=$?

# Borrado de archivos si se especifica
if [ "$BORRAR" = true ]; then
    eval "find \"$ENTRADA\" -type f -mtime -\"$DIAS\" \\( $condiciones_archivos \\) -print0 | xargs -0 rm -f >> \"$LOGFILE\" 2>&1"
    rm_exit_code=$?
    if [ $rm_exit_code -ne 0 ]; then
        echo "[$(date +"%m/%d/%y %T")] Error: No se pudieron borrar los archivos. Codigo de error: $rm_exit_code" >> "$LOGFILE"
        exit $rm_exit_code
    fi
fi

RUTA_COMPLETA=$(realpath "$SALIDA/backup_files_hasta_${DATE}.tar.gz")
echo "[$(date +"%m/%d/%y %T")] Archivos comprimidos correctamente en \"$RUTA_COMPLETA\"" >> "$LOGFILE"
exit 0