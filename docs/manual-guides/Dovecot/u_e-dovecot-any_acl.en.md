On August the 17th, we disabled the possibility to share with "any" or "all authenticated users" by default.

This function can be re-enabled by setting `ACL_ANYONE` to `allow` in mailcow.conf:

```
ACL_ANYONE=allow
```

Apply the changes by restarting the stack:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```