#!/bin/bash
# Minecraft Server Docker Container Permissions Fix Script
# Author: James A. Chambers - https://jamesachambers.com/minecraft-java-bedrock-server-together-geyser-floodgate/
# GitHub Repository: https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate

# Takes ownership of server files to fix common permission errors such as access denied
# This is very common when restoring backups, moving and editing files, etc.

# Take ownership of files
echo "Taking ownership of all server files/folders in /minecraft..."
sudo -n chown -R $(whoami) /minecraft >/dev/null 2>&1
echo "Complete"