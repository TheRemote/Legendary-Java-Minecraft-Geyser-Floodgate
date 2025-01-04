#!/bin/bash
# Legendary Paper Minecraft Java Server Docker + Geyser/Floodgate server startup script
# Author: James A. Chambers - https://jamesachambers.com/minecraft-java-bedrock-server-together-geyser-floodgate/
# GitHub Repository: https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate

CurlArgs=(
    -H "Accept-Encoding: identity"
    -H "Accept-Language: en"
    -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36"
    -L
)

# If running as root, fix ownership of all files and restart script as 'minecraft' user
if [ "$(id -u)" = '0' ]; then
    echo "Script is running as '$(whoami)', switching to 'minecraft' user ..."

    echo "     Changing ownership of all files in /minecraft to 'minecraft:minecraft' ..."
    chown -R minecraft:minecraft /minecraft >/dev/null

    echo "     Restarting script as 'minecraft' user."
    exec su minecraft -c "$0" "$@"
fi

echo "################################################################################################################"
echo "Paper Minecraft Java Server Docker + Geyser/Floodgate script by James A. Chambers"
echo "################################################################################################################"
echo "Latest version always at https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate"
echo "Don't forget to set up port forwarding on your router!  The default port is 25565 and the Bedrock port is 19132."

echo ""
echo "************************************************************************"
echo "Prepare Environment"
echo "************************************************************************"
echo "Checking volume mount ..."
if ! df -h | grep -q /minecraft; then
    echo "ERROR:  A named volume was not specified for the minecraft server data.  Please create one with: docker volume create yourvolumename"
    echo "Please pass the new volume to docker like this:  docker run -it -v yourvolumename:/minecraft"
    exit 1
else
    echo "     Volume mount found for /minecraft"
fi

# Change directory to server directory
cd /minecraft || exit

# Create backups/downloads folder if it doesn't exist
if [ ! -d "/minecraft/downloads" ]; then
    mkdir -p /minecraft/downloads
fi
if [ ! -d "/minecraft/config" ]; then
    mkdir -p /minecraft/config
fi
if [ ! -d "/minecraft/backups" ]; then
    mkdir -p /minecraft/backups
fi
if [ ! -d "/minecraft/plugins/Geyser-Spigot" ]; then
    mkdir -p /minecraft/plugins/Geyser-Spigot
fi

# Check if network interfaces are up
echo "Checking network interface status ..."
if [ -e '/sbin/route' ]; then
    DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
else
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
fi
if [ -n "$DefaultRoute" ]; then
      echo "     Network interface is up."
fi
NetworkChecks=0
while [ -z "$DefaultRoute" ]; do
    echo "     Network interface not up, will try again in 1 second ..."
    sleep 1
    if [ -e '/sbin/route' ]; then
        DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
    else
        DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    fi
    NetworkChecks=$((NetworkChecks + 1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "ERROR:  Waiting for network interface to come up timed out - starting server without network connection."
        break
    fi
    if [ -n "$DefaultRoute" ]; then
      echo "     Network interface is up."
    fi
done

# Check ownership of server files
if [ -z "$NoPermCheck" ]; then
    echo "Checking ownership of all server files/folders in /minecraft for user:group - '$(whoami):$(whoami)' ..."
    chown -R minecraft:minecraft /minecraft >/dev/null
    echo "     Ownership check complete.  Any errors above could indicate an issue."
else
    echo "Skipping ownership check due to NoPermCheck flag."
fi

# Back up server
if [ -d "world" ]; then
    echo "Running backup ..."
    # Build tar args
    tarExcludes=(
        --exclude='./backups'
        --exclude='./cache'
        --exclude='./logs'
        --exclude='./paperclip.jar'
    )
    if [ -n "$NoBackup" ]; then
        echo "     Excluding the following extra items from backups: ${NoBackup}"
        IFS=','
        read -ra ADDR <<< "$NoBackup"
        for i in "${ADDR[@]}"; do
            tarExcludes+=(--exclude="./$i")
        done
    fi
    if [ -n "$(which pigz)" ]; then
        tarCompression="-I pigz"
        coresMsg="all cores"
    else
        tarCompression=""
        coresMsg="single core, pigz not found"
    fi
    echo "     Backing up server ($coresMsg) to /minecraft/backups folder..."
    tar "${tarExcludes[@]}" \
        "$tarCompression" \
        --totals \
        -pcf \
        "backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz" \
        . 2>&1 | sed 's/^Total bytes written:/     Total bytes written:/'
fi

# Rotate backups
if [ -d /minecraft/backups ] && [ -n "$BackupCount" ]; then
    (
        pushd /minecraft/backups || exit
        find . -type f -printf "%T@ %p\n" | sort -n | head -n -"$BackupCount" | cut -d' ' -f2- | xargs -d '\n' rm -f --
        popd || exit
    ) > /dev/null
fi
# Ensure we are back in the server directory
cd /minecraft > /dev/null || exit

# Copy config files if this is a brand new server
if [ ! -e "/minecraft/bukkit.yml" ]; then
    cp /scripts/bukkit.yml /minecraft/bukkit.yml
fi
if [ ! -e "/minecraft/config/paper-global.yml" ]; then
    cp /scripts/paper-global.yml /minecraft/config/paper-global.yml
fi
if [ ! -e "/minecraft/spigot.yml" ]; then
    cp /scripts/spigot.yml /minecraft/spigot.yml
fi
if [ ! -e "/minecraft/server.properties" ]; then
    cp /scripts/server.properties /minecraft/server.properties
fi
if [ ! -e "/minecraft/plugins/Geyser-Spigot/config.yml" ]; then
    cp /scripts/config.yml /minecraft/plugins/Geyser-Spigot/config.yml
fi

# Update paperclip.jar
echo "Updating to most recent Paper server version ..."

# Test update website connectivity first
if ! curl "${CurlArgs[@]}" \
          -s \
          https://api.papermc.io \
          -o /dev/null; then
    echo "ERROR:  Unable to connect to update website (internet connection may be down).  Skipping server and plugin updates."
else
    # Get latest build number
    BuildJSON=$(curl --no-progress-meter \
        "${CurlArgs[@]}" \
        https://api.papermc.io/v2/projects/paper/versions/"${Version:?}"/builds
    )
    Build=$(echo "$BuildJSON" | jq '.builds | if map(select(.channel == "default")) | length > 0 then map(select(.channel == "default") | .build) | . else map(select(.channel == "experimental") | .build) | . end | .[-1]')
    Build=$((Build + 0))

    # Download latest build for the targeted version
    if [[ $Build != 0 ]]; then
        echo "     Found latest Paper build $Build for version $Version"
        curl ${QuietCurl:+"--no-progress-meter"} \
             "${CurlArgs[@]}" \
             -o /minecraft/paperclip.jar \
             "https://api.papermc.io/v2/projects/paper/versions/$Version/builds/$Build/downloads/paper-$Version-$Build.jar"
    else
        echo "     Unable to retrieve latest Paper build (got result of: $Build)"
    fi

    # Update Floodgate
    echo "Updating Floodgate ..."
    curl ${QuietCurl:+"--no-progress-meter"} \
         "${CurlArgs[@]}" \
         -o /minecraft/plugins/Floodgate-Spigot.jar \
         "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"

    # Update Geyser
    echo "Updating Geyser ..."
    curl ${QuietCurl:+"--no-progress-meter"} \
         "${CurlArgs[@]}" \
         -o /minecraft/plugins/Geyser-Spigot.jar \
         "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"

    echo "Updating ViaVersion ..."
    if [ -z "$NoViaVersion" ]; then
        # Update ViaVersion if new version is available
        echo "     Checking the latest version of ViaVersion ..."
        ViaVersionLatestVersion=$(curl --no-progress-meter \
            "${CurlArgs[@]}" \
            -k \
            https://ci.viaversion.com/job/ViaVersion/lastBuild/artifact/build/libs/ \
            | grep -P '(?<=href=")ViaVersion[^"]+' -o --max-count=1 | head -n1
        )
        if [ -n "$ViaVersionLatestVersion" ]; then
            ViaVersionLatestMD5=$(curl --no-progress-meter \
                "${CurlArgs[@]}" \
                -k \
                "https://ci.viaversion.com/job/ViaVersion/lastBuild/artifact/build/libs/$ViaVersionLatestVersion/*fingerprint*/" \
                | grep breadcrumbs | cut -d'_' -f24- | cut -d'<' -f2 | cut -d'>' -f2
            )
            if [ -n "$ViaVersionLatestMD5" ]; then
                ViaVersionLocalMD5=$(md5sum plugins/ViaVersion.jar | cut -d' ' -f1)
                if [ -e /minecraft/plugins/ViaVersion.jar ] && [ "$ViaVersionLocalMD5" = "$ViaVersionLatestMD5" ]; then
                    echo "     ViaVersion is up to date: $ViaVersionLatestVersion"
                else
                    echo "     Downloading new version: $ViaVersionLatestVersion"
                    curl ${QuietCurl:+"--no-progress-meter"} \
                         "${CurlArgs[@]}" \
                         -k \
                         -o /minecraft/plugins/ViaVersion.jar \
                         "https://ci.viaversion.com/job/ViaVersion/lastBuild/artifact/build/libs/$ViaVersionLatestVersion"
                fi
            else
                echo "ERROR:  Unable to check for updates to ViaVersion!"
            fi
        fi
    else
        echo "     ViaVersion is disabled -- skipping"
    fi
fi

# Accept EULA
echo "Accepting EULA ..."
echo eula=true > eula.txt

# Change ports in server.properties
echo "Setting server ports ..."
if [ -z "$Port" ]; then
    Port="25565"
fi
echo "     Java port used: $Port"
sed -i "/server-port=/c\server-port=$Port" /minecraft/server.properties
sed -i "/query\.port=/c\query\.port=$Port" /minecraft/server.properties
# Change Bedrock port in Geyser config
if [ -z "$BedrockPort" ]; then
    Port="19132"
fi
echo "     Bedrock port used: $BedrockPort"
if [ -e /minecraft/plugins/Geyser-Spigot/config.yml ]; then
    sed -i -z "s/  port: [0-9]*/  port: $BedrockPort/" /minecraft/plugins/Geyser-Spigot/config.yml
fi

# Start server
echo ""
echo "************************************************************************"
echo "Launch Minecraft"
echo "************************************************************************"
echo "Starting Minecraft server ..."
if [[ -z "$MaxMemory" ]] || [[ "$MaxMemory" -le 0 ]]; then
    exec java -XX:+UnlockDiagnosticVMOptions -XX:-UseAESCTRIntrinsics -DPaper.IgnoreJavaVersion=true -Xms400M -jar /minecraft/paperclip.jar
else
    exec java -XX:+UnlockDiagnosticVMOptions -XX:-UseAESCTRIntrinsics -DPaper.IgnoreJavaVersion=true -Xms400M -Xmx"${MaxMemory}"M -jar /minecraft/paperclip.jar
fi

# Exit container
exit 0
