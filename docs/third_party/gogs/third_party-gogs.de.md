Mit Gogs' Fähigkeit, sich über SMTP zu authentifizieren, ist es einfach, es mit mailcow zu verbinden. Es sind nur wenige Änderungen erforderlich:

1\. Um eine Datenbank für Gogs zu erstellen, verbinden Sie sich mit ihrem Server und führen Sie folgende Befehle aus:
```
source mailcow.conf
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE gogs;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'gogs'@'%' IDENTIFIED BY 'your_strong_password';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON gogs.* TO 'gogs'@'%';
```

2\. Öffne `docker-compose.override.yml` und füge Gogs hinzu:

```yaml
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

3\. Erstelle `data/conf/nginx/site.gogs.custom`, füge hinzu:
```
location /gogs/ {
    proxy_pass http://gogs:3000/;
}
```

4\. Öffne `mailcow.conf` und definiere die Bindung, die Gogs für SSH verwenden soll. Beispiel:

```
GOGS_SSH_PORT=127.0.0.1:4000
```

5\. Führen Sie folgenden Befehl aus, um den Gogs-Container hochzufahren und führen Sie anschließend einen Neustart von NGINX mit dem zweiten Befehl durch:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
	docker compose restart nginx-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
	docker-compose restart nginx-mailcow
    ```

6\. Öffnen Sie `http://${MAILCOW_HOSTNAME}/gogs/`, zum Beispiel `http://mx.example.org/gogs/`. Für Datenbank-Details setzen Sie `mysql` als Datenbank-Host. Verwenden Sie gogs als Datenbankname, gogs als Datenbankbenutzer und your_strong_password als Datenbankpasswort, welches Sie in Schritt 1 definiert haben.

7\. Sobald die Installation abgeschlossen ist, loggen Sie sich als Administrator ein und setzen Sie "Einstellungen" -> "Autorisierung" -> "SMTP aktivieren". SMTP-Host sollte `postfix` mit Port `587` sein, setzen Sie `Skip TLS Verify`, da wir ein nicht gelistetes SAN verwenden ("postfix" ist höchstwahrscheinlich nicht Teil Ihres Zertifikats).

8\. Erstellen Sie `data/gogs/gogs/conf/app.ini` und setzen Sie die folgenden Werte. Sie können [Gogs cheat sheet](https://gogs.io/docs/advanced/configuration_cheat_sheet) für ihre Bedeutung und andere mögliche Werte konsultieren.

```ini
[server]
SSH_LISTEN_PORT = 22
# Für GOGS_SSH_PORT=127.0.0.1:4000 in mailcow.conf, setzen:
SSH_DOMAIN = 127.0.0.1
SSH_PORT = 4000
# Für MAILCOW_HOSTNAME=mx.example.org in mailcow.conf (und Standard-Ports für HTTPS), setzen:
ROOT_URL = https://mx.example.org/gogs/
```

9\. Starten Sie Gogs neu mit dem kommenden Befehl. Ihre Nutzer sollten in der Lage sein, sich mit von mailcow verwalteten Konten anzumelden.

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart gogs-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart gogs-mailcow
    ```

