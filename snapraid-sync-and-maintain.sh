#!/bin/bash
# v0.2
set -euo pipefail # strict mode for bash

# -------------------------------------------------------------
# Configuration
# -------------------------------------------------------------
NTFY_TOPIC="https://ntfy.example.com/NAS"
MERGERFS_MOUNT="/mnt/data"

# -------------------------------------------------------------
# Check dependencies
# -------------------------------------------------------------
for cmd in snapraid smartctl curl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "❌ Required command not found: $cmd"
    exit 1
  }
done

# -------------------------------------------------------------
# A function that Sends ntfy notification and logs to journal
# -------------------------------------------------------------
notify() {
  local msg="$1"
  printf "%b" "$msg" | /usr/bin/curl -s -d @- "$NTFY_TOPIC" || true
  echo -e "$msg" # To also log to systemd journal
}

# Preventing concurent runs with a lockfile
LOCKFILE="/run/snapraid_maintenance.lock"
exec 9>"$LOCKFILE" || exit 1
flock -n 9 || {
  notify "❌ Another instance of SnapRAID maintenance script is already running."
  exit 0
}

# -------------------------------------------------------------
echo "=== SnapRAID maintenance script started $(date +"%F %T") ==="
SCRIPT_FAILED=false # variable to check if send success notification or not

# -------------------------------------------------------------
# Check if mergerfs mount point exists
# -------------------------------------------------------------
if ! mountpoint -q "$MERGERFS_MOUNT"; then
  notify "❌ mergerfs mount $MERGERFS_MOUNT not accessible!"
  exit 1
fi

# -------------------------------------------------------------
# Check if disks defined in SnapRAID config are mounted
# -------------------------------------------------------------
SNAPRAID_DATA_DISKS=$(grep '^disk' /etc/snapraid.conf | awk '{print $3}' || true)

if [[ -z "$SNAPRAID_DATA_DISKS" ]]; then
  notify "❌ No disks found in SnapRAID config!"
  exit 1
fi

for disk in $SNAPRAID_DATA_DISKS; do
  if ! mountpoint -q "$disk"; then
    notify "❌ SnapRAID disk not mounted: $disk!"
    exit 1
  fi
done

# -------------------------------------------------------------
# Do SnapRAID sync
# -------------------------------------------------------------
if ! sync_output=$(snapraid sync 2>&1); then
  notify "❌ SnapRAID sync failed:\n$sync_output"
  exit 1
fi

# -------------------------------------------------------------
# Do partial scrub, 15% of data once a month on the 1st
# -------------------------------------------------------------
if [[ $(date +%d) -eq 01 ]]; then
  if ! scrub_output=$(snapraid scrub -p 15 -o 180 2>&1); then
    notify "❌ SnapRAID scrub failed:\n$scrub_output"
    SCRIPT_FAILED=true
  fi
fi

# -------------------------------------------------------------
# SMART health check once a week on sunday
# -------------------------------------------------------------
if [[ $(date +%u) -eq 7 ]]; then
  SMART_DISKS=$(smartctl --scan | awk '{print $1}')
  for disk in $SMART_DISKS; do
    echo "$(date +"%F %T") Starting SMART check $disk"
    if ! smartctl -H "$disk" >/dev/null 2>&1; then
      MODEL=$(smartctl -i "$disk" | grep "Device Model" | cut -d: -f2 | xargs)
      notify "❌ SMART health check failed $disk ($MODEL)"
      SCRIPT_FAILED=true
    fi
  done
fi

# -------------------------------------------------------------
# SMART short test once a month on 10th
# -------------------------------------------------------------
if [[ $(date +%d) -eq 10 ]]; then
  SMART_DISKS=$(smartctl --scan | awk '{print $1}')
  for disk in $SMART_DISKS; do
    echo "$(date +"%F %T") Starting SMART short test $disk"
    smartctl -t short "$disk" >/dev/null 2>&1 || true
  done
  notify "🔍 Monthly SMART short tests started"

  sleep 600 # waiting 10 minutes for tests to finish

  ALL_PASSED=true
  for disk in $SMART_DISKS; do
    if ! smartctl -l selftest "$disk" | head -n 8 | grep -q "Completed without error"; then
      MODEL=$(smartctl -i "$disk" | grep "Device Model" | cut -d: -f2 | xargs)
      notify "❌ SMART short test failed: $disk ($MODEL)"
      ALL_PASSED=false
      SCRIPT_FAILED=true
    fi
  done

  if $ALL_PASSED; then
    notify "✅ All SMART short tests passed"
  fi
fi

# -------------------------------------------------------------
# SMART long test once every 4 months - april | august | december | 19th
# -------------------------------------------------------------
if [[ $(date +%d) -eq 19 ]] && ((10#$(date +%m) % 4 == 0)); then
  SMART_DISKS=$(smartctl --scan | awk '{print $1}')
  for disk in $SMART_DISKS; do
    echo "$(date +"%F %T") Starting SMART long test $disk"
    smartctl -t long "$disk" >/dev/null 2>&1 || true
  done
  notify "🔍 Triannual SMART long tests started, results in 2 days"
fi

# Results check 2 days later
if [[ $(date +%d) -eq 21 ]] && ((10#$(date +%m) % 4 == 0)); then
  SMART_DISKS=$(smartctl --scan | awk '{print $1}')
  ALL_PASSED=true
  for disk in $SMART_DISKS; do
    if ! smartctl -l selftest "$disk" | head -n 8 | grep -q "Completed without error"; then
      MODEL=$(smartctl -i "$disk" | grep "Device Model" | cut -d: -f2 | xargs)
      notify "❌ SMART long test failed: $disk ($MODEL)"
      ALL_PASSED=false
      SCRIPT_FAILED=true
    fi
  done

  if $ALL_PASSED; then
    notify "✅ All SMART long tests passed"
  fi
fi

# -------------------------------------------------------------
# Send success ntfy notification
# -------------------------------------------------------------
if ! $SCRIPT_FAILED; then
  notify "✅ SnapRAID sync and maintenance completed successfully $(date +"%F %T")"
fi
