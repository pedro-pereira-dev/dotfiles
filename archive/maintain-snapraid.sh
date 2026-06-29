#!/bin/bash
set -euo pipefail

snapraid_lockfile=/run/maintain-snapraid.lock
snapraid_maintenance_lock_fd=9
snapraid_logfile=/var/log/maintain-snapraid.log

log_message() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$snapraid_logfile"; }

! command -v snapraid >/dev/null 2>&1 && log_message 'snapraid not found' && exit 1
! exec {snapraid_maintenance_lock_fd}>"$snapraid_lockfile" && exit 1
! flock -n "$snapraid_maintenance_lock_fd" && log_message 'Another instance is running' && exit 0

log_message 'Starting snapraid maintenance'
snapraid sync 2>&1 | tee -a "$snapraid_logfile" || true
snapraid scrub 2>&1 | tee -a "$snapraid_logfile" || true
snapraid status 2>&1 | tee -a "$snapraid_logfile" || true
log_message 'Completed snapraid maintenance'
