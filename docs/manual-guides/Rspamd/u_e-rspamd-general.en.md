Rspamd is used for AV handling, DKIM signing and SPAM handling. It's a powerful and fast filter system. For a more in-depth documentation on Rspamd please visit its [own documentation](https://docs.rspamd.com/).

## UI access

Rspamd offers a comprehensive WebUI, which is included in every mailcow: dockerized installation.

The Rspamd UI is provided with a login, which is set to a random password during the initial installation to deny third party access.

To be able to log in to the Rspamd UI, you must first set your own password for the Rspamd interface.

You do this as follows:

1. Log in to your **mailcow UI** as administrator.
2. Switch to the tab (top left) `System` :material-chevron-right: `Configuration` and there the sub-tab: `Access` :material-chevron-right: `Rspamd UI`.
3. Change the Rspamd UI password here, or set one.
4. Go to https://${MAILCOW_HOSTNAME}/rspamd in a browser and log in!

Further configuration options and documentation for the WebUI can be found here: https://docs.rspamd.com/

---

## CLI tools

Rspamd offers a variety of commands that can be used via CLI.

Enter the following commands to get an overview of these:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow rspamc --help
    docker compose exec rspamd-mailcow rspamadm --help
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow rspamc --help
    docker-compose exec rspamd-mailcow rspamadm --help
    ```

---


## Increase history retention

By default Rspamd keeps 1000 elements in the history.

The history is stored compressed.

It is recommended not to use a disproportionate high value here, try something along 5000 or 10000 and see how your server handles it:

Edit `data/conf/rspamd/local.d/history_redis.conf`:

```
nrows = 1000; # change this value
```

Restart Rspamd afterwards:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

---

## Wipe all ratelimit keys

If you don't want to use the UI and instead wipe all keys in the Redis database, you can use redis-cli for that task:
=== "docker compose (Plugin)"

    ``` bash
    docker compose exec redis-mailcow sh
    # Unlink (available in Redis >=4.) will delete in the backgronud
    redis-cli --scan --pattern RL* | xargs redis-cli unlink
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec redis-mailcow sh
    # Unlink (available in Redis >=4.) will delete in the backgronud
    redis-cli --scan --pattern RL* | xargs redis-cli unlink
    ```

Restart Rspamd:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```
