FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    cron \
    curl \
    nginx \
    python3 \
    xmltv-util \
    && rm -rf /var/lib/apt/lists/*

# Set default values
ENV SD_FETCH_DAYS 2

# Create log file for cron
RUN touch /var/log/cron.log && chmod 0666 /var/log/cron.log

# Set up cron to refresh from schedules direct
COPY tvgrab-cron /etc/cron.d/tvgrab-cron
RUN chmod 0644 /etc/cron.d/tvgrab-cron

# Create an entrypoint script to generate the config with the password
COPY index.nginx-debian.html /var/www/html/index.html
COPY start.sh /start.sh
COPY fetch_json.sh /fetch_json.sh
RUN chmod +x /start.sh /fetch_json.sh

# Set the entrypoint
ENTRYPOINT ["/start.sh"]
