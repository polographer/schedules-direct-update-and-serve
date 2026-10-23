#!/bin/bash

XMLTV_CONFIG="$HOME/.xmltv/tv_grab_zz_sdjson.conf"

# Store environment variables for cron runs
printenv > /etc/environment

# ------------------------------------------------------------------
# First-run: interactive configuration
# ------------------------------------------------------------------
if [ ! -f "${XMLTV_CONFIG}" ]; then
  echo "No configuration found. Running initial setup..."
  echo ""
  /usr/bin/tv_grab_zz_sdjson --configure </dev/null
  echo ""
  echo "Configuration complete. Start the service with:"
  echo "  docker compose up -d"
  exit 0
fi

# ------------------------------------------------------------------
# Normal operation: fetch schedules and serve via nginx
# ------------------------------------------------------------------

# Clean cache so we get fresh data
rm -f /var/www/html/tv_grab_zz_sdjson.cache || true

# Start cron
crontab /etc/cron.d/tvgrab-cron
service cron start

# Initial run of the grab command
echo "$(date '+%Y-%m-%d %H:%M:%S') - [INITIAL SYNC] Starting Schedules Direct data fetch..."
/fetch_json.sh
echo "$(date '+%Y-%m-%d %H:%M:%S') - [INITIAL SYNC] Completed Schedules Direct data fetch"

# Set up log rotation for cron.log
cat > /etc/logrotate.d/cron << 'EOF'
/var/log/cron.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}
EOF

# Start nginx in foreground
nginx -g 'daemon off;'
