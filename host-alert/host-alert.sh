#!/bin/bash

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "Starting host alert script"

log_file="$(pwd)/${LOG_FILE:-host_alert.log}"

send_telegram_message() {
  local url="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
  local data="{\"chat_id\": \"$CHAT_ID\", \"text\": \"$1\", \"disable_notification\": true}"
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
    send_telegram_message "[Alert] Host: $h is down"
    save_log "Host $h is down"
  else
      save_log "Host $1 is up"
  fi
}

detect_redirection() {
  # shellcheck disable=SC2155
  local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$1")

  if [ "$response_code" -ne 200 ]; then
    send_telegram_message "[Alert] Non-200 response: detected for $1 with code $response_code"
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
  local hosts=("https://ossaycia.cl" "https://glign.com")

  while true; do
    for host in "${hosts[@]}"; do
        detect_redirection "$host"
    done
    sleep 60
  done
}

main