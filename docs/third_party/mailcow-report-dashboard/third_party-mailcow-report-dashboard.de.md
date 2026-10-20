# mailcow Report Dashboard

Ein Add-on, das die DMARC-Aggregate-Berichte (RUA) und SMTP-TLS-Berichte (TLS-RPT) sammelt, die andere Mailserver über Ihre Domains senden, und sie auf einer Seite in der mailcow-Oberfläche anzeigt, die nur Administratoren sehen. Eine Warnmail wird nur verschickt, wenn tatsächlich etwas nicht stimmt.

## Funktionen

- **In mailcow integriert**: Die Seite erscheint im Apps-Menü und nutzt die Admin-Anmeldung von mailcow. Kein zusätzlicher Container, Webserver oder Port.
- **Warnungen nur bei echten Problemen**: TLS-Fehler bei Verbindungen zu Ihrem MX, DMARC-Fehler bei Mails Ihres eigenen Servers, nicht lesbare Berichte.
- **Übersicht**: Status pro Domain, Verlauf über 52 Wochen, Ergebnisse pro Empfänger (Google, Microsoft, ...), TLS-Fehler und Absender gefälschter Mails mit Reverse DNS.
- **DNS-Assistent**: Zeigt die TXT-Einträge, die jede Domain benötigt (DMARC `rua`, TLS-RPT, Freigabe externer Empfänger), und prüft sie live.
- **Sofortige Verarbeitung**: Neue Berichte werden verarbeitet, sobald sie im Berichtspostfach ankommen.
- **Update-sicher**: Nutzt nur die Erweiterungspunkte von mailcow (`data/conf/nginx/*.custom`, App-Links), alle 31 Sprachen der mailcow-Oberfläche sind enthalten.

## Installation

Das Add-on läuft auf dem mailcow-Host (root, `python3` ab 3.8, systemd).

1.  Repository klonen und den Installer ausführen:
    ```bash
    git clone https://github.com/ThxGiving/mailcow-report-dashboard.git
    cd mailcow-report-dashboard
    sudo ./install.sh --language de-de --alert-to postmaster@example.org
    ```

2.  In der mailcow-Oberfläche **Apps → Zustellberichte** öffnen, zu **Einstellungen** wechseln und das Postfach auswählen oder anlegen, das die Berichte empfangen soll.

3.  Die vom DNS-Assistenten angezeigten DNS-Einträge anlegen, zum Beispiel:

    | Eintrag | Wert |
    |---|---|
    | `_smtp._tls.example.org` TXT | `v=TLSRPTv1; rua=mailto:reports@example.org` |
    | `_dmarc.example.org` TXT | `v=DMARC1; p=quarantine; rua=mailto:reports@example.org` |

Die ersten Berichte kommen in der Regel ein bis zwei Tage später an.

Alle Optionen sowie Update und Deinstallation sind im [GitHub-Repository](https://github.com/ThxGiving/mailcow-report-dashboard) beschrieben.
