### Caddy v2 (von der Community unterstützt)

!!! warning "Warnung"
    Dies ist ein nicht unterstützter Communitybeitrag. Korrekturen sind immer erwünscht!

Die Konfiguration von Caddy mit mailcow ist sehr simpel.

In der Caddyfile muss einfach nur ein Bereich für den E-Mailserver angelegt werden.

Bspw:

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

Dies erlaubt es Caddy automatisch die Zertifikate zu erstellen und den Traffic für diese erwähnten Domains anzunehmen und an mailcow weiterzuleiten.

**Wichtig**: Der ACME Client der mailcow muss deaktiviert sein, da es sonst zu Fehlern seitens mailcow kommt.

Da Caddy sich direkt selbst um die Zertifikate kümmert, können wir mit dem folgenden Skript die Caddy generierten Zertifikate in die mailcow inkludieren:

```bash
#!/bin/bash
MD5SUM_CURRENT_CERT=($(md5sum /opt/mailcow-dockerized/data/assets/ssl/cert.pem))
MD5SUM_NEW_CERT=($(md5sum /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/your.domain.tld/your.domain.tld.crt))

if [ $MD5SUM_CURRENT_CERT != $MD5SUM_NEW_CERT ]; then
        cp /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/your.domain.tld/your.domain.tld.crt /opt/mailcow-dockerized/data/assets/ssl/cert.pem
        cp /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/your.domain.tld/your.domain.tld.key /opt/mailcow-dockerized/data/assets/ssl/key.pem
        postfix_c=$(docker ps -qaf name=postfix-mailcow)
        dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
        nginx_c=$(docker ps -qaf name=nginx-mailcow)
        docker restart ${postfix_c} ${dovecot_c} ${nginx_c}

else
        echo "Certs not copied from Caddy (Not needed)"
fi
```

!!! warning "Achtung"
    Der Zertifikatspfad von Caddy variiert je nach Installationsart.<br>
    Bei diesem Installationsbeispiel wurde Caddy mithilfe des Caddy Repos ([weitere Informationen hier](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)) installiert.<br>
    <br>
    Um den Caddy Zertifikatspfad auf Ihrem System herauszufinden, genügt ein `find / -name "certificates"`.


Dieses Skript könnte dann als Cronjob jede Stunde aufgerufen werden:

```bash
0 * * * * /bin/bash /path/to/script/deploy-certs.sh  >/dev/null 2>&1
```
