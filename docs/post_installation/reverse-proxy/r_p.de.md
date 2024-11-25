Sie müssen die Nginx-Seite, die mit mailcow: dockerized geliefert wird, nicht ändern.
mailcow: dockerized vertraut auf das Standard-Gateway IP 172.22.1.1 als Proxy.

Stellen Sie sicher, dass Sie HTTP_BIND und HTTPS_BIND in `mailcow.conf` auf eine lokale Adresse ändern und die Ports entsprechend einstellen, zum Beispiel:
``` bash
HTTP_BIND=127.0.0.1
HTTP_PORT=8080
HTTPS_BIND=127.0.0.1
HTTPS_PORT=8443
```

Dadurch werden auch die Bindungen innerhalb des Nginx-Containers geändert! Dies ist wichtig, wenn Sie sich entscheiden, einen Proxy innerhalb von Docker zu verwenden.

**WICHTIG:** Verwenden Sie nicht Port 8081, 9081 oder 65510!

Erzeugen Sie die betroffenen Container neu, indem Sie den folgenden Befehl ausführen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

## Wichtige Informationen, bitte lesen Sie diese sorgfältig durch!

!!! info
    Wenn Sie planen, einen Reverse-Proxy zu verwenden und einen anderen Servernamen als **MAILCOW_HOSTNAME** verwenden wollen, müssen Sie [Zusätzliche Servernamen für mailcow UI](#hinzufugen-weiterer-servernamen-fur-mailcow-ui) hierunter.

!!! warning "Warnung"
    Stellen Sie sicher, dass Sie `generate_config.sh` ausführen, bevor Sie die Konfigurationsbeispiele aktivieren.
    Das Skript `generate_config.sh` kopiert die Snake-oil Zertifikate an den richtigen Ort, so dass die Dienste nicht aufgrund fehlender Dateien nicht starten können.

!!! warning "Warnung"
    Wenn Sie TLS SNI aktivieren (`ENABLE_SSL_SNI` in mailcow.conf), **müssen** die Zertifikatspfade in Ihrem Reverse-Proxy mit den korrekten Pfaden in `data/assets/ssl/{hostname}` übereinstimmen. Die Zertifikate werden in `data/assets/ssl/{hostname1,hostname2,etc}` aufgeteilt und werden daher nicht funktionieren, wenn Sie die Beispiele von unten kopieren, die auf `data/assets/ssl/cert.pem` etc. zeigen.

!!! info
    Die Verwendung der Konfigurationsbeispiele wird **acme-Anfragen an mailcow** weiterleiten und es die Zertifikate selbst verwalten lassen.
    Der Nachteil der Verwendung von mailcow als ACME-Client hinter einem Reverse-Proxy ist, dass Sie Ihren Webserver neu laden müssen, nachdem acme-mailcow das Zertifikat geändert/erneuert/erstellt hat. Sie können entweder Ihren Webserver täglich neu laden oder ein Skript schreiben, um die Datei auf Änderungen zu überwachen.
    Auf vielen Servern wird logrotate den Webserver sowieso täglich neu laden.

    Wenn Sie eine lokale Certbot-Installation verwenden möchten, müssen Sie die SSL-Zertifikatsparameter entsprechend ändern.
    **Stellen Sie sicher, dass Sie ein Post-Hook-Skript** ausführen, wenn Sie sich entscheiden, externe ACME-Clients zu verwenden. [Ein Beispiel](#optional-post-hook-skript-fur-nicht-mailcow-acme-clients) finden Sie hierunter.


Konfigurieren Sie Ihren lokalen Webserver als Reverse Proxy anhand folgender Konfigurationsbeispiele:

- [Apache 2.4](r_p-apache24.md)
- [Nginx](r_p-nginx.md)
- [HAProxy](r_p-haproxy.md)
- [Traefik v2](r_p-traefik2.md)
- [Caddy v2](r_p-caddy2.md)

## Optional: Post-Hook-Skript für nicht-mailcow ACME-Clients

Die Verwendung eines lokalen Certbots (oder eines anderen ACME-Clients) erfordert den Neustart einiger Container, was Sie mit einem Post-Hook-Skript erledigen können.
Stellen Sie sicher, dass Sie die Pfade entsprechend ändern:
```
#!/bin/bash
cp /etc/letsencrypt/live/my.domain.tld/fullchain.pem /opt/mailcow-dockerized/data/assets/ssl/cert.pem
cp /etc/letsencrypt/live/my.domain.tld/privkey.pem /opt/mailcow-dockerized/data/assets/ssl/key.pem
postfix_c=$(docker ps -qaf name=postfix-mailcow)
dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
nginx_c=$(docker ps -qaf name=nginx-mailcow)
docker restart ${postfix_c} ${dovecot_c} ${nginx_c}
```

## Hinzufügen weiterer Servernamen für mailcow UI

Wenn Sie vorhaben, einen Servernamen zu verwenden, der nicht `MAILCOW_HOSTNAME` in Ihrem Reverse-Proxy ist, stellen Sie sicher, dass Sie diesen Namen zuerst in mailcow.conf über `ADDITIONAL_SERVER_NAMES` einpflegen. Die Namen müssen durch Kommas getrennt werden und **dürfen** keine Leerzeichen enthalten. Wenn Sie diesen Schritt überspringen, kann es sein, dass mailcow auf Ihren Reverse-Proxy mit einer falschen Seite antwortet.

```
ADDITIONAL_SERVER_NAMES=webmail.domain.tld,other.example.tld
```

Führen Sie zum Anwenden folgendes aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```
