Um eine Quarantäne Benachrichtigung erneut zu versenden geben Sie folgenden Befehl ein:

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
    Wir empfehlen die Verwendung dieses Befehles **NUR** zum debugging Prozess, da die Benachrichtigung im Normalfall automatisiert, anhand der pro Mailbox gesetzten Einstellungen, ausgelöst wird.