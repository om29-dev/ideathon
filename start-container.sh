#!/bin/sh

# Start backend server in background
cd /backend
python3 main.py &

# Start nginx in foreground
nginx -g "daemon off;"
