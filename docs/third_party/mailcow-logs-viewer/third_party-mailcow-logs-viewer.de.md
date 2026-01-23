# mailcow Logs Viewer

Ein modernes, selbst gehostetes Dashboard zur Anzeige und Analyse von mailcow-Mailserver-Logs. Entwickelt für Systemadministratoren und Techniker, die schnellen Zugriff auf den Mail-Zustellstatus, Spam-Analysen und Authentifizierungsfehler benötigen.

## Funktionen

- **Dashboard**: Echtzeit-Statistiken, Container-Status und Speichernutzung.
- **Nachrichten**: Einheitliche Ansicht von Postfix- und Rspamd-Daten mit intelligenter Korrelation.
- **Sicherheit**: Visualisierung von Netfilter-Logs für fehlgeschlagene Authentifizierungsversuche.
- **Domänen**: SPF-, DKIM- und DMARC-Validierung und Überwachung.
- **Postfach-Statistiken**: Statistiken zur Nutzung und zum Traffic pro Postfach.

## Installation

Sie können den Logs Viewer einfach mit Docker Compose ausführen.

1.  Erstellen Sie ein Verzeichnis und wechseln Sie hinein:
    ```bash
    mkdir mailcow-logs-viewer && cd mailcow-logs-viewer
    ```

2.  Laden Sie die Dateien [`docker-compose.yml`](https://github.com/ShlomiPorush/mailcow-logs-viewer/blob/main/docker-compose.yml) und [`env.example`](https://github.com/ShlomiPorush/mailcow-logs-viewer/blob/main/env.example) aus dem Repository herunter.

3.  Konfigurieren Sie Ihre `.env`-Datei mit Ihrer mailcow-URL und dem API-Schlüssel.

4.  Starten Sie den Container:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

5.  Zugriff auf das Dashboard unter `http://your-server-ip:8080`.

Für vollständige Installationsanweisungen und Konfigurationsoptionen besuchen Sie bitte den [Getting Started Guide](https://github.com/ShlomiPorush/mailcow-logs-viewer/blob/main/documentation/GETTING_STARTED.md) oder das [GitHub Repository](https://github.com/ShlomiPorush/mailcow-logs-viewer).
