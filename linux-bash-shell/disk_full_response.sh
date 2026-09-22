#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Helps respond to a disk-full event by showing
#              the largest space consumers and files still held
#              open by deleted processes. Report only — accepts
#              the path to scan as an optional argument.
# ============================================================

target_path="${1:-/}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Disk usage overview:"
df -h

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Top 10 largest directories under $target_path:"
du -x -h "$target_path" 2>/dev/null | sort -rh | head -n 10

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Files deleted but still held open by a process:"
lsof +L1 2>/dev/null | awk 'NR==1 || $0 ~ /deleted/'

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Report complete. Review above before manually deleting anything."
