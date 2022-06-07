Mit Gogs' Fähigkeit, sich über SMTP zu authentifizieren, ist es einfach, es mit mailcow zu verbinden. Es sind nur wenige Änderungen erforderlich:

1\. Öffne `docker-compose.override.yml` und füge Gogs hinzu:

```
version: '2.1'
services:

    gogs-mailcow:
      image: gogs/gogs
      volumes:
        - ./data/gogs:/data
      networks:
        mailcow-network:
          aliases:
            - gogs
      ports:
        - "${GOGS_SSH_PORT:-127.0.0.1:4000}:22"
```

2\. Erstelle `data/conf/nginx/site.gogs.custom`, füge hinzu:
```
location /gogs/ {
    proxy_pass http://gogs:3000/;
}
```

3\. Öffne `mailcow.conf` und definiere die Bindung, die Gogs für SSH verwenden soll. Beispiel:

```
GOGS_SSH_PORT=127.0.0.1:4000
```

5\. Führen Sie `docker compose up -d` aus, um den Gogs-Container hochzufahren und führen Sie anschließend `docker compose restart nginx-mailcow` aus.

6\. Öffnen Sie `http://${MAILCOW_HOSTNAME}/gogs/`, zum Beispiel `http://mx.example.org/gogs/`. Für Datenbank-Details setzen Sie `mysql` als Datenbank-Host. Verwenden Sie den in mailcow.conf gefundenen Wert von DBNAME als Datenbankname, DBUSER als Datenbankbenutzer und DBPASS als Datenbankpasswort.

7\. Sobald die Installation abgeschlossen ist, loggen Sie sich als Administrator ein und setzen Sie "Einstellungen" -> "Autorisierung" -> "SMTP aktivieren". SMTP-Host sollte `postfix` mit Port `587` sein, setzen Sie `Skip TLS Verify`, da wir ein nicht gelistetes SAN verwenden ("postfix" ist höchstwahrscheinlich nicht Teil Ihres Zertifikats).

8\. Erstellen Sie `data/gogs/gogs/conf/app.ini` und setzen Sie die folgenden Werte. Sie können [Gogs cheat sheet](https://gogs.io/docs/advanced/configuration_cheat_sheet) für ihre Bedeutung und andere mögliche Werte konsultieren.

```
[server]
SSH_LISTEN_PORT = 22
# Für GOGS_SSH_PORT=127.0.0.1:4000 in mailcow.conf, setzen:
SSH_DOMAIN = 127.0.0.1
SSH_PORT = 4000
# Für MAILCOW_HOSTNAME=mx.example.org in mailcow.conf (und Standard-Ports für HTTPS), setzen:
ROOT_URL = https://mx.example.org/gogs/
```

9\. Starten Sie Gogs neu mit `docker compose restart gogs-mailcow`. Ihre Benutzer sollten in der Lage sein, sich mit von mailcow verwalteten Konten einzuloggen.

