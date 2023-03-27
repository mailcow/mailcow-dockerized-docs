## New guide

Edit a mailbox and select "Allow to send as *".

For historical reasons we kept the old and deprecated guide below:

## Deprecated guide (DO NOT USE ON NEWER MAILCOWS!)

This option is not best-practice and should only be implemented when there is no other option available to achieve whatever you are trying to do.

Simply create a file `data/conf/postfix/check_sasl_access` and enter the following content. This user must exist in your installation and needs to authenticate before sending mail.
```
user-to-allow-everything@example.com OK
```

Open `data/conf/postfix/main.cf` and find `smtpd_sender_restrictions`. Prepend `check_sasl_access hash:/opt/postfix/conf/check_sasl_access` like this:
```
smtpd_sender_restrictions = check_sasl_access hash:/opt/postfix/conf/check_sasl_access reject_authenticated_sender_login_mismatch [...]
```

Run postmap on check_sasl_access:
=== "docker compose (Plugin)"

    ``` bash
    docker compose exec postfix-mailcow postmap /opt/postfix/conf/check_sasl_access
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec postfix-mailcow postmap /opt/postfix/conf/check_sasl_access
    ```

Restart the Postfix container.
