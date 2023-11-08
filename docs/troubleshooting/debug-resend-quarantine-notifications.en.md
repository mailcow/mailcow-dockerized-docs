To resend a quarantine notification, enter the following command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec dovecot-mailcow bash
    mysql -umailcow -p$DBPASS mailcow -e "update quarantine set notified = 0;"
    redis-cli -h redis DEL Q_LAST_NOTIFIED
    quarantine_notify.py
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec dovecot-mailcow bash
    mysql -umailcow -p$DBPASS mailcow -e "update quarantine set notified = 0;"
    redis-cli -h redis DEL Q_LAST_NOTIFIED
    quarantine_notify.py
    ```

!!! info
    We recommend to use this command **ONLY** for debugging process as the notification is normally triggered automatically based on the settings set for each mailbox.