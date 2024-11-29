#!/bin/bash

if [ -f .env ]; then
  export $(grep -v '^#' .env | grep -E '^[A-Za-z_][A-Za-z0-9_]*=' | xargs)
fi

echo "Starting host alert script"

log_file="$(pwd)/${LOG_FILE:-host_alert.log}"

send_telegram_message() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local url="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
  local data="{\"chat_id\": \"$CHAT_ID\", \"text\": \"[$timestamp] $1\", \"disable_notification\": true}"
  curl -X POST -H 'Content-Type: application/json' \
  -d  "$data" \
  "$url"
}

save_log() {
  echo "$1" >> "$log_file"
}

ping_to_host() {
  h=$(remove_protocol "$1")
  if ! ping -c 1 "$h" &> /dev/null; then
    send_telegram_message "[Alert] ping to host: $h is timeout"
    save_log "ping to host $h timeout"
  else
      save_log "ping to host $1 timeout"
  fi
}

detect_redirection() {
  # shellcheck disable=SC2155
  local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$1")
  echo "Response code: $response_code"
  if [ "$response_code" -ne 200 && "$response_code" -ne 000 ]; then
    send_telegram_message "[Alert] non-200 response: detected for $1 with code $response_code"
    ping_to_host "$1"
  fi
}

remove_protocol() {
  local url="$1"
  # shellcheck disable=SC2046
  # shellcheck disable=SC2005
  echo $(echo "$url" | sed -e 's/(https|http)\?:\/\///')
}

verify_or_create_log_file() {
  if [ ! -f "$log_file" ]; then
    touch "$log_file"
  fi
}

main() {
  verify_or_create_log_file
  local hosts=("${HOSTS}")

  #while true; do
    for host in "${hosts[@]}"; do
        IFS=',' read -r -a array <<< "$host"
        for element in "${array[@]}"; do
          echo "Checking host: $element"
          detect_redirection "$element"
        done
    done
  #  sleep 60
  #done
}

main
