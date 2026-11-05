Open `data/conf/postfix/extra.cf` and set the `message_size_limit` accordingly in bytes. See `main.cf` for the default value.

You will also need to adjust message size in Rspamd and Clamav configurations:

+ in `data/conf/rspamd/local.d/options.inc` add `max_message` parameter, check [Rspamd Docs](https://rspamd.com/doc/configuration/options.html#:~:text=DoS%20(default%3A%201024)-,max_message,-maximum%20size%20of) for defaults
+ in `data/conf/rspamd/local.d/external_services.conf` adjust `max_size` parameter for `oletools`
+ in `data/conf/rspamd/local.d/antivirus.conf` adjust `max_size` parameter for `clamav`
+ in `data/conf/clamav/clamd.conf` adjust `MaxScanSize` and `MaxFileSize`
+ in `mailcow.conf` set `NGINX_MAX_BODY_SIZE` above the new message size (default `128m`), it limits requests to SOGo webmail, CalDAV/CardDAV and ActiveSync. Apply it with `docker compose up -d`.

Restart Postfix, Rspamd and Clamav:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow rspamd-mailcow clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow rspamd-mailcow clamd-mailcow
    ```

## Request size limits in nginx

nginx limits the size of requests:

- **SOGo webmail, ActiveSync and CalDAV/CardDAV:** `NGINX_MAX_BODY_SIZE` in `mailcow.conf`, default `128m`. The value uses nginx syntax (e.g. `128m` or `1g`), `0` means unlimited, an invalid value falls back to `128m`. Keep it above `message_size_limit`, otherwise large mails cannot be sent through SOGo or ActiveSync (error `413`).
- **mailcow UI, API, Rspamd UI and own locations in `site.*.custom`:** 64 MB. For larger uploads in own locations, set `client_max_body_size` there (see [Config expansion in mailcows Nginx](../Nginx/u_e-nginx_custom.md#config-expansion-in-mailcows-nginx)).
