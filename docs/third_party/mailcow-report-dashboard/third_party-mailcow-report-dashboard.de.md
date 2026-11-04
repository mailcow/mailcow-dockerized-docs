# DMARC/TLS Reports for mailcow

Ein Add-on, das die DMARC-Aggregate-Berichte (RUA) und SMTP-TLS-Berichte (TLS-RPT) sammelt, die andere Mailserver über Ihre Domains senden, und sie auf einer Seite in der mailcow-Oberfläche anzeigt, die nur Administratoren sehen. Es läuft als kleiner Container neben mailcow und verschickt nur dann eine Warnmail, wenn tatsächlich etwas nicht stimmt.

## Funktionen

- **In mailcow integriert**: Die Seite liegt unter `/admin/dmarc/`, nutzt die Admin-Anmeldung von mailcow und kann ins Apps-Menü aufgenommen werden (nur für Admins sichtbar). Kein zusätzlicher Webserver oder Port.
- **Minimale Rechte**: Der Container liest das Berichtspostfach per IMAP mit einem App-Passwort, das nur für dieses Postfach gilt. Kein Zugriff auf Docker-Socket, Datenbank oder vmail.
- **Warnungen nur bei echten Problemen**: TLS-Fehler bei Verbindungen zu Ihrem MX, DMARC-Fehler bei Mails Ihres eigenen Servers, nicht lesbare Berichte.
- **Übersicht**: Status pro Domain, Verlauf über 52 Wochen, Ergebnisse pro Empfänger (Google, Microsoft, ...), TLS-Fehler und Absender gefälschter Mails mit Reverse DNS.
- **DNS-Assistent**: Zeigt die TXT-Einträge, die jede Domain benötigt (DMARC `rua`, TLS-RPT, Freigabe externer Empfänger), und prüft sie live.
- **Echtzeit**: Neue Berichte werden innerhalb von Sekunden verarbeitet (IMAP IDLE).
- **Update-sicher**: Nutzt nur die Erweiterungspunkte von mailcow; alle 31 Sprachen der mailcow-Oberfläche sind enthalten.

## Installation

1.  Den Dienst in die `docker-compose.override.yml` im mailcow-Ordner eintragen (Datei anlegen, falls sie nicht existiert):

    ```yaml
    services:
      reports-mailcow:
        image: ghcr.io/thxgiving/dmarc-tls-reports-for-mailcow:latest
        restart: always
        depends_on:
          - nginx-mailcow
        environment:
          - SLUG=admin/dmarc
          - MAILCOW_HOSTNAME=${MAILCOW_HOSTNAME}
          - HTTPS_PORT=${HTTPS_PORT:-443}
          - SNAT_TO_SOURCE=${SNAT_TO_SOURCE:-}
          - SNAT6_TO_SOURCE=${SNAT6_TO_SOURCE:-}
          - TZ=${TZ}
        volumes:
          - ./data/web/admin/dmarc:/page
          - ./data/conf/nginx:/nginx-conf
          - ./data/web/css/build:/mailcow-css
          - reports-vol-1:/data
        networks:
          mailcow-network:
            aliases:
              - reports

    volumes:
      reports-vol-1:
    ```

2.  Starten:

    === "docker compose (Plugin)"
    
        ``` bash
        docker compose up -d
        ```
    
    === "docker-compose (Standalone)"
    
        ``` bash
        docker-compose up -d
        ```

3.  Als Admin `https://<mailcow-host>/admin/dmarc/` öffnen und den Einrichtungsassistenten abschließen (Berichtspostfach, Empfänger der Warnungen, Eintrag im Apps-Menü).

4.  Die vom DNS-Assistenten angezeigten DNS-Einträge anlegen, zum Beispiel:

    | Eintrag | Wert |
    |---|---|
    | `_smtp._tls.example.org` TXT | `v=TLSRPTv1; rua=mailto:reports@example.org` |
    | `_dmarc.example.org` TXT | `v=DMARC1; p=quarantine; rua=mailto:reports@example.org` |

Die ersten Berichte kommen in der Regel ein bis zwei Tage später an.

Update, Deinstallation und alle Details sind im [GitHub-Repository](https://github.com/ThxGiving/dmarc-tls-reports-for-mailcow) beschrieben.
