Create a file `data/conf/dovecot/extra.conf` - if missing - and add your additional content here.

Restart `dovecot-mailcow` to apply your changes:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart dovecot-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart dovecot-mailcow
    ```