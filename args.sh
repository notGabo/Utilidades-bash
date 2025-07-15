#!/bin/bash

# Constantes
VERSION="0.1"
DATE=$(date +%Y%m%d)

BORRAR=false
condiciones_logfile=""
nombreprefijo=""

# Control de argumentos
for arg in "$@"
do
  case $arg in
    --help|-h)
        echo "Uso: $0 [--archivos=lista de archivos separados por coma] [--dias=<dias>] [--entrada=directorio] [--salida=directorio] [--nombreprefijo=nombre] [--borrar] [--help] [--version] [--verbose][--logfile=archivo]"
        echo "Opciones:"
        echo "  --archivos=formatos      [Obligatorio] Especifica los tipos de archivos permitidos. Ejemplo: --archivos=txt,log,csv"
        echo "  --entrada=directorio     [Obligatorio] Especifica el directorio de entrada (no relativo)"
        echo "  --salida=directorio      [Obligatorio] Especifica el directorio de salida (no relativo)"
        echo "  --dias=<dias>            [Obligatorio] Especifica el número de días para filtrar archivos"
        echo "  --nombreprefijo=nombre   [Opcional] Filtra archivos por su titulo. Ejemplo: --expresion=backup == resultado ejemplo backup_20231001.txt"
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
    --nombreprefijo=*)
        nombreprefijo="${arg#*=}"
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
LOGFILE_PROVIDED=false
if [ -n "$LOGFILE" ]; then
  LOGFILE_PROVIDED=true
  # Crear el directorio del log si no existe
  mkdir -p "$(dirname "$LOGFILE")"
  # Inicializar el archivo de log
  touch "$LOGFILE"
fi

# Construcción de condiciones para find
condiciones_archivos="$(echo "$ARCHIVOS" | sed 's/,/" -o -name "*./g' | sed 's/^/-name "*./' | sed 's/$/"/')"

## Ejecucion del script
find_cmd="find \"$ENTRADA\" -type f -mtime -\"$DIAS\" \\( $condiciones_archivos \\)"
echo "Comando find: $find_cmd -print | grep -E \"/${nombreprefijo}[^/]*$\""

if [ -n "$nombreprefijo" ]; then
    files=$(eval "$find_cmd -print | grep -E \"/${nombreprefijo}[^/]*$\"")
else
    files=$(eval "$find_cmd -print")
fi

if [ -z "$files" ]; then
    if [ "$LOGFILE_PROVIDED" = true ]; then
        echo "[$(date +"%m/%d/%y %T")] Error: No se han encontrado archivos, no se comprimirá nada" >> "$LOGFILE"
    else
        echo "[$(date +"%m/%d/%y %T")] Error: No se han encontrado archivos, no se comprimirá nada"
    fi
    exit 1
fi

# Asegurarse de que el directorio de salida existe
mkdir -p "$SALIDA"

if [ "$LOGFILE_PROVIDED" = true ]; then
    echo "$files" | tr '\n' '\0' | xargs -0 tar -czf "$SALIDA/backup_files_hasta_${DATE}.tar.gz" >> "$LOGFILE" 2>&1
else
    echo "$files" | tr '\n' '\0' | xargs -0 tar -czf "$SALIDA/backup_files_hasta_${DATE}.tar.gz"
fi
tar_exit_code=$?

# Borrado de archivos si se especifica
if [ "$BORRAR" = true ]; then
    if [ "$LOGFILE_PROVIDED" = true ]; then
        echo "$files" | tr '\n' '\0' | xargs -0 rm -f >> "$LOGFILE" 2>&1
    else
        echo "$files" | tr '\n' '\0' | xargs -0 rm -f
    fi
    rm_exit_code=$?

    if [ $rm_exit_code -ne 0 ]; then
        if [ "$LOGFILE_PROVIDED" = true ]; then
            echo "[$(date +"%m/%d/%y %T")] Error: No se pudieron borrar los archivos. Codigo de error: $rm_exit_code" >> "$LOGFILE"
        else
            echo "[$(date +"%m/%d/%y %T")] Error: No se pudieron borrar los archivos. Codigo de error: $rm_exit_code"
        fi
        exit $rm_exit_code
    fi
fi

RUTA_COMPLETA=$(realpath "$SALIDA/backup_files_hasta_${DATE}.tar.gz")
if [ "$LOGFILE_PROVIDED" = true ]; then
    echo "[$(date +"%m/%d/%y %T")] Archivos comprimidos correctamente en \"$RUTA_COMPLETA\"" >> "$LOGFILE"
else
    echo "[$(date +"%m/%d/%y %T")] Archivos comprimidos correctamente en \"$RUTA_COMPLETA\""
fi
exit 0