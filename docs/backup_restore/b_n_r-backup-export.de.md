### Export von Backups

#### Sicherung
Es wird dringend empfohlen, den Mailserver regelmäßig zu sichern, um Datenverluste zu vermeiden. Zusätzlich sollte das Backup exportiert werden, um einen vollständigen Datenverlust zu verhindern.

Allgemeine Informationen zum Thema Sicherungen finden Sie im Kapitel [Sicherung](b_n_r-backup.md).

In diesem Kapitel werden die Möglichkeiten zum Export von Backups erläutert.

#### Borgmatic Backup
Borgmatic ist eine ausgezeichnete Lösung, um Backups auf Ihrem mailcow-Setup durchzuführen. Es bietet eine sichere Verschlüsselung Ihrer Daten und ist äußerst einfach einzurichten.

Darüber hinaus ist die Funktion zum Export von Backups bereits integriert.

Weitere Informationen zum Backup und Export mit Borgmatic finden Sie im Kapitel [Borgmatic Backup](../third_party/borgmatic/third_party-borgmatic.md).

#### Export via WebDAV, FTP/SFTP, NAS und S3 (V3)
Die Community-Erweiterung [mailcow-backup](https://github.com/the1andoni/mailcow-backup) ermöglicht den automatisierten Export und die Verschlüsselung von Backups auf externe Ziele.

!!! warning "Hinweis"
    Diese Funktion wird von der Community entwickelt. Der Link verweist auf ein externes GitHub-Repository.

**Funktionen der Version 3:**
* **Ziele:** Unterstützung für WebDAV, FTP/SFTP, NAS und S3-Cloud-Speicher.
* **Sicherheit:** Optionale Backup-Verschlüsselung und Nutzung gesicherter Protokolle.
* **Automatisierung:** Einfache Integration via Cronjob durch modulare Skripte.

Die Einrichtung und Konfiguration sind detailliert im [Repository](https://github.com/the1andoni/mailcow-backup) beschrieben.

Das Skript wird aktiv weiterentwickelt und um zusätzliche Funktionen ergänzt. Es wird grundsätzlich empfohlen, bei der Nutzung von FTP die Backups über TLS-Zertifikate zu exportieren (SFTP).
