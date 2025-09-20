# Installation von mailcow

## Voraussetzungen

### Systempakete

Die folgenden Linux-Pakete sind für die Nutzung von mailcow erforderlich und müssen je nach Ihrer Distribution gegebenenfalls nachinstalliert werden:

- git
- openssl
- curl
- awk
- sha1sum
- grep
- cut
- jq (**neu ab [2025-09](https://mailcow.email/posts/2025/release-2025-09/#2025-09-release-10th-september-2025)**)

### Docker und Docker Compose

Für die Installation benötigen Sie:

- **Docker**: Version `>= 24.0.0`
- **Docker Compose**: Version `>= 2.0`

Anleitungen zur Installation finden Sie hier:

- [Docker installieren](https://docs.docker.com/install/)
- [Docker Compose installieren](https://docs.docker.com/compose/install/)

### Schnellinstallation

#### Systempakete

##### Debian/Ubuntu:

``` bash
apt update
apt install -y git openssl curl gawk coreutils grep jq
```

##### RHEL-basierte Systeme (z.B. Rocky Linux 9):
``` bash
dnf install -y git openssl curl gawk coreutils grep jq
```

##### Alpine Linux (bspw. 3.22):
```bash
apk add --no-cache --upgrade sed findutils bash git openssl curl gawk coreutils grep jq
```

!!! info "Hinweis"
    Alle Programme, die nicht explizit im Installationsprozess aufgeführt sind, sind bereits als Unterprogramme in `coreutils` enthalten.

#### Docker

!!! danger "Wichtig"
    Verwenden Sie die **neueste verfügbare Docker-Engine** und nicht die Version aus den Paketquellen Ihrer Linux-Distribution.

##### Debian/Ubuntu:

```bash
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
systemctl enable --now docker
```

##### RHEL-basierte Systeme (z. B. Rocky Linux 9):

```bash
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
```

##### Alpine Linux (bspw. 3.22):

```bash
apk --no-cache --upgrade add docker
rc-update add docker default
rc-service docker start
```

!!! info "Hinweis"
    Das `get.docker.com`-Skript funktioniert auf RHEL und Alpine Linux Systemen nicht zuverlässig oder gar nicht. Verwenden Sie stattdessen die manuelle Methode.

#### Docker Compose

!!! danger "Achtung"
    **mailcow benötigt Docker Compose in Version `>= 2.0`.**

##### Installation über Paketmanager (Plugin)

!!! info "Hinweis"
    Diese Methode setzt voraus, dass das Docker-Repository eingebunden wurde (siehe [Docker](#docker)).

###### Debian/Ubuntu:

```bash
apt update
apt install docker-compose-plugin
```

###### RHEL-basierte Systeme:

```bash
dnf update
dnf install docker-compose-plugin
```

###### Alpine Linux (bspw. 3.22):

```bash
 apk add --no-cache --upgrade docker-cli-compose
```

!!! danger "Achtung"
    Bei der Plugin-Variante lautet der Befehl **`docker compose`** (ohne Bindestrich).

##### Installation als Standalone-Version

```bash
LATEST=$(curl -Ls -w %{url_effective} -o /dev/null https://github.com/docker/compose/releases/latest) && \
LATEST=${LATEST##*/} && \
curl -L https://github.com/docker/compose/releases/download/$LATEST/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

!!! danger "Achtung"
    Bei der Standalone-Version lautet der Befehl **`docker-compose`** (mit Bindestrich).

---

## SELinux-Konfiguration (optional)

Auf SELinux-aktivierten Systemen (z. B. CentOS 7):

1. Prüfen Sie, ob das Paket `container-selinux` installiert ist:

    ```bash
    rpm -qa | grep container-selinux
    ```

2. Aktivieren Sie die SELinux-Unterstützung in Docker:

    - Bearbeiten Sie `/etc/docker/daemon.json` und fügen Sie `"selinux-enabled": true` hinzu:

      ```json
      {
        "selinux-enabled": true
      }
      ```

    - Starten Sie den Docker-Daemon neu.

Weitere Informationen finden Sie in der [container-selinux-Readme](https://github.com/containers/container-selinux).

---

## Installation von mailcow

1. Klonen Sie das Repository:

    ```bash
    su
    umask 0022
    cd /opt
    git clone https://github.com/mailcow/mailcow-dockerized
    cd mailcow-dockerized
    ```

2. Generieren Sie die Konfigurationsdatei:

    ```bash
    ./generate_config.sh
    ```

3. Passen Sie die Konfiguration bei Bedarf an:

    ```bash
    nano mailcow.conf
    ```

---

## Starten von mailcow

Laden Sie die Images herunter und starten Sie die Container:

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

Geschafft!

Sie können nun unter  **`https://${MAILCOW_HOSTNAME}/admin`**  mit den Standard-Zugangsdaten `admin` und dem Passwort `moohoo` zugreifen.

---

## Problembehandlung

### MTU ungleich 1500 (z. B. OpenStack)

Passen Sie die Netzwerkeinstellungen in `docker-compose.yml` an:

```yaml
networks:
  mailcow-network:
    driver_opts:
      com.docker.network.driver.mtu: 1450
```

### Kein IPv6 auf dem Hostsystem

Deaktivieren Sie IPv6 für das mailcow-Netzwerk, falls Ihr Hostsystem kein IPv6 unterstützt. Weitere Informationen finden Sie [hier](../post_installation/firststeps-disable_ipv6.de.md).

---

## Wichtige Hinweise

- **Datenpersistenz**: Ihre Daten werden in Docker-Volumes gespeichert und bleiben erhalten, auch wenn Sie Container neu erstellen oder löschen.
- **Reverse Proxy**: Wenn Sie keinen Reverse Proxy verwenden, sollten Sie [HTTP auf HTTPS umleiten](../manual-guides/u_e-80_to_443.md).
