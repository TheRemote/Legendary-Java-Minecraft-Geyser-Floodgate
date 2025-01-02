# Minecraft Java Paper Server + Geyser + Floodgate Docker Container
# Author: James A. Chambers - https://jamesachambers.com/minecraft-java-bedrock-server-together-geyser-floodgate/
# GitHub Repository: https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate

# Use Ubuntu rolling version
FROM --platform=linux/amd64 ubuntu:rolling

# Fetch dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install openjdk-21-jre-headless tzdata sudo curl unzip net-tools gawk openssl findutils pigz libcurl4 libc6 libcrypt1 apt-utils libcurl4-openssl-dev ca-certificates binfmt-support nano jq vim -yqq && rm -rf /var/cache/apt/*

# Set port environment variable
ENV Port=25565

# Set Bedrock port environment variable
ENV BedrockPort=19132

# Optional maximum memory Minecraft is allowed to use
ENV MaxMemory=

# Optional Paper Minecraft Version override
ENV Version="1.21.3"

# Optional Timezone
ENV TZ="America/Denver"

# Optional folder to ignore during backup operations
ENV NoBackup=""

# Number of rolling backups to keep
ENV BackupCount=10

# Optional switch to skip permissions check
ENV NoPermCheck=""

# Optional switch to tell curl to suppress the progress meter which generates much less noise in the logs
ENV QuietCurl=""

# Optional switch to disable ViaVersion
ENV NoViaVersion=""

# IPV4 Ports
EXPOSE 25565/tcp
EXPOSE 19132/tcp
EXPOSE 19132/udp

# Copy files into image and make the scripts executable
RUN mkdir /scripts
COPY *.sh /scripts/
COPY *.yml /scripts/
COPY server.properties /scripts/
RUN chmod -R +x /scripts/*.sh

# Create the minecraft user/group and set the container to run as the minecraft user
RUN groupadd -g 999 minecraft && \
    useradd -m -u 999 -g 999 -s /bin/bash minecraft && \
    mkdir /minecraft && \
    chown minecraft:minecraft /minecraft && \
    chmod 777 /minecraft
USER minecraft
WORKDIR /minecraft

# Set entrypoint to start.sh script
ENTRYPOINT ["/bin/bash", "/scripts/start.sh"]
