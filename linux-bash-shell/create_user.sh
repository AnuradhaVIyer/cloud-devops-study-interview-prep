#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Creates a new user account with a home directory
#              and a temporary password that must be changed at
#              first login. Accepts username and optional group
#              as arguments.
# ============================================================

username="$1"
group="$2"

if [ -z "$username" ]; then
    echo "Usage: $0 <username> [group]"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating user $username..."

if [ -n "$group" ]; then
    getent group "$group" >/dev/null || groupadd "$group"
    useradd -m -s /bin/bash -g "$group" "$username"
else
    useradd -m -s /bin/bash "$username"
fi

temp_password=$(openssl rand -base64 12)
echo "${username}:${temp_password}" | chpasswd
chage -d 0 "$username"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] User $username created with temporary password: $temp_password"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Password change will be required at first login."
