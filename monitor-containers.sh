#!/bin/bash
LOCKFILE="/tmp/monitor-containers.lock"

# verify if the script is already running
if [ -e "$LOCKFILE" ]; then
    echo "the script is already running"
    exit 1
fi

touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

load_env_file() {
  # Get the directory of the script
  script_dir=$(dirname "$0")

  if [ -f "$script_dir/.env" ]; then
    export "$(grep -v '^#' "$script_dir/.env" | grep -E '^[A-Za-z_][A-Za-z0-9_]*=' | xargs)"
  fi
}

send_telegram_message() {
   timestamp=$(date +"%Y-%m-%d %H:%M:%S")
   local url="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
   local data="{\"chat_id\": \"$CHAT_ID\", \"text\": \"[$timestamp] $1\", \"disable_notification\": true}"
   curl -X POST -H 'Content-Type: application/json' \
   -d  "$data" \
   "$url"
   logger -t monitor-containers "send_telegram_message: $1"
}

# Path to the log file
LOG_FILE="/tmp/docker_container_monitor.log"
# File where the list of active containers to monitor will be saved
HISTORY_FILE="/tmp/docker_container_history.txt"

# Initialize the history file if it does not exist
initialize_history() {
    if [ ! -f "$HISTORY_FILE" ]; then
        logger -t monitor-containers "$(date +'%Y-%m-%d %H:%M:%S') - Initializing history of active containers" >> "$LOG_FILE"
        docker ps --format "{{.ID}} {{.Names}}" > "$HISTORY_FILE"
    fi
}

# Function to update the history if new active containers are detected
update_history() {
    current_containers=$(docker ps --format "{{.ID}} {{.Names}}")

    while IFS= read -r line; do
        container_id=$(echo "$line" | awk '{print $1}')
        container_name=$(echo "$line" | awk '{print $2}')

        # If the container is not in the history, add it and log it
        if ! grep -q "$container_id" "$HISTORY_FILE"; then
            echo "$line" >> "$HISTORY_FILE"
            logger -t monitor-containers "$line"
            echo "$(date +'%Y-%m-%d %H:%M:%S') - New container detected: $container_name ($container_id) added to history" >> "$LOG_FILE"
            logger -t monitor-containers "$(date +'%Y-%m-%d %H:%M:%S') - New container detected: $container_name ($container_id) added to history"
        fi
    done <<< "$current_containers"
}

# Function to check the status of the containers in the history
check_containers() {
    stopped_containers=""

    while IFS= read -r line; do
        container_id=$(echo "$line" | awk '{print $1}')
        container_name=$(echo "$line" | awk '{print $2}')

        # Check if the container is in "exited" state
        if [ "$(docker inspect -f '{{.State.Status}}' "$container_id")" = "exited" ]; then
            send_telegram_message "Container $container_name stopped"
            stopped_containers+="$container_id $container_name\n"
        fi
    done < "$HISTORY_FILE"

    if [ -n "$stopped_containers" ]; then
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') - Stopped containers found:\n$stopped_containers" >> "$LOG_FILE"
        logger -t monitor-containers "$(date +'%Y-%m-%d %H:%M:%S') - Stopped containers found:\n$stopped_containers"
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - All containers in the history are running correctly" >> "$LOG_FILE"
        logger -t monitor-containers "$(date +'%Y-%m-%d %H:%M:%S') - All containers in the history are running correctly"
    fi
}

# Initialize the history on the first run
initialize_history
# Update history with new containers
update_history
# Check the status of the containers in the history
check_containers
exit 0