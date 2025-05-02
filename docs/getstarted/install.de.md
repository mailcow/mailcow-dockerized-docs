!!! success "Überall gleich"
    Die Installation ist auf x86 und ARM64 exakt identisch!

## Docker und Docker Compose Installation

Sie benötigen Docker (eine Version >= `24.0.0` ist erforderlich) und Docker Compose (eine Version `>= 2.0` ist erforderlich).

Erfahren Sie, wie Sie [Docker](https://docs.docker.com/install/) und [Docker Compose](https://docs.docker.com/compose/install/) installieren.

Schnelle Installation für die meisten Betriebssysteme:

### Docker

!!! danger "Wichtig"
    Bitte verwenden Sie die neueste verfügbare Docker-Engine und nicht die Engine, die mit den Paket Quellen ihrer Linux Distribution ausgeliefert wird.

#### Auf Debian/Ubuntu-Systemen:

``` bash
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
systemctl enable --now docker
```

#### Auf RHEL-basierten Systemen (z. B. Rocky Linux 9):

``` bash
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
```

!!! info "Hinweis"
    Das praktische get Docker Skript funktioniert für RHEL Systeme nicht zuverlässig, daher muss bei diesen eine manuelle Einbindung erfolgen.

### docker compose

!!! danger "Achtung"
    **mailcow benötigt eine Version von Docker Compose >= v2**.
    <br>Sollte die Installation von Docker über das obenstehende Skript erfolgt sein wird das Docker Compose Plugin bereits automatisch
    in einer Version >=2.0 installiert. <br>
    Ist die mailcow Installation älter oder Docker wurde auf einem anderen Weg installiert, muss das Compose Plugin bzw. die Standalone Version von Docker manuell installiert werden.

#### Installation via Paketmanager (Plugin)

!!! info "Hinweis"
    Diese Vorgehensweise mit den Paketquellen ist nur dann möglich, wenn das Docker Repository eingebunden wurde. Dies kann entweder durch die Anleitung oben (siehe [Docker](#docker)) oder durch eine manuelle Einbindung passieren.

Auf Debian/Ubuntu Systemen:

``` bash
apt update
apt install docker-compose-plugin
```

Auf RHEL-basierten Systemen (z. B. Rocky Linux 9):

``` bash
dnf update
dnf install docker-compose-plugin
```

!!! danger "Achtung"
    Die Syntax der Docker Compose Befehle lautet **`docker compose`** bei der **Plugin Variante** von Docker Compose!!

#### Installation via Script (Standalone)

!!! info "Hinweis"
    Diese Installation ist die alt bekannte Weise. Sie installiert Docker Compose als Standalone Programm und ist nicht auf die Art und weise der Docker Installation angewiesen.

```
LATEST=$(curl -Ls -w %{url_effective} -o /dev/null https://github.com/docker/compose/releases/latest) && LATEST=${LATEST##*/} && curl -L https://github.com/docker/compose/releases/download/$LATEST/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

!!! danger "Achtung"
    Die Syntax der Docker Compose Befehle lautet **`docker-compose`** bei der **Standalone Variante** von Docker Compose!!

## SELinux Besonderheiten prüfen
Auf SELinux-aktivierten Systemen, z.B. CentOS 7:

- Prüfen Sie, ob das Paket "container-selinux" auf Ihrem System vorhanden ist:

```
rpm -qa | grep container-selinux
```

Wenn der obige Befehl eine leere oder keine Ausgabe liefert, sollten Sie es über Ihren Paketmanager installieren.

- Prüfen Sie, ob Docker SELinux-Unterstützung aktiviert hat:

```
docker info | grep selinux
```

Wenn der obige Befehl eine leere oder keine Ausgabe liefert, erstellen oder bearbeiten Sie `/etc/docker/daemon.json` und fügen Sie `"selinux-enabled": true` hinzu. Beispielhafter Inhalt der Datei:

```
{
  "selinux-enabled": true
}
```

Starten Sie den Docker-Daemon neu und überprüfen Sie, ob SELinux nun aktiviert ist.

Dieser Schritt ist erforderlich, um sicherzustellen, dass die mailcows-Volumes richtig gekennzeichnet sind, wie in der Compose-Datei angegeben.
Wenn Sie daran interessiert sind, wie das funktioniert, können Sie sich die Readme-Datei von https://github.com/containers/container-selinux ansehen, die auf viele nützliche Informationen zu diesem Thema verweist.


## mailcow Installieren
 Klonen Sie den Master-Zweig des Repositorys und stellen Sie sicher, dass Ihre umask gleich 0022 ist. Bitte klonen Sie das Repository als root-Benutzer und kontrollieren Sie auch den Stack als root. Wir werden die Attribute - wenn nötig - ändern, während wir die Container automatisch bereitstellen und sicherstellen, dass alles gesichert ist. Das update.sh-Skript muss daher ebenfalls als root ausgeführt werden. Es kann notwendig sein, den Besitzer und andere Attribute von Dateien zu ändern, auf die Sie sonst keinen Zugriff haben. **Wir geben die Berechtigungen für jede exponierte Anwendung** auf und führen einen exponierten Dienst nicht als root aus! Wenn Sie den Docker-Daemon als Nicht-Root-Benutzer steuern, erhalten Sie keine zusätzliche Sicherheit. Der unprivilegierte Benutzer wird die Container ebenfalls als root spawnen. Das Verhalten des Stacks ist identisch.

```
$ su
# umask
0022 # <- Überprüfen, dass es 0022 ist
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

## mailcow Initialisieren
Erzeugen Sie eine Konfigurationsdatei. Verwenden Sie einen FQDN (`host.domain.tld`) als Hostname, wenn Sie gefragt werden.
```
./generate_config.sh
```

Ändern Sie die Konfiguration, wenn Sie wollen oder müssen.
```
nano mailcow.conf
```
Wenn Sie planen, einen Reverse Proxy zu verwenden, können Sie zum Beispiel HTTPS an 127.0.0.1 auf Port 8443 und HTTP an 127.0.0.1 auf Port 8080 binden.

Möglicherweise müssen Sie einen vorinstallierten MTA stoppen, der Port 25/tcp blockiert. Siehe [dieses Kapitel](../post_installation/firststeps-local_mta.de.md), um zu erfahren, wie man Postfix rekonfiguriert, um nach einer erfolgreichen Installation neben mailcow laufen zu lassen.

Einige Updates modifizieren mailcow.conf und fügen neue Parameter hinzu. Es ist schwer, in der Dokumentation den Überblick zu behalten. Bitte überprüfen Sie deren Beschreibung und fragen Sie, wenn Sie unsicher sind, in den bekannten Kanälen nach Rat.

## Problembehandlungen

### Benutzer mit einer MTU ungleich 1500 (z.B. OpenStack)
**Wenn Sie auf Probleme und seltsame Phänomene stoßen, überprüfen Sie bitte Ihre MTU.**

Bearbeiten Sie `docker-compose.yml` und ändern Sie die Netzwerkeinstellungen entsprechend Ihrer MTU.
Fügen Sie den neuen Parameter driver_opts wie folgt hinzu:
```
networks:
  mailcow-network:
    ...
    driver_opts:
      com.docker.network.driver.mtu: 1450
    ...
```

### Benutzer ohne ein IPv6-aktiviertes Netzwerk auf ihrem Hostsystem

**Schalten Sie IPv6 bitte nicht ab, auch wenn es Ihnen nicht gefällt. IPv6 ist die Zukunft und sollte nicht ignoriert werden.**

Sollten Sie jedoch kein IPv6-fähiges Netzwerk auf Ihrem Host haben und Sie sich nicht um ein besseres Internet kümmern wollen (hehe), ist es empfehlenswert, IPv6 für das mailcow-Netzwerk zu [deaktivieren](../post_installation/firststeps-disable_ipv6.de.md), um unvorhergesehene Probleme zu vermeiden.


## mailcow starten
Laden Sie die Images herunter und führen Sie die Compose-Datei aus. Der Parameter `-d` wird ihre mailcow dann im Hintergrund starten:
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

Geschafft!

=== "Post 2025-03 (LDAP-Patch)"

    !!! warning "Wichtig"
        Die Logins sind seit 2025-03 getrennt.

    - **Administratoren**:  
      Sie können sich jetzt als Administrator mit den Standard-Zugangsdaten `admin` und dem Passwort `moohoo` unter folgender Adresse anmelden:  
      **`https://${MAILCOW_HOSTNAME}/admin`**

    - **Normale Mailbox-Benutzer**:  
      Loggen sich wie gewohnt hier ein:  
      **`https://${MAILCOW_HOSTNAME}`** (nur FQDN)

    - **Domänen-Administratoren**:  
      Bitte nutzen Sie die separate Login-Adresse:  
      **`https://${MAILCOW_HOSTNAME}/domainadmin`**

=== "Pre 2025-03 (LDAP-Patch)"

    Sie können nun unter  **`https://${MAILCOW_HOSTNAME}`**  mit den Standard-Zugangsdaten `admin` und dem Passwort `moohoo` zugreifen.

!!! info
    Wenn Sie mailcow nicht hinter einem Reverse Proxy verwenden, sollten Sie [alle HTTP-Anfragen auf HTTPS umleiten](../manual-guides/u_e-80_to_443.md).

Die Datenbank wird sofort initialisiert, nachdem eine Verbindung zu MySQL hergestellt werden kann.

Ihre Daten bleiben in mehreren Docker-Volumes erhalten, die nicht gelöscht werden, wenn Sie Container neu erstellen oder löschen. Führen Sie `docker volume ls` aus, um eine Liste aller Volumes zu sehen. Sie können `docker compose down` sicher ausführen, ohne persistente Daten zu entfernen.
