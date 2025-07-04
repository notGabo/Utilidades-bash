# Ejemplo Práctico para el Script de Compresión

Este conjunto de scripts permite probar la funcionalidad del script `args.sh` para comprimir archivos y liberar espacio de forma automatizada, con especial énfasis en la nueva funcionalidad de expresión regular para filtrar por nombres de archivo.

## Archivos incluidos

- `args.sh`: El script principal de compresión
- `generar_archivos_prueba.sh`: Script para generar archivos de prueba con diversos nombres y patrones
- `ejemplos_uso.sh`: Script con ejemplos de uso del script principal

## Instrucciones de uso

1. Asegúrate de tener permisos de ejecución en los scripts:
   ```
   chmod +x args.sh generar_archivos_prueba.sh ejemplos_uso.sh
   ```

2. Ejecuta el script de ejemplos para ver diferentes casos de uso:
   ```
   bash ejemplos_uso.sh
   ```

3. Para ejecutar ejemplos específicos manualmente:

   - Comprimir todos los archivos .log y .txt:
     ```
     bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --logfile=./logs/manual.log
     ```

   - Comprimir solo los archivos que empiezan con "backup":
     ```
     bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --expresion=^backup --logfile=./logs/manual_regex.log
     ```

## Estructura de archivos generados para pruebas

El script `generar_archivos_prueba.sh` crea la siguiente estructura:

```
entrada/
├── backup_20230101.log
├── backup_20230102.log
├── backup_20230103.log
├── otro_20230104.log
├── informe_enero.txt
├── informe_febrero.txt
├── datos_marzo.txt
├── usuarios_2023.csv
├── inventario_2023.csv
├── subdir1/
│   ├── backup_subdir1.log
│   └── informe_subdir1.txt
└── subdir2/
    ├── backup_subdir2.log
    └── datos_subdir2.csv
```

## Funciones principales probadas

- Filtrado por extensión (--archivos)
- Filtrado por antigüedad (--dias)
- Filtrado por nombre usando expresiones regulares (--expresion)
- Comprimir archivos filtrados
- Borrar archivos después de comprimir (--borrar)