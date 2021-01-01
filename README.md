# Docker container for CrashPlan
[![Docker Image Size](https://img.shields.io/microbadger/image-size/jlesage/crashplan)](http://microbadger.com/#/images/jlesage/crashplan) [![Build Status](https://drone.le-sage.com/api/badges/jlesage/docker-crashplan/status.svg)](https://drone.le-sage.com/jlesage/docker-crashplan) [![GitHub Release](https://img.shields.io/github/release/jlesage/docker-crashplan.svg)](https://github.com/jlesage/docker-crashplan/releases/latest) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/JocelynLeSage/0usd)

This is a Docker container for [CrashPlan](https://www.crashplan.com).

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on the client side) or via any VNC client.

> **_IMPORTANT_**: *CrashPlan for Home*, the version implemented by this
> container, is [being decommissioned].  One of the choice users have is to
> migrate to *CrashPlan PRO* (aka *CrashPlan for Small Business*).
>
> To do so, the [jlesage/crashplan-pro] Docker container can be used.  Make sure
> to read the related [documentation] for a smooth transition.

---

[![CrashPlan logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/crashplan-icon.png&w=200)](https://www.crashplan.com)[![CrashPlan](https://dummyimage.com/400x110/ffffff/575757&text=CrashPlan)](https://www.crashplan.com)

CrashPlan makes it easy to protect your digital life, so you can get back to
what’s important in real life.  Only CrashPlan offers totally free local and
offsite backup. A subscription to the cloud backup service gets you continuous
backup, mobile file access and lots more. For the ultimate in computer backup,
get all three, from the same easy application.

---

## Table of Content

   * [Docker container for CrashPlan](#docker-container-for-crashplan)
      * [Table of Content](#table-of-content)
      * [Quick Start](#quick-start)
      * [Usage](#usage)
         * [Environment Variables](#environment-variables)
         * [Data Volumes](#data-volumes)
         * [Ports](#ports)
         * [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
      * [Docker Compose File](#docker-compose-file)
      * [Docker Image Update](#docker-image-update)
         * [Synology](#synology)
         * [unRAID](#unraid)
      * [User/Group IDs](#usergroup-ids)
      * [Accessing the GUI](#accessing-the-gui)
      * [Security](#security)
         * [SSVNC](#ssvnc)
         * [Certificates](#certificates)
         * [VNC Password](#vnc-password)
      * [Reverse Proxy](#reverse-proxy)
         * [Routing Based on Hostname](#routing-based-on-hostname)
         * [Routing Based on URL Path](#routing-based-on-url-path)
      * [Shell Access](#shell-access)
      * [Networking](#networking)
      * [Taking Over Existing Backup](#taking-over-existing-backup)
      * [Troubleshooting](#troubleshooting)
         * [Crashes / Maximum Amount of Allocated Memory](#crashes--maximum-amount-of-allocated-memory)
         * [Inotify's Watch Limit](#inotifys-watch-limit)
            * [Synology](#synology-1)
         * [Connection Between Computers](#connection-between-computers)
         * [Command-Line Interface Disappears After Running Command](#command-line-interface-disappears-after-running-command)
         * [Forcing Sign-In When Access To CrashPlan Requires Password](#forcing-sign-in-when-access-to-crashplan-requires-password)
         * [Upgrade Failed Error Message](#upgrade-failed-error-message)
      * [Support or Contact](#support-or-contact)

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the CrashPlan docker container with the following command:
```
docker run -d \
    --name=crashplan \
    -p 5800:5800 \
    -v /docker/appdata/crashplan:/config:rw \
    -v $HOME:/storage:ro \
    jlesage/crashplan
```

Where:
  - `/docker/appdata/crashplan`: This is where the application stores its configuration, log and any files needing persistency.
  - `$HOME`: This location contains files from your host that need to be accessible by the application.

Browse to `http://your-host-ip:5800` to access the CrashPlan GUI.
Files from the host appear under the `/storage` folder in the container.

## Usage

```
docker run [-d] \
    --name=crashplan \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    jlesage/crashplan
```
| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in the background.  If not set, the container runs in the foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host).  See the [Ports](#ports) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (unset) |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl | (unset) |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted if it crashes or if a user quits it. | `0` |
|`APP_NICENESS`| Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are deleted during the container startup. | `1` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1280` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `768` |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via a web browser or VNC client).  See the [Security](#security) section for more details. | `0` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI.  See the [VNC Password](#vnc-password) section for more details. | (unset) |
|`X11VNC_EXTRA_OPTS`| Extra options to pass to the x11vnc server running in the Docker container.  **WARNING**: For advanced users. Do not use unless you know what you are doing. | (unset) |
|`ENABLE_CJK_FONT`| When set to `1`, open-source computer font `WenQuanYi Zen Hei` is installed.  This font contains a large range of Chinese/Japanese/Korean characters. | `0` |
|`CRASHPLAN_SRV_MAX_MEM`| Maximum amount of memory the CrashPlan Engine is allowed to use. One of the following memory unit (case insensitive) should be added as a suffix to the size: `G`, `M` or `K`.  By default, when this variable is not set, a maximum of 1024MB (`1024M`) of memory is allowed.  **NOTE**: Setting this variable as the same effect as running the `java mx VALUE, restart` command from the CrashPlan command line. | (unset) |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/config`| rw | This is where the application stores its configuration, log and any files needing persistency. |
|`/storage`| ro | This location contains files from your host that need to be accessible by the application. |
|`/backupArchives`| rw | This is where inbound backups are stored. |

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Mandatory | Port used to access the application's GUI via the web interface. |
| 5900 | Optional | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |
| 4242 | Optional | Port used by CrashPlan for computer-to-computer backups.  No need to expose this port if this feature is not used.  **NOTE**: Because this port is reported by CrashPlan to other devices signed to your account, the port mapped on the host side *must* be the same (i.e. 4242). |

### Changing Parameters of a Running Container

As can be seen, environment variables, volume and port mappings are all specified
while creating the container.

The following steps describe the method used to add, remove or update
parameter(s) of an existing container.  The general idea is to destroy and
re-create the container:

  1. Stop the container (if it is running):
```
docker stop crashplan
```
  2. Remove the container:
```
docker rm crashplan
```
  3. Create/start the container using the `docker run` command, by adjusting
     parameters as needed.

**NOTE**: Since all application's data is saved under the `/config` container
folder, destroying and re-creating a container is not a problem: nothing is lost
and the application comes back with the same state (as long as the mapping of
the `/config` folder remains the same).

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.  Note that only mandatory network
ports are part of the example.

```yaml
version: '3'
services:
  crashplan:
    image: jlesage/crashplan
    build: .
    ports:
      - "5800:5800"
    volumes:
      - "/docker/appdata/crashplan:/config:rw"
      - "$HOME:/storage:ro"
```

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update
the Docker image, the following steps can be followed:

  1. Fetch the latest image:
```
docker pull jlesage/crashplan
```
  2. Stop the container:
```
docker stop crashplan
```
  3. Remove the container:
```
docker rm crashplan
```
  4. Start the container using the `docker run` command.

### Synology

For owners of a Synology NAS, the following steps can be used to update a
container image.

  1.  Open the *Docker* application.
  2.  Click on *Registry* in the left pane.
  3.  In the search bar, type the name of the container (`jlesage/crashplan`).
  4.  Select the image, click *Download* and then choose the `latest` tag.
  5.  Wait for the download to complete.  A  notification will appear once done.
  6.  Click on *Container* in the left pane.
  7.  Select your CrashPlan container.
  8.  Stop it by clicking *Action*->*Stop*.
  9.  Clear the container by clicking *Action*->*Clear*.  This removes the
      container while keeping its configuration.
  10. Start the container again by clicking *Action*->*Start*. **NOTE**:  The
      container may temporarily disappear from the list while it is re-created.

### unRAID

For unRAID, a container image can be updated by following these steps:

  1. Select the *Docker* tab.
  2. Click the *Check for Updates* button at the bottom of the page.
  3. Click the *update ready* link of the container to be updated.

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

  * A web browser:
```
http://<HOST IP ADDR>:5800
```

  * Any VNC client:
```
<HOST IP ADDR>:5900
```

## Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable.  See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser.  All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL.  Note that
few VNC clients support this method.  [SSVNC] is one of them.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

### SSVNC

[SSVNC] is a VNC viewer that adds encryption security to VNC connections.

While the Linux version of [SSVNC] works well, the Windows version has some
issues.  At the time of writing, the latest version `1.0.30` is not functional,
as a connection fails with the following error:
```
ReadExact: Socket error while reading
```
However, for your convenience, an unofficial and working version is provided
here:

https://github.com/jlesage/docker-baseimage-gui/raw/master/tools/ssvnc_windows_only-1.0.30-r1.zip

The only difference with the official package is that the bundled version of
`stunnel` has been upgraded to version `5.49`, which fixes the connection
problems.

### Certificates

Here are the certificate files needed by the container.  By default, when they
are missing, self-signed certificates are generated and used.  All files have
PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified.  This can
be done via two methods:
  * By using the `VNC_PASSWORD` environment variable.
  * By creating a `.vncpass_clear` file at the root of the `/config` volume.
    This file should contain the password in clear-text.  During the container
    startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:
  * The type of communication channel (encrypted/unencrypted).
  * How secure the access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

**ATTENTION**: Password is limited to 8 characters.  This limitation comes from
the Remote Framebuffer Protocol [RFC](https://tools.ietf.org/html/rfc6143) (see
section [7.2.2](https://tools.ietf.org/html/rfc6143#section-7.2.2)).  Any
characters beyond the limit are ignored.

## Reverse Proxy

The following sections contain NGINX configurations that need to be added in
order to reverse proxy to this container.

A reverse proxy server can route HTTP requests based on the hostname or the URL
path.

### Routing Based on Hostname

In this scenario, each hostname is routed to a different application/container.

For example, let's say the reverse proxy server is running on the same machine
as this container.  The server would proxy all HTTP requests sent to
`crashplan.domain.tld` to the container at `127.0.0.1:5800`.

Here are the relevant configuration elements that would be added to the NGINX
configuration:

```
map $http_upgrade $connection_upgrade {
	default upgrade;
	''      close;
}

upstream docker-crashplan {
	# If the reverse proxy server is not running on the same machine as the
	# Docker container, use the IP of the Docker host here.
	# Make sure to adjust the port according to how port 5800 of the
	# container has been mapped on the host.
	server 127.0.0.1:5800;
}

server {
	[...]

	server_name crashplan.domain.tld;

	location / {
	        proxy_pass http://docker-crashplan;
	}

	location /websockify {
		proxy_pass http://docker-crashplan;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_read_timeout 86400;
	}
}

```

### Routing Based on URL Path

In this scenario, the hostname is the same, but different URL paths are used to
route to different applications/containers.

For example, let's say the reverse proxy server is running on the same machine
as this container.  The server would proxy all HTTP requests for
`server.domain.tld/crashplan` to the container at `127.0.0.1:5800`.

Here are the relevant configuration elements that would be added to the NGINX
configuration:

```
map $http_upgrade $connection_upgrade {
	default upgrade;
	''      close;
}

upstream docker-crashplan {
	# If the reverse proxy server is not running on the same machine as the
	# Docker container, use the IP of the Docker host here.
	# Make sure to adjust the port according to how port 5800 of the
	# container has been mapped on the host.
	server 127.0.0.1:5800;
}

server {
	[...]

	location = /crashplan {return 301 $scheme://$http_host/crashplan/;}
	location /crashplan/ {
		proxy_pass http://docker-crashplan/;
		location /crashplan/websockify {
			proxy_pass http://docker-crashplan/websockify/;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $connection_upgrade;
			proxy_read_timeout 86400;
		}
	}
}

```
## Shell Access

To get shell access to the running container, execute the following command:

```
docker exec -ti CONTAINER sh
```

Where `CONTAINER` is the ID or the name of the container used during its
creation (e.g. `crashplan-pro`).

## Networking

By default, the container runs in bridge mode networking.  This is the best way
to go, unless your CrashPlan container is the backup destination of other
devices on your local network (LAN).

In this network mode, a private IP address on an isolated subnet is assigned to
containers.  For example, devices on your LAN may have IP addresses in the
`192.168.1.x` subnet, while containers have IP addresses in the `172.17.x.x`
range.  Thus, CrashPlan detects and reports a local/internal IP address in the
`172.17.x.x` subnet, something that other devices on your LAN cannot reach.

**NOTE**: The problem described here doesn't affect the scenario where your
CrashPlan container is the backup destination of other devices located *outside*
your LAN (i.e. over the Internet).  In this case, CrashPlan uses your public IP
address, which is properly detected no matter the networking mode.

The first solution to this issue is to add a static route on your router to
allow other devices to reach your CrashPlan container.  The way to configure
routes is different for each router, but here is the route information you will
need:
```
Subnet IP address:  172.17.0.0
Subnet mask:        255.255.0.0
Subnet prefix size: /16
Gateway:            IP address of your Docker host
```

The second solution is to run the container in host mode networking.  This mode
effectively disables network isolation of a Docker container. The container
shares the networking namespace of the host, meaning that it shares the same IP
address and is directly exposed to your LAN.  Consequently, port mappings are
note used/needed.  Note that this mode increases chances to conflict with other
containers or services running on the host.  To enable the host mode networking,
run the container with the `--net=host` parameter.

For more information, see the [Docker container networking] documentation.

## Taking Over Existing Backup

If this container is replacing a CrashPlan installation (from Linux, Windows,
MAC or another Docker container), your existing backup can be taken over to
avoid re-uploading all your data.

To proceed, make sure to carefully read the [official documentation].

Here is a summary of what needs to be done:
  1. Start CrashPlan Docker container.  Make sure the configuration directory
     if not mapped to a folder used by a different CrashPlan container.
  2. Sign in to your account.
  3. Perform an adoption.  There is a gray banner asking you to do so.
  4. Once done, you will probably see missing items in the file selection.  This
     is normal, since path to your files is different in the container.
  5. Update the file selection by re-adding your files.  **Do not unselect
     missing items yet**.
  6. Perform a backup.  Because of deduplication, files will not be uploaded
     again.
  7. Once the backup is terminated, you can remove missing items **if you
     don't care about file versions**.  Else, keep missing items.
  8. If you are the destination for other computers, you have to adjust the
     location of previous backup archives.  In the `Inbound` section, if some of
     your friends have the message `Backup disabled - backup location is not
     accessible`: click on the name, then update the location.  It should be
     under `/backupArchives/<Computer ID>`.

## Troubleshooting

### Crashes / Maximum Amount of Allocated Memory

If CrashPlan crashes unexpectedly with large backups, try to increase the
maximum amount of memory CrashPlan is allowed to use. This can be done by:

  1. Setting the `CRASHPLAN_SRV_MAX_MEM` environment variable.  See the
     [Environment Variables](#environment-variables) section for more details.
  2. Using the [solution provided by CrashPlan] from its support site.

### Inotify's Watch Limit

If CrashPlan exceeds inotify's max watch limit, real-time file watching cannot
work properly and the inotify watch limit needs to be increased on the **host**,
not the container.

For more details, see the CrashPlan's [Linux real-time file watching errors]
article.

#### Synology

On Synology NAS, the instuctions provided by the article mentioned in the
previous section apply, except that the inotify's max watch limit must be set in
`/etc.defaults/sysctl.conf` (instead of `/etc/sysctl.conf`) to make the setting
permanent.

**NOTE**: After an upgrade of the DSM software, verify that the content of the
file has not been overwritten.

### Connection Between Computers

If you have connection issues between your computers, make sure to read the
[Connection between computers] article from CrashPlan support site.

When changing the inbound backup port from CrashPlan settings, don't forget to
also add the proper port mapping when running the container.  For example, if
the listening port is changed to `12345`, the option `-p 12345:12345` needs to
be added to the `docker run` command.

### Command-Line Interface Disappears After Running Command

After entering a command in the command-line interface, the window immediately
disappear.  This is a known issue, but it should be noted that the requested
command is still executed as requested.

If the result and/or output of the command is needed, consult the log file
located at `log/service.log.0` in the config directory of container.  Here is
an example of log messages produced when running the `version` command:

```
[03.05.18 06:03:17.179 INFO  MQ-UI-1      backup42.service.ui.UIController] UserActionRequest: CommandMessage[version]
[03.05.18 06:03:17.179 INFO  MQ-UI-1      kup42.common.command.CliExecutor] RUN COMMAND: version  >  CommandResult@1111973668[ version, success=true, result=4.8.4 - 1436674800484 (2015-07-12T04:20:00:484+0000) - Build: 15 ]
```

The list of [available commands] can be consulted online.

### Forcing Sign-In When Access To CrashPlan Requires Password

CrashPlan can be configured to require a password to access the application.
Enabling this option ensures no one else can make changes to settings or
restore files without the account password.

Sign-in is needed when the application is started.  Since the application is
always running in this container, a manual step is required to replace the
action of closing the application:
  1. Double click on the CrashPlan logo to open the command-line interface.
  2. Type `exit` and then press the Enter key.

After a few seconds, the CrashPlan application closes and then automatically
restarts.  At this point, password of the account is required to continue.

### Upgrade Failed Error Message

Because the CrashPlan's self-upgrade feature is disabled in this container, an
error message about failed upgrade can be seen when a new CrashPlan version is
released.

To fix this, [updating the container's image](#docker-image-update) to the
latest version will also bring the latest version of CrashPlan.

[TimeZone]: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
[being decommissioned]: https://www.crashplan.com/en-us/consumer/nextsteps/
[jlesage/crashplan-pro]: https://hub.docker.com/r/jlesage/crashplan-pro/
[documentation]: https://github.com/jlesage/docker-crashplan-pro/blob/master/README.md#migrating-from-crashplan-for-home
[Docker container networking]: https://docs.docker.com/engine/userguide/networking/
[official documentation]: https://support.code42.com/CrashPlan/4/Configuring/Replacing_Your_Device
[solution provided by CrashPlan]: https://support.code42.com/CrashPlan/4/Troubleshooting/Adjusting_CrashPlan_Settings_For_Memory_Usage_With_Large_Backups
[Connections between computers]: https://support.code42.com/CrashPlan/4/Troubleshooting/Connections_between_computers
[Linux real-time file watching errors]: https://support.code42.com/CrashPlan/4/Troubleshooting/Linux_real-time_file_watching_errors
[available commands]: https://support.code42.com/CrashPlan/4/Troubleshooting/Code42_commands

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/jlesage/docker-crashplan/issues
