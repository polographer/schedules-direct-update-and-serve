# Schedules Direct XMLTV Docker Service

This project provides a Docker container that automatically fetches TV schedule data from [Schedules Direct](https://www.schedulesdirect.org/) on a schedule, converts it to XMLTV format, and serves it via HTTP for use with various home media applications.

This is particularly useful to connect Schedules Direct with [Threadfin](https://github.com/Threadfin/Threadfin).

The Docker image is published to the [GitHub Container Registry](https://ghcr.io/polographer/schedules-direct-update-and-serve).

## Features

- Automatically fetches TV listings from Schedules Direct
- Converts listings to XMLTV format compatible with media center software
- Serves the XMLTV file via HTTP
- Periodically updates the listings data
- Runs in a Docker container for simple deployment

## Configuration

### Docker Compose

```yaml
services:
  xmltv:
    image: ghcr.io/polographer/schedules-direct-update-and-serve:latest
    environment:
      - TZ=America/New_York
    container_name: xmltv
    ports:
      - "51969:80"
    volumes:
      - xmltv_data:/var/www/html
      - xmltv_config:/root/.xmltv
    restart: unless-stopped

volumes:
  xmltv_data:
    name: xmltv_data
  xmltv_config:
    name: xmltv_config
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| TZ | Timezone (default: UTC. Since it runs every day at midnight, choose a TZ where that is the time you want it to run.) |
| SD_CRON_SCHEDULE | Cron schedule for fetching data (default: `0 0 * * *` — midnight daily). Format: `minute hour dom month dow` |

### Volumes

The Docker Compose configuration creates two volumes:
- `xmltv_data` — stores the fetched XMLTV data (`/var/www/html`)
- `xmltv_config` — stores the grabber config and cache (`/root/.xmltv`)

## Quick Start

### First run (interactive setup)

Run the container interactively to configure your lineups:

```bash
docker compose run --rm -it xmltv
```

This runs the `tv_grab_zz_sdjson` configuration wizard where you:
1. Enter your Schedules Direct username and password
2. Add a lineup — type `add`, enter your country (e.g., `USA`), then your zip code (e.g., `20171`), and pick a lineup from the list
3. Select mode (`lineup`) and choose which lineups to use
4. The config file is saved to `/root/.xmltv/` (persisted via volume)

> **Note:** Lineups must be added through the grabber wizard, not the Schedules Direct website. The website lineup management does not sync with the JSON API.

### Normal run (background)

After the first run, start the service in the background:

```bash
docker compose up -d
```

## Usage

Once running, the XMLTV file is available at:

```bash
http://your-server-ip:51969/tvxml.xml
```

You can use this URL in your media center software (such as Threadfin, Plex, Emby, Jellyfin, TVHeadend, etc.) as the source for your TV guide data.

## Troubleshooting

### Re-run the interactive setup

If you need to change your lineups or credentials, remove the config file and re-run the wizard:

```bash
# Remove the config file from the volume
docker compose run --rm -it debian:trixie-slim rm -f /root/.xmltv/tv_grab_zz_sdjson.conf

# Re-run the interactive setup
docker compose run --rm -it xmltv
```

Or remove the volumes entirely for a clean slate:

```bash
docker compose down
docker volume rm xmltv_data xmltv_config
docker compose run --rm -it xmltv
```

### "Lineup X in the current configuration is not enabled on your account"

Re-run the interactive setup to add the correct lineups:

```bash
docker compose run --rm -it xmltv
```

### Container exits with error

Check the logs for details:

```bash
docker logs xmltv
```

Common causes:
- Invalid username/password
- Lineup IDs don't match your account
- Schedules Direct API is down

## Development

### Development Setup

Build and run locally:

```bash
docker compose -f docker-compose.dev.yaml up
```

This:
- Builds from the local `Dockerfile`
- Mounts `start.sh` and `fetch_json.sh` for live editing
- Exposes port **51970** (instead of 51969)
- Uses separate volumes so it doesn't conflict with production

### First run in development

```bash
docker compose -f docker-compose.dev.yaml run --rm -it xmltv
```

### Making Changes

1. Edit `start.sh` or `fetch_json.sh` — changes are reflected immediately (no rebuild needed)
2. Restart the container to pick up changes:

   ```bash
   docker compose -f docker-compose.dev.yaml restart
   ```

3. View logs:

   ```bash
   docker compose -f docker-compose.dev.yaml logs -f
   ```

### Building the Production Image

```bash
docker build -t ghcr.io/polographer/schedules-direct-update-and-serve:latest .
```

Or let GitHub Actions handle it by pushing to `main`/`master`.

## Acknowledgements

This project uses the `tv_grab_zz_sdjson` tool to interact with the Schedules Direct API.
