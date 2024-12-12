FROM=""
TO=""
SUBJECT=""
BODY=""

function load_env_file() {
    source .env
}

function get_params() {
    while getopts "f:t:s:b:" opt; do
        case $opt in
            f) FROM=$OPTARG ;;
            t) TO=$OPTARG ;;
            s) SUBJECT=$OPTARG ;;
            b) BODY=$OPTARG ;;
            \?) echo "Invalid option: -$OPTARG" >&2 ;;
        esac
    done
}

load_env_file
get_params "$@"

curl -s --user "api:${MAILGUN_API}" \
    https://api.mailgun.net/v3/${MAILGUN_DOMAIN}/messages \
    -F from="${FROM}" \
    -F to="${TO}" \
    -F subject="${SUBJECT}" \
    -F text="${BODY}"
