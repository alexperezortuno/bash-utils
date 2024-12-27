NAME=""
ABS_PATH="/"

function get_params() {
  while [[ $# -gt 0 ]]; do
      case "$1" in
          -n|--name) NAME="$2"; shift ;;
          -d|--directory) ABS_PATH="$2"; shift ;;
          -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -d, --directory: directory to search"
            echo "  -n, --name: folder name"
            echo "  -h, --help: display help"
            exit 0
            ;;
          \?) echo "Invalid option: -$2" >&2; exit 1 ;;
      esac
      shift
  done
}

get_params "$@"

find "$ABS_PATH" -type d -name "$NAME" -exec echo "remove: {}" \;
find "$ABS_PATH" -type d -name "$NAME" -exec rm -rf {} \;
exit 0
