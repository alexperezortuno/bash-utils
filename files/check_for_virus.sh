#!/bin/bash
API_KEY=""

# Verificar si se proporciona un argumento (archivo o carpeta)
if [ -z "$1" ]; then
    echo "Usage: $0 <file_or_directory_path>"
    exit 1
fi

PATH_STR="$1"

# Carpetas a excluir (modifica esta lista si es necesario)
EXCLUDE_FOLDERS=".git .cache node_modules .idea"

# Archivo de salida donde se guardarán los hashes
HASH_FILES="hashes.txt"

# Limpiar el archivo si ya existe
> "$HASH_FILES"

# Si la ruta es un archivo, calcular su hash
if [ -f "$PATH_STR" ]; then
    HASH=$(sha256sum "$PATH_STR" | awk '{print $1}')
    echo "$HASH  $PATH_STR" >> "$HASH_FILES"
    echo "Calculated hash for file: $PATH_STR"

# Si la ruta es un directorio, calcular los hashes de todos los archivos dentro
elif [ -d "$PATH_STR" ]; then
    echo "Processing folder: $PATH_STR (excluding $EXCLUDE_FOLDERS)"

    # Construir la opción `-not -path` para excluir carpetas específicas
    EXCLUDE_ARGS=""
    for folder in $EXCLUDE_FOLDERS; do
        EXCLUDE_ARGS+=" -not -path \"$PATH_STR/$folder/*\""
    done

    echo "Excluding folders: $EXCLUDE_ARGS"

    eval find \"$PATH_STR\" -type f $EXCLUDE_ARGS | while read -r FILE_STR; do
        HASH=$(sha256sum "$FILE_STR" | awk '{print $1}')
        curl --request GET \
             --url https://www.virustotal.com/api/v3/files/$HASH \
             --header "accept: application/json" \
             --header "x-apikey: $API_KEY" | jq #.data.attributes.last_analysis_stats
        sleep 1
        echo "$HASH  $FILE_STR" >> "$HASH_FILES"
        echo "Calculated hashes: $FILE_STR"
    done

# Si la ruta no es válida, mostrar un error
else
    echo "Error: '$PATH_STR' no es un archivo ni una carpeta válida."
    exit 1
fi

echo "Hashes saved in $HASH_FILES"
exit 0