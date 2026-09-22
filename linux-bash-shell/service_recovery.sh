#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Checks a failed service, shows recent logs,
#              attempts a restart, and verifies it comes back
#              active. Accepts the service name as an argument.
# ============================================================

service="$1"

if [ -z "$service" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking status of $service..."
systemctl status "$service" --no-pager

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Recent logs for $service:"
journalctl -u "$service" -n 50 --no-pager

state=$(systemctl is-active "$service")
if [ "$state" == "active" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $service is already active. No action needed."
    exit 0
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restarting $service..."
systemctl restart "$service"
sleep 3

new_state=$(systemctl is-active "$service")
if [ "$new_state" == "active" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $service recovered successfully."
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CRITICAL: $service failed to restart (state: $new_state)."
    exit 2
fi
