Please create a new file `data/conf/postfix/extra.cf` for overrides or additional content to `main.cf`.

Restart `postfix-mailcow` to apply your changes:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```
