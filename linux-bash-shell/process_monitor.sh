#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Shows top CPU and memory consuming processes and
#              flags zombie processes. Accepts CPU% and memory%
#              alert thresholds as optional arguments.
# ============================================================

cpu_threshold="${1:-90}"
mem_threshold="${2:-80}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Top 5 CPU-consuming processes:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Top 5 memory-consuming processes:"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for zombie processes..."
ps -eo pid,ppid,stat,comm | awk '$3 ~ /^Z/'

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for processes over $cpu_threshold% CPU or $mem_threshold% memory..."
ps -eo pid,comm,%cpu,%mem --no-headers | awk -v c="$cpu_threshold" -v m="$mem_threshold" '$3+0 > c || $4+0 > m'

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Process monitoring complete."
