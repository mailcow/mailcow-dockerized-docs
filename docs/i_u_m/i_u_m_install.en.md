You need Docker (a version >= `20.10.2` is required) and Docker Compose (a version `>= 2.0` is required).

## Installing Docker
Learn how to install [Docker](https://docs.docker.com/install/) in general.

Quick installation for most operating systems:

- Docker
```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# After the installation process is finished, you may need to enable the service and make sure it is started (e.g. CentOS 7)
systemctl enable --now docker
```

**Please use the latest available Docker engine and not the engine that ships with your distro repository.**

**On SELinux-enabled systems, e.g. CentOS 7:**

- Check if "container-selinux" package is present on your system:

```
rpm -qa | grep container-selinux
```

If the above command returns an empty or no output, you should install it via your package manager.

- Check if docker has SELinux support enabled:

```
docker info | grep selinux
```

If the above command returns an empty or no output, create or edit `/etc/docker/daemon.json` and add `"selinux-enabled": true`. Example file content:

```
{
  "selinux-enabled": true
}
```

Restart the docker daemon and verify SELinux is now enabled.

This step is required to make sure mailcows volumes are properly labeled as declared in the compose file.
If you are interested in how this works, you can check out the readme of https://github.com/containers/container-selinux which links to a lot of useful information on that topic.

## Install Docker Compose v2

!!! danger
    As of June 2022, Docker Compose v1 has been replaced in mailcow by Docker Compose v2. <br>
    **Docker Compose v1 will lose official support from Docker in October 2022.** <br>
    _mailcow supports Docker Compose v1 until December 2022, after which installation is **imperative** should you wish to **continue** running mailcow._

!!! bug "Compatibility"
    The web interface will only be accessible via v4 by default in the period from June - December 2022.<br>
    The reason for this is the dual compatibility between Compose v1 and v2. <br>
    Should you wish to access the web interface, as before by default via v6, please take a look at [this chapter](../post_installation/firststeps-ip_bindings.md#ipv6-binding). <br>
    **The 2022-12 update will restore the native IPv6 reachability from the UI.**

If you are freshly installing mailcow and have installed Docker in the above way, Docker Compose v2 will already be installed with it. So you don't need to do anything else.

You can check this with `docker compose version`, if the return looks something like `Docker Compose version v2.5.0`, then the new Docker Compose is already installed on your system.

If it is not installed or you want to upgrade from Docker Compose v1 to v2 just follow the instructions:    

#### Uninstall Docker Compose v1
**If you are already running the mailcow stack with docker-compose v1, make sure you have shut down the mailcow stack and installed the latest update before upgrading to Compose v2**.

To uninstall Docker Compose v1 enter the following command:

```
rm -rf /usr/local/bin/docker-compose
```

#### Install Docker Compose v2

Docker Compose v2 comes with the repository (assuming you followed the instructions at point [installing Docker](#installing-docker)).

Then the installation is quite simple:

```
apt install docker-compose-plugin -y
```

Now type `docker compose version` again and check the return. Is it similar to: `Docker Compose version v2.5.0`? Then everything has been installed correctly!

!!! warning
    If you are using an operating system other than Debian/Ubuntu, please take a look at the [official installation manual](https://docs.docker.com/compose/install/#install-compose-on-linux-systems) of Docker itself to learn how to install Docker Compose v2 on other Linux systems.

## Install mailcow

**1\.** Clone the master branch of the repository, make sure your umask equals 0022. Please clone the repository as root user and also control the stack as root. We will modify attributes - if necessary - while bootstrapping the containers automatically and make sure everything is secured. The update.sh script must therefore also be run as root. It might be necessary to change ownership and other attributes of files you will otherwise not have access to. **We drop permissions for every exposed application** and will not run an exposed service as root! Controlling the Docker daemon as non-root user does not give you additional security. The unprivileged user will spawn the containers as root likewise. The behaviour of the stack is identical.

```
$ su
# umask
0022 # <- Verify it is 0022
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

**2\.** Generate a configuration file. Use a FQDN (`host.domain.tld`) as hostname when asked.
```
./generate_config.sh
```

**3\.** Change configuration if you want or need to.
```
nano mailcow.conf
```
If you plan to use a reverse proxy, you can, for example, bind HTTPS to 127.0.0.1 on port 8443 and HTTP to 127.0.0.1 on port 8080.

You may need to stop an existing pre-installed MTA which blocks port 25/tcp. See [this chapter](../post_installation/firststeps-local_mta.en.md) to learn how to reconfigure Postfix to run besides mailcow after a successful installation.

Some updates modify mailcow.conf and add new parameters. It is hard to keep track of them in the documentation. Please check their description and, if unsure, ask at the known channels for advise.

**3\.1\.** Users with a MTU not equal to 1500 (e.g. OpenStack):

**Whenever you run into trouble and strange phenomena, please check your MTU.**

Edit `docker-compose.yml` and change the network settings according to your MTU.
Add the new driver_opts parameter like this:
```
networks:
  mailcow-network:
    ...
    driver_opts:
      com.docker.network.driver.mtu: 1450
    ...
```

**3\.2\.** Users without an IPv6 enabled network on their host system:

**Enable IPv6. Finally.**

If you do not have an IPv6 enabled network on your host and you don't care for a better internet (thehe), it is recommended to [disable IPv6](../post_installation/firststeps-disable_ipv6.en.md) for the mailcow network to prevent unforeseen issues.


**4\.** Pull the images and run the compose file. The parameter `-d` will start mailcow: dockerized detached:
```
docker compose pull
docker compose up -d
```

Done!

You can now access **https://${MAILCOW_HOSTNAME}** with the default credentials `admin` + password `moohoo`.

!!! info
    If you are not using mailcow behind a reverse proxy, you should [redirect all HTTP requests to HTTPS](../manual-guides/u_e-80_to_443.md).

The database will be initialized right after a connection to MySQL can be established.

Your data will persist in multiple Docker volumes, that are not deleted when you recreate or delete containers. Run `docker volume ls` to see a list of all volumes. You can safely run `docker compose down` without removing persistent data.
