# host-alerts

## Description

This script is used to send alerts to telegram when a specific log message is found in the log file.

## usage

```bash
cd bash-utils
sudo chmod +x ./host-alert.sh
./host-alert.sh
```

## How to get ChatId

use curl to get the chat id

```bash
curl https://api.telegram.org/bot<YourBotToken>/getUpdates
```