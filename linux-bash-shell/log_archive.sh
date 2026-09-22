#!/bin/bash

#!/usr/bin/env bash
# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description: This tool runs from the command line, accept the 
#              log folder and log archive folder as arguments, 
#              compresses the logs, and stores them in a log 
#              archive folder. Default to log_folder and 
#              log_archive_folder if not provided.
# ============================================================

# Assign arguments or fall back to default values
log_folder="${1:-log_folder}"
log_archive_folder="${2:-log_archive_folder}"

# Ensure directories exist
mkdir -p "$log_folder"
mkdir -p "$log_archive_folder"

echo "Compressing logs from $log_folder to $log_archive_folder..."

# Compress the logs into a timestamped tarball
tar -czf "$log_archive_folder/logs_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$log_folder" .

# Safely delete files older than 15 days in the log folder
find "$log_folder" -type f -mtime +15 -delete

echo "Logs compressed and old logs deleted successfully."



