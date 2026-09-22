#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: This script checks the disk usage of the system,
# log it and sends an email alert if the usage exceeds a 
# specified threshold.
# ============================================================

THRESHOLD_START=80
THRESHOLD_END=90
EMAIL="info@example.com"
LOG_FILE="disk_usage.log"

# check if the log file exists, if not create it
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

current_usage=$(df -h / | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 }' | cut -d'%' -f1)  

if [ "$current_usage" -lt "$THRESHOLD_START" ]; then
    echo "INFO: Disk usage is normal. Current usage: $current_usage%"
    echo "INFO: Disk usage is normal. Current usage: $current_usage%" >> $LOG_FILE
    
elif [ "$current_usage" -ge "$THRESHOLD_START" ] && [ "$current_usage" -lt "$THRESHOLD_END" ]; then
    echo "WARNING: Disk usage is above $THRESHOLD_START%. Current usage: $current_usage%" 
    echo "WARNING: Disk usage is above $THRESHOLD_START%. Current usage: $current_usage%" >> $LOG_FILE
    echo "WARNING: Disk usage is above $THRESHOLD_START%. Current usage: $current_usage%" | mail -s "Disk Usage Warning Alert" $EMAIL
elif [ "$current_usage" -ge "$THRESHOLD_END" ]; then
    echo "CRITICAL: Disk usage is above $THRESHOLD_END%. Current usage: $current_usage%"
    echo "CRITICAL: Disk usage is above $THRESHOLD_END%. Current usage: $current_usage%" >> $LOG_FILE
    echo "CRITICAL: Disk usage is above $THRESHOLD_END%. Current usage: $current_usage%" | mail -s "Disk Usage Critical Alert" $EMAIL
fi
