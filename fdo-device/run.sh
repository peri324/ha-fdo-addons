#!/bin/bash
set -e

echo "Starting FDO Device Add-on..."

# 1. Parse Options from Home Assistant
# HA stores the user config in /data/options.json
CONFIG_PATH=/data/options.json
MUD_URL=$(jq --raw-output '.mud_url // empty' $CONFIG_PATH)
DI_URL=$(jq --raw-output '.di_url // empty' $CONFIG_PATH)
RESET_CREDENTIALS=$(jq --raw-output '.reset_credentials // false' $CONFIG_PATH)

if [ -z "$MUD_URL" ]; then
    echo "Warning: No MUD_URL provided!"
else
    echo "Using MUD_URL: $MUD_URL"
    export MUD_URL="$MUD_URL"
fi

if [ "$RESET_CREDENTIALS" == "true" ]; then
    echo "⚠️  FACTORY RESET ENABLED ⚠️"
    echo "Deleting credentials.bin to generate a new device GUID..."
    
    # Remove the file if it exists
    if [ -f "/data/app-data/credentials.bin" ]; then
        rm -f /data/app-data/credentials.bin
        echo "✅ Credentials deleted."
    else
        echo "ℹ️  No credentials file found to delete."
    fi
    
    echo "⚠️  NOTE: Please turn off 'reset_credentials' in the configuration and restart,"
    echo "   otherwise, the device will be reset on every startup!"
fi

if [ ! -z "$DI_URL" ]; then
    echo "Configuring Service DI-URL to: $DI_URL"
    
    # We use sed to edit service.yml in place.
    # Regex explanation:
    # \( *di-url: \)  -> Captures the key and any leading spaces (indentation)
    # .* -> Matches the old URL
    # \1$DI_URL       -> Replaces it with the captured indentation + key + new URL
    sed -i "s|\( *di-url: \).*|\1$DI_URL|" service.yml
else
    echo "Using default DI-URL from service.yml"
fi

# 2. Handle Persistence
# HA Add-ons MUST store data in /data to survive restarts/updates.
# We create a symlink so the Java app writes to /data/app-data instead of inside the container.

mkdir -p /data/app-data
# Remove existing folder if it exists (it's empty from Dockerfile) to allow symlink
rm -rf /home/fdo/app-data
# Link the persistent storage
ln -s /data/app-data /home/fdo/app-data

echo "Persistence configured. Data will be stored in /data/app-data"

# 3. Run the Application
# We run as root here (standard for HA simple addons), or you can switch user if strictly needed.
exec /usr/lib/jvm/java-17-openjdk-amd64/bin/java -jar device.jar
