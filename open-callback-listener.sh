#!/bin/bash

# Configuration
PORT=${2:-8080}
PORT_CALLBACK=${3:-8081}
CALLBACK_URL="http://localhost:$PORT_CALLBACK/callback"
URL_TO_OPEN=${1:-"http://localhost:$PORT"}
HTML_FILE="index.html"
OPEN_URL="$URL_TO_OPEN?callback_url=$CALLBACK_URL"

# Create a simple HTML file with the message
cat <<EOL > $HTML_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Callback Page</title>
</head>
<body>
    <h1>Welcome!</h1>
    <p>This is your custom message.</p>
    <p>Waiting for a callback at: <strong>$CALLBACK_URL</strong></p>
</body>
</html>
EOL

# Start a simple web server to serve the HTML
echo "Starting server on port $PORT..."

# Detect Python version
if command -v python3 &>/dev/null; then
  PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
  PYTHON_CMD="python"
else
  echo "Python is not installed."
  exit 1
fi

$PYTHON_CMD -m http.server $PORT & SERVER_PID=$!

# Open the URL in the browser
echo "Opening URL: $OPEN_URL"
open_by_os() {
  case "$OSTYPE" in
    linux* | freebsd*)
      xdg-open "$1" &
    ;;
    darwin*)
      open "$1" &
    ;;
    cygwin* | msys* | win32*)
      start "$1" &
    ;;
    *)
      echo "Unknown OS: $OSTYPE"
      exit 1
    ;;
  esac
}
open_by_os "$OPEN_URL"

# Start a local server to wait for the callback
echo "Waiting for callback in $CALLBACK_URL..."
while true; do
    # Listen on the callback port and capture the callback
    RESPONSE=$(nc -l -p "$PORT_CALLBACK" -q 1)
    echo "Callback received: $RESPONSE"

    # Process the callback response
    if [[ "$RESPONSE" =~ "callback" ]]; then
        echo "Callback processed successfully."
        break
    else
        echo "Waiting for a valid response..."
    fi
done

# Clean up
kill $SERVER_PID
rm $HTML_FILE
echo "Finished script."
