#!/bin/bash
logger_logfile=/var/log/spindown-state.log
logger_statefile=/var/lib/disks-spin.state
logger_summary=/var/log/spindown-summary.log
DATE=$(date +"%Y-%m-%d %H:%M:%S")
DAY=$(date +"%Y-%m-%d")

mkdir -p /var/lib

for dev in /dev/sd[a-z]; do
  CURR_STATE=$(hdparm -C "$dev" 2>/dev/null | awk '/drive state/ {print $NF}')
  [[ -z "$CURR_STATE" ]] && continue

  PREV_STATE=$(awk -v d="$dev" '$1==d {print $2}' "$logger_statefile" 2>/dev/null)

  if [[ "$CURR_STATE" != "$PREV_STATE" ]]; then
    echo "$DATE $dev $CURR_STATE" >>"$logger_logfile"

    case "$CURR_STATE" in
    active* | idle*)
      EVENT="SPINUP"
      ;;
    standby)
      EVENT="SPINDOWN"
      ;;
    *)
      EVENT=""
      ;;
    esac

    if [[ -n "$EVENT" ]]; then
      awk -v dev="$dev" -v day="$DAY" -v event="$EVENT" '
                BEGIN {found=0}
                {
                    if ($1==day && $2==dev) {
                        if (event=="SPINUP")   $3++
                        if (event=="SPINDOWN") $4++
                        found=1
                    }
                    print
                }
                END {
                    if (!found) {
                        up=(event=="SPINUP")?1:0
                        down=(event=="SPINDOWN")?1:0
                        print day, dev, up, down
                    }
                }
            ' "$logger_summary" 2>/dev/null >"$logger_summary.tmp"
      mv "$logger_summary.tmp" "$logger_summary"

      if ! grep -q "^DATE" "$logger_summary"; then
        sed -i '1iDATE DEVICE SPINUPS SPINDOWNS' "$logger_summary"
      fi

    fi

    grep -v "^$dev " "$logger_statefile" 2>/dev/null >"$logger_statefile.tmp"
    echo "$dev $CURR_STATE" >>"$logger_statefile.tmp"
    mv "$logger_statefile.tmp" "$logger_statefile"
  fi
done
