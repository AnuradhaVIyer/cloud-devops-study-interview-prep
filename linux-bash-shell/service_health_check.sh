#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Checks whether given services are active and
#              enabled at boot. Accepts a space-separated list
#              of service names as arguments; defaults to
#              sshd, nginx, and cron if none are given.
# ============================================================

services="${*:-sshd nginx cron}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking services: $services"

for svc in $services; do
    active=$(systemctl is-active "$svc" 2>/dev/null)
    enabled=$(systemctl is-enabled "$svc" 2>/dev/null)
    echo "Service: $svc | Active: $active | Enabled: $enabled"

    if [ "$active" != "active" ]; then
        echo "CRITICAL: $svc is not active."
    fi

    if [ "$enabled" != "enabled" ]; then
        echo "WARNING: $svc is not enabled at boot."
    fi
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Service health check complete."
