# bash-utils

A collection of bash scripts that I use to make my life easier.

## open-callback-listener.sh

This script is used to open a callback listener on port 8080. It will listen for POST requests and print the request body to the console.

```bash
sudo chmod +x ./open-callback-listener.sh
```

## open-callback-listener
```bash
./open-callback-listener.sh
```

Test the callback listener by sending a POST request to the listener.

```bash
curl -X POST http://localhost:8081/callback -d "callback=success"
```

---