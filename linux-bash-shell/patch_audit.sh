#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: Checks for pending OS/package updates and shows
#              how many are security updates. Detection only —
#              does not install anything.
# ============================================================

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for pending updates..."

if command -v apt-get >/dev/null 2>&1; then
    apt-get -s upgrade > /tmp/updates.txt 2>/dev/null
    total=$(grep -c '^Inst' /tmp/updates.txt)
    security=$(grep -ci 'security' /tmp/updates.txt)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Total pending updates: $total"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Security updates: $security"
    grep '^Inst' /tmp/updates.txt
    rm -f /tmp/updates.txt

elif command -v dnf >/dev/null 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Security updates:"
    dnf -q updateinfo list security
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] All pending updates:"
    dnf -q check-update

else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No supported package manager found (apt/dnf)."
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Patch audit complete."
