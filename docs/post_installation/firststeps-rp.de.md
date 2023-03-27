Sie müssen die Nginx-Seite, die mit mailcow: dockerized geliefert wird, nicht ändern.
mailcow: dockerized vertraut auf das Standard-Gateway IP 172.22.1.1 als Proxy.

1\. Stellen Sie sicher, dass Sie HTTP_BIND und HTTPS_BIND in `mailcow.conf` auf eine lokale Adresse ändern und die Ports entsprechend einstellen, zum Beispiel:
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

**Wichtige Informationen, bitte lesen Sie diese sorgfältig durch!**

!!! info
    Wenn Sie planen, einen Reverse-Proxy zu verwenden und einen anderen Servernamen als **MAILCOW_HOSTNAME** verwenden wollen, müssen Sie **Zusätzliche Servernamen für mailcow UI** am Ende dieser Seite hinzufügen.

!!! warning "Warnung"
    Stellen Sie sicher, dass Sie `generate_config.sh` ausführen, bevor Sie die untenstehenden Konfigurationsbeispiele aktivieren.
    Das Skript `generate_config.sh` kopiert die Snake-oil Zertifikate an den richtigen Ort, so dass die Dienste nicht aufgrund fehlender Dateien nicht starten können.

!!! warning "Warnung"
    Wenn Sie TLS SNI aktivieren (`ENABLE_TLS_SNI` in mailcow.conf), **müssen** die Zertifikatspfade in Ihrem Reverse-Proxy mit den korrekten Pfaden in data/assets/ssl/{hostname} übereinstimmen. Die Zertifikate werden in `data/assets/ssl/{hostname1,hostname2,etc}` aufgeteilt und werden daher nicht funktionieren, wenn Sie die Beispiele von unten kopieren, die auf `data/assets/ssl/cert.pem` etc. zeigen.

!!! info
    Die Verwendung der untenstehenden Site-Konfigurationen wird **acme-Anfragen an mailcow** weiterleiten und es die Zertifikate selbst verwalten lassen.
    Der Nachteil der Verwendung von mailcow als ACME-Client hinter einem Reverse-Proxy ist, dass Sie Ihren Webserver neu laden müssen, nachdem acme-mailcow das Zertifikat geändert/erneuert/erstellt hat. Sie können entweder Ihren Webserver täglich neu laden oder ein Skript schreiben, um die Datei auf Änderungen zu überwachen.
    Auf vielen Servern wird logrotate den Webserver sowieso täglich neu laden.

    Wenn Sie eine lokale Certbot-Installation verwenden möchten, müssen Sie die SSL-Zertifikatsparameter entsprechend ändern.
    **Stellen Sie sicher, dass Sie ein Post-Hook-Skript** ausführen, wenn Sie sich entscheiden, externe ACME-Clients zu verwenden. Ein Beispiel finden Sie am Ende dieser Seite.


2\. Konfigurieren Sie Ihren lokalen Webserver als Reverse Proxy:

### Apache 2.4
Erforderliche Module:
```
a2enmod rewrite proxy proxy_http headers ssl
```

Let's Encrypt wird unserem Rewrite folgen, Zertifikatsanfragen in mailcow werden problemlos funktionieren.

**Die hervorgehobenen Zeilen müssen beachtet werden**.

``` apache hl_lines="2 10 11 17 22 23 24 25 30 31"
<VirtualHost *:80>
  ServerName ZU MAILCOW HOSTNAMEN ÄNDERN
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*
  RewriteEngine on

  RewriteCond %{HTTPS} off
  RewriteRule ^/?(.*) https://%{HTTP_HOST}/$1 [R=301,L]

  ProxyPass / http://127.0.0.1:8080/
  ProxyPassReverse / http://127.0.0.1:8080/
  ProxyPreserveHost On
  ProxyAddHeaders On
  RequestHeader set X-Forwarded-Proto "http"
</VirtualHost>
<VirtualHost *:443>
  ServerName ZU MAILCOW HOSTNAMEN ÄNDERN
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*

  # You should proxy to a plain HTTP session to offload SSL processing
  ProxyPass /Microsoft-Server-ActiveSync http://127.0.0.1:8080/Microsoft-Server-ActiveSync connectiontimeout=4000
  ProxyPassReverse /Microsoft-Server-ActiveSync http://127.0.0.1:8080/Microsoft-Server-ActiveSync
  ProxyPass / http://127.0.0.1:8080/
  ProxyPassReverse / http://127.0.0.1:8080/
  ProxyPreserveHost On
  ProxyAddHeaders On
  RequestHeader set X-Forwarded-Proto "https"

  SSLCertificateFile MAILCOW_ORDNER/data/assets/ssl/cert.pem
  SSLCertificateKeyFile MAILCOW_ORDNER/data/assets/ssl/key.pem

  # Wenn Sie einen HTTPS-Host als Proxy verwenden möchten:
  #SSLProxyEngine On

  # Wenn Sie einen Proxy für einen nicht vertrauenswürdigen HTTPS-Host einrichten wollen:
  #SSLProxyVerify none
  #SSLProxyCheckPeerCN off
  #SSLProxyCheckPeerName off
  #SSLProxyCheckPeerExpire off
</VirtualHost>
```
### Nginx

Let's Encrypt folgt unserem Rewrite, Zertifikatsanfragen funktionieren problemlos.

**Achten Sie auf die hervorgehobenen Zeilen**.

``` hl_lines="4 10 12 13 25 39"
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name ZU MAILCOW HOSTNAMEN ÄNDERN autodiscover.* autoconfig.*;
  return 301 https://$host$request_uri;
}
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name ZU MAILCOW HOSTNAMEN ÄNDERN autodiscover.* autoconfig.*;

  ssl_certificate MAILCOW_PATH/data/assets/ssl/cert.pem;
  ssl_certificate_key MAILCOW_PATH/data/assets/ssl/key.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;

  # Siehe https://ssl-config.mozilla.org/#server=nginx für die neuesten Empfehlungen zu ssl-Einstellungen
  # Ein Beispiel für eine Konfiguration ist unten angegeben
  ssl_protocols TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5:!SHA1:!kRSA;
  ssl_prefer_server_ciphers off;

  location /Microsoft-Server-ActiveSync {
    proxy_pass http://127.0.0.1:8080/Microsoft-Server-ActiveSync;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_connect_timeout 75;
    proxy_send_timeout 3650;
    proxy_read_timeout 3650;
    proxy_buffers 64 512k; # Seit dem 2022-04 Update nötig für SOGo
    client_body_buffer_size 512k;
    client_max_body_size 0;
  }

  location / {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 0;
  # Die folgenden Proxy-Buffer müssen gesetzt werden, wenn Sie SOGo nach dem Update 2022-04 (April 2022) verwenden wollen
  # Andernfalls wird ein Login wie folgt fehlschlagen: https://github.com/mailcow/mailcow-dockerized/issues/4537
	proxy_buffer_size 128k;
    proxy_buffers 64 512k;
    proxy_busy_buffers_size 512k;
  }
}
```

### HAProxy (von der Community unterstützt)

!!! warning "Warnung"
    Dies ist ein nicht unterstützter Community Beitrag. Korrekturen sind immer erwünscht!

**Wichtig/Fix erwünscht**: Dieses Beispiel leitet nur HTTPS-Verkehr weiter und benutzt nicht den in mailcow eingebauten ACME-Client.

```
frontend https-in
  bind :::443 v4v6 ssl crt mailcow.pem
  default_backend mailcow

backend mailcow
  option forwardfor
  http-request set-header X-Forwarded-Proto https if { ssl_fc }
  http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
  server mailcow 127.0.0.1:8080 check
```

### Traefik v2 (von der Community unterstützt)

!!! warning "Warnung"
    Dies ist ein nicht unterstützter Community Beitrag. Korrekturen sind immer erwünscht!

**Wichtig**: Diese Konfiguration deckt nur das "Reverseproxing" des Webpanels (nginx-mailcow) unter Verwendung von Traefik v2 ab. Wenn Sie auch die Mail-Dienste wie dovecot, postfix... reproxen wollen, müssen Sie die folgende Konfiguration an jeden Container anpassen und einen [EntryPoint](https://docs.traefik.io/routing/entrypoints/) in Ihrer `traefik.toml` oder `traefik.yml` (je nachdem, welche Konfiguration Sie verwenden) für jeden Port erstellen. 

In diesem Abschnitt gehen wir davon aus, dass Sie Ihren Traefik 2 `[certificatesresolvers]` in Ihrer Traefik-Konfigurationsdatei richtig konfiguriert haben und auch acme verwenden. Das folgende Beispiel verwendet Lets Encrypt, aber Sie können es gerne auf Ihren eigenen Zertifikatsresolver ändern. Eine grundlegende Traefik 2 toml-Konfigurationsdatei mit allen oben genannten Elementen, die für dieses Beispiel verwendet werden kann, finden Sie hier [traefik.toml](https://github.com/Frenzoid/TraefikBasicConfig/blob/master/traefik.toml), falls Sie eine solche Datei benötigen oder einen Hinweis, wie Sie Ihre Konfiguration anpassen können.

Zuallererst werden wir den acme-mailcow-Container deaktivieren, da wir die von traefik bereitgestellten Zertifikate verwenden werden.
Dazu müssen wir `SKIP_LETS_ENCRYPT=y` in unserer `mailcow.conf` setzen und den folgenden Befehl ausführen, um die Änderungen zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Dann erstellen wir eine `docker-compose.override.yml` Datei, um die Hauptdatei `docker-compose.yml` zu überschreiben, die sich im mailcow-Stammverzeichnis befindet. 

```yaml
version: '2.1'

services:
    nginx-mailcow:
      networks:
        # Traefiks Netzwerk hinzufügen
        web:
      labels:
        - traefik.enable=true
        # Erstellt einen Router namens "moo" für den Container und richtet eine Regel ein, um den Container mit einer bestimmten Regel zu verknüpfen,
        # in diesem Fall eine Host-Regel mit unserer MAILCOW_HOSTNAME-Variable.
        - traefik.http.routers.moo.rule=Host(`${MAILCOW_HOSTNAME}`)
        # Aktiviert tls über den zuvor erstellten Router.
        - traefik.http.routers.moo.tls=true
        # Gibt an, welche Art von Cert-Resolver wir verwenden werden, in diesem Fall le (Lets Encrypt).
        - traefik.http.routers.moo.tls.certresolver=le
        # Erzeugt einen Dienst namens "moo" für den Container und gibt an, welchen internen Port des Containers
        # Traefik die eingehenden Daten weiterleiten soll.
        - traefik.http.services.moo.loadbalancer.server.port=${HTTP_PORT}
        # Gibt an, welchen Eingangspunkt (externer Port) traefik für diesen Container abhören soll.
        # Websecure ist Port 443, siehe die Datei traefik.toml wie oben.
        - traefik.http.routers.moo.entrypoints=websecure
        # Stellen Sie sicher, dass traefik das Web-Netzwerk verwendet, nicht das mailcowdockerized_mailcow-network
        - traefik.docker.network=traefik_web

    certdumper:
        image: humenius/traefik-certs-dumper
        command: --restart-containers ${COMPOSE_PROJECT_NAME}-postfix-mailcow-1,${COMPOSE_PROJECT_NAME}-nginx-mailcow-1,${COMPOSE_PROJECT_NAME}-dovecot-mailcow-1
        network_mode: none
        volumes:
          # Binden Sie das Volume, das Traefiks `acme.json' Datei enthält, ein
          - acme:/traefik:ro
          # SSL-Ordner von mailcow einhängen
          - ./data/assets/ssl/:/output:rw
          # Binden Sie den Docker Socket ein, damit traefik-certs-dumper die Container neu starten kann
          - /var/run/docker.sock:/var/run/docker.sock:ro
        restart: always
        environment:
          # Ändern Sie dies nur, wenn Sie eine andere Domain für mailcows Web-Frontend verwenden als in der Standard-Konfiguration
          - DOMAIN=${MAILCOW_HOSTNAME}

networks:
  web:
    external: true
    # Name des externen Netzwerks
    name: traefik_web

volumes:
  acme:
    external: true
    # Name des externen Docker Volumes, welches Traefiks `acme.json' Datei enthält
    name: traefik_acme
```

Starten Sie die neuen Container mit:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Da Traefik 2 ein acme v2 Format verwendet, um ALLE Zertifikaten von allen Domains zu speichern, müssen wir einen Weg finden, die Zertifikate auszulagern. Zum Glück haben wir [diesen kleinen Container] (https://hub.docker.com/r/humenius/traefik-certs-dumper), der die Datei `acme.json` über ein Volume und eine Variable `DOMAIN=example. org`, und damit wird der Container die `cert.pem` und `key.pem` Dateien ausgeben, dafür lassen wir einfach den `traefik-certs-dumper` Container laufen, binden das `/traefik` Volume an den Ordner, in dem unsere `acme.json` gespeichert ist, binden das `/output` Volume an unseren mailcow `data/assets/ssl/` Ordner, und setzen die `DOMAIN=example.org` Variable auf die Domain, von der wir die Zertifikate ausgeben wollen. 

Dieser Container überwacht die Datei `acme.json` auf Änderungen und generiert die Dateien `cert.pem` und `key.pem` direkt in `data/assets/ssl/`, wobei der Pfad mit dem `/output`-Pfad des Containers verbunden ist.

Sie können es über die Kommandozeile ausführen oder das [hier](https://hub.docker.com/r/humenius/traefik-certs-dumper) gezeigte docker-compose.yml verwenden.

Nachdem wir die Zertifikate übertragen haben, müssen wir die Konfigurationen aus unseren Postfix- und Dovecot-Containern neu laden und die Zertifikate überprüfen. Wie das geht, sehen Sie [hier](https://mailcow.github.io/mailcow-dockerized-docs/de/post_installation/firststeps-ssl/#ein-eigenes-zertifikat-verwenden).

Und das sollte es gewesen sein 😊, Sie können überprüfen, ob der Traefik-Router einwandfrei funktioniert, indem Sie das Dashboard von Traefik / traefik logs / über https auf die eingestellte Domain zugreifen, oder / und HTTPS, SMTP und IMAP mit den Befehlen auf der zuvor verlinkten Seite überprüfen.

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

### Optional: Post-Hook-Skript für nicht-mailcow ACME-Clients

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

### Hinzufügen weiterer Servernamen für mailcow UI

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
