## SSL

Bitte lesen Sie [Erweitertes SSL](../../post_installation/firststeps-ssl.md) und überprüfen Sie explizit `ADDITIONAL_SERVER_NAMES` für die SSL-Konfiguration.

Bitte fügen Sie ADDITIONAL_SERVER_NAMES nicht hinzu, wenn Sie planen, einen anderen Web-Root zu verwenden.

## Neue Website

Um persistente (über Updates) Sites zu erstellen, die von mailcow: dockerized gehostet werden, muss eine neue Site-Konfiguration in `data/conf/nginx/` platziert werden:

Eine gute Vorlage, um damit zu beginnen:

```
nano data/conf/nginx/my_custom_site.conf
```

``` hl_lines="16"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
  ssl_ecdh_curve X25519:X448:secp384r1:secp256k1;
  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;
  index index.php index.html;
  client_max_body_size 0;
  # Location: data/web
  root /web;
  # Location: data/web/mysite.com
  #root /web/mysite.com
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name mysite.example.org;
  server_tokens off;

  # This allows acme to be validated even with a different web root
  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    rewrite /.well-known/acme-challenge/(.*) /$1 break;
    root /web/.well-known/acme-challenge/;
  }

  if ($scheme = http) {
    return 301 https://$server_name$request_uri;
  }
}
```

## Neue Website mit Proxy zu einem entfernten Location
Ein weiteres Beispiel mit einer Reverse-Proxy-Konfiguration:

```
nano data/conf/nginx/my_custom_site.conf
```

``` hl_lines="16 28"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
  ssl_ecdh_curve X25519:X448:secp384r1:secp256k1;
  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;
  index index.php index.html;
  client_max_body_size 0;
  root /web;
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name example.domain.tld;
  server_tokens off;

  location ^~ /.well-known/acme-challenge/ {
    allow all;
    default_type "text/plain";
  }

  if ($scheme = http) {
    return 301 https://$host$request_uri;
  }

  location / {
    proxy_pass http://service:3000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 0;
  }
}
```

## Konfig-Erweiterung in mailcows Nginx

Der Dateiname, der für eine neue Site verwendet wird, ist nicht wichtig, solange der Dateiname eine .conf-Erweiterung trägt.

Es ist auch möglich, die Konfiguration der Standarddatei `site.conf` Datei zu erweitern:

```
nano data/conf/nginx/site.my_content.custom
```

Dieser Dateiname muss keine ".conf"-Erweiterung haben, sondern folgt dem Muster `site.*.custom`, wobei `*` ein eigener Name ist.

Wenn PHP in eine benutzerdefinierte Site eingebunden werden soll, verwenden Sie bitte den PHP-FPM-Listener auf phpfpm:9002 oder erstellen Sie einen neuen Listener in `data/conf/phpfpm/php-fpm.d/pools.conf`.

Starten Sie Nginx neu (und PHP-FPM, falls ein neuer Listener erstellt wurde):
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart nginx-mailcow
    docker compose restart php-fpm-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart nginx-mailcow
    docker-compose restart php-fpm-mailcow
    ```
