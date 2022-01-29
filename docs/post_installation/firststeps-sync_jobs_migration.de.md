Sync-Aufträge werden verwendet, um bestehende E-Mails von einem externen IMAP-Server oder innerhalb von mailcow's bestehenden Mailboxen zu kopieren oder zu verschieben.

!!! info
    Abhängig von der ACL Ihrer Mailbox haben Sie möglicherweise nicht die Möglichkeit, einen Sync-Job hinzuzufügen. Bitte kontaktieren Sie in diesem Fall Ihren Domain-Administrator.

## Einrichten eines Sync-Jobs
1. Erstellen Sie unter dem Punkt "Konfiguration --> E-Mail-Setup" oder "Benutzereinstellungen" einen neuen Synchronisierungsauftrag.

2. Wenn Sie ein Administrator sind, wählen Sie den Benutzernamen der nachgelagerten mailcow-Mailbox im Dropdown-Menü "Benutzername".

3. Füllen Sie die Felder "Host" und "Port" mit den entsprechenden korrekten Werten des vorgelagerten IMAP-Servers aus.

4. Geben Sie in den Feldern "Benutzername" und "Passwort" die korrekten Zugangsdaten des vorgelagerten IMAP-Servers ein.

5. Wählen Sie die "Verschlüsselungsmethode". Wenn der vorgelagerte IMAP-Server Port 143 verwendet, ist es wahrscheinlich, dass die Verschlüsselungsmethode TLS und SSL für Port 993 ist. Sie können auch PLAIN-Authentifizierung verwenden, aber davon wird dringend abgeraten.

6. Alle anderen Felder können Sie so lassen, wie sie sind, oder sie nach Belieben ändern.

7. Vergewissern Sie sich, dass Sie "Aktiv" ankreuzen und klicken Sie auf "Hinzufügen".

!!! info
    Sobald Sie fertig sind, melden Sie sich in der Mailbox an und überprüfen Sie, ob alle E-Mails korrekt importiert wurden. Wenn alles gut geht, werden alle Ihre E-Mails in Ihrem neuen Postfach landen. Vergessen Sie nicht, den Synchronisierungsauftrag zu löschen oder zu deaktivieren, nachdem er verwendet wurde.