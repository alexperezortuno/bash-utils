#!/bin/bash

send_telegram_message() {
   timestamp=$(date +"%Y-%m-%d %H:%M:%S")
   local url="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
   local data="{\"chat_id\": \"$CHAT_ID\", \"text\": \"[$timestamp] $1\", \"disable_notification\": true}"
   curl -X POST -H 'Content-Type: application/json' \
   -d  "$data" \
   "$url"
   logger -t host-alert "send_telegram_message: $1"
 }

 process_container_event() {
   local status="$1"
   local container_name="$2"
   local exit_code="$3"

   local message
    if [ "$status" == "start" ]; then
      message="Container $container_name started"
    elif [[ -z "$exit_code" ]] && [ "$exit_code" -eq 0 ]; then
      message="Container $container_name stopped"
    else
      message="Container $container_name stopped with exit code $exit_code"
    fi

    send_telegram_message "$message"
 }

docker events \
  --filter type=container \
  --filter event=die \
  --filter event=start \
  --format '{{.Status}} {{.Actor.Attributes.name}} {{.Actor.Attributes.exitCode}}' | \
while read -r status container_name exit_code; do
  process_container_event "$status" "$container_name" "$exit_code"
done