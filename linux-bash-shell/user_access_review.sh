#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Reviews local accounts for risky configurations —
#              non-root UID 0 accounts, missing password expiry,
#              and old SSH authorized_keys files. Accepts the
#              max SSH key age (in days) as an optional argument.
# ============================================================

ssh_key_max_age="${1:-90}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for non-root UID 0 accounts..."
awk -F: '($3 == 0 && $1 != "root") {print $1}' /etc/passwd

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for accounts with no password expiry..."
for user in $(cut -f1 -d: /etc/passwd); do
    max_days=$(chage -l "$user" 2>/dev/null | grep "Maximum number of days" | awk -F': ' '{print $2}')
    if [ "$max_days" == "-1" ]; then
        echo "No expiry set: $user"
    fi
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking SSH keys older than $ssh_key_max_age days..."
for home_dir in /home/*; do
    key_file="$home_dir/.ssh/authorized_keys"
    if [ -f "$key_file" ]; then
        age_days=$(( ( $(date +%s) - $(stat -c %Y "$key_file") ) / 86400 ))
        if [ "$age_days" -gt "$ssh_key_max_age" ]; then
            echo "Stale key ($age_days days old): $key_file"
        fi
    fi
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] User and access review complete."
