Dies wird **NUR** empfohlen, wenn Sie kein IPv6-fähiges Netzwerk auf Ihrem Host haben!

Wenn Sie es wirklich brauchen, können Sie die Verwendung von IPv6 in der Compose-Datei deaktivieren.
Zusätzlich können Sie auch den Start des Containers "ipv6nat-mailcow" deaktivieren, da er nicht benötigt wird, wenn Sie IPv6 nicht verwenden.

Anstatt die Datei docker-compose.yml direkt zu bearbeiten, ist es besser, eine Override-Datei zu erstellen 
zu erstellen und Ihre Änderungen am Dienst dort zu implementieren. Leider scheint dies im Moment nur für Dienste zu funktionieren, nicht für Netzwerkeinstellungen.

Um IPv6 im mailcow-Netzwerk zu deaktivieren, öffnen Sie docker-compose.yml mit Ihrem bevorzugten Texteditor und suchen Sie nach dem Netzwerk-Abschnitt (er befindet sich am Ende der Datei). 

**1.** Ändern Sie docker-compose.yml

Ändern Sie `enable_ipv6: true` in `enable_ipv6: false`:

```
networks:
  mailcow-network:
    [...]
    enable_ipv6: true # <<< auf false setzen
    [...]
```

**2.** ipv6nat-mailcow deaktivieren

Um den ipv6nat-mailcow Container ebenfalls zu deaktivieren, gehen Sie in Ihr mailcow Verzeichnis und erstellen Sie eine neue Datei namens "docker-compose.override.yml": 

**HINWEIS:** Wenn Sie bereits eine Override-Datei haben, erstellen Sie diese natürlich nicht neu, sondern fügen Sie die untenstehenden Zeilen entsprechend in Ihre bestehende Datei ein!

```
# cd /opt/mailcow-dockerized
# touch docker-compose.override.yml
```

Öffnen Sie die Datei in Ihrem bevorzugten Texteditor und tragen Sie folgendes ein:

```
version: '2.1'
services:

    ipv6nat-mailcow:
      image: bash:latest
      restart: "no"
      entrypoint: ["echo", "ipv6nat disabled in compose.override.yml"]
```

Damit diese Änderungen wirksam werden, müssen Sie den Stack vollständig stoppen und dann neu starten, damit Container und Netzwerke neu erstellt werden:


=== "docker compose (Plugin)"

    ``` bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down
    docker-compose up -d
    ```

**3.** Deaktivieren Sie IPv6 in unbound-mailcow

Bearbeiten Sie `data/conf/unbound/unbound.conf` und setzen Sie `do-ip6` auf "no":

```
Server:
  [...]
  do-ip6: no
  [...]
```

unbound neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart unbound-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart unbound-mailcow
    ```

**4.** Deaktivieren Sie IPv6 in postfix-mailcow

Erstellen Sie `data/conf/postfix/extra.cf` und setzen Sie `smtp_address_preference` auf `ipv4`:

```
smtp_address_preference = ipv4
inet_protocols = ipv4
```

Starten Sie Postfix neu:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

**5.** Wenn im Docker Daemon IPv6 komplett deaktiviert ist:

Folgende NGINX, Dovecot und Php-fpm Konfigurationsdateien anpassen

```
sed -i '/::/d' data/conf/nginx/listen_*
sed -i '/::/d' data/conf/nginx/templates/listen*
sed -i '/::/d' data/conf/nginx/dynmaps.conf
sed -i 's/,\[::\]//g' data/conf/dovecot/dovecot.conf
sed -i 's/\[::\]://g' data/conf/phpfpm/php-fpm.d/pools.conf
```
