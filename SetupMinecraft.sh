#!/bin/bash
# Legendary Paper Minecraft Java Server Docker + Geyser/Floodgate script by James A. Chambers - image build time
# Author: James A. Chambers - https://jamesachambers.com/minecraft-java-bedrock-server-together-geyser-floodgate/
# GitHub Repository: https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate

Install_Java() {
  # Install Java
  echo "Installing OpenJDK..."

  cd /

  CPUArch=$(uname -m)
  if [[ "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://github.com/adoptium/temurin19-binaries/releases/download/jdk-19%2B36/OpenJDK19U-jre_arm_linux_hotspot_19_36.tar.gz -o /jre19.tar.gz -L
    tar -xf /jre19.tar.gz
    rm -f /jre19.tar.gz
    mv /jdk-* /jre
  elif [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://github.com/adoptium/temurin19-binaries/releases/download/jdk-19%2B36/OpenJDK19U-jre_aarch64_linux_hotspot_19_36.tar.gz -o /jre19.tar.gz -L
    tar -xf /jre19.tar.gz
    rm -f /jre19.tar.gz
    mv /jdk-* /jre
  elif [[ "$CPUArch" == *"x86_64"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://github.com/adoptium/temurin19-binaries/releases/download/jdk-19%2B36/OpenJDK19U-jre_x64_linux_hotspot_19_36.tar.gz -o /jre19.tar.gz -L
    tar -xf /jre19.tar.gz
    rm -f /jre19.tar.gz
    mv /jdk-* /jre
  elif [[ "$CPUArch" == *"s390x"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://github.com/adoptium/temurin19-binaries/releases/download/jdk-19%2B36/OpenJDK19U-jre_s390x_linux_hotspot_19_36.tar.gz -o /jre19.tar.gz -L
    tar -xf /jre19.tar.gz
    rm -f /jre19.tar.gz
    mv /jdk-* /jre
  elif [[ "$CPUArch" == *"ppc64le"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://github.com/adoptium/temurin19-binaries/releases/download/jdk-19%2B36/OpenJDK19U-jre_ppc64le_linux_hotspot_19_36.tar.gz -o /jre19.tar.gz -L
    tar -xf /jre19.tar.gz
    rm -f /jre19.tar.gz
    mv /jdk-* /jre
  fi

  if [ -e "/jre/bin/java" ]; then
    CurrentJava=$(/jre/bin/java -version 2>&1 | head -1 | cut -d '"' -f 2 | cut -d '.' -f 1)
    if [[ $CurrentJava -lt 18 || $CurrentJava -gt 19 ]]; then
      echo "Required OpenJDK version 18/19 could not be installed."
      exit 1
    else
      echo "OpenJDK installation completed."
    fi
  else
    rm -rf /jre
    echo "Required OpenJDK version 18/19 could not be installed."
    exit 1
  fi
}

Install_Java

rm -rf /var/cache/apt/*
