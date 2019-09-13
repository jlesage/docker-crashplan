# Docker container for CrashPlan
[![Docker Automated build](https://img.shields.io/docker/automated/jlesage/crashplan.svg)](https://hub.docker.com/r/jlesage/crashplan/) [![Docker Image](https://images.microbadger.com/badges/image/jlesage/crashplan.svg)](http://microbadger.com/#/images/jlesage/crashplan) [![Build Status](https://travis-ci.org/jlesage/docker-crashplan.svg?branch=master)](https://travis-ci.org/jlesage/docker-crashplan) [![GitHub Release](https://img.shields.io/github/release/jlesage/docker-crashplan.svg)](https://github.com/jlesage/docker-crashplan/releases/latest) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/JocelynLeSage/0usd)

This is a Docker container for [CrashPlan](https://www.crashplan.com).

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on client side) or via any VNC client.

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

## Documentation

Full documentation is available at https://github.com/jlesage/docker-crashplan.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/jlesage/docker-crashplan/issues
