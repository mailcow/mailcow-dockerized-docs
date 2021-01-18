!!! warning
    Make sure you've read ["Prepare Your System"](https://mailcow.github.io/mailcow-dockerized-docs/prerequisite-system) before proceeding!
    **We do not recommend** CentOS 8 anymore.


You need Docker and Docker Compose.

**1\.** Learn how to install [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).

Quick installation for most operation systems:

- Docker
```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# After the installation process is finished, you may need to enable the service and make sure it is started (e.g. CentOS 7)
systemctl enable docker.service
systemctl start docker.service
```

- Docker-Compose

!!! warning
    **mailcow requires the latest version of docker-compose.** It is highly recommended to use the commands below to install `docker-compose`. Package managers (e.g. `apt`, `yum`) **likely won't** give you the latest version.
    _Note: This command downloads docker-compose from the official Docker Github repository and is a safe method. The snippet will determine the latest supported version by mailcow. In almost all cases this is the latest version available (exceptions are broken releases or major changes not yet supported by mailcow)._

```
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Please use the latest Docker engine available and do not use the engine that ships with your distros repository.

**1\.1\.** On SELinux enabled systems, e.g. CentOS 7:

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


**2\.** Clone the master branch of the repository, make sure your umask equals 0022. Please clone the repository as root user and also control the stack as root. We will modify attributes - if necessary - while boostrapping the containers automatically and make sure everything is secured. The update.sh script must therefore also be run as root. It might be necessary to change ownership and other attributes of files you will otherwise not have access to. **We drop permissions for every exposed application** and will not run an exposed service as root! Controlling the Docker daemon as non-root user does not give you additional security. The unprivileged user will spawn the containers as root likewise. The behaviour of the stack is identical.

```
$ su
# umask
0022 # <- Verify it is 0022
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

**3\.** Generate a configuration file. Use a FQDN (`host.domain.tld`) as hostname when asked.
```
./generate_config.sh
```

**4\.** Change configuration if you want or need to.
```
nano mailcow.conf
```
If you plan to use a reverse proxy, you can, for example, bind HTTPS to 127.0.0.1 on port 8443 and HTTP to 127.0.0.1 on port 8080.

You may need to stop an existing pre-installed MTA which blocks port 25/tcp. See [this chapter](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-local_mta/) to learn how to reconfigure Postfix to run besides mailcow after a successful installation.

Some updates modify mailcow.conf and add new parameters. It is hard to keep track of them in the documentation. Please check their description and, if unsure, ask at the known channels for advise.

**4\.1\.** Users with a MTU not equal to 1500 (e.g. OpenStack):

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

**4\.2\.** Users without an IPv6 enabled network on their host system:

**Enable IPv6. Finally.**

If you do not have an IPv6 enabled network on your host and you don't care for a better internet (thehe), it is recommended to [disable IPv6](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-disable_ipv6/) for the mailcow network to prevent unforeseen issues.


**5\.** Pull the images and run the compose file. The parameter `-d` will start mailcow: dockerized detached:
```
docker-compose pull
docker-compose up -d
```

Done!

You can now access **https://${MAILCOW_HOSTNAME}** with the default credentials `admin` + password `moohoo`.

!!! info
    If you are not using mailcow behind a reverse proxy, you should [redirect all HTTP requests to HTTPS](https://mailcow.github.io/mailcow-dockerized-docs/u_e-80_to_443/).

The database will be initialized right after a connection to MySQL can be established.

Your data will persist in multiple Docker volumes, that are not deleted when you recreate or delete containers. Run `docker volume ls` to see a list of all volumes. You can safely run `docker-compose down` without removing persistent data.
