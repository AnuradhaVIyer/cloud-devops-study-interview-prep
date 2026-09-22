#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Lists user and system crontabs and flags any
#              cron job that points to a script no longer
#              present on disk.
# ============================================================

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking user crontabs..."
for user in $(cut -f1 -d: /etc/passwd); do
    tab=$(crontab -l -u "$user" 2>/dev/null)
    if [ -n "$tab" ]; then
        echo "Crontab for $user:"
        echo "$tab"
        script_path=$(echo "$tab" | grep -oE '/[^ ]+\.(sh|py)\b')
        for path in $script_path; do
            if [ ! -f "$path" ]; then
                echo "MISSING SCRIPT: $path (user: $user)"
            fi
        done
    fi
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking system crontab and /etc/cron.d..."
for f in /etc/crontab /etc/cron.d/*; do
    [ -f "$f" ] || continue
    echo "Checking $f:"
    script_path=$(grep -oE '/[^ ]+\.(sh|py)\b' "$f")
    for path in $script_path; do
        if [ ! -f "$path" ]; then
            echo "MISSING SCRIPT: $path (file: $f)"
        fi
    done
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cron audit complete."
