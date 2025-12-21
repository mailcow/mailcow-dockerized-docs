# Installation of mailcow

## Prerequisites

### System Packages

The following Linux packages are required for using mailcow and may need to be installed depending on your distribution:

- git
- openssl
- curl
- awk
- sha1sum
- grep
- cut
- jq (**new as of [2025-09](https://mailcow.email/posts/2025/release-2025-09/#2025-09-release-10th-september-2025)**)

### Docker and Docker Compose

For the installation, you will need:

- **Docker**: Version `>= 24.0.0`
- **Docker Compose**: Version `>= 2.0`

Installation guides can be found here:

- [Install Docker](https://docs.docker.com/install/)
- [Install Docker Compose](https://docs.docker.com/compose/install/)

### Quick Installation

#### System Packages

##### Debian/Ubuntu:

```bash
apt update
apt install -y git openssl curl gawk coreutils grep jq
```

##### RHEL-based systems (e.g., Rocky Linux 9):
```bash
dnf install -y git openssl curl gawk coreutils grep jq
```

##### Alpine Linux (e.g., 3.22):
```bash
apk add --no-cache --upgrade sed findutils bash git openssl curl gawk coreutils grep jq
```

!!! info "Note"
    All programs not explicitly listed in the installation process are already included as subprograms in `coreutils`.

#### Docker

!!! danger "Important"
    Use the **latest available Docker Engine** and not the version from your Linux distribution's package sources.

##### Debian/Ubuntu:

```bash
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
systemctl enable --now docker
```

##### RHEL-based systems (e.g., Rocky Linux 9):

```bash
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
```

##### Alpine Linux (e.g., 3.22):

```bash
apk --no-cache --upgrade add docker
rc-update add docker default
rc-service docker start
```

!!! info "Note"
    The `get.docker.com` script does not work reliably or at all on RHEL and Alpine Linux systems. Use the manual method instead.

#### Docker Compose

!!! danger "Warning"
    **mailcow requires Docker Compose version `>= 2.0`.**

##### Installation via Package Manager (Plugin)

!!! info "Note"
    This method requires that the Docker repository has been added (see [Docker](#docker)).

###### Debian/Ubuntu:

```bash
apt update
apt install docker-compose-plugin
```

###### RHEL-based systems:

```bash
dnf update
dnf install docker-compose-plugin
```

###### Alpine Linux (e.g., 3.22):

```bash
apk add --no-cache --upgrade docker-cli-compose
```

!!! danger "Warning"
    For the plugin version, the command is **`docker compose`** (without a hyphen).

##### Installation as a Standalone Version

```bash
LATEST=$(curl -Ls -w %{url_effective} -o /dev/null https://github.com/docker/compose/releases/latest) && \
LATEST=${LATEST##*/} && \
curl -L https://github.com/docker/compose/releases/download/$LATEST/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

!!! danger "Warning"
    For the standalone version, the command is **`docker-compose`** (with a hyphen).

---

## SELinux Configuration (Optional)

On SELinux-enabled systems (e.g., CentOS 7):

1. Check if the `container-selinux` package is installed:

    ```bash
    rpm -qa | grep container-selinux
    ```

2. Enable SELinux support in Docker:

    - Edit `/etc/docker/daemon.json` and add `"selinux-enabled": true`:

      ```json
      {
        "selinux-enabled": true
      }
      ```

    - Restart the Docker daemon.

For more information, see the [container-selinux Readme](https://github.com/containers/container-selinux).

---

## Installing mailcow

1. Clone the repository:

    ```bash
    su
    umask 0022
    cd /opt
    git clone https://github.com/mailcow/mailcow-dockerized
    cd mailcow-dockerized
    ```

2. Generate the configuration file:

    ```bash
    ./generate_config.sh
    ```

3. Adjust the configuration if necessary:

    ```bash
    nano mailcow.conf
    ```

---

## Starting mailcow

Download the images and start the containers:

=== "Docker Compose (Plugin)"

    ```bash
    docker compose pull
    docker compose up -d
    ```

=== "Docker Compose (Standalone)"

    ```bash
    docker-compose pull
    docker-compose up -d
    ```
    
Done!

You can now access **`https://${MAILCOW_HOSTNAME}/admin`**  using the default credentials `admin` and the password `moohoo`.

---

## Troubleshooting

### MTU not equal to 1500 (e.g., OpenStack)

Adjust the network settings in `docker-compose.yml`:

```yaml
networks:
  mailcow-network:
    driver_opts:
      com.docker.network.driver.mtu: 1450
```

### No IPv6 on the Host System

Disable IPv6 for the mailcow network if your host system does not support IPv6. More information can be found [here](../post_installation/firststeps-disable_ipv6.en.md).

---

## Important Notes

- **Data Persistence**: Your data is stored in Docker volumes and remains intact even if you recreate or delete containers.
- **Reverse Proxy**: If you are not using a reverse proxy, you should [redirect HTTP to HTTPS](../manual-guides/u_e-80_to_443.md).
