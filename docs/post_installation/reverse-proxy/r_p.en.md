You don't need to change the Nginx site that comes with mailcow: dockerized.
mailcow: dockerized trusts the default gateway IP 172.22.1.1 as proxy.

Make sure you change HTTP_BIND and HTTPS_BIND in `mailcow.conf` to a local address and set the ports accordingly, for example:
``` bash
HTTP_BIND=127.0.0.1
HTTP_PORT=8080
HTTPS_BIND=127.0.0.1
HTTPS_PORT=8443
```

This will also change the bindings inside the Nginx container! This is important, if you decide to use a proxy within Docker.

**IMPORTANT:** Do not use port 8081, 9081 or 65510!

Recreate affected containers by running the command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

## Important information, please read them carefully!

!!! info
    If you plan to use a reverse proxy and want to use another server name that is **not** MAILCOW_HOSTNAME, you need to read [Adding additional server names for mailcow UI](#adding-additional-server-names-for-mailcow-ui) below.

!!! warning
    Make sure you run `generate_config.sh` before you enable any site configuration examples.
    The script `generate_config.sh` copies snake-oil certificates to the correct location, so the services will not fail to start due to missing files.

!!! warning
    If you enable TLS SNI (`ENABLE_TLS_SNI` in mailcow.conf), the certificate paths in your reverse proxy **must** match the correct paths in `data/assets/ssl/{hostname}`. The certificates will be split into `data/assets/ssl/{hostname1,hostname2,etc}` and therefore will not work when you copy the examples from below pointing to `data/assets/ssl/cert.pem` etc.

!!! info
    Using the site configuration examples will **forward ACME requests to mailcow** and let it handle certificates itself.
    The downside of using mailcow as ACME client behind a reverse proxy is, that you will need to reload your webserver after acme-mailcow changed/renewed/created the certificate. You can either reload your webserver daily or write a script to watch the file for changes.
    On many servers logrotate will reload the webserver daily anyway.

    If you want to use a local certbot installation, you will need to change the SSL certificate parameters accordingly.
    **Make sure you run a post-hook script** when you decide to use external ACME clients. You will find [an example](#optional-post-hook-script-for-non-mailcow-acme-clients) below.


Configure your local webserver as reverse proxy using following configuration examples:

- [Apache 2.4](r_p-apache24.md)
- [Nginx](r_p-nginx.md)
- [HAProxy](r_p-haproxy.md)
- [Traefik v2](r_p-traefik2.md)
- [Caddy v2](r_p-caddy2.md)

## Optional: Post-hook script for non-mailcow ACME clients

Using a local certbot (or any other ACME client) requires to restart some containers, you can do this with a post-hook script.
Make sure you change the paths accordingly:
```
#!/bin/bash
cp /etc/letsencrypt/live/my.domain.tld/fullchain.pem /opt/mailcow-dockerized/data/assets/ssl/cert.pem
cp /etc/letsencrypt/live/my.domain.tld/privkey.pem /opt/mailcow-dockerized/data/assets/ssl/key.pem
postfix_c=$(docker ps -qaf name=postfix-mailcow)
dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
nginx_c=$(docker ps -qaf name=nginx-mailcow)
docker restart ${postfix_c} ${dovecot_c} ${nginx_c}
```

## Adding additional server names for mailcow UI

If you plan to use a server name that is not `MAILCOW_HOSTNAME` in your reverse proxy, make sure to populate that name in mailcow.conf via `ADDITIONAL_SERVER_NAMES` first. Names must be separated by commas and **must not** contain spaces. If you skip this step, mailcow may respond to your reverse proxy with an incorrect site.

```
ADDITIONAL_SERVER_NAMES=webmail.domain.tld,other.example.tld
```

Run the following command to apply:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```
