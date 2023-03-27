Erstellen Sie eine Datei `data/conf/dovecot/extra.conf` - falls nicht vorhanden - und fügen Sie Ihren zusätzlichen Inhalt hier ein.

Starten Sie `dovecot-mailcow` neu, um Ihre Änderungen zu übernehmen:


=== "docker compose (Plugin)"

    ``` bash
    docker compose restart dovecot-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart dovecot-mailcow
    ```