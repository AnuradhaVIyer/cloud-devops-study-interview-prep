# DevOps Shell Scripting Automation

Author: Anuradha Iyer
Date: 2026-09-22

A set of standalone bash scripts automating common Linux system administration tasks — routine checks, user provisioning/offboarding, and troubleshooting. Each script is self-contained and can be run independently.

## Usage
Most scripts accept optional arguments with sensible defaults, and print timestamped log lines to stdout. Run with `-h` or no arguments to see usage where applicable:

```bash
./script_name.sh [arguments]
```

## Cost/impact note
`create_user.sh`, `offboard_user.sh`, `disk_full_response.sh`, and `service_recovery.sh` make actual changes to the system (create/lock accounts, revoke keys, restart services). Review before running on a production host.

## Script Index

| Script | Category | Description |
|---|---|---|
| [disk_usage_check.sh](disk_usage_check.sh) | Routine | Checks filesystem usage against a threshold and flags the largest space consumers. |
| [log_archive.sh](log_archive.sh) | Routine | Compresses logs into a timestamped archive and removes old logs past retention. |
| [patch_audit.sh](patch_audit.sh) | Routine | Reports pending OS/package updates and separates security updates from regular ones. Detection only. |
| [user_access_review.sh](user_access_review.sh) | Routine | Flags non-root UID 0 accounts, accounts with no password expiry, and stale SSH authorized_keys files. |
| [process_monitor.sh](process_monitor.sh) | Routine | Shows top CPU/memory-consuming processes and flags zombie processes. |
| [cron_audit.sh](cron_audit.sh) | Routine | Lists user and system crontabs and flags jobs pointing to missing scripts. |
| [service_health_check.sh](service_health_check.sh) | Routine | Checks whether given services are active and enabled at boot. |
| [create_user.sh](create_user.sh) | Provisioning | Creates a new user account with a home directory and a temporary password requiring change at first login. |
| [offboard_user.sh](offboard_user.sh) | Provisioning | Locks a departing user's account, revokes SSH keys, and archives the home directory. |
| [service_recovery.sh](service_recovery.sh) | Troubleshooting | Checks a failed service, shows recent logs, attempts a restart, and verifies recovery. |
| [disk_full_response.sh](disk_full_response.sh) | Troubleshooting | Reports the largest space consumers and files held open by deleted processes during a disk-full event. |
| [network_diagnostics.sh](network_diagnostics.sh) | Troubleshooting | Diagnoses connectivity to a target host via ping, DNS lookup, port check, and traceroute. |