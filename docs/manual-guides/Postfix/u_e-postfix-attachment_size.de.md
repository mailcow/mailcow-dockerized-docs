Öffnen Sie `data/conf/postfix/extra.cf` und setzen Sie das `message_size_limit` entsprechend in Bytes. Siehe `main.cf` für den Standardwert.

Sie müssen auch die Nachrichtengröße in den Konfigurationen von Rspamd und Clamav anpassen:

+ in `data/conf/rspamd/local.d/options.inc` fügen Sie den `max_message` Parameter entsprechend den im Postfix gesetzten Wert hinzu. Ziehen Sie die [Rspamd Docs](https://rspamd.com/doc/configuration/options.html#:~:text=DoS%20(default%3A%201024)-,max_message,-maximum%20size%20of) für den Standardwert zu rate.
+ in `data/conf/rspamd/local.d/external_services.conf` ändern Sie den Wert `max_size` Parameter für `oletools`
+ in `data/conf/rspamd/local.d/antivirus.conf` ändern Sie den Wert `max_size` Parameter für `clamav`
+ in `data/conf/clamav/clamd.conf` ändern Sie den Wert `MaxScanSize` und `MaxFileSize` auf dieselbe Größe wie in der Postfix `extra.cf`
+ in `mailcow.conf` setzen Sie `NGINX_MAX_BODY_SIZE` über die neue Nachrichtengröße (Standard `128m`), es begrenzt Anfragen an SOGo-Webmail, CalDAV/CardDAV und ActiveSync. Übernehmen Sie es mit `docker compose up -d`.

Starten Sie Postfix, Rspamd and Clamav neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow rspamd-mailcow clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow rspamd-mailcow clamd-mailcow
    ```

## Größenlimits für Anfragen in nginx

nginx begrenzt die Größe von Anfragen:

- **SOGo-Webmail, ActiveSync und CalDAV/CardDAV:** `NGINX_MAX_BODY_SIZE` in der `mailcow.conf`, Standard `128m`. Der Wert folgt der nginx-Syntax (z. B. `128m` oder `1g`), `0` heißt unbegrenzt, ein ungültiger Wert fällt auf `128m` zurück. Er muss über `message_size_limit` liegen, sonst lassen sich große Mails nicht über SOGo oder ActiveSync verschicken (Fehler `413`).
- **mailcow UI, API, Rspamd UI und eigene Locations in `site.*.custom`:** 64 MB. Für größere Uploads in eigenen Locations dort `client_max_body_size` setzen (siehe [Konfig-Erweiterung in mailcows Nginx](../Nginx/u_e-nginx_custom.md#konfig-erweiterung-in-mailcows-nginx)).
