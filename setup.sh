#!/bin/bash

# Media Server Setup Script
echo "Setting up directory structure for Media Server..."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
    
    # Get current user's UID and GID
    CURRENT_UID=$(id -u)
    CURRENT_GID=$(id -g)
    
    # Try to detect timezone
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CURRENT_TZ=$(systemsetup -gettimezone 2>/dev/null | awk '{print $3}')
    else
        # Linux
        CURRENT_TZ=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
    fi

    # If timezone detection failed, use default
    if [ -z "$CURRENT_TZ" ]; then
        CURRENT_TZ="America/Chicago"
    fi

    # Update .env file with current user's UID, GID and timezone
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/PUID=1000/PUID=$CURRENT_UID/" .env
        sed -i '' "s/PGID=1000/PGID=$CURRENT_GID/" .env
        sed -i '' "s|TZ=America/Chicago|TZ=$CURRENT_TZ|" .env
    else
        # Linux
        sed -i "s/PUID=1000/PUID=$CURRENT_UID/" .env
        sed -i "s/PGID=1000/PGID=$CURRENT_GID/" .env
        sed -i "s|TZ=America/Chicago|TZ=$CURRENT_TZ|" .env
    fi
    
    echo "Created .env file with your user ID ($CURRENT_UID), group ID ($CURRENT_GID), and timezone ($CURRENT_TZ)."
    echo "You may want to edit it further to match your system configuration."
fi

# Create config directories
mkdir -p config/sonarr
mkdir -p config/radarr
mkdir -p config/jellyseerr
mkdir -p config/jellyfin
mkdir -p config/transmission
mkdir -p config/nzbget

# Create downloads and media directories
mkdir -p downloads
mkdir -p downloads/watch  # Transmission watch directory
mkdir -p media
mkdir -p media/movies
mkdir -p media/tv
mkdir -p media/music
mkdir -p media/photos

# Set permissions (optional - uncomment if needed)
# Replace 1000:1000 with your user:group ID if different
# chown -R 1000:1000 config downloads media

echo "Directory structure created successfully!"
echo ""
echo "You can now start your media server with:"
echo "docker-compose up -d"
echo ""
echo "Access your services at (using host networking):"
echo "- Sonarr: http://localhost:8989"
echo "- Radarr: http://localhost:7878"
echo "- Jellyseerr: http://localhost:5055"
echo "- Jellyfin: http://localhost:8096"
echo "- Transmission: http://localhost:9091"
echo "- NZBGet: http://localhost:6789"
echo ""
echo "You can also access these services from other devices on your network"
echo "by replacing 'localhost' with this server's IP address."
