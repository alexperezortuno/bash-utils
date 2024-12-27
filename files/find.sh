#!/bin/bash

SIZE_MORE_THAN=0
SIZE_LESS_THAN=0
SAVE=0
SIZE="1"
MEASURE="M"
ABS_PATH="/"
EXTENSION="*"
TIME=365

function get_params() {
  while [[ $# -gt 0 ]]; do
      case "$1" in
          -l|--lt) SIZE_LESS_THAN=1 ;;
          -m|--mt) SIZE_MORE_THAN=1 ;;
          --save) SAVE=1 ;;
          -s|--size) SIZE="$2"; shift ;;
          -r|--measure) MEASURE="$2"; shift ;;
          -d|--directory) ABS_PATH="$2"; shift ;;
          -e|--extension) EXTENSION="$2"; shift ;;
          -t|--time) TIME="$2"; shift ;;
          -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -l, --lt: size less than"
            echo "  -m, --mt: size more than"
            echo "  --save: save results to file"
            echo "  -s, --size: size in MB, use M for MB, G for GB, k for KB"
            echo "  -r, --measure: measure (K, M, G)"
            echo "  -d, --directory: directory to search"
            echo "  -e, --extension: file extension"
            echo "  -h, --help: display help"
            exit 0
            ;;
          \?) echo "Invalid option: -$2" >&2; exit 1 ;;
      esac
      shift
  done
}

get_params "$@"

# find /mnt/d -type f -size +10k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'

if [ $SIZE_MORE_THAN -eq 1 ]; then
  if [ "$SAVE" -eq 1 ]; then
    find "$ABS_PATH" -type f -size +"$SIZE""$MEASURE" -mtime -"$TIME" -name "*.$EXTENSION" > results.txt
  else
    find "$ABS_PATH" -type f -size +"$SIZE""$MEASURE" -mtime -"$TIME" -name "*.$EXTENSION"
  fi
elif [ $SIZE_LESS_THAN -eq 1 ]; then
  if [ "$SAVE" -eq 1 ]; then
    find "$ABS_PATH" -type f -size -"$SIZE""$MEASURE" -mtime -"$TIME" -name "*.$EXTENSION" > results.txt
  else
    find "$ABS_PATH" -type f -size -"$SIZE""$MEASURE" -mtime -"$TIME" -name "*.$EXTENSION"
  fi
fi
