Please create a new file `data/conf/postfix/extra.cf` for overrides or additional content to `main.cf`.

Postfix will complain about duplicate values once after starting postfix-mailcow, this is intended.

Syslog-ng was configured to hide those warnings while Postfix is running, to not spam the log files with unnecessary information every time a service is used.

Restart `postfix-mailcow` to apply your changes:

=== "docker compose"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose"

    ``` bash
    docker-compose restart postfix-mailcow
    ```
