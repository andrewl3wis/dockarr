# Media Server Docker Compose Setup

This Docker Compose configuration sets up a complete media server stack with the following services:

- **Sonarr**: TV show management and automation
- **Radarr**: Movie management and automation
- **Jellyseerr**: Media request and user management system
- **Jellyfin**: Media server for streaming your media collection
- **NZBGet**: Usenet downloader (lightweight and efficient)
- **Transmission**: BitTorrent client

## Directory Structure

The setup creates the following directory structure:

```
.
├── docker-compose.yml
├── config/
│   ├── sonarr/       # Sonarr configuration
│   ├── radarr/       # Radarr configuration
│   ├── jellyseerr/   # Jellyseerr configuration
│   ├── jellyfin/     # Jellyfin configuration
│   ├── transmission/ # Transmission configuration
│   └── nzbget/       # NZBGet configuration
├── downloads/        # Shared downloads folder
│   └── watch/        # Transmission watch directory
└── media/            # Shared media library
    ├── movies/       # Movies directory
    ├── tv/           # TV shows directory
    ├── music/        # Music directory
    └── photos/       # Photos directory
```

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your system
- Sufficient disk space for media storage

### Setup

Run the included setup script to create the necessary directory structure:

```bash
./setup.sh
```

This will create all required directories for configuration, downloads, and media storage.

### Starting the Services

To start all services:

```bash
docker-compose up -d
```

The `-d` flag runs the containers in detached mode (in the background).

### Stopping the Services

To stop all services:

```bash
docker-compose down
```

## Accessing the Services

All services are configured to use host networking, which means they're accessible directly on the host's network interface using their default ports. After starting the containers, you can access each service at:

- **Sonarr**: http://localhost:8989
- **Radarr**: http://localhost:7878
- **Jellyseerr**: http://localhost:5055
- **Jellyfin**: http://localhost:8096
- **NZBGet**: http://localhost:6789
- **Transmission**: http://localhost:9091

You can also access these services from other devices on your network by replacing `localhost` with your server's IP address.

### Host Networking

All containers are configured to use host networking (`network_mode: "host"`), which provides several benefits:

1. **Direct Network Access**: Services run directly on the host's network, eliminating the need for port mapping
2. **Better Performance**: Reduced network overhead compared to Docker's bridge networking
3. **Simplified Configuration**: Services can communicate with each other using localhost
4. **Full Network Functionality**: Services like DLNA discovery and UPnP work without additional configuration
5. **Access from Other Devices**: Services are accessible from other devices on your network using your server's IP address

Note that with host networking, you cannot run multiple services that use the same port. If you need to change a service's port, you'll need to configure it within the service's settings rather than through Docker port mapping.

## Configuration

### Environment Variables

The setup uses a `.env` file to configure environment variables. You can customize the following settings:

```
# User/Group IDs
PUID=1000
PGID=1000

# Timezone
TZ=America/Chicago

# Ports (not used for port mapping since we're using host networking)
# These are kept for reference and potential future use
SONARR_PORT=8989
RADARR_PORT=7878
JELLYSEERR_PORT=5055
JELLYFIN_PORT=8096
JELLYFIN_HTTPS_PORT=8920
TRANSMISSION_PORT=9091
TRANSMISSION_PEER_PORT=51413
NZBGET_PORT=6789

# Transmission credentials
TRANSMISSION_USER=admin
TRANSMISSION_PASS=adminadmin

# Directories
CONFIG_DIR=./config
DOWNLOADS_DIR=./downloads
MEDIA_DIR=./media
```

To find your user and group IDs:

```bash
# Find your user ID
id -u

# Find your group ID
id -g
```

Simply edit the `.env` file to match your system's configuration before starting the services.

### Hardware Acceleration

Jellyfin is configured with comprehensive hardware acceleration support for multiple platforms:

- **Intel/AMD GPUs**: `/dev/dri` devices
- **ARM Mali GPU**: 
  - Device: `/dev/mali0`
  - Mali libraries: `/usr/lib/aarch64-linux-gnu/mali` mounted from host
  - OpenCL support: `/etc/OpenCL` mounted from host
  - Environment variable: `LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/mali`
- **Rockchip SoCs**: Various devices for hardware video encoding/decoding
  - `/dev/rga`, `/dev/mpp_service`, `/dev/iep`, etc.
- **H.265/HEVC Encoding**: Dedicated encoder devices

The container is configured with the `privileged` flag to ensure proper access to these hardware devices. The official `jellyfin/jellyfin:latest` image is used instead of the LinuxServer.io image to ensure compatibility with the ARM Mali GPU libraries.

If you're experiencing issues with hardware acceleration or if some devices don't exist on your system, you can modify the `devices` section and volume mounts in the Jellyfin service configuration in the docker-compose.yml file.

For systems without these specific devices, you may need to adjust the configuration to match your hardware.

## Volume Management

All data is stored outside the containers in the following locations:

- **Configuration**: `./config/` directory contains all application settings
- **Downloads**: `./downloads/` directory is shared between all services
  - `./downloads/watch/` is monitored by Transmission for automatic torrent downloads
- **Media**: `./media/` directory contains all your media files and is accessible by all services

## Initial Setup

After starting the services for the first time:

1. Configure your Usenet downloader:
   - **NZBGet**: Configure your Usenet providers
     - Default login is nzbget/tegbzn6789

2. Configure Transmission with your BitTorrent settings
   - Default login is admin/adminadmin (configurable in .env file)
   - The watch directory is set up at ./downloads/watch

3. Set up Sonarr and Radarr to use your download clients:
   - NZBGet for Usenet downloads
   - Transmission for BitTorrent downloads
   - In Sonarr/Radarr settings, go to "Download Clients" and add each service

4. Configure Jellyfin to scan your media directory
   - Add libraries for Movies, TV Shows, Music, etc.
   - Point each library to the corresponding folder in the media directory

5. Set up Jellyseerr to connect to your Jellyfin, Sonarr, and Radarr instances
   - Follow the setup wizard to connect to each service

## Backup

To backup your configuration, simply copy the `config` directory. This contains all the settings for your services.

## Advanced Configuration

### Docker Compose Override

For advanced customization, you can use a Docker Compose override file. An example file `docker-compose.override.yml.example` is provided that demonstrates:

- Adding Traefik reverse proxy for Jellyfin
- Custom network settings for Sonarr
- Adding Watchtower for automatic container updates
- Creating custom networks

To use it:

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

Then edit the file to match your needs. Docker Compose will automatically merge this with the main configuration when you run `docker-compose up -d`.

## Updating

To update the containers to their latest versions:

```bash
docker-compose pull
docker-compose up -d
```
