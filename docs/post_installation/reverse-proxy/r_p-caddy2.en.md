!!! warning "Important"
    First read [the overview](r_p.md).

!!! danger
    This is an community supported contribution. Feel free to provide fixes.

The configuration of Caddy with mailcow is very simple.

In the caddyfile you just have to create a section for the mailserver.

For example
``` hl_lines="1 3 13"

MAILCOW_HOSTNAME autodiscover.MAILCOW_HOSTNAME autoconfig.MAILCOW_HOSTNAME {
        log {
                output file /var/log/caddy/MAILCOW_HOSTNAME.log {
                        roll_disabled
                        roll_size 512M
                        roll_uncompressed
                        roll_local_time
                        roll_keep 3
                        roll_keep_for 48h
                }
        }

        reverse_proxy 127.0.0.1:HTTP_BIND
}
```

This allows Caddy to automatically create the certificates and accept traffic for these mentioned domains and forward them to mailcow.

**Important**: The ACME client of mailcow must be disabled, otherwise mailcow will fail.

Since Caddy takes care of the certificates itself, we can use the following script to include the Caddy generated certificates into mailcow:

```bash
#!/bin/bash
MAILCOW_HOSTNAME=your.domain.tld
CADDY_CERTS_DIR=/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory
MD5SUM_CURRENT_CERT=($(md5sum /opt/mailcow-dockerized/data/assets/ssl/cert.pem))
MD5SUM_NEW_CERT=($(md5sum $CADDY_CERTS_DIR/$MAILCOW_HOSTNAME/$MAILCOW_HOSTNAME.crt))

if [ $MD5SUM_CURRENT_CERT != $MD5SUM_NEW_CERT ]; then
        cp $CADDY_CERTS_DIR/$MAILCOW_HOSTNAME/$MAILCOW_HOSTNAME.crt /opt/mailcow-dockerized/data/assets/ssl/cert.pem
        cp $CADDY_CERTS_DIR/$MAILCOW_HOSTNAME/$MAILCOW_HOSTNAME.key /opt/mailcow-dockerized/data/assets/ssl/key.pem
        cp $CADDY_CERTS_DIR/$MAILCOW_HOSTNAME/$MAILCOW_HOSTNAME.crt /opt/mailcow-dockerized/data/assets/ssl/$MAILCOW_HOSTNAME/cert.pem
        cp $CADDY_CERTS_DIR/$MAILCOW_HOSTNAME/$MAILCOW_HOSTNAME.key /opt/mailcow-dockerized/data/assets/ssl/$MAILCOW_HOSTNAME/key.pem
        postfix_c=$(docker ps -qaf name=postfix-mailcow)
        dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
        nginx_c=$(docker ps -qaf name=nginx-mailcow)
        docker restart ${postfix_c} ${dovecot_c} ${nginx_c}

else
        echo "Certs not copied from Caddy (Not needed)"
fi
```

!!! warning "Attention"
    Caddy's certificate path varies depending on the installation type.<br>
    In this installation example, Caddy was installed using the Caddy repo ([more informations here](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)).<br>
    <br>
    To find out the Caddy certificate path on your system, just run a `find / -name "certificates"`.

This script could be called as a cronjob every hour:

```bash
0 * * * * /bin/bash /path/to/script/deploy-certs.sh  >/dev/null 2>&1
```

Alternatively, if you are using Caddy as an external reverse proxy and do not wish for it to manage the certs for Mailcow, you may include a line to pass through the ACME challenges to mailcow-acme to allow it to manage certificates.

``` hl_lines="1 3 13"

MAILCOW_HOSTNAME autodiscover.MAILCOW_HOSTNAME autoconfig.MAILCOW_HOSTNAME {
        log {
                output file /var/log/caddy/MAILCOW_HOSTNAME.log {
                        roll_disabled
                        roll_size 512M
                        roll_uncompressed
                        roll_local_time
                        roll_keep 3
                        roll_keep_for 48h
                }
        }

        handle /.well-known/acme-challenge* {
            root * /acme
        }

        reverse_proxy 127.0.0.1:HTTP_BIND
}
```
