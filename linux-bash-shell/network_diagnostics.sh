#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Diagnoses connectivity to a target host using
#              ping, DNS lookup, port check, and traceroute.
#              Accepts the target host and optional port
#              (default 443) as arguments.
# ============================================================

target="$1"
port="${2:-443}"

if [ -z "$target" ]; then
    echo "Usage: $0 <host> [port]"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Resolving DNS for $target..."
getent hosts "$target"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pinging $target..."
ping -c 3 -W 2 "$target"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking port $port on $target..."
nc -z -w 3 "$target" "$port" && echo "Port $port is reachable." || echo "Port $port is not reachable."

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Route trace to $target:"
traceroute -w 2 -m 15 "$target" 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Network diagnostics complete."
