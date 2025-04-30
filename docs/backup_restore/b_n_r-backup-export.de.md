### Export von Backups

#### Sicherung
Es wird dringend empfohlen, den Mailserver regelmäßig zu sichern, um Datenverluste zu vermeiden. Zusätzlich sollte das Backup exportiert werden, um einen vollständigen Datenverlust zu verhindern.

Allgemeine Informationen zum Thema Sicherungen finden Sie im Kapitel [Sicherung](https://docs.mailcow.email/de/backup_restore/b_n_r-backup/).

In diesem Kapitel werden die Möglichkeiten zum Export von Backups erläutert.

#### Borgmatic Backup
Borgmatic ist eine ausgezeichnete Lösung, um Backups auf Ihrem mailcow-Setup durchzuführen. Es bietet eine sichere Verschlüsselung Ihrer Daten und ist äußerst einfach einzurichten.

Darüber hinaus ist die Funktion zum Export von Backups bereits integriert.

Weitere Informationen zum Backup und Export mit Borgmatic finden Sie im Kapitel [Borgmatic Backup](https://docs.mailcow.email/de/third_party/borgmatic/third_party-borgmatic/).

#### Export via Nextcloud / sFTP
Mit dem Backup-Skript [mailcow-backup.sh](https://github.com/the1andoni/mailcow-backup.sh) können Backups auch per FTP oder Nextcloud exportiert werden.

!!! note
    Diese Funktion wird von der Community entwickelt. Der Link verweist auf ein externes (nicht mailcow-eigenes) GitHub-Repository.

Das Skript sammelt mithilfe der mailcow-eigenen Backup-Funktion alle erforderlichen Daten und verpackt diese in ein komprimiertes Verzeichnis.

Für die Einrichtung der Backups wird empfohlen, die Dokumentation des entsprechenden Repositories zu konsultieren.

Das Skript wird aktiv weiterentwickelt und um zusätzliche Funktionen ergänzt. Es wird grundsätzlich empfohlen, bei der Nutzung von FTP die Backups über TLS-Zertifikate zu exportieren.