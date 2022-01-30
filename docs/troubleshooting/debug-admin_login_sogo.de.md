Dies ist eine experimentelle Funktion, die es Admins und Domänenadmins erlaubt, sich direkt als Mailbox-Benutzer direkt bei SOGo anzumelden, ohne das Passwort des Benutzers zu kennen.
Dazu wird ein zusätzlicher Link zu SOGo in der Mailbox-Liste (mailcow UI) angezeigt.

Auch mehrere gleichzeitige Admin-Logins auf verschiedene Postfächer sind mit dieser Funktion möglich.

## Aktivieren der Funktion

Die Funktion ist standardmäßig deaktiviert. Es kann in der `mailcow.conf` durch Setzen aktiviert werden:
```
ALLOW_ADMIN_EMAIL_LOGIN=y
```
und die betroffenen Container neu erstellen mit
```
docker-compose up -d
```

## Nachteile bei Aktivierung

- Jeder SOGo-Seiten-Load und jede Active-Sync-Anfrage verursacht eine zusätzliche Ausführung eines internen PHP-Skripts.
Dies kann die Ladezeiten von SOGo / EAS beeinträchtigen.
In den meisten Fällen sollte dies nicht spürbar sein, aber Sie sollten es im Hinterkopf behalten, wenn Sie Performance-Probleme haben.
- SOGo zeigt keinen Logout-Link für Admin-Logins an, um sich normal anzumelden, muss man sich von der mailcow UI abmelden, so dass die PHP-Sitzung zerstört wird.
- Das Abonnieren des Kalenders oder Adressbuchs eines anderen Nutzers, während man als Admin eingeloggt ist, funktioniert nicht. Ebenso wenig funktioniert das Einladen anderer Nutzer zu Kalender-Events. Die Seite wird neu geladen, wenn diese Dinge versucht werden.

## Technische Details

Die Option SOGoTrustProxyAuthentication ist auf YES gesetzt, so dass SOGo dem x-webobjects-remote-user-Header vertraut.

Dovecot erhält ein zufälliges Master-Passwort, das für alle Mailboxen gültig ist, wenn es vom SOGo-Container verwendet wird.

Ein Klick auf den SOGo-Button in der Mailbox-Liste öffnet die Datei sogo-auth.php, die Berechtigungen prüft, Session-Variablen setzt und auf die SOGo-Mailbox umleitet.

Jede SOGo, CardDAV, CalDAV und EAS http-Anfrage verursacht einen zusätzlichen, nginx-internen auth_request-Aufruf an sogo-auth.php mit folgendem Verhalten:

- Wenn ein basic_auth-Header vorhanden ist, wird das Skript die Anmeldedaten anstelle von SOGo validieren und die folgenden Header bereitstellen:
`x-webobjects-remote-user`, `Authorization` und `x-webobjects-auth-type`.

- Wenn kein basic_auth-Header vorhanden ist, wird das Skript nach einer aktiven Mailcow-Admin-Sitzung für den angeforderten E-Mail-Benutzer suchen und die gleichen Header bereitstellen, aber mit dem Dovecot-Master-Passwort, das im `Authorization`-Header verwendet wird.

- Wenn beides fehlschlägt, werden die Header leer gesetzt, was SOGo dazu bringt, seine Standard-Authentifizierungsmethoden zu verwenden.

Alle diese Optionen/Verhaltensweisen sind deaktiviert, wenn die Option `ALLOW_ADMIN_EMAIL_LOGIN` in der Konfiguration nicht aktiviert ist.