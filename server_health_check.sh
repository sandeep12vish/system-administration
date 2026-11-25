
#!/usr/bin/env bash
# server_health_check.sh
# Checks disk usage, memory, load average, and key services.
# Logs results to a file and prints warnings for anything over threshold.
# Usage: sudo ./server_health_check.sh

set -u

LOG_FILE="/var/log/server_health.log"
DISK_THRESHOLD=80          # percent
MEM_THRESHOLD=85           # percent
LOAD_THRESHOLD=$(nproc)    # 1-minute load above CPU count triggers a warning
SERVICES=("sshd" "cron" "nginx")   # adjust to services on your server

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
    echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

warn() {
    log "WARNING: $1"
}

check_disk() {
    df -P -x tmpfs -x devtmpfs | awk 'NR>1 {print $5, $6}' | while read -r usage mount; do
        pct=${usage%\%}
        if [ "$pct" -ge "$DISK_THRESHOLD" ]; then
            warn "Disk usage on $mount is ${pct}%"
        else
            log "OK: Disk usage on $mount is ${pct}%"
        fi
    done
}

check_memory() {
    total=$(free -m | awk '/^Mem:/ {print $2}')
    used=$(free -m | awk '/^Mem:/ {print $3}')
    pct=$(( used * 100 / total ))
    if [ "$pct" -ge "$MEM_THRESHOLD" ]; then
        warn "Memory usage is ${pct}%"
    else
        log "OK: Memory usage is ${pct}%"
    fi
}

check_load() {
    load=$(awk '{print $1}' /proc/loadavg)
    if awk -v l="$load" -v t="$LOAD_THRESHOLD" 'BEGIN {exit !(l > t)}'; then
        warn "1-minute load average is $load (CPUs: $LOAD_THRESHOLD)"
    else
        log "OK: Load average is $load"
    fi
}

check_services() {
    for svc in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            log "OK: Service $svc is running"
        else
            warn "Service $svc is NOT running"
        fi
    done
}

log "===== Health check started on $(hostname) ====="
check_disk
check_memory
check_load
check_services
log "===== Health check finished ====="
