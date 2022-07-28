Bitte erstellen Sie eine neue Datei `data/conf/postfix/extra.cf` für Überschreibungen oder zusätzliche Inhalte zur `main.cf`.

Postfix wird sich einmal nach dem Start von postfix-mailcow über doppelte Werte beschweren, dies ist beabsichtigt.

Syslog-ng wurde so konfiguriert, dass es diese Warnungen ausblendet, während Postfix läuft, um die Log-Dateien nicht jedes Mal mit unnötigen Informationen zu spammen, wenn ein Dienst benutzt wird.

Starten Sie `postfix-mailcow` neu, um Ihre Änderungen zu übernehmen:

```
docker compose restart postfix-mailcow
```
