SIZE_MORE_THAN=0
SIZE_LESS_THAN=0
SIZE="1"
MEASURE="M"
ABS_PATH="/"

function get_params() {
  while [[ $# -gt 0 ]]; do
      case "$1" in
          -l|--lt) SIZE_LESS_THAN=1 ;;
          -m|--mt) SIZE_MORE_THAN=1 ;;
          -s|--size) SIZE="$2" ;;
          -r|--measure) MEASURE="$2"; shift ;;
          -f|--absolute_path) ABS_PATH="$2"; shift ;;
          \?) echo "Invalid option: -$2" >&2; exit 1 ;;
      esac
      shift
  done
}

get_params "$@"

# find /mnt/d -type f -size +10k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'

if [ $SIZE_MORE_THAN -eq 1 ]; then
  find "$ABS_PATH" -type f -size +"$SIZE""$MEASURE"
elif [ $SIZE_LESS_THAN -eq 1 ]; then
  find "$ABS_PATH" -type f -size -"$SIZE""$MEASURE"
fi
