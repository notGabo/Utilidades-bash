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
        echo "Uso: $0 [--archivos=lista de archivos separados por coma] [--dias=<dias>] [--entrada=directorio] [--salida=directorio] [--expresion=regex] [--borrar] [--help] [--version] [--verbose][--logfile=archivo]"
        echo "Opciones:"
        echo "  --archivos=formatos      [Obligatorio] Especifica los tipos de archivos permitidos. Ejemplo: --archivos=txt,log,csv"
        echo "  --entrada=directorio     [Obligatorio] Especifica el directorio de entrada (no relativo)"
        echo "  --salida=directorio      [Obligatorio] Especifica el directorio de salida (no relativo)"
        echo "  --expresion=regex        [En desarrollo] Expresión regular para filtrar archivos por su titulo. Ejemplo: --expresion=backup_[0-9]+"
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
    --expresion=*)
        regex="${arg#*=}"
        ;;
    --regex=*)
        regex="${arg#*=}"
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
# No usamos una variable para la redirección, sino que redirigimos directamente en los comandos
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

# Validar entrada de regex
if [ -n "$regex" ]; then
    if [ "$LOGFILE_PROVIDED" = true ]; then
        echo "[$(date +"%m/%d/%y %T")] Usando expresión regular: $regex" >> "$LOGFILE"
    else
        echo "[$(date +"%m/%d/%y %T")] Usando expresión regular: $regex"
    fi
fi

## Ejecucion del script
# Construir comando find base
find_cmd="find \"$ENTRADA\" -type f -mtime -\"$DIAS\" \\( $condiciones_archivos \\)"

# Ejecutar el comando find
if [ -n "$regex" ]; then
    # Si hay regex, ejecutamos find y luego filtramos con grep
    # Extraemos solo el nombre de archivo y aplicamos grep
    files=$(eval "$find_cmd -print | xargs -n1 basename | grep -E \"${regex}\" | xargs -I{} find \"$ENTRADA\" -name \"{}\"")
else
    # Si no hay regex, ejecutamos find directamente
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

# Crear un archivo temporal con la lista de archivos
temp_file=$(mktemp)
echo "$files" > "$temp_file"

# Ejecutar tar con redirección adecuada
if [ "$LOGFILE_PROVIDED" = true ]; then
    tar -czf "$SALIDA/backup_files_hasta_${DATE}.tar.gz" -T "$temp_file" >> "$LOGFILE" 2>&1
else
    tar -czf "$SALIDA/backup_files_hasta_${DATE}.tar.gz" -T "$temp_file"
fi
tar_exit_code=$?

# Eliminar el archivo temporal
rm -f "$temp_file"

# Borrado de archivos si se especifica
if [ "$BORRAR" = true ]; then
    # Crear un archivo temporal con la lista de archivos para borrar
    temp_delete_file=$(mktemp)
    echo "$files" > "$temp_delete_file"
    
    # Borrar los archivos
    if [ "$LOGFILE_PROVIDED" = true ]; then
        cat "$temp_delete_file" | xargs rm -f >> "$LOGFILE" 2>&1
    else
        cat "$temp_delete_file" | xargs rm -f
    fi
    rm_exit_code=$?
    
    # Eliminar el archivo temporal
    rm -f "$temp_delete_file"
    
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