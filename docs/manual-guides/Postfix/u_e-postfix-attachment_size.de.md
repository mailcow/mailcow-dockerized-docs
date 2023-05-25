Öffnen Sie `data/conf/postfix/extra.cf` und setzen Sie das `message_size_limit` entsprechend in Bytes. Siehe `main.cf` für den Standardwert.

Sie müssen auch die Nachrichtengröße in den Konfigurationen von Rspamd und Clamav anpassen:

+ in `data/conf/rspamd/local.d/options.inc` fügen Sie den `max_message` Parameter entsprechend den im Postfix gesetzten Wert hinzu. Ziehen Sie die [Rspamd Docs](https://rspamd.com/doc/configuration/options.html#:~:text=DoS%20(default%3A%201024)-,max_message,-maximum%20size%20of) für den Standardwert zu rate.
+ in `data/conf/clamav/clamd.conf` ändern Sie den Wert `MaxScanSize` und `MaxFileSize` auf dieselbe Größe wie in der Postfix `extra.cf`

Starten Sie Postfix neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow rspamd-mailcow clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow rspamd-mailcow clamd-mailcow
    ```
