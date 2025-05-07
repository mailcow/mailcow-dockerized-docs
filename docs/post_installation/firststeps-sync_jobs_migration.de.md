Sync-Jobs dienen dazu, bestehende E-Mails entweder von einem externen IMAP-Server oder zwischen bestehenden Mailboxen innerhalb von mailcow zu kopieren oder zu verschieben.

!!! warning "Hinweis"
    Abhängig von den Zugriffsrechten (ACL) Ihrer Mailbox kann es sein, dass Sie keinen Sync-Job erstellen können. Wenden Sie sich in diesem Fall bitte an Ihren Domain-Administrator.

## Einrichten eines Sync-Jobs

1. Navigieren Sie zu „E-Mail :material-arrow-right: Konfiguration :material-arrow-right: Synchronisationen“ (bei Anmeldung als Admin oder Domain-Admin) oder zu „Benutzereinstellungen :material-arrow-right: Sync-Jobs“ (als normaler Mailbox-Nutzer), um einen neuen Sync-Job zu erstellen.

2. Wenn Sie als Administrator angemeldet sind, wählen Sie im Dropdown-Menü „Benutzername“ die Mailbox aus, in die die E-Mails kopiert werden sollen (Ziel-Mailbox).

3. Tragen Sie in den Feldern „Host“ und „Port“ die korrekten Verbindungsdaten des Quell-IMAP-Servers ein (von dem die E-Mails übertragen werden sollen).

4. Geben Sie unter „Benutzername“ und „Passwort“ die Zugangsdaten des Quellservers ein.

5. Wählen Sie die passende Verschlüsselungsmethode. Für Port 143 ist in der Regel TLS korrekt, während Port 993 meist mit SSL verwendet wird. Die Nutzung von PLAIN-Authentifizierung ist möglich, wird aber dringend abgeraten.

6. Alle weiteren Felder können bei den Standardwerten belassen oder nach Bedarf angepasst werden.

7. Aktivieren Sie das Kontrollkästchen „Aktiv“ und klicken Sie anschließend auf „Hinzufügen“.

!!! notice "Denken Sie dran..."
    Nach dem Einrichten sollten Sie sich in der Ziel-Mailbox anmelden und prüfen, ob alle E-Mails korrekt importiert wurden. Wenn alles erfolgreich war, befinden sich alle Nachrichten im neuen Postfach. Vergessen Sie nicht, den Sync-Job zu deaktivieren oder zu löschen, sobald er nicht mehr benötigt wird.