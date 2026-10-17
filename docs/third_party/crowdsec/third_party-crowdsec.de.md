# CrowdSec-Integration

[Mailcow-Crowdsec](https://github.com/JoeRu/Mailcow-Crowdsec) ist eine von der Community gepflegte Integration, die mailcow über `docker-compose.override.yml` um CrowdSec-Protokollanalyse und Firewall-Sperren erweitert. Zusätzliche Dienste werden eingebunden, ohne die ursprüngliche Compose-Datei von mailcow zu bearbeiten. Probleme mit der Integration bitte im [Issue-Tracker des Projekts](https://github.com/JoeRu/Mailcow-Crowdsec/issues) melden.

## Funktionen

- Liest Docker-Protokolle von Postfix, Dovecot und nginx mithilfe von CrowdSec-Collections sowie zusätzlichen lokalen Parsern und Szenarien.
- Setzt CrowdSec-Sperrentscheidungen mit einem iptables/ipset-Firewall-Bouncer in den Host-Ketten `INPUT`, `FORWARD` und `DOCKER-USER` um.
- Enthält konfigurierbare länderabhängige Regeln für die SMTP-Authentifizierung, Szenarien für wiederholte Angriffe und Freigabelisten für vertrauenswürdige IP-Adressen und CIDR-Netze.
- Nutzt Bedrohungsinformationen der CrowdSec-Community; die Registrierung in der CrowdSec Console ist optional.

## Voraussetzungen und Installation

Das Projekt setzt eine laufende mailcow-Installation auf einem Linux-Host, Docker Compose v2 sowie Root- oder sudo-Zugriff voraus. Das mitgelieferte Bouncer-Dockerfile lädt eine Linux-Binärdatei für **amd64** herunter; prüfen Sie die Kompatibilität bei anderen Architekturen.

Folgen Sie der gepflegten [Installationsanleitung](https://github.com/JoeRu/Mailcow-Crowdsec#installation). Die Einrichtung umfasst folgende Schritte:

1. Das Projektverzeichnis `crowdsec/` und die Compose-Override-Datei in das mailcow-Installationsverzeichnis kopieren. Existiert bereits eine Override-Datei, die Abschnitte `services:` und `volumes:` zusammenführen, statt die Datei zu überschreiben. Die ursprüngliche Compose-Datei von mailcow unverändert lassen.
2. Die Containernamen in `crowdsec/acquis.yaml` an die laufenden nginx-, Postfix- und Dovecot-Container anpassen.
3. `crowdsec/parsers/s02-enrich/whitelists.yaml` prüfen und vertrauenswürdige Administrations-, VPN- und Monitoring-Adressen vor dem Aktivieren der Sperren hinzufügen.
4. Die SMTP-Szenarien in `crowdsec/scenarios/` prüfen. Die mitgelieferten Länderregeln unterscheiden Deutschland (`DE`) von anderen Ländern; beide Regeln und ihre Schwellwerte an Ihre Benutzer anpassen.
5. CrowdSec starten und anhand der Erfassungsmetriken prüfen, ob alle drei Protokollquellen gelesen werden.
6. Den Firewall-Bouncer bei CrowdSec registrieren und dessen API-Schlüssel in eine Kopie von `crowdsec/cs-firewall-bouncer.yaml.example` mit dem Namen `crowdsec/cs-firewall-bouncer.yaml` eintragen.
7. `cs-firewall-bouncer` bauen und starten. Anschließend die Bouncer-Registrierung, Firewall-Ketten und Sperrentscheidungen gemäß der Projektanleitung prüfen.

!!! warning "Host-Zugriff und Sperrregeln prüfen"

    Der Bouncer verwendet das Host-Netzwerk und die Capabilities `NET_ADMIN` und `NET_RAW`, um die Host-Firewall zu ändern. Sperren können auch Dienste außerhalb von mailcow betreffen. Halten Sie einen Zugang zur Wiederherstellung bereit und prüfen Sie Freigabelisten und Szenarien, damit Sie sich selbst oder berechtigte Benutzer nicht aussperren.

    CrowdSec bindet `/var/run/docker.sock` schreibgeschützt ein, um Container-Protokolle zu lesen. Ein schreibgeschützter Socket-Mount beschränkt die Docker-API nicht auf Lesezugriffe; behandeln Sie dies als privilegierten Zugriff auf den Host.

## Sicherheit und Wartung

- Schützen Sie die Bouncer-Konfiguration: Sie enthält einen geheimen LAPI-API-Schlüssel und darf weder eingecheckt noch weitergegeben werden. Das Projekt schließt sie über `.gitignore` aus.
- Behalten Sie die mitgelieferte LAPI-Bindung an `127.0.0.1:8080` bei und prüfen Sie vor der Installation auf Portkonflikte.
- Prüfen Sie die Einstellungen zum Datenaustausch mit der CrowdSec-Community vor dem Aktivieren der Integration.
- Das CrowdSec-Image verwendet `latest`; der Bouncer-Build lädt standardmäßig die neueste Upstream-Version. Prüfen Sie Aktualisierungen; das Projekt beschreibt das Festlegen einer Bouncer-Version über das Build-Argument `VERSION`.
- Prüfen Sie Ihre Override-Datei und eigene Konfiguration nach mailcow-Updates. Beachten Sie die [Bouncer-Update-Anleitung](https://github.com/JoeRu/Mailcow-Crowdsec#upgrading-the-bouncer) des Projekts und prüfen Sie optionale Update-Hooks vor der Installation.

Informationen zur Verwaltung von Parsern, Szenarien und Sperrentscheidungen finden Sie in der [CrowdSec-Dokumentation](https://docs.crowdsec.net/).
