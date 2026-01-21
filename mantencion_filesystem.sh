#!/bin/bash

# Constantes
VERSION="0.1"
DATE=$(date +%Y%m%d)

# Variables por defecto
BORRAR=false
condiciones_logfile=""
nombreprefijo=""

# Control de argumentos
for arg in "$@"
do
  case $arg in
    --help|-h)
        echo -e "Uso: $0 [--archivos=lista de archivos separados por coma] [--dias=<dias>] [--entrada=directorio] [--salida=directorio] [--nombreprefijo=nombre] [--borrar] [--configuracion=archivo] [--help] [--version] [--verbose] [--logfile=archivo]"
        echo -e "Opciones:"
        echo -e "  --archivos=formatos      [Obligatorio] Especifica los tipos de archivos permitidos. Ejemplo: --archivos=txt,log,csv"
        echo -e "  --entrada=directorio     [Obligatorio] Especifica el directorio de entrada (no relativo)"
        echo -e "  --salida=directorio      [Obligatorio] Especifica el directorio de salida (no relativo)"
        echo -e "  --dias=<+dias o -dias>   [Obligatorio] Especifica el número de días para filtrar archivos"
        echo -e "  --nombreprefijo=nombre   [Opcional] Filtra archivos por su titulo. Ejemplo: --expresion=backup == resultado ejemplo backup_20231001.txt"
        echo -e "  --borrar                 [Opcional] Especifica si se debe los archivos a comprimir"
        echo -e "  --configuracion=archivo  [Opcional] Especifica un archivo de configuración para los parámetros"
        echo -e "  --logfile=archivo        [Opcional] Especifica el archivo de log"
        echo -e "  --help, -h               Muestra esta ayuda"
        echo -e "  --verbose                Muestra información detallada durante la ejecución"
        echo -e "  --version, -v            Muestra la versión del script"
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
    --configuracion=*)
        CONFIGURACION="${arg#*=}"
        if [ -f "$CONFIGURACION" ]; then
            source "$CONFIGURACION"
            echo -e "Configuración actual:"
            echo -e "  Configuracion: $CONFIGURACION"
            if [ -n "$ARCHIVOS" ]; then
                echo -e "  Archivos: $ARCHIVOS"
            else
                echo -e "  Archivos: No especificados"
            fi
            if [ -n "$ENTRADA" ]; then
                echo -e "  Entrada: $ENTRADA"
            else
                echo -e "  Entrada: No especificado"
            fi
            if [ -n "$SALIDA" ]; then
                echo -e "  Salida: $SALIDA"
            else
                echo -e "  Salida: No especificado"
            fi
            if [ -n "$DIAS" ]; then
                echo -e "  Días: $DIAS"
            else
                echo -e "  Días: No especificado"
            fi
            if [ "$BORRAR" = true ]; then
                echo -e "  Borrar: Sí"
            else
                echo -e "  Borrar: No"
            fi
            if [ -n "$nombreprefijo" ]; then
                echo -e "  Nombre Prefijo: $nombreprefijo"
            else
                echo -e "  Nombre Prefijo: No especificado"
            fi
            if [ -n "$LOGFILE" ]; then
                echo -e "  Logfile: $LOGFILE"
            else
                echo -e "  Logfile: No especificado"
            fi
        else
            echo -e "Error: El archivo de configuración '$CONFIGURACION' no existe."
            exit 1
        fi
        ;;
    --version|-v)
        echo -e "Versión: $VERSION"
        exit 0
        ;;
    --verbose)
        set -x
        ;;
    *)
  esac
done



# Validación de argumentos
if [ -z "$ARCHIVOS" ] || [ -z "$SALIDA" ] || [ -z "$ENTRADA" ] || [ -z "$DIAS" ] ; then
  echo -e "Error: Los argumentos --archivos, --salida, --entrada y --dias son obligatorios."
  exit 1
fi

# Función para encontrar el siguiente número disponible para el archivo
obtener_numero_siguiente_archivo() {
    local nombreBase="backup_files_hasta_${DATE}"
    local contador=1

    while [[ -f "$SALIDA/${nombreBase}.${contador}.tar.gz" ]]; do
        ((contador++))
    done

    echo -e $contador
}


# Obtener el siguiente número de archivo disponible
file_number=$(obtener_numero_siguiente_archivo)
nombrearchivocomprimido="backup_files_hasta_${DATE}.${file_number}.tar.gz"

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
condiciones_archivos="$(echo -e "$ARCHIVOS" | sed 's/,/" -o -name "*./g' | sed 's/^/-name "*./' | sed 's/$/"/')"

## Ejecucion del script
find_cmd="find \"$ENTRADA\" -type f -mtime \"$DIAS\" \\( $condiciones_archivos \\)"
# find_cmd="find \"$ENTRADA\" -type f \\( $condiciones_archivos \\)"
# echo -e "Comando find: $find_cmd -print | grep -E \"/${nombreprefijo}[^/]*$\""
echo -e "Comando find: $find_cmd -print"

if [ -n "$nombreprefijo" ]; then
    files=$(eval "$find_cmd -print | grep -E \"/${nombreprefijo}[^/]*$\"")
else
    files=$(eval "$find_cmd -print")
fi

if [ -z "$files" ]; then
    if [ "$LOGFILE_PROVIDED" = true ]; then
        echo -e "\n[$(date +"%m/%d/%y %T")] Error: No se han encontrado archivos, no se comprimirá nada" >> "$LOGFILE"
    else
        echo -e "\n[$(date +"%m/%d/%y %T")] Error: No se han encontrado archivos, no se comprimirá nada"
    fi
    exit 1
fi

echo -e "\n[$(date +"%m/%d/%y %T")] Directorio antes de la compresión:"
find "${ENTRADA}" -name "${nombreprefijo}*" -print | sed "s|^${ENTRADA}||"

# Asegurarse de que el directorio de salida existe
mkdir -p "$SALIDA"

# Manejo del logfile
if [ "$LOGFILE_PROVIDED" = true ]; then
    echo -e "$files" | tr '\n' '\0' | xargs -0 tar -czf "$SALIDA/$nombrearchivocomprimido" >> "$LOGFILE" 2>&1
else
    echo -e "$files" | tr '\n' '\0' | xargs -0 tar -czf "$SALIDA/$nombrearchivocomprimido"
fi
tar_exit_code=$?

# Borrado de archivos si se especifica
if [ "$BORRAR" = true ]; then
    if [ "$LOGFILE_PROVIDED" = true ]; then
        echo -e "$files" | tr '\n' '\0' | xargs -0 rm -f >> "$LOGFILE" 2>&1
    else
        echo -e "$files" | tr '\n' '\0' | xargs -0 rm -f
    fi
    rm_exit_code=$?

    if [ $rm_exit_code -ne 0 ]; then
        if [ "$LOGFILE_PROVIDED" = true ]; then
            echo -e "\n[$(date +"%m/%d/%y %T")] Error: No se pudieron borrar los archivos. Codigo de error: $rm_exit_code" >> "$LOGFILE"
        else
            echo -e "\n[$(date +"%m/%d/%y %T")] Error: No se pudieron borrar los archivos. Codigo de error: $rm_exit_code"
        fi
        exit $rm_exit_code
    fi
fi


echo -e "\n[$(date +"%m/%d/%y %T")] directorio después de la compresión:"
find "${ENTRADA}" -name "${nombreprefijo}*" -print | sed "s|^${ENTRADA}||"

RUTA_COMPLETA=$(realpath "$SALIDA/$nombrearchivocomprimido")
if [ "$LOGFILE_PROVIDED" = true ]; then
    echo -e "\n[$(date +"%m/%d/%y %T")] Archivos comprimidos correctamente en \"$RUTA_COMPLETA\"" >> "$LOGFILE"
else
    echo -e "\n[$(date +"%m/%d/%y %T")] Archivos comprimidos correctamente en \"$RUTA_COMPLETA\""
fi
exit 0