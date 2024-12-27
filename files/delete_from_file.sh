#!/bin/bash

# File with the paths of the files to delete
FILE="results.txt"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "the file $FILE does not exist"
    exit 1
fi

# Read each line of the file and delete the corresponding file
while IFS= read -r line; do
    if [ -f "$line" ]; then
        echo "remove file: $line"
        rm "$line"
    else
        echo "the file does not exist: $line"
    fi
done < "$FILE"

echo "finished deleting files"
exit 0
