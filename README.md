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

## Quick Start

Deploy with Docker Compose. Create a `docker-compose.yaml` with the following:

```yaml
services:
  xmltv:
    image: ghcr.io/polographer/schedules-direct-update-and-serve:latest
    environment:
      - SD_USERNAME=${SCHEDULES_DIRECT_USERNAME}
      - SD_PASSWORD=${SCHEDULES_DIRECT_PASSWORD}
      - SD_LINEUPS=USA-0000001-CUSTOM,USA-DITV505-X,USA-MI21464-X,USA-YOUTUBE-X
      - TZ=America/New_York
    container_name: xmltv
    ports:
      - "51969:80"
    volumes:
      - xmltv_data:/var/www/html
    restart: unless-stopped

volumes:
  xmltv_data:
```

Create a `.env` file with your Schedules Direct credentials:

```bash
SCHEDULES_DIRECT_USERNAME=your_username
SCHEDULES_DIRECT_PASSWORD=your_password
```

Then run:

```bash
docker compose up -d
```

## Configuration

The service can be configured with custom lineups using the `SD_LINEUPS` environment variable. By default, it includes:

- USA-0000001-CUSTOM
- USA-DITV505-X
- USA-MI21464-X
- USA-YOUTUBE-X

You can modify these lineups by setting the `SD_LINEUPS` environment variable in your docker-compose.yaml file:

```yaml
environment:
  - SD_LINEUPS=USA-0000001-CUSTOM,USA-DITV505-X,USA-MI21464-X,USA-YOUTUBE-X
```

Multiple lineups should be separated by commas.

## Usage

Once running, the XMLTV file is available at:

```bash
http://your-server-ip:51969/tvxml.xml
```

You can use this URL in your media center software (such as Threadfin, Plex, Emby, Jellyfin, TVHeadend, etc.) as the source for your TV guide data.

## How It Works

- The container runs a cron job that regularly updates the TV listings data
- `tv_grab_zz_sdjson` tool fetches data from Schedules Direct in JSON format
- The data is converted to XMLTV format
- Nginx serves the XMLTV file via HTTP on port 51969

## Environment Variables

| Variable | Description |
|----------|-------------|
| SCHEDULES_DIRECT_USERNAME | Your Schedules Direct username |
| SCHEDULES_DIRECT_PASSWORD | Your Schedules Direct password |
| SD_LINEUPS | Comma-separated list of lineups to fetch (default: USA-0000001-CUSTOM,USA-DITV505-X,USA-MI21464-X,USA-YOUTUBE-X) |
| SD_FETCH_DAYS | The number of days to fetch guide data for (default: 2) |
| TZ | Timezone (default: UTC. Since it runs every day at midnight, choose a TZ where that is the time you want it to run.) |

## Volumes

The Docker Compose configuration creates a volume named `xmltv_data` to store the fetched data, ensuring it persists between container restarts.

## Acknowledgements

This project uses the `tv_grab_zz_sdjson` tool to interact with the Schedules Direct API.
