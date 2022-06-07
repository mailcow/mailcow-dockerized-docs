Sie benötigen Docker (eine Version >= `20.10.2` ist erforderlich) und Docker Compose (eine Version `>= 2.0` ist erforderlich).

## Installation von Docker
Erfahren Sie, wie Sie [Docker](https://docs.docker.com/install/) allgemein installieren.

Schnelle Installation für die meisten Betriebssysteme:

```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# Nachdem der Installationsprozess abgeschlossen ist, müssen Sie eventuell den Dienst aktivieren und sicherstellen, dass er gestartet ist (z. B. CentOS 7)
systemctl enable --now docker
```

**Bitte verwenden Sie die neueste verfügbare Docker-Engine und nicht die Engine, die mit Ihrem Distro-Repository ausgeliefert wird.**

**Auf SELinux-aktivierten Systemen, z.B. CentOS 7:**

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

## Installation von Docker Compose v2

!!! danger "Achtung"
    Seit Juni 2022 wurde Docker Compose v1 in der mailcow durch Docker Compose v2 abgelöst. <br>
    **Docker Compose v1 verliert den offiziellen Support seitens Docker im Oktober 2022.** <br>
    _mailcow unterstützt bis Dezember 2022 Docker Compose v1. Danach ist die Installation **unumgänglich**, sollten Sie mailcow **weiter betreiben** wollen._

!!! bug "Kompatibilität"
    Das Webinterface wird im Zeitraum von Juni - Dezember 2022 standardmäßig nur über v4 erreichbar sein.<br>
    Der Grund dafür ist die Dual-Kompatibilität zwischen Compose v1 und v2. <br>
    Sollten Sie das Webinterface, wie bisher standardmäßig über v6 erreichen wollen, werfen Sie bitte einen Blick auf [dieses Kapitel](../post_installation/firststeps-ip_bindings.de.md#ipv6-binding). <br>
    **Mit dem 2022-12 Update wird die native IPv6 Erreichbarkeit der Weboberfläche wiederhergestellt.**

Sollten Sie mailcow frisch installieren und Docker auf die oben stehende Weise installiert haben, wird Docker Compose v2 schon mit installiert. Sie müssen also nichts weiter tun.

Prüfen lässt sich dies mit `docker compose version`, wenn die Rückgabe in etwa so aussieht: `Docker Compose version v2.5.0`, dann ist das neue Docker Compose bereits auf Ihrem System installiert.

Falls es nicht installiert ist oder Sie von Docker-Compose v1 auf v2 Upgraden möchten folgen Sie einfach der Anleitung:

#### Docker Compose v1 deinstallieren
**Sollten Sie den mailcow Stack bereits mit docker-compose v1 betreiben, stellen Sie sicher, dass Sie den mailcow Stack vor dem Upgrade auf Compose v2 heruntergefahren und das aktuellste Update installiert haben**

Um Docker Compose v1 zu deinstallieren geben Sie folgenden Befehl ein:

```
rm -rf /usr/local/bin/docker-compose
```

#### Docker Compose v2 installieren

Docker Compose v2 kommt (vorausgesetzt Sie haben die Anleitung bei Punkt [Installation von Docker](#installation-von-docker) befolgt) mit dem Repository mit.

Dann ist die Installation ganz einfach:

```
apt install docker-compose-plugin -y
```

Nun noch einmal `docker compose version` eingeben und die Rückgabe überprüfen. Ist diese ähnlich zu: `Docker Compose version v2.5.0`? Dann ist alles korrekt installiert worden!

!!! warning "Hinweis"
    Sollten Sie ein anderes Betriebssystem als Debian/Ubuntu verwenden, werfen Sie bitte einen Blick in das [offizielle Installationshandbuch](https://docs.docker.com/compose/install/#install-compose-on-linux-systems) von Docker selbst, um zu erfahren wie Sie Docker Compose v2 auf anderen Linux Systemen installieren können.

## Installation von mailcow

 **1\.** Klonen Sie den Master-Zweig des Repositorys und stellen Sie sicher, dass Ihre umask gleich 0022 ist. 
 Bitte klonen Sie das Repository als root-Benutzer und kontrollieren Sie auch den Stack als root. 
 Wir werden die Attribute - wenn nötig - ändern, während wir die Container automatisch bereitstellen und sicherstellen, dass alles gesichert ist. 
 Das update.sh-Skript muss daher ebenfalls als root ausgeführt werden. 
 Es kann notwendig sein, den Besitzer und andere Attribute von Dateien zu ändern, auf die Sie sonst keinen Zugriff haben. 
 **Wir geben die Berechtigungen für jede exponierte Anwendung** auf und führen einen exponierten Dienst nicht als root aus! 
 Wenn Sie den Docker-Daemon als Nicht-Root-Benutzer steuern, erhalten Sie keine zusätzliche Sicherheit. 
 Der unprivilegierte Benutzer wird die Container ebenfalls als root spawnen. Das Verhalten des Stacks ist identisch.

```
$ su
# umask
0022 # <- Überprüfen, dass es 0022 ist
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

**2\.** Erzeugen Sie eine Konfigurationsdatei. Verwenden Sie einen FQDN (`host.domain.tld`) als Hostname, wenn Sie gefragt werden.
```
./generate_config.sh
```

**3\.** Ändern Sie die Konfiguration, wenn Sie das wollen oder müssen.
```
nano mailcow.conf
```
Wenn Sie planen, einen Reverse Proxy zu verwenden, können Sie zum Beispiel HTTPS an 127.0.0.1 auf Port 8443 und HTTP an 127.0.0.1 auf Port 8080 binden.

Möglicherweise müssen Sie einen vorinstallierten MTA stoppen, der Port 25/tcp blockiert. Siehe [dieses Kapitel](../post_installation/firststeps-local_mta.de.md), um zu erfahren, wie man Postfix rekonfiguriert, um nach einer erfolgreichen Installation neben mailcow laufen zu lassen.

Einige Updates modifizieren mailcow.conf und fügen neue Parameter hinzu. Es ist schwer, in der Dokumentation den Überblick zu behalten. Bitte überprüfen Sie deren Beschreibung und fragen Sie, wenn Sie unsicher sind, in den bekannten Kanälen nach Rat.

**3\.1\.** Benutzer mit einer MTU ungleich 1500 (z.B. OpenStack):

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

**3\.2\.** Benutzer ohne ein IPv6-aktiviertes Netzwerk auf ihrem Hostsystem:

**Einschalten von IPv6. Endlich.**

Wenn Sie kein IPv6-fähiges Netzwerk auf Ihrem Host haben und Sie sich nicht um ein besseres Internet kümmern (hehe), ist es empfehlenswert, IPv6 für das mailcow-Netzwerk zu [deaktivieren](../post_installation/firststeps-disable_ipv6.de.md), um unvorhergesehene Probleme zu vermeiden.


**4\.** Laden Sie die Images herunter und führen Sie die Compose-Datei aus. Der Parameter `-d` wird mailcow: dockerized starten:
```
docker compose pull
docker compose up -d
```

Geschafft!

Sie können nun auf **https://${MAILCOW_HOSTNAME}** mit den Standard-Zugangsdaten `admin` + Passwort `moohoo` zugreifen.

!!! info
    Wenn Sie mailcow nicht hinter einem Reverse Proxy verwenden, sollten Sie [alle HTTP-Anfragen auf HTTPS umleiten](../manual-guides/u_e-80_to_443.md).

Die Datenbank wird sofort initialisiert, nachdem eine Verbindung zu MySQL hergestellt werden kann.

Ihre Daten bleiben in mehreren Docker-Volumes erhalten, die nicht gelöscht werden, wenn Sie Container neu erstellen oder löschen. Führen Sie `docker volume ls` aus, um eine Liste aller Volumes zu sehen. Sie können `docker compose down` sicher ausführen, ohne persistente Daten zu entfernen.
