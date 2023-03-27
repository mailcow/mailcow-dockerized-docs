Zufällige Master-Benutzernamen und Passwörter werden automatisch bei jedem Neustart von dovecot-mailcow erstellt.

**Das wird empfohlen und sollte nicht geändert werden.**

Wenn der Benutzer trotzdem statisch sein soll, geben Sie bitte zwei Variablen in `mailcow.conf` an.

**Beide** Parameter dürfen nicht leer sein!

```
DOVECOT_MASTER_USER=mymasteruser
DOVECOT_MASTER_PASS=mysecretpass
```

Führen Sie folgenden Befehl aus, um Ihre Änderungen zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
	docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose up -d
    ```


Der statische Master-Benutzername wird zu `DOVECOT_MASTER_USER@mailcow.local` erweitert.

Um sich als `test@example.org` anzumelden, würde dies `test@example.org*mymasteruser@mailcow.local` mit dem oben angegebenen Passwort entsprechen.

Eine Anmeldung bei SOGo ist mit diesem Benutzernamen nicht möglich. Für Admins steht eine Click-to-Login-Funktion für SOGo zur Verfügung, wie [hier] beschrieben (https://mailcow.github.io/mailcow-dockerized-docs/debug-admin_login_sogo/)
Es wird kein Hauptbenutzer benötigt.