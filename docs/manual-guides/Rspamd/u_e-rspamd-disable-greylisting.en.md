!!! info 
    In this guide we assume the default mailcow path (`/opt/mailcow-dockerized`).<br>
    *The path in your installation may vary.*

---

Only messages with a higher Rspamd score will be considered to be greylisted (soft rejected).

We do **NOT** recommend deactivating greylisting.

However, if you see a valid reason to disable greylisting, you can disable it server-wide by editing the `greylist.conf`:

`/opt/mailcow-dockerized/data/conf/rspamd/local.d/greylist.conf`

Add the line:

```cpp
enabled = false;
```

Save the file and restart "rspamd-mailcow":
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Greylisting is now deactivated **serverwide**!