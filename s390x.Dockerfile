# Minecraft Java Paper Server + Geyser + Floodgate Docker Container
# Author: James A. Chambers - https://jamesachambers.com/minecraft-java-bedrock-server-together-geyser-floodgate/
# GitHub Repository: https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate

# Use latest Ubuntu version for builder
FROM ubuntu:latest AS builder

# Update apt
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install qemu-user-static binfmt-support apt-utils -yqq && rm -rf /var/cache/apt/*

# Use current Ubuntu LTS version
FROM --platform=linux/s390x ubuntu:latest

# Add QEMU
COPY --from=builder /usr/bin/qemu-s390x-static /usr/bin/

# Fetch dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get install sudo curl unzip screen net-tools gawk openssl findutils pigz libcurl4 libc6 libcrypt1 apt-utils libcurl4-openssl-dev ca-certificates binfmt-support nano -yqq && rm -rf /var/cache/apt/*

# Set port environment variable
ENV Port=25565

# Set Bedrock port environment variable
ENV BedrockPort=19132

# Optional maximum memory Minecraft is allowed to use
ENV MaxMemory=

# Optional Paper Minecraft Version override
ENV Version="1.19.2"

# Optional switch to prevent usage of screen (disables logging but may fix container launch issues on some platforms)
ENV NoScreen=

# IPV4 Ports
EXPOSE 25565/tcp
EXPOSE 19132/tcp
EXPOSE 19132/udp

# Copy scripts to minecraftbe folder and make them executable
RUN mkdir /scripts
COPY *.sh /scripts/
COPY *.yml /scripts/
COPY server.properties /scripts/
RUN chmod -R +x /scripts/*.sh

# Run SetupMinecraft.sh
RUN /scripts/SetupMinecraft.sh

# Set entrypoint to start.sh script
ENTRYPOINT ["/bin/bash", "/scripts/start.sh"]
