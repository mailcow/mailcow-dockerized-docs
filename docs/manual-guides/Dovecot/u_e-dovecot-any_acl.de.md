Am 17. August haben wir die Möglichkeit, mit "jedem" oder "allen authentifizierten Benutzern" zu teilen, standardmäßig deaktiviert.

Diese Funktion kann wieder aktiviert werden, indem `ACL_ANYONE` auf `allow` in mailcow.conf gesetzt wird:

```
ACL_ANYONE=allow
```

Wenden Sie die Änderungen an, indem Sie den Docker Stack neustarten mit:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```