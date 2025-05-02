!!! success "It's the same"
    The installation is exactly the same on x86 and ARM64 platforms!

## Docker and Docker Compose Installation
You need Docker (a version >= `24.0.0` is required) and Docker Compose (a version `>= 2.0` is required).

 Learn how to install [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).

Quick installation for most operation systems:

### Docker

!!! danger "Important"
    Always use the latest available Docker Engine from Docker Inc. — do not use the version provided by your distribution's default repository.

#### On Debian/Ubuntu systems:

``` bash
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
systemctl enable --now docker
```

#### On RHEL-based systems (e.g. Rocky Linux 9):

``` bash
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
```

!!! info "Note"
    The convenience "get Docker" script does not reliably work on RHEL systems, so a manual setup is required there.

### docker compose

!!! danger
    **mailcow requires the latest version of docker compose v2.**<br>
    If Docker was installed using the script above, the Docker Compose plugin is already automatically installed in a version >=2.0.<br>
    Is your mailcow installation older or Docker was installed in a different way, the Compose plugin or the standalone version of Docker must be installed manually.

#### Installation via Paketmanager (plugin)

!!! info
    This approach with the package sources is only possible if the Docker repository has been included. This can happen either through the instructions above (see [Docker](#docker)) or through a manually integration.

On Debian/Ubuntu systems:
```
apt update
apt install docker-compose-plugin
```

On RHEL based systems:
```
dnf update
dnf install docker-compose-plugin
```

!!! danger
    The Docker Compose command syntax is **`docker compose`** for the **plugin variant** of Docker Compose!!!

#### Installation via Script (standalone)

!!! info
    This installation is the old familiar way. It installs Docker Compose as a standalone program and does not rely on the Docker installation way.

```
LATEST=$(curl -Ls -w %{url_effective} -o /dev/null https://github.com/docker/compose/releases/latest) && LATEST=${LATEST##*/} && curl -L https://github.com/docker/compose/releases/download/$LATEST/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

!!! danger
    The Docker Compose command syntax is **`docker-compose`** for the **standalone variant** of Docker Compose!!!   

Please use the latest Docker engine available and do not use the engine that ships with your distros repository.

## Check SELinux specifics
On SELinux enabled systems, e.g. CentOS 7:

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


## Install mailcow
Clone the master branch of the repository, make sure your umask equals 0022. Please clone the repository as root user and also control the stack as root. We will modify attributes - if necessary - while bootstrapping the containers automatically and make sure everything is secured. The update.sh script must therefore also be run as root. It might be necessary to change ownership and other attributes of files you will otherwise not have access to. **We drop permissions for every exposed application** and will not run an exposed service as root! Controlling the Docker daemon as non-root user does not give you additional security. The unprivileged user will spawn the containers as root likewise. The behaviour of the stack is identical.

```
$ su
# umask
0022 # <- Verify it is 0022
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

## Initialize mailcow
Generate a configuration file. Use a FQDN (`host.domain.tld`) as hostname when asked.
```
./generate_config.sh
```

Change configuration if you want or need to.
```
nano mailcow.conf
```
If you plan to use a reverse proxy, you can, for example, bind HTTPS to 127.0.0.1 on port 8443 and HTTP to 127.0.0.1 on port 8080.

You may need to stop an existing pre-installed MTA which blocks port 25/tcp. See [this chapter](../post_installation/firststeps-local_mta.en.md) to learn how to reconfigure Postfix to run besides mailcow after a successful installation.

Some updates modify mailcow.conf and add new parameters. It is hard to keep track of them in the documentation. Please check their description and, if unsure, ask at the known channels for advise.


## Troubleshooting
### Users with a MTU not equal to 1500 (e.g. OpenStack)

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

### Users without an IPv6 enabled network on their host system

**Please don't turn off IPv6, even if you don't like it. IPv6 is the future and should not be ignored.**

If you do not have an IPv6 enabled network on your host and you don't care for a better internet (thehe), it is recommended to [disable IPv6](../post_installation/firststeps-disable_ipv6.en.md) for the mailcow network to prevent unforeseen issues.


## Start mailcow
Pull the images and run the compose file. The parameter `-d` will start mailcow: dockerized detached:
=== "docker compose (Plugin)"

    ``` bash
    docker compose pull
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose pull
    docker-compose up -d
    ```

Done!

=== "Post 2025-03 (LDAP Patch)"

    !!! warning "Important"
        Logins have been separated since 2025-03.

    - **Administrators**:  
    You can now log in as an administrator using the default credentials `admin` and the password `moohoo` at:  
    **`https://${MAILCOW_HOSTNAME}/admin`**

    - **Regular mailbox users**:  
    Continue logging in at the usual URL:  
    **`https://${MAILCOW_HOSTNAME}`** (FQDN only)

    - **Domain administrators**:  
    Log in at the dedicated URL:  
    **`https://${MAILCOW_HOSTNAME}/domainadmin`**

=== "Pre 2025-03 (LDAP Patch)"

    You can now access **`https://${MAILCOW_HOSTNAME}`**  using the default credentials `admin` and the password `moohoo`.


!!! info
    If you are not using mailcow behind a reverse proxy, you should [redirect all HTTP requests to HTTPS](../manual-guides/u_e-80_to_443.md).

The database will be initialized right after a connection to MySQL can be established.

Your data will persist in multiple Docker volumes, that are not deleted when you recreate or delete containers. Run `docker volume ls` to see a list of all volumes. You can safely run `docker compose down` without removing persistent data.
