# Resultados Esperados de los Ejemplos

Este documento explica los resultados que deberías obtener al ejecutar cada uno de los ejemplos del script `ejemplos_uso.sh`.

## Ejemplo 1: Comprimir todos los archivos .log y .txt
```bash
bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --logfile=./logs/ejemplo1.log
```

**Archivos que se comprimirán:**
- entrada/backup_20230101.log
- entrada/backup_20230102.log
- entrada/backup_20230103.log
- entrada/otro_20230104.log
- entrada/informe_enero.txt
- entrada/informe_febrero.txt
- entrada/datos_marzo.txt
- entrada/subdir1/backup_subdir1.log
- entrada/subdir1/informe_subdir1.txt
- entrada/subdir2/backup_subdir2.log

**Resultado esperado:**
- Se crea un archivo `backup_files_hasta_YYYYMMDD.tar.gz` en el directorio `./salida`
- El archivo comprimido contiene todos los archivos .log y .txt listados arriba
- En el log `./logs/ejemplo1.log` debe aparecer un mensaje confirmando que los archivos se comprimieron correctamente

## Ejemplo 2: Comprimir archivos que empiezan con "backup"
```bash
bash args.sh --archivos=log,txt --dias=30 --entrada=./entrada --salida=./salida --expresion=^backup --logfile=./logs/ejemplo2.log
```

**Archivos que se comprimirán:**
- entrada/backup_20230101.log
- entrada/backup_20230102.log
- entrada/backup_20230103.log
- entrada/subdir1/backup_subdir1.log
- entrada/subdir2/backup_subdir2.log

**Resultado esperado:**
- Se crea un archivo `backup_files_hasta_YYYYMMDD.tar.gz` en el directorio `./salida`
- El archivo comprimido contiene SOLAMENTE los archivos que empiezan con "backup"
- En el log `./logs/ejemplo2.log` debe aparecer un mensaje confirmando que los archivos se comprimieron correctamente y que se usó la expresión regular "^backup"

## Ejemplo 3: Comprimir archivos con patrón "informe" y borrarlos
```bash
bash args.sh --archivos=txt --dias=30 --entrada=./entrada --salida=./salida --expresion=informe --borrar --logfile=./logs/ejemplo3.log
```

**Archivos que se comprimirán y luego borrarán:**
- entrada/informe_enero.txt
- entrada/informe_febrero.txt
- entrada/subdir1/informe_subdir1.txt

**Resultado esperado:**
- Se crea un archivo `backup_files_hasta_YYYYMMDD.tar.gz` en el directorio `./salida`
- El archivo comprimido contiene SOLAMENTE los archivos .txt que contienen "informe" en el nombre
- Los archivos comprimidos son ELIMINADOS del directorio de origen
- En el log `./logs/ejemplo3.log` debe aparecer un mensaje confirmando que los archivos se comprimieron correctamente y que se usó la expresión regular "informe"

## Ejemplo 4: Comprimir archivos CSV con números en el nombre
```bash
bash args.sh --archivos=csv --dias=30 --entrada=./entrada --salida=./salida --expresion=[0-9] --logfile=./logs/ejemplo4.log
```

**Archivos que se comprimirán:**
- entrada/usuarios_2023.csv
- entrada/inventario_2023.csv
- entrada/subdir2/datos_subdir2.csv

**Resultado esperado:**
- Se crea un archivo `backup_files_hasta_YYYYMMDD.tar.gz` en el directorio `./salida`
- El archivo comprimido contiene SOLAMENTE los archivos .csv que tienen al menos un dígito en su nombre
- En el log `./logs/ejemplo4.log` debe aparecer un mensaje confirmando que los archivos se comprimieron correctamente y que se usó la expresión regular "[0-9]"

## Verificación de los resultados

Para verificar los resultados, puedes:

1. **Examinar los archivos comprimidos**:
   ```bash
   tar -tvf ./salida/backup_files_hasta_*.tar.gz
   ```
   Esto mostrará el contenido de cada archivo comprimido para confirmar que contiene exactamente los archivos esperados.

2. **Verificar que los archivos borrados ya no existen** (después del ejemplo 3):
   ```bash
   ls -la ./entrada/*informe*
   ```
   Deberías obtener un error indicando que los archivos no existen.

3. **Revisar los logs generados**:
   El ejemplo 5 muestra automáticamente el contenido de los logs, que deberían confirmar que cada operación se realizó correctamente.