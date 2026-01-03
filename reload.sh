#!/bin/bash
# Reload Flutter web app - kills existing process and restarts fresh

# Kill any process on port 3000
fuser -k 3000/tcp 2>/dev/null && echo "Killed existing process on port 3000" && sleep 2

# Start Flutter web server
cd "$(dirname "$0")"
flutter run -d web-server --web-port=3000 --web-hostname=0.0.0.0
