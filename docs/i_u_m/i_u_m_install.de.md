Sie benötigen Docker (eine Version >= `20.10.2` ist erforderlich) und Docker Compose (eine Version `>= 2.0` ist erforderlich).

**1\.** Erfahren Sie, wie Sie [Docker](https://docs.docker.com/install/) und [Docker Compose](https://docs.docker.com/compose/install/) installieren.

Schnelle Installation für die meisten Betriebssysteme:

- Docker
```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# Nachdem der Installationsprozess abgeschlossen ist, müssen Sie eventuell den Dienst aktivieren und sicherstellen, dass er gestartet ist (z. B. CentOS 7)
systemctl enable --now docker
```

- Docker-Compose

!!! danger "Achtung"
    **mailcow benötigt die neueste Version von Docker Compose v2.** Es wird dringend empfohlen, die untenstehenden Befehle zu verwenden, um Docker Compose zu installieren. Paket-Manager (z.B. `apt`, `yum`) werden **wahrscheinlich** nicht die richtige Version liefern.
    Hinweis: Dieser Befehl lädt Docker Compose aus dem offiziellen Docker-Github-Repository herunter und ist eine sichere Methode. Das Snippet ermittelt die neueste unterstützte Version von mailcow. In fast allen Fällen ist dies die letzte verfügbare Version (Ausnahmen sind kaputte Versionen oder größere Änderungen, die noch nicht von mailcow unterstützt werden).

```
curl -SL https://github.com/docker/compose/releases/download/v$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
```

Bitte verwenden Sie die neueste verfügbare Docker-Engine und nicht die Engine, die mit Ihrem Distros-Repository ausgeliefert wird.

**1.1.1.** Auf SELinux-aktivierten Systemen, z.B. CentOS 7:

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


**2\.** Klonen Sie den Master-Zweig des Repositorys und stellen Sie sicher, dass Ihre umask gleich 0022 ist. Bitte klonen Sie das Repository als root-Benutzer und kontrollieren Sie auch den Stack als root. Wir werden die Attribute - wenn nötig - ändern, während wir die Container automatisch bereitstellen und sicherstellen, dass alles gesichert ist. Das update.sh-Skript muss daher ebenfalls als root ausgeführt werden. Es kann notwendig sein, den Besitzer und andere Attribute von Dateien zu ändern, auf die Sie sonst keinen Zugriff haben. **Wir geben die Berechtigungen für jede exponierte Anwendung** auf und führen einen exponierten Dienst nicht als root aus! Wenn Sie den Docker-Daemon als Nicht-Root-Benutzer steuern, erhalten Sie keine zusätzliche Sicherheit. Der unprivilegierte Benutzer wird die Container ebenfalls als root spawnen. Das Verhalten des Stacks ist identisch.

```
$ su
# umask
0022 # <- Überprüfen, dass es 0022 ist
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

**3\.** Erzeugen Sie eine Konfigurationsdatei. Verwenden Sie einen FQDN (`host.domain.tld`) als Hostname, wenn Sie gefragt werden.
```
./generate_config.sh
```

**4\.** Ändern Sie die Konfiguration, wenn Sie das wollen oder müssen.
```
nano mailcow.conf
```
Wenn Sie planen, einen Reverse Proxy zu verwenden, können Sie zum Beispiel HTTPS an 127.0.0.1 auf Port 8443 und HTTP an 127.0.0.1 auf Port 8080 binden.

Möglicherweise müssen Sie einen vorinstallierten MTA stoppen, der Port 25/tcp blockiert. Siehe [dieses Kapitel](../post_installation/firststeps-local_mta.de.md), um zu erfahren, wie man Postfix rekonfiguriert, um nach einer erfolgreichen Installation neben mailcow laufen zu lassen.

Einige Updates modifizieren mailcow.conf und fügen neue Parameter hinzu. Es ist schwer, in der Dokumentation den Überblick zu behalten. Bitte überprüfen Sie deren Beschreibung und fragen Sie, wenn Sie unsicher sind, in den bekannten Kanälen nach Rat.

**4\.1\.** Benutzer mit einer MTU ungleich 1500 (z.B. OpenStack):

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

**4\.2\.** Benutzer ohne ein IPv6-aktiviertes Netzwerk auf ihrem Hostsystem:

**Einschalten von IPv6. Endlich.**

Wenn Sie kein IPv6-fähiges Netzwerk auf Ihrem Host haben und Sie sich nicht um ein besseres Internet kümmern (hehe), ist es empfehlenswert, IPv6 für das mailcow-Netzwerk zu [deaktivieren](../post_installation/firststeps-disable_ipv6.de.md), um unvorhergesehene Probleme zu vermeiden.


**5\.** LAden Sie die Images herunter und führen Sie die Compose-Datei aus. Der Parameter `-d` wird mailcow: dockerized starten:
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
