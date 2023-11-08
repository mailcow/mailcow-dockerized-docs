
## Spam filter thresholds (global)

Each user is able to change [their spam rating individually](../mailcow-UI/u_e-mailcow_ui-spamfilter.en.md). To define a new **server-wide** limit, edit `data/conf/rspamd/local.d/actions.conf`:

```cpp
reject = 15;
add_header = 8;
greylist = 7;
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

!!! warning
    Existing settings of users will not be overwritten!

To reset custom defined thresholds, run:
=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf
    docker compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel';"
    # or:
    docker compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel' and object = 'only-this-mailbox@example.org';"
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf
    docker-compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel';"
    # or:
    docker-compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel' and object = 'only-this-mailbox@example.org';"
    ```

---

## Custom reject messages

The default spam reject message can be changed by adding a new file `data/conf/rspamd/override.d/worker-proxy.custom.inc` with the following content:

```
reject_message = "My custom reject message";
```

Save the file and restart Rspamd:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

While the above works for rejected mails with a high spam score, prefilter reject actions will ignore this setting. For these maps, the multimap module in Rspamd needs to be adjusted:

1. Find prefilet reject symbol for which you want change message, to do it run: `grep -R "SYMBOL_YOU_WANT_TO_ADJUST" /opt/mailcow-dockerized/data/conf/rspamd/`

2. Add your custom message as new line:

    ```
    GLOBAL_RCPT_BL {
    type = "rcpt";
    map = "${LOCAL_CONFDIR}/custom/global_rcpt_blacklist.map";
    regexp = true;
    prefilter = true;
    action = "reject";
    message = "Sending mail to this recipient is prohibited by postmaster@your.domain";
    }
    ```

3. Save the file and restart Rspamd:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

---

## Discard instead of reject

If you want to silently drop a message, create or edit the file `data/conf/rspamd/override.d/worker-proxy.custom.inc` and add the following content:

```
discard_on_reject = true;
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