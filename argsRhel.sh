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
        echo "  --borrar                 [Opcional] Especifica si se debe borrar los archivos a comprimir"
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
        echo "Argumento desconocido: $arg"
        exit 1
        ;;
  esac
done

# Validación de argumentos
if [ -z "$ARCHIVOS" ] || [ -z "$SALIDA" ] || [ -z "$ENTRADA" ] || [ -z "$DIAS" ]; then
  echo "Error: Los argumentos --archivos, --salida, --entrada y --dias son obligatorios."
  exit 1
fi

# Validación de directorios
if [ ! -d "$ENTRADA" ]; then
  echo "Error: El directorio de entrada '$ENTRADA' no existe."
  exit 1
fi

if [ ! -d "$SALIDA" ]; then
  echo "Creando directorio de salida '$SALIDA'..."
  mkdir -p "$SALIDA" || {
    echo "Error: No se pudo crear el directorio de salida '$SALIDA'."
    exit 1
  }
fi

# Validación de logfile
if [ -n "$LOGFILE" ]; then
  touch "$LOGFILE" || {
    echo "Error: No se pudo crear/editar el archivo de log '$LOGFILE'."
    exit 1
  }
  condiciones_logfile=">> \"$LOGFILE\" 2>&1"
fi

# Construcción de condiciones para find
IFS=',' read -ra EXT <<< "$ARCHIVOS"
condiciones_archivos=""
for ext in "${EXT[@]}"; do
  [ -n "$condiciones_archivos" ] && condiciones_archivos+=" -o"
  condiciones_archivos+=" -name \"*.$ext\""
done

# Creación del comando find
find_cmd="find \"$ENTRADA\" -type f -mtime -$DIAS \( $condiciones_archivos \) -print"

# Ejecución del script
echo "Comprimiendo archivos..." ${condiciones_logfile:+>> "$LOGFILE"}
eval "$find_cmd | zip -r \"$SALIDA/backup_files_hasta_${DATE}.zip\" -@ $condiciones_logfile"
zip_exit_code=$?

if [ $zip_exit_code -eq 0 ]; then
  echo "Compresión completada correctamente en $SALIDA/backup_files_hasta_${DATE}.zip" ${condiciones_logfile:+>> "$LOGFILE"}
else
  echo "Error durante la compresión (código $zip_exit_code). Verifique los permisos y espacio disponible." ${condiciones_logfile:+>> "$LOGFILE"}
  exit $zip_exit_code
fi

# Borrado de archivos si se especifica
if [ "$BORRAR" = true ]; then
  echo "Borrando archivos originales..." ${condiciones_logfile:+>> "$LOGFILE"}
  eval "$find_cmd -print0 | xargs -0 rm -f $condiciones_logfile"
  if [ $? -eq 0 ]; then
    echo "Borrado completado correctamente." ${condiciones_logfile:+>> "$LOGFILE"}
  else
    echo "Error durante el borrado de archivos." ${condiciones_logfile:+>> "$LOGFILE"}
    exit 1
  fi
fi

exit 0