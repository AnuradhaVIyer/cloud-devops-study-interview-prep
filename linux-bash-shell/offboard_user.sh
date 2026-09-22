#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Offboards a departing user — locks the account,
#              revokes SSH keys, and archives the home directory.
#              Accepts the username as an argument.
# ============================================================

username="$1"
archive_dir="/var/backups/offboarded_users"

if [ -z "$username" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

home_dir=$(getent passwd "$username" | cut -d: -f6)

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Locking account $username..."
usermod -L "$username"

key_file="$home_dir/.ssh/authorized_keys"
if [ -f "$key_file" ]; then
    mv "$key_file" "${key_file}.revoked.$(date +%Y%m%d)"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Revoked SSH keys for $username."
fi

mkdir -p "$archive_dir"
if [ -d "$home_dir" ]; then
    tar -czf "$archive_dir/${username}_$(date +%Y%m%d).tar.gz" -C "$(dirname "$home_dir")" "$(basename "$home_dir")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Archived home directory to $archive_dir/${username}_$(date +%Y%m%d).tar.gz"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Offboarding of $username complete."
