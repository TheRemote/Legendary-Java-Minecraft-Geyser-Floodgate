# Legendary Java Minecraft + Geyser + Floodgate + Paper Dedicated Server for Docker
<img src="https://jamesachambers.com/wp-content/uploads/2022/08/Minecraft-Geyser-Docker-Container-1024x576.webp" alt="Legendary Minecraft Geyser Container">

This is the Docker containerized version of my <a href="https://github.com/TheRemote/RaspberryPiMinecraft">Minecraft Java Paper Dedicated Server for Linux/Raspberry Pi</a> scripts but with Geyser and Floodgate included.

Geyser and Floodgate allow Minecraft Bedrock players to join your Java server!

My <a href="https://jamesachambers.com/minecraft-java-bedrock-server-together-geyser-floodgate/" target="_blank" rel="noopener">main blog article (and the best place for support) is here</a>.<br>
The <a href="https://jamesachambers.com/legendary-paper-minecraft-java-container/" target="_blank" rel="noopener">version without Floodgate and Geyser is here</a>.<br>
The <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate" target="_blank" rel="noopener">official GitHub repository is located here</a>.<br>
The <a href="https://hub.docker.com/r/05jchambers/legendary-minecraft-geyser-floodgate" target="_blank" rel="noopener">official Docker Hub repository is located here</a>.<br>
<br>
The <a href="https://github.com/TheRemote/Legendary-Bedrock-Container" target="_blank" rel="noopener">Bedrock version of the Docker container is available here</a>.  This is for Java Minecraft but Bedrock players can connect to it.<br>
 
<h2>Features</h2>
<ul>
  <li>Sets up fully operational Minecraft server that allows both Java and Bedrock clients to connect</li>
  <li>Runs the highly efficient "Paper" Minecraft server</li>
  <li>Runs Geyser to allow Bedrock clients to connect and Floodgate to allow them to authenticate with their Bedrock credentials to a Java server</li>
  <li>Uses named Docker volume for safe and easy to access storage of server data files (which enables more advanced Docker features such as automatic volume backups)</li>
  <li>Plugin support for Paper + Spigot + Bukkit</li>
  <li>Installs and configures OpenJDK 18</li>
  <li>Automatic backups to minecraft/backups when server restarts</li>
  <li>Full logging available in minecraft/logs folder</li>
  <li>Updates automatically to the latest version when server is started</li>
  <li>Runs on all Docker platforms including Raspberry Pi</li>
</ul>

<h2>Usage</h2>
First you must create a named Docker volume.  This can be done with:<br>
<pre>docker volume create yourvolumename</pre>

Now you may launch the server and open the ports necessary with one of the following Docker launch commands:<br>
<br>
With default ports:
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
With custom ports (this example uses 12345 for the Java port and 54321 for the Bedrock port):
<pre>docker run -it -v yourvolumename:/minecraft -p 12345:12345 -e Port=12345 -p 54321:54321/udp -p 54321:54321 -e BedrockPort=54321 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
With a custom Minecraft version (add -e Version=1.X.X, must be present on Paper's API servers to work):
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e Version=1.17.1 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
With a maximum memory limit in megabytes (optional, prevents crashes on platforms with limited memory, -e MaxMemory=2048):
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e MaxMemory=2048 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
Without using the screen application (useful if the container won't launch saying "Must be connected to a terminal.", will disable some logging features):
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e NoScreen=Y 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
Using a different timezone:
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e TZ="America/Denver" 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>

<h2>Configuration / Accessing Server Files</h2>
The server data is stored where Docker stores your volumes.  This is typically a folder on the host OS that is shared and mounted with the container.<br>
You can find your exact path by typing: <pre>docker volume inspect yourvolumename</pre>  This will give you the fully qualified path to your volume like this:
<pre>{
        "CreatedAt": "2022-05-09T21:08:34-06:00",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/yourvolumename/_data",
        "Name": "yourvolumename",
        "Options": {},
        "Scope": "local"
    }</pre>
<br>
On Linux it's typically available at: <pre>/var/lib/docker/volumes/yourvolumename/_data</pre><br>
On Windows it's at <pre>C:\ProgramData\DockerDesktop</pre> but may be located at something more like <pre>\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes\</pre>if you are using WSL (Windows Subsystem for Linux<br>
<br>
On Mac it's typically <pre>~/Library/Containers/com.docker.docker/Data/vms/0/</pre><br>
If you are using Docker Desktop on Mac then you need to access the Docker VM with the following command first:
<pre>screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty</pre>
You can then normally access the Docker volumes using the path you found in the first step with docker volume inspect<br><br>
Most people will want to edit server.properties.  You can make the changes to the file and then restart the container to make them effective.<br>
<br>
Backups are stored in the "backups" folder<br>
<br>
Log files with timestamps are stored in the "logs" folder.<br>
The Geyser configuration is located in plugins/Geyser-Spigot/config.yml<br>
The Floodgate configuration is located in plugins/floodgate/config.yml<br>

<h2>NoScreen Environment Variable</h2>
Disables launching the server with the screen application which prevents needing an interactive terminal (but disables some logging): <pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e NoScreen=Y 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>

<h2>TZ (timezone) Environment Variable</h2>
You can change the timezone from the default "America/Denver" to own timezone using this environment variable: <pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e TZ="America/Denver" 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
A <a href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones">list of Linux timezones is available here</a>

<h2>Plugins</h2>
This is a "Paper" Minecraft server which has plugin compatibility with Paper / Spigot / Bukkit.<br>
<br>
Installation is simple.  There is a "plugins" folder on your Docker named volume.<br>
<br>
Navigate to your server files on your host operating system (see accessing server files section if you don't know where this is) and you will see the "plugins" folder.<br>
<br>
You just need to drop the extracted version of the plugin (a .jar file) into this folder and restart the container.  That's it!<br>
<br>
Some plugins have dependencies so make sure you read the installation guide first for the plugin you are looking at.<br>
A popular place to get plugins is: <a href="https://dev.bukkit.org/bukkit-plugins">https://dev.bukkit.org/bukkit-plugins</a>

<h2>Buy A Coffee / Donate</h2>
<p>People have expressed some interest in this (you are all saints, thank you, truly)</p>
<ul>
 <li>PayPal: 05jchambers@gmail.com</li>
 <li>Venmo: @JamesAChambers</li>
 <li>CashApp: $theremote</li>
 <li>Bitcoin (BTC): 3H6wkPnL1Kvne7dJQS8h7wB4vndB9KxZP7</li>
</ul>

<h2>Update History</h2>
<ul>
  <li>August 29nd 2022</li>
    <ul>
        <li>Add environment variables section to docker-compose.yml template</li>
        <li>Add optional TZ environment variable to set timezone</li>
    </ul>
  <li>August 28nd 2022</li>
    <ul>
        <li>Additional fix for #2 by adding a default config.yml for the server to use for Geyser (thanks vecnar, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/issues/2">issue #2</a>)</li>
    </ul>
  <li>August 27nd 2022</li>
    <ul>
        <li>Fix broken Geyser-Spigot config.yml issue (thanks vecnar, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/issues/2">issue #2</a>)</li>
    </ul>
  <li>August 22nd 2022</li>
    <ul>
        <li>Add NoScreen environment variable -- disables screen which prevents needing an interactive terminal (but disables some logging)</li>
        <li>Fix issue #1 (thanks Sam7, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/issues/1">issue #1</a>)</li>
    </ul>
  <li>August 18th 2022</li>
    <ul>
        <li>Test rolling back OpenJDK version slightly to earlier version of OpenJDK 18 previous to 10th-11th gen Intel CPU bugs</li>
    </ul>
  <li>August 17th 2022</li>
    <ul>
        <li>Add XX:-UseAESCTRIntrinsics to java launch line to prevent encryption issue on 10th Gen Intel processors</li>
    </ul>
  <li>August 10th 2022</li>
    <ul>
        <li>Adjust query.port in server.properties to be the same as the main server port to keep the "ping port" working properly</li>
        <li>Add enforce-secure-profile=false to default server.properties to prevent login errors</li>
        <li>Add text editor inside the container (nano) for diagnostic/troubleshooting purposes</li>
    </ul>
  <li>August 6th 2022</li>
    <ul>
        <li>Initial release</li>
    </ul>
</ul>