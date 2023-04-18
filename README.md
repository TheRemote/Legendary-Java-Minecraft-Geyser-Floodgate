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
  <li>Updates automatically to the latest version when server is started</li>
  <li>Runs on all Docker platforms including Raspberry Pi</li>
  <li>Runs on all Kubernetes platforms including Raspberry Pi</li>
</ul>


<h2>Docker Usage</h2>
First you must create a named Docker volume.  This can be done with:<br>
<pre>docker volume create yourvolumename</pre>

Now you may launch the server and open the ports necessary with one of the following Docker launch commands:<br>
<br>
With default ports:
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
With custom ports (this example uses 12345 for the Java port and 54321 for the Bedrock port):
<pre>docker run -it -v yourvolumename:/minecraft -p 12345:12345 -e Port=12345 -p 54321:54321/udp -p 54321:54321 -e BedrockPort=54321 --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
With a custom Minecraft version (add -e Version=1.X.X, must be present on Paper's API servers to work):
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e Version=1.17.1 --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
With a maximum memory limit in megabytes (optional, prevents crashes on platforms with limited memory, -e MaxMemory=2048):
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e MaxMemory=2048 --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
Using a different timezone:
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e TZ="America/Denver" --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
Skipping backups on certain folders (comma separated):
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e NoBackup="plugins/ftp,plugins/test2" --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
Skipping permissions check:
<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e NoPermCheck="Y" --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>

<h2>Kubernetes Usage</h2>
First you must create a suitable PVC using your preferred StorageClass.<br>
To run within Kubernetes, you must pass the enviroment variable `k8s="True"`
alongside any others you require:<br>
<pre>
        env:
        - name: MaxMemory
          value: '1024'
        - name: TZ
          value: Europe/London
        - name: k8s
          value: "True"
</pre>
<bold>Be aware that terminal features will not be available when running in kubernetes</bold>
<br>
The pod can be exposed using a LoadBalancer or TCP/UDP Ingress service.  See example manifests in the /kubernetes folder of the repo.  The examples are based on Longhorn
storage backend and a LoadBalancer service - these will need altering to be suitable
for your environment.<br>

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
The Geyser configuration is located in plugins/Geyser-Spigot/config.yml<br>
The Floodgate configuration is located in plugins/floodgate/config.yml<br>

<h2>TZ (timezone) Environment Variable</h2>
You can change the timezone from the default "America/Denver" to own timezone using this environment variable: <pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e TZ="America/Denver" --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>
A <a href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones">list of Linux timezones is available here</a>

<h2>BackupCount Environment Variable</h2>
By default the server keeps 10 rolling backups that occur each time the container restarts.  You can override this using the BackupCount environment variable:<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e BackupCount=20 --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>

<h2>QuietCurl Environment Variable</h2>
You can use the QuietCurl environment variable to suppress curl's download output.  This will keep your logs tidier but may make it harder to diagnose if something is going wrong.  If things are working well it's safe to enable this option and turn it back off so you can see the output if you need to:<pre>docker run -it -v yourvolumename:/minecraft -p 25565:25565 -p 19132:19132/udp -p 19132:19132 -e QuietCurl=Y --restart unless-stopped 05jchambers/legendary-minecraft-geyser-floodgate:latest</pre>

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

<h2>Troubleshooting Note - Oracle Virtual Machines</h2>
A very common problem people have with the Oracle Virtual Machine tutorials out there that typically show you how to use a free VM is that the VM is much more difficult to configure than just about any other product / offering out there.<br>
The symptom you will have is that nobody will be able to connect.<br>
It is because there are several steps you need to take to open the ports on the Oracle VM.  You need to both:<br>
<ul>
  <li>Set the ingress ports (TCP/UDP) in the Virtual Cloud Network (VCN) security list</li>
  <li>*and* set the ingress ports in a Network Security Group assigned to your instance</li>
</ul><br>
Both of these settings are typically required before you will be able to connect to your VM instance.  This is purely configuration related and has nothing to do with the script or the Minecraft server itself.<br><br>
I do not recommend this platform due to the configuration difficulty but the people who have gone through the pain of configuring an Oracle VM have had good experiences with it after that point.  Just keep in mind it's going to be a rough ride through the configuration for most people.<br><br>
Here are some additional links:<br>
<ul>
<li>https://jamesachambers.com/official-minecraft-bedrock-dedicated-server-on-raspberry-pi/comment-page-8/#comment-13946</li>
<li>https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/comment-page-53/#comment-13936</li>
<li>https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/comment-page-49/#comment-13377</li>
<li>https://jamesachambers.com/legendary-minecraft-bedrock-container/comment-page-2/#comment-13706</li>
</ul>

<h2>Troubleshooting Note - Hyper-V</h2>
There is a weird bug in Hyper-V that breaks UDP connections on the Minecraft server.  There are two fixes for this.  The simplest fix is that you have to use a Generation 1 VM with the Legacy LAN network driver.<br>
See the following links:<br>
<ul>
<li>https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/comment-page-54/#comment-13863</li>
<li>https://jamesachambers.com/minecraft-bedrock-edition-ubuntu-dedicated-server-guide/comment-page-56/#comment-14207</li>
</ul>
There is a second fix that was <a href="https://jamesachambers.com/legendary-minecraft-bedrock-container/comment-page-3/#comment-14654">shared by bpsimons here</a>.<br>You need to install ethtool first with sudo apt install ethtool.  Next in your /etc/network/interfaces file add "offload-tx off" to the bottom as the issue appears to be with TX offloading.<br>
Here's an example:<pre># The primary network interface
auto eth0
iface eth0 inet static
address 192.168.1.5
netmask 255.255.255.0
network 192.168.1.0
broadcast 192.168.1.255
gateway 192.168.1.1
offload-tx off</pre>
This can also be done non-persistently with the following ethtool command: <pre>ethtool -K eth0 tx off</pre>

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
  <li>April 18th 2023</li>
    <ul>
      <li>Add NoViaVersion environment variable to disable using ViaVersion in case of incompatible plugins</li>
    </ul>
  <li>March 25th 2023</li>
    <ul>
      <li>Migrate paper.yml to paper-global.yml (thanks karl007, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/issues/21">Issue #21</a>)</li>
    </ul>
  <li>March 16th 2023</li>
    <ul>
      <li>Update to Paper 1.19.4</li>
    </ul>
  <li>March 15th 2023</li>
    <ul>
      <li>Add ViaVersion plugin to allow players on newer clients to connect to the server (very helpful when waiting for new updates to be released)</li>
      <li>Fix Geyser and Floodgate update checks</li>
    </ul>
  <li>January 25th 2023</li>
    <ul>
      <li>Removed check for terminal and will let the Minecraft server throw an error if environment is not appropriate</li>
    </ul>
  <li>January 14th 2023</li>
    <ul>
      <li>Change google.com connectivity change to papermc.io as Google is blocked in some countries causing the connectivity check to fail when a connection to papermc.io would have succeeded (thanks Misakaou, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/issues/14">Issue #14</a></li>
    </ul>
  <li>January 12th 2023</li>
    <ul>
      <li>Remove broken ScheduleRestart environment variable -- this needs to be done in your OS using docker restart (typically with crontab in Linux or Task Scheduler in Windows)</li>
    </ul>
  <li>December 7th 2022</li>
    <ul>
      <li>Update to 1.19.3 (thanks WarpOverload, issue #9)</li>
    </ul>
  <li>November 19th 2022</li>
    <ul>
      <li>Add "QuietCurl" environment variable which will suppress the progress meter on curl keeping the logs much tidier (thanks willman42, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/pull/6">PR #6</a></li>
      <li>Remove fixpermissions.sh and add 3 lines into main start.sh file</li>
    </ul>
  <li>November 7th 2022</li>
    <ul>
      <li>Fail immediately if ran without an interactive terminal (as the Minecraft server won't work without one)</li>
    </ul>
  <li>October 30th 2022</li>
    <ul>
      <li>Add RISC architecture support</li>
      <li>Switch from ubuntu:latest to ubuntu:rolling</li>
      <li>Switch from using Adoptium to using ubuntu:rolling OpenJDK</li>
      <li>Removed SetupMinecraft.sh</li>
      <li>Fix bug with new ScheduleRestart environment variable</li>
    </ul>
  <li>October 21st 2022</li>
    <ul>
      <li>Added new environment variable "BackupCount" to control the number of backups the container keeps</li>
      <li>NoBackup optional environment variable can now be multiple paths to files to skip backups on separated by a comma.  Example: plugins/test,plugins/test2</li>
    </ul>
  <li>October 20th 2022</li>
    <ul>
      <li>Added new environment variable "NoBackup" to skip a folder from backup activities</li>
      <li>Added new environment variable "NoPermCheck" to skip permissions check during startup</li>
      <li>Added new environment variable "ScheduleRestart" -- this schedules the container to shut down at a certain time which combined with the --restart switch gives daily reboot functionality</li>
    </ul>
  <li>October 8th 2022</li>
    <ul>
      <li>Upgrade to OpenJDK 19</li>
    </ul>
  <li>September 27th 2022</li>
    <ul>
      <li>Fix SIGTERM catching in certain situations by running java with the "exec" command which passes execution completely to that process (thanks vp-en)</li>
      <li>Remove screen dependency</li>
    </ul>
  <li>September 20th 2022</li>
    <ul>
      <li>Fixed Geyser update code (thanks vp-en)</li>
      <li>Update to OpenJDK 18.0.2.1</li>
    </ul>
  <li>August 29th 2022</li>
    <ul>
      <li>Add environment variables section to docker-compose.yml template</li>
      <li>Add optional TZ environment variable to set timezone</li>
    </ul>
  <li>August 28th 2022</li>
    <ul>
      <li>Additional fix for #2 by adding a default config.yml for the server to use for Geyser (thanks vecnar, <a href="https://github.com/TheRemote/Legendary-Java-Minecraft-Geyser-Floodgate/issues/2">issue #2</a>)</li>
    </ul>
  <li>August 27th 2022</li>
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
