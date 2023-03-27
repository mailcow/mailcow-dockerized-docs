Mit der Fähigkeit von Gitea, sich über SMTP zu authentifizieren, ist es trivial, es mit mailcow zu integrieren. Es sind nur wenige Änderungen erforderlich:

1\. Um eine Datenbank für Gitea zu erstellen, verbinden Sie sich mit ihrem Server und führen Sie folgende Befehle aus:
```
source mailcow.conf
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE gitea;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'gitea'@'%' IDENTIFIED BY 'your_strong_password';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON gitea.* TO 'gitea'@'%';
```

2\. Öffnen Sie `docker-compose.override.yml` und fügen Sie Gitea hinzu:

```yaml
version: '2.1'
services:

		gitea-mailcow:
			image: gitea/gitea:1
			volumes:
				- ./data/gitea:/data
			networks:
				mailcow-network:
					aliases:
						- gitea
			ports:
				- "${GITEA_SSH_PORT:-127.0.0.1:4000}:22"
```

3\. Erstellen Sie `data/conf/nginx/site.gitea.custom`, fügen Sie folgendes hinzu:
```
location /gitea/ {
		proxy_pass http://gitea:3000/;
}
```

4\. Öffne `mailcow.conf` und definiere den Port Bind, den Gitea für SSH verwenden soll. Beispiel:

```
GITEA_SSH_PORT=127.0.0.1:4000
```

5\. Führen Sie folgenden Befehl aus, um den Gitea-Container hochzufahren und führen Sie anschließend einen Neustart von NGINX mit dem zweiten Befehl durch:

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

6\. Wenn Sie mailcow zu https gezwungen haben, führen Sie Schritt 9 aus und starten Sie gitea mit dem folgenden Befehl neu. 
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart gitea-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart gitea-mailcow
    ```

Fahren Sie mit Schritt 7 fort (Denken Sie daran, https anstelle von http zu verwenden, `https://mx.example.org/gitea/`)

7\. Öffnen Sie `http://${MAILCOW_HOSTNAME}/gitea/`, zum Beispiel `http://mx.example.org/gitea/`. Für Datenbank-Details setzen Sie `mysql` als Datenbank-Host. Verwenden Sie gitea als Datenbankname, gitea als Datenbankbenutzer und your_strong_password als Datenbankpasswort, welches Sie in Schritt 1 definiert haben.

8\. Sobald die Installation abgeschlossen ist, loggen Sie sich als Administrator ein und setzen Sie "Einstellungen" -> "Autorisierung" -> "SMTP aktivieren". SMTP-Host sollte `postfix` mit Port `587` sein, setzen Sie `Skip TLS Verify`, da wir ein nicht gelistetes SAN verwenden ("postfix" ist höchstwahrscheinlich nicht Teil Ihres Zertifikats).

9\. Erstellen Sie `data/gitea/gitea/conf/app.ini` und setzen Sie die folgenden Werte. Sie können [gitea cheat sheet, leider bisher nur in Englisch verfügbar](https://docs.gitea.io/en-us/config-cheat-sheet/) für deren Bedeutung und andere mögliche Werte konsultieren.

```ini
[server]
SSH_LISTEN_PORT = 22
# Für GITEA_SSH_PORT=127.0.0.1:4000 in mailcow.conf, setzen:
SSH_DOMAIN = 127.0.0.1
SSH_PORT = 4000
# Für MAILCOW_HOSTNAME=mx.example.org in mailcow.conf (und Standard-Ports für HTTPS), setzen:
ROOT_URL = https://mx.example.org/gitea/
```

10\. Starten Sie gitea neu mit dem kommenden Befehl. Ihre Nutzer sollten in der Lage sein, sich mit von mailcow verwalteten Konten anzumelden.

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart gitea-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart gitea-mailcow
    ```

